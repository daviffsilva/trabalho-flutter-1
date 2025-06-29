package com.entregas.pedidos.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Objeto de requisição para criação de pedido")
public class CreatePedidoRequest {

    @Schema(description = "Endereço de origem", example = "Rua das Flores, 123 - São Paulo, SP", required = true)
    @NotBlank(message = "Endereço de origem é obrigatório")
    private String originAddress;

    @Schema(description = "Endereço de destino", example = "Av. Paulista, 1000 - São Paulo, SP", required = true)
    @NotBlank(message = "Endereço de destino é obrigatório")
    private String destinationAddress;

    @Schema(description = "Latitude da origem", example = "-23.5505", required = true)
    @NotNull(message = "Latitude da origem é obrigatória")
    private Double originLatitude;

    @Schema(description = "Longitude da origem", example = "-46.6333", required = true)
    @NotNull(message = "Longitude da origem é obrigatória")
    private Double originLongitude;

    @Schema(description = "Latitude do destino", example = "-23.5631", required = true)
    @NotNull(message = "Latitude do destino é obrigatória")
    private Double destinationLatitude;

    @Schema(description = "Longitude do destino", example = "-46.6544", required = true)
    @NotNull(message = "Longitude do destino é obrigatória")
    private Double destinationLongitude;

    @Schema(description = "ID do cliente", example = "1", required = true)
    @NotNull(message = "ID do cliente é obrigatório")
    private Long clienteId;

    @Schema(description = "Nome do cliente", example = "João Silva", required = true)
    @NotBlank(message = "Nome do cliente é obrigatório")
    private String clienteNome;

    @Schema(description = "Email do cliente", example = "joao@exemplo.com", required = true)
    @NotBlank(message = "Email do cliente é obrigatório")
    @Email(message = "Email deve ter um formato válido")
    private String clienteEmail;

    @Schema(description = "Telefone do cliente", example = "(11) 99999-9999")
    private String clienteTelefone;

    @Schema(description = "Tipo de carga", example = "Eletrônicos", required = true)
    @NotBlank(message = "Tipo de carga é obrigatório")
    private String cargoType;

    @Schema(description = "Peso da carga em kg", example = "5.5")
    private Double cargoWeight;

    @Schema(description = "Dimensões da carga", example = "30x20x15 cm")
    private String cargoDimensions;

    @Schema(description = "Instruções especiais", example = "Fragil, manuseio com cuidado")
    private String specialInstructions;

    public CreatePedidoRequest() {}

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
} 