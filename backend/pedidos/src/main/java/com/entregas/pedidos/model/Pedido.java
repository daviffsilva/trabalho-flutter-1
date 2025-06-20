package com.entregas.pedidos.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

@Entity
@Table(name = "pedidos")
public class Pedido {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Column(name = "cliente_id")
    private Long clienteId;

    @NotBlank
    @Column(name = "origin_address")
    private String originAddress;

    @NotBlank
    @Column(name = "destination_address")
    private String destinationAddress;

    @NotNull
    @Column(name = "origin_latitude")
    private Double originLatitude;

    @NotNull
    @Column(name = "origin_longitude")
    private Double originLongitude;

    @NotNull
    @Column(name = "destination_latitude")
    private Double destinationLatitude;

    @NotNull
    @Column(name = "destination_longitude")
    private Double destinationLongitude;

    @NotBlank
    @Column(name = "cliente_nome")
    private String clienteNome;

    @NotBlank
    @Column(name = "cliente_email")
    private String clienteEmail;

    @Column(name = "cliente_telefone")
    private String clienteTelefone;

    @NotBlank
    @Column(name = "cargo_type")
    private String cargoType;

    @Column(name = "cargo_weight")
    private Double cargoWeight;

    @Column(name = "cargo_dimensions")
    private String cargoDimensions;

    @Column(name = "special_instructions")
    private String specialInstructions;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private PedidoStatus status;

    @Column(name = "motorista_id")
    private Long motoristaId;

    @Column(name = "estimated_distance")
    private Double estimatedDistance;

    @Column(name = "estimated_duration")
    private Integer estimatedDuration;

    @Column(name = "total_price")
    private Double totalPrice;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "delivered_at")
    private LocalDateTime deliveredAt;

    @Column(name = "delivery_photo_url")
    private String deliveryPhotoUrl;

    @Column(name = "delivery_signature")
    private String deliverySignature;

    public Pedido() {
        this.status = PedidoStatus.PENDING;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getClienteId() {
        return clienteId;
    }

    public void setClienteId(Long clienteId) {
        this.clienteId = clienteId;
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
