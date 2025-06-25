package com.entregas.notificacao.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;
import java.util.Map;

@Schema(description = "Request para envio de notificação em massa")
public class BulkNotificationRequest {

    @NotEmpty(message = "Lista de usuários não pode estar vazia")
    @Schema(description = "Lista de IDs dos usuários que receberão a notificação")
    private List<Long> userIds;

    @NotBlank(message = "Título é obrigatório")
    @Schema(description = "Título da notificação", example = "Promoção especial!")
    private String title;

    @NotBlank(message = "Mensagem é obrigatória")
    @Schema(description = "Corpo da mensagem", example = "Aproveite nossa promoção de 20% de desconto.")
    private String message;

    @Schema(description = "Tipo da notificação", example = "PROMOCIONAL")
    private String type;

    @Schema(description = "Dados adicionais da notificação")
    private Map<String, Object> data;

    @Schema(description = "Prioridade da notificação", example = "LOW")
    private String priority = "NORMAL";

    @Schema(description = "Público-alvo da notificação", example = "CLIENTES", allowableValues = {"ALL_USERS", "CLIENTES", "MOTORISTAS"})
    private String targetAudience = "ALL_USERS";

    public BulkNotificationRequest() {}

    public BulkNotificationRequest(List<Long> userIds, String title, String message, String type) {
        this.userIds = userIds;
        this.title = title;
        this.message = message;
        this.type = type;
    }

    public List<Long> getUserIds() {
        return userIds;
    }

    public void setUserIds(List<Long> userIds) {
        this.userIds = userIds;
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