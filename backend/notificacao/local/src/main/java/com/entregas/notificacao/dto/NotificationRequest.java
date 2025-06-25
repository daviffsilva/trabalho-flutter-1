package com.entregas.notificacao.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.Map;

@Schema(description = "Request para envio de notificação push")
public class NotificationRequest {

    @NotNull(message = "User ID é obrigatório")
    @Schema(description = "ID do usuário que receberá a notificação", example = "123")
    private Long userId;

    @NotBlank(message = "Título é obrigatório")
    @Schema(description = "Título da notificação", example = "Pedido finalizado!")
    private String title;

    @NotBlank(message = "Mensagem é obrigatória")
    @Schema(description = "Corpo da mensagem", example = "Seu pedido foi entregue com sucesso.")
    private String message;

    @Schema(description = "Tipo da notificação", example = "PEDIDO_FINALIZADO")
    private String type;

    @Schema(description = "Dados adicionais da notificação")
    private Map<String, Object> data;

    @Schema(description = "Prioridade da notificação", example = "HIGH")
    private String priority = "NORMAL";

    @Schema(description = "Público-alvo da notificação", example = "USER", allowableValues = {"USER", "ALL_USERS", "CLIENTES", "MOTORISTAS"})
    private String targetAudience = "USER";

    public NotificationRequest() {}

    public NotificationRequest(Long userId, String title, String message, String type) {
        this.userId = userId;
        this.title = title;
        this.message = message;
        this.type = type;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Map<String, Object> getData() {
        return data;
    }

    public void setData(Map<String, Object> data) {
        this.data = data;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public String getTargetAudience() {
        return targetAudience;
    }

    public void setTargetAudience(String targetAudience) {
        this.targetAudience = targetAudience;
    }
} 