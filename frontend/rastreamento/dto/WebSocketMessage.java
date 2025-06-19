package com.entregas.rastreamento.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Mensagem WebSocket para rastreamento")
public class WebSocketMessage {

    @Schema(description = "Tipo da mensagem", example = "LOCATION_UPDATE")
    private String type;

    @Schema(description = "ID do motorista", example = "123")
    private Long driverId;

    @Schema(description = "ID do pedido", example = "456")
    private Long pedidoId;

    @Schema(description = "Dados da localização")
    private LocalizacaoResponse localizacao;

    @Schema(description = "Mensagem de texto", example = "Motorista chegou ao destino")
    private String message;

    public WebSocketMessage() {}

    public WebSocketMessage(String type, Long driverId, Long pedidoId, LocalizacaoResponse localizacao, String message) {
        this.type = type;
        this.driverId = driverId;
        this.pedidoId = pedidoId;
        this.localizacao = localizacao;
        this.message = message;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Long getDriverId() {
        return driverId;
    }

    public void setDriverId(Long driverId) {
        this.driverId = driverId;
    }

    public Long getPedidoId() {
        return pedidoId;
    }

    public void setPedidoId(Long pedidoId) {
        this.pedidoId = pedidoId;
    }

    public LocalizacaoResponse getLocalizacao() {
        return localizacao;
    }

    public void setLocalizacao(LocalizacaoResponse localizacao) {
        this.localizacao = localizacao;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
} 