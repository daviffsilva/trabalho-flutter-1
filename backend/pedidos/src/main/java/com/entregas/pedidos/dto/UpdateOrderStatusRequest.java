package com.entregas.pedidos.dto;

import com.entregas.pedidos.model.OrderStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Objeto de requisição para atualização de status do pedido")
public class UpdateOrderStatusRequest {

    @Schema(description = "Novo status do pedido", example = "IN_TRANSIT", required = true)
    @NotNull(message = "Status é obrigatório")
    private OrderStatus status;

    @Schema(description = "ID do motorista (opcional)")
    private Long driverId;

    @Schema(description = "URL da foto da entrega (opcional)")
    private String deliveryPhotoUrl;

    @Schema(description = "Assinatura da entrega (opcional)")
    private String deliverySignature;

    public UpdateOrderStatusRequest() {}

    public OrderStatus getStatus() {
        return status;
    }

    public void setStatus(OrderStatus status) {
        this.status = status;
    }

    public Long getDriverId() {
        return driverId;
    }

    public void setDriverId(Long driverId) {
        this.driverId = driverId;
    }

    public String getDeliveryPhotoUrl() {
        return deliveryPhotoUrl;
    }

    public void setDeliveryPhotoUrl(String deliveryPhotoUrl) {
        this.deliveryPhotoUrl = deliveryPhotoUrl;
    }

    public String getDeliverySignature() {
        return deliverySignature;
    }

    public void setDeliverySignature(String deliverySignature) {
        this.deliverySignature = deliverySignature;
    }
} 