package com.entregas.notificacao.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(description = "Response do envio de notificação")
public class NotificationResponse {

    @Schema(description = "ID da notificação", example = "123")
    private Long notificationId;

    @Schema(description = "Status do envio", example = "SENT")
    private String status;

    @Schema(description = "Mensagem de resultado", example = "Notificação enviada com sucesso")
    private String message;

    @Schema(description = "Timestamp do envio")
    private LocalDateTime sentAt;

    @Schema(description = "ID da mensagem na fila SQS")
    private String messageId;

    public NotificationResponse() {}

    public NotificationResponse(Long notificationId, String status, String message) {
        this.notificationId = notificationId;
        this.status = status;
        this.message = message;
        this.sentAt = LocalDateTime.now();
    }

    public Long getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(Long notificationId) {
        this.notificationId = notificationId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public LocalDateTime getSentAt() {
        return sentAt;
    }

    public void setSentAt(LocalDateTime sentAt) {
        this.sentAt = sentAt;
    }

    public String getMessageId() {
        return messageId;
    }

    public void setMessageId(String messageId) {
        this.messageId = messageId;
    }
} 