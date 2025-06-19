package com.entregas.pedidos.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Objeto de requisição para motorista reivindicar pedido")
public class ClaimPedidoRequest {

    @Schema(description = "ID do motorista", example = "1", required = true)
    @NotNull(message = "ID do motorista é obrigatório")
    private Long motoristaId;

    public ClaimPedidoRequest() {
    }

    public ClaimPedidoRequest(Long motoristaId) {
        this.motoristaId = motoristaId;
    }

    public Long getMotoristaId() {
        return motoristaId;
    }

    public void setMotoristaId(Long motoristaId) {
        this.motoristaId = motoristaId;
    }
} 