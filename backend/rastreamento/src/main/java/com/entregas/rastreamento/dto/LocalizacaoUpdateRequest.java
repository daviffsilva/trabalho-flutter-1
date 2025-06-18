package com.entregas.rastreamento.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

@Schema(description = "Objeto de requisição para atualização de localização")
public class LocalizacaoUpdateRequest {

    @Schema(description = "ID do motorista", example = "123", required = true)
    @NotNull(message = "ID do motorista é obrigatório")
    private Long driverId;

    @Schema(description = "Latitude", example = "-23.5505", required = true)
    @NotNull(message = "Latitude é obrigatória")
    private Double latitude;

    @Schema(description = "Longitude", example = "-46.6333", required = true)
    @NotNull(message = "Longitude é obrigatória")
    private Double longitude;

    @Schema(description = "Altitude em metros", example = "760.0")
    private Double altitude;

    @Schema(description = "Velocidade em km/h", example = "45.0")
    private Double speed;

    @Schema(description = "Direção em graus", example = "180.0")
    private Double heading;

    @Schema(description = "Precisão em metros", example = "5.0")
    private Double accuracy;

    @Schema(description = "ID do pedido", example = "456", required = true)
    @NotNull(message = "ID do pedido é obrigatório")
    private Long pedidoId;

    @Schema(description = "Timestamp da atualização", example = "2024-04-15T12:00:00")
    private LocalDateTime timestamp;

    public LocalizacaoUpdateRequest() {}

    public LocalizacaoUpdateRequest(Long driverId, Double latitude, Double longitude) {
        this.driverId = driverId;
        this.latitude = latitude;
        this.longitude = longitude;
        this.timestamp = LocalDateTime.now();
    }

    public Long getDriverId() {
        return driverId;
    }

    public void setDriverId(Long driverId) {
        this.driverId = driverId;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public Double getAltitude() {
        return altitude;
    }

    public void setAltitude(Double altitude) {
        this.altitude = altitude;
    }

    public Double getSpeed() {
        return speed;
    }

    public void setSpeed(Double speed) {
        this.speed = speed;
    }

    public Double getHeading() {
        return heading;
    }

    public void setHeading(Double heading) {
        this.heading = heading;
    }

    public Double getAccuracy() {
        return accuracy;
    }

    public void setAccuracy(Double accuracy) {
        this.accuracy = accuracy;
    }

    public Long getPedidoId() {
        return pedidoId;
    }

    public void setPedidoId(Long pedidoId) {
        this.pedidoId = pedidoId;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
} 