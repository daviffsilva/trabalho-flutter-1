package com.entregas.pedidos.dto;

import java.time.LocalDateTime;

import com.entregas.pedidos.model.PedidoStatus;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Objeto de resposta de pedido")
public class PedidoResponse {

    @Schema(description = "ID do pedido", example = "1")
    private Long id;

    @Schema(description = "Endereço de origem", example = "Rua das Flores, 123 - São Paulo, SP")
    private String originAddress;

    @Schema(description = "Endereço de destino", example = "Av. Paulista, 1000 - São Paulo, SP")
    private String destinationAddress;

    @Schema(description = "Latitude da origem", example = "-23.5505")
    private Double originLatitude;

    @Schema(description = "Longitude da origem", example = "-46.6333")
    private Double originLongitude;

    @Schema(description = "Latitude do destino", example = "-23.5631")
    private Double destinationLatitude;

    @Schema(description = "Longitude do destino", example = "-46.6544")
    private Double destinationLongitude;

    @Schema(description = "ID do cliente", example = "1")
    private Long clienteId;

    @Schema(description = "Nome do cliente", example = "João Silva")
    private String clienteNome;

    @Schema(description = "Email do cliente", example = "joao@exemplo.com")
    private String clienteEmail;

    @Schema(description = "Telefone do cliente", example = "(11) 99999-9999")
    private String clienteTelefone;

    @Schema(description = "Tipo de carga", example = "Eletrônicos")
    private String cargoType;

    @Schema(description = "Peso da carga em kg", example = "5.5")
    private Double cargoWeight;

    @Schema(description = "Dimensões da carga", example = "30x20x15 cm")
    private String cargoDimensions;

    @Schema(description = "Instruções especiais", example = "Fragil, manuseio com cuidado")
    private String specialInstructions;

    @Schema(description = "Status do pedido", example = "PENDING")
    private PedidoStatus status;

    @Schema(description = "ID do motorista", example = "123")
    private Long motoristaId;

    @Schema(description = "Distância estimada em km", example = "15.5")
    private Double estimatedDistance;

    @Schema(description = "Duração estimada em minutos", example = "45")
    private Integer estimatedDuration;

    @Schema(description = "Preço total", example = "75.50")
    private Double totalPrice;

    @Schema(description = "Data de criação")
    private LocalDateTime createdAt;

    @Schema(description = "Data de atualização")
    private LocalDateTime updatedAt;

    @Schema(description = "Data de entrega")
    private LocalDateTime deliveredAt;

    @Schema(description = "URL da foto da entrega")
    private String deliveryPhotoUrl;

    @Schema(description = "Assinatura da entrega")
    private String deliverySignature;

    public PedidoResponse() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getOriginAddress() {
        return originAddress;
    }

    public void setOriginAddress(String originAddress) {
        this.originAddress = originAddress;
    }

    public String getDestinationAddress() {
        return destinationAddress;
    }

    public void setDestinationAddress(String destinationAddress) {
        this.destinationAddress = destinationAddress;
    }

    public Double getOriginLatitude() {
        return originLatitude;
    }

    public void setOriginLatitude(Double originLatitude) {
        this.originLatitude = originLatitude;
    }

    public Double getOriginLongitude() {
        return originLongitude;
    }

    public void setOriginLongitude(Double originLongitude) {
        this.originLongitude = originLongitude;
    }

    public Double getDestinationLatitude() {
        return destinationLatitude;
    }

    public void setDestinationLatitude(Double destinationLatitude) {
        this.destinationLatitude = destinationLatitude;
    }

    public Double getDestinationLongitude() {
        return destinationLongitude;
    }

    public void setDestinationLongitude(Double destinationLongitude) {
        this.destinationLongitude = destinationLongitude;
    }

    public Long getClienteId() {
        return clienteId;
    }

    public void setClienteId(Long clienteId) {
        this.clienteId = clienteId;
    }

    public String getClienteNome() {
        return clienteNome;
    }

    public void setClienteNome(String clienteNome) {
        this.clienteNome = clienteNome;
    }

    public String getClienteEmail() {
        return clienteEmail;
    }

    public void setClienteEmail(String clienteEmail) {
        this.clienteEmail = clienteEmail;
    }

    public String getClienteTelefone() {
        return clienteTelefone;
    }

    public void setClienteTelefone(String clienteTelefone) {
        this.clienteTelefone = clienteTelefone;
    }

    public String getCargoType() {
        return cargoType;
    }

    public void setCargoType(String cargoType) {
        this.cargoType = cargoType;
    }

    public Double getCargoWeight() {
        return cargoWeight;
    }

    public void setCargoWeight(Double cargoWeight) {
        this.cargoWeight = cargoWeight;
    }

    public String getCargoDimensions() {
        return cargoDimensions;
    }

    public void setCargoDimensions(String cargoDimensions) {
        this.cargoDimensions = cargoDimensions;
    }

    public String getSpecialInstructions() {
        return specialInstructions;
    }

    public void setSpecialInstructions(String specialInstructions) {
        this.specialInstructions = specialInstructions;
    }

    public PedidoStatus getStatus() {
        return status;
    }

    public void setStatus(PedidoStatus status) {
        this.status = status;
    }

    public Long getMotoristaId() {
        return motoristaId;
    }

    public void setMotoristaId(Long motoristaId) {
        this.motoristaId = motoristaId;
    }

    public Double getEstimatedDistance() {
        return estimatedDistance;
    }

    public void setEstimatedDistance(Double estimatedDistance) {
        this.estimatedDistance = estimatedDistance;
    }

    public Integer getEstimatedDuration() {
        return estimatedDuration;
    }

    public void setEstimatedDuration(Integer estimatedDuration) {
        this.estimatedDuration = estimatedDuration;
    }

    public Double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(Double totalPrice) {
        this.totalPrice = totalPrice;
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

    public LocalDateTime getDeliveredAt() {
        return deliveredAt;
    }

    public void setDeliveredAt(LocalDateTime deliveredAt) {
        this.deliveredAt = deliveredAt;
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
