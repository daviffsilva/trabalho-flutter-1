package com.entregas.notificacao.service;

import com.entregas.notificacao.dto.BulkNotificationRequest;
import com.entregas.notificacao.dto.NotificationRequest;
import com.entregas.notificacao.dto.NotificationResponse;
import com.entregas.notificacao.model.NotificationLog;
import com.entregas.notificacao.repository.NotificationLogRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.SendMessageRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageResponse;
import software.amazon.awssdk.services.sqs.model.SqsException;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class NotificationService {

    @Autowired
    private SqsClient sqsClient;

    @Autowired
    private NotificationLogRepository notificationLogRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private AuthValidationService authValidationService;

    @Value("${aws.sqs.queue-url}")
    private String queueUrl;

    public NotificationResponse sendNotification(NotificationRequest request) {
        NotificationLog log = new NotificationLog(
                request.getUserId(),
                request.getTitle(),
                request.getMessage(),
                request.getType(),
                request.getPriority()
        );

        try {
            Map<String, Object> messageBody = createMessageBody(request);
            String messageJson = objectMapper.writeValueAsString(messageBody);

            SendMessageRequest sendMessageRequest = SendMessageRequest.builder()
                    .queueUrl(queueUrl)
                    .messageBody(messageJson)
                    .build();

            SendMessageResponse response = sqsClient.sendMessage(sendMessageRequest);

            log.setStatus("SENT");
            log.setSqsMessageId(response.messageId());
            notificationLogRepository.save(log);

            NotificationResponse notificationResponse = new NotificationResponse(
                    log.getId(),
                    "SENT",
                    "Notificação enviada com sucesso"
            );
            notificationResponse.setMessageId(response.messageId());
            return notificationResponse;

        } catch (JsonProcessingException e) {
            log.setStatus("FAILED");
            log.setErrorMessage("Erro ao serializar mensagem: " + e.getMessage());
            notificationLogRepository.save(log);
            throw new RuntimeException("Erro ao processar dados da notificação", e);

        } catch (SqsException e) {
            log.setStatus("FAILED");
            log.setErrorMessage("Erro ao enviar para SQS: " + e.getMessage());
            notificationLogRepository.save(log);
            throw new RuntimeException("Erro ao enviar notificação para fila", e);
        }
    }

    public List<NotificationResponse> sendBulkNotifications(BulkNotificationRequest request) {
        List<NotificationResponse> responses = new ArrayList<>();

        for (Long userId : request.getUserIds()) {
            NotificationRequest individualRequest = new NotificationRequest(
                    userId,
                    request.getTitle(),
                    request.getMessage(),
                    request.getType()
            );
            individualRequest.setPriority(request.getPriority());
            individualRequest.setData(request.getData());
            individualRequest.setTargetAudience(request.getTargetAudience());

            try {
                NotificationResponse response = sendNotification(individualRequest);
                responses.add(response);
            } catch (Exception e) {
                NotificationResponse errorResponse = new NotificationResponse(
                        null,
                        "FAILED",
                        "Erro ao enviar notificação para usuário " + userId + ": " + e.getMessage()
                );
                responses.add(errorResponse);
            }
        }

        return responses;
    }

    public List<NotificationLog> getNotificationHistory(Long userId) {
        return notificationLogRepository.findByUserIdOrderBySentAtDesc(userId);
    }

    public List<NotificationLog> getNotificationsByStatus(String status) {
        return notificationLogRepository.findByStatusOrderBySentAtDesc(status);
    }

    public List<NotificationLog> getNotificationsByType(String type) {
        return notificationLogRepository.findByTypeOrderBySentAtDesc(type);
    }

    public Map<String, Object> getNotificationStats() {
        LocalDateTime oneDayAgo = LocalDateTime.now().minusDays(1);
        LocalDateTime oneWeekAgo = LocalDateTime.now().minusDays(7);

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalNotifications", notificationLogRepository.count());
        stats.put("successfulLast24h", notificationLogRepository.countSuccessfulNotificationsSince(oneDayAgo));
        stats.put("successfulLastWeek", notificationLogRepository.countSuccessfulNotificationsSince(oneWeekAgo));
        stats.put("timestamp", LocalDateTime.now());

        return stats;
    }

    private Map<String, Object> createMessageBody(NotificationRequest request) {
        Map<String, Object> messageBody = new HashMap<>();
        messageBody.put("userId", request.getUserId());
        messageBody.put("title", request.getTitle());
        messageBody.put("message", request.getMessage());
        messageBody.put("type", request.getType());
        messageBody.put("priority", request.getPriority());
        messageBody.put("timestamp", LocalDateTime.now().toString());
        messageBody.put("topic", determineTopic(request.getTargetAudience(), request.getUserId()));

        if (request.getData() != null) {
            messageBody.put("data", request.getData());
        }

        return messageBody;
    }

    private String determineTopic(String targetAudience, Long userId) {
        if (targetAudience == null) {
            targetAudience = "USER";
        }
        
        switch (targetAudience.toUpperCase()) {
            case "ALL_USERS":
                return "all_users";
            case "CLIENTES":
                return "clientes";
            case "MOTORISTAS":
                return "motoristas";
            case "USER":
            default:
                return "user_" + userId;
        }
    }

    public boolean isAuthServiceHealthy() {
        return authValidationService.isAuthServiceHealthy();
    }
} 