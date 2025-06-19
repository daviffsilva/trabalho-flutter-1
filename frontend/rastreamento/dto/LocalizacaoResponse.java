package com.entregas.rastreamento.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(description = "Objeto de resposta para localização")
public class LocalizacaoResponse {

    @Schema(description = "ID da localização", example = "1")
    private Long id;

    @Schema(description = "ID do motorista", example = "123")
    private Long driverId;

    @Schema(description = "Latitude", example = "-23.5505")
    private Double latitude;

    @Schema(description = "Longitude", example = "-46.6333")
    private Double longitude;

    @Schema(description = "Altitude em metros", example = "760.0")
    private Double altitude;

    @Schema(description = "Velocidade em m/s", example = "15.5")
    private Double speed;

    @Schema(description = "Direção em graus", example = "45.0")
    private Double heading;

    @Schema(description = "Precisão do GPS em metros", example = "5.0")
    private Double accuracy;

    @Schema(description = "Timestamp da localização", example = "2024-04-15T12:00:00")
    private LocalDateTime timestamp;

    @Schema(description = "ID do pedido", example = "1001")
    private Long pedidoId;

    @Schema(description = "Se a localização está ativa", example = "true")
    private Boolean isActive;

    @Schema(description = "Data de criação", example = "2024-04-15T12:00:00")
    private LocalDateTime createdAt;

    @Schema(description = "Data de atualização", example = "2024-04-15T12:00:00")
    private LocalDateTime updatedAt;

    public LocalizacaoResponse() {}

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public Long getPedidoId() {
        return pedidoId;
    }

    public void setPedidoId(Long pedidoId) {
        this.pedidoId = pedidoId;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
} 