/**
 *
 * Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format
 * @param {Object} event - API Gateway Lambda Proxy Input Format
 *
 * Context doc: https://docs.aws.amazon.com/lambda/latest/dg/nodejs-prog-model-context.html 
 * @param {Object} context
 *
 * Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
 * @returns {Object} object - API Gateway Lambda Proxy Output Format
 * 
 */

import admin from 'firebase-admin';


let firebaseInitialized = false;

const initializeFirebase = () => {
    if (firebaseInitialized) return;
    
    try {
        let privateKey;
        try {
            const privateKeyObject = JSON.parse(process.env.FIREBASE_PRIVATE_KEY);
            privateKey = privateKeyObject.privateKey;
            
            if (!privateKey.includes('\n')) {
                privateKey = privateKey
                    .replace('-----BEGIN PRIVATE KEY-----', '-----BEGIN PRIVATE KEY-----\n')
                    .replace('-----END PRIVATE KEY-----', '\n-----END PRIVATE KEY-----')
                    .replace(/(.{64})/g, '$1\n')
                    .replace(/\n\n/g, '\n')
                    .replace(/\n-----END/g, '\n-----END');
            }
        } catch (decodeError) {
            console.error('Error decoding Firebase private key:', decodeError);
            throw new Error(`Failed to decode private key: ${decodeError.message}`);
        }

        const serviceAccount = {
            type: "service_account",
            project_id: process.env.FIREBASE_PROJECT_ID,
            private_key: privateKey,
            client_email: process.env.FIREBASE_CLIENT_EMAIL,
        };

        console.log('Initializing Firebase with project ID:', process.env.FIREBASE_PROJECT_ID);
        console.log('Private key starts with:', privateKey.substring(0, 50) + '...');

        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            projectId: process.env.FIREBASE_PROJECT_ID
        });
        
        firebaseInitialized = true;
        console.log('Firebase Admin SDK initialized successfully');
    } catch (error) {
        console.error('Failed to initialize Firebase:', error);
        throw new Error(`Failed to parse private key: ${error.message}`);
    }
};

const sendFirebaseNotification = async (notificationData) => {
    try {
        const message = {
            notification: {
                title: notificationData.title || 'New Notification',
                body: notificationData.body || 'You have a new notification',
            },
            data: {
                ...notificationData.data,
                timestamp: new Date().toISOString()
            },
    
            ...(notificationData.token 
                ? { token: notificationData.token }
                : { topic: notificationData.topic || 'general' }
            )
        };

        const response = await admin.messaging().send(message);
        console.log('Firebase notification sent successfully:', response);
        return response;
    } catch (error) {
        console.error('Failed to send Firebase notification:', error);
        throw error;
    }
};

const processSQSMessage = async (record) => {
    try {
        console.log('Processing SQS message:', record.messageId);
        

        const messageBody = record.body;
        let notificationData;
        
        try {
            notificationData = JSON.parse(messageBody);
        } catch (parseError) {
            console.error('Failed to parse message body as JSON:', messageBody);
            throw new Error(`Invalid JSON in message body: ${parseError.message}`);
        }
        

        if (!notificationData.title && !notificationData.body) {
            throw new Error('Message must contain title or body');
        }
        

        const result = await sendFirebaseNotification(notificationData);
        
        console.log(`Message ${record.messageId} processed successfully`);
        return {
            messageId: record.messageId,
            status: 'success',
            result: result,
            notificationData: notificationData
        };
        
    } catch (error) {
        console.error(`Failed to process message ${record.messageId}:`, error);
        throw error
    }
};

export const lambdaHandler = async (event, context) => {
    console.log('Lambda function started');
    console.log('Received SQS event with', event.Records?.length || 0, 'records');
    
    try {
        initializeFirebase();
    } catch (error) {
        console.error('Failed to initialize Firebase:', error);
        throw error
    }
    
    const results = [];
    const errors = [];
    
    for (const record of event.Records || []) {
        try {
            const result = await processSQSMessage(record);
            results.push(result);
        } catch (error) {
            const errorInfo = {
                messageId: record.messageId,
                status: 'error',
                error: error.message,
                body: record.body
            };
            errors.push(errorInfo);
            console.error('Error processing record:', errorInfo);
        }
    }
    
    console.log(`Processing completed: ${results.length} successful, ${errors.length} failed`);
    
    if (errors.length > 0) {
        console.error('Some messages failed processing:', errors);
        throw new Error(`Failed to process ${errors.length} out of ${event.Records.length} messages`);
    }
    
    const response = {
        statusCode: 200,
        body: JSON.stringify({
            message: 'SQS messages processed successfully',
            processedCount: results.length,
            results: results,
            timestamp: new Date().toISOString()
        })
    };
    
    console.log('Lambda function completed successfully');
    return response;
};
