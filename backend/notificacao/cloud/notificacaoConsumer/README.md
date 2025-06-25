# SQS Consumer with Firebase Cloud Messaging

This AWS Lambda function consumes messages from an Amazon SQS queue and sends notifications via Firebase Cloud Messaging (FCM).

## Architecture

The function:
1. Receives SQS events automatically through Lambda's native SQS integration
2. Processes batches of SQS messages (up to 10 at a time)
3. Parses message content as JSON
4. Sends Firebase Cloud Messaging notifications based on message content
5. Automatically handles message acknowledgment and retry logic through SQS

## Prerequisites

1. **AWS Account**: With permissions to create SQS queues and Lambda functions
2. **Firebase Project**: With Cloud Messaging enabled
3. **Firebase Service Account**: With appropriate permissions

## Configuration

### Environment Variables

The function requires these environment variables to be configured in the SAM template:

- `FIREBASE_PROJECT_ID`: Your Firebase project ID
- `FIREBASE_PRIVATE_KEY`: Base64-encoded private key from Firebase service account
- `FIREBASE_CLIENT_EMAIL`: Service account email from Firebase

### Firebase Setup

1. Create a Firebase project at https://console.firebase.google.com
2. Go to Project Settings > Service Accounts
3. Generate a new private key (JSON file)
4. Extract the required values:
   - `project_id`
   - `private_key` (encode to base64: `echo "your-private-key" | base64`)
   - `client_email`

## Message Format

The function expects SQS messages with JSON body in this structure:

```json
{
  "title": "Notification Title",
  "body": "Notification message body",
  "data": {
    "customKey": "customValue"
  },
  "token": "device_token_here" 
}
```

OR for topic-based notifications:

```json
{
  "title": "Notification Title", 
  "body": "Notification message body",
  "data": {
    "customKey": "customValue"
  },
  "topic": "topic_name"  
}
```

See examples in `events/` directory.

## SQS Integration

The SAM template creates:
- **Main Queue**: `{StackName}-notifications` - for processing notification messages
- **Dead Letter Queue**: `{StackName}-notifications-dlq` - for messages that fail after 3 attempts
- **Lambda Trigger**: Automatically invokes the function when messages arrive

### SQS Configuration
- **Batch Size**: Up to 10 messages per Lambda invocation
- **Batching Window**: 5 seconds maximum wait time to collect messages
- **Visibility Timeout**: 35 seconds (greater than Lambda timeout)
- **Message Retention**: 14 days
- **Max Receive Count**: 3 attempts before moving to DLQ

## Deployment

1. Install dependencies:
   ```bash
   cd hello_world
   npm install
   ```

2. Build and deploy with SAM:
   ```bash
   sam build
   sam deploy --guided
   ```

3. Provide the required parameters during deployment:
   - Firebase configuration values

## Testing

### Local Testing

```bash
sam local invoke NotificationConsumerFunction --event events/event.json
```

### Send Messages to SQS

After deployment, send test messages to the SQS queue:

**Using AWS CLI:**
```bash
aws sqs send-message \
  --queue-url https://sqs.region.amazonaws.com/account/queue-name \
  --message-body '{"title": "Test", "body": "Hello World", "topic": "general"}'
```

**Using AWS Console:**
1. Go to SQS in AWS Console
2. Select your notification queue
3. Click "Send and receive messages"
4. Paste JSON message in the message body

### Manual Lambda Invocation

```bash
aws lambda invoke \
  --function-name your-function-name \
  --payload file://events/event.json \
  response.json
```

## Function Behavior

- **Batch Processing**: Processes up to 10 SQS messages per invocation
- **Automatic Scaling**: Lambda scales based on SQS queue depth
- **Error Handling**: Failed messages are automatically retried by SQS
- **Dead Letter Queue**: Messages that fail 3 times are moved to DLQ
- **Concurrency**: Multiple Lambda instances can process messages in parallel

## Monitoring

Monitor the function through:
- **AWS CloudWatch Logs**: Detailed execution logs for each message
- **AWS CloudWatch Metrics**: Lambda and SQS performance metrics
- **SQS Queue Metrics**: Queue depth, message age, and processing rates
- **Dead Letter Queue**: Monitor for failed messages requiring investigation

## Dependencies

- `firebase-admin`: Firebase Admin SDK for sending notifications
- `axios`: HTTP client (inherited from template)

## Error Handling

- **Parse Errors**: Invalid JSON messages are logged and moved to DLQ
- **Firebase Errors**: Network or authentication issues cause message retry
- **Validation Errors**: Messages without title/body are rejected
- **Partial Failures**: If some messages in a batch fail, only those messages are retried

## Sending Messages to SQS

### From Another Lambda Function
```javascript
import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs";

const sqs = new SQSClient({ region: "us-east-1" });

const notification = {
  title: "New Message",
  body: "You have a new notification",
  data: { userId: "123" },
  topic: "general"
};

await sqs.send(new SendMessageCommand({
  QueueUrl: process.env.QUEUE_URL,
  MessageBody: JSON.stringify(notification)
}));
```

### From Other AWS Services
- **API Gateway**: Direct SQS integration for REST APIs
- **EventBridge**: Route events to SQS based on patterns
- **S3 Events**: Trigger notifications on file uploads
- **DynamoDB Streams**: Send notifications on data changes

## Notes

- The function automatically scales based on SQS message volume
- SQS handles message deduplication and ordering (if using FIFO queues)
- Firebase private keys are sensitive - use AWS Secrets Manager for production
- Consider using SQS FIFO queues if message ordering is important
- Monitor DLQ regularly for failed messages requiring attention
