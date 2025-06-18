package com.entregas.pedidos.model;

public enum OrderStatus {
    PENDING("Pendente"),
    ACCEPTED("Aceito"),
    IN_TRANSIT("Em trânsito"),
    OUT_FOR_DELIVERY("Saiu para entrega"),
    DELIVERED("Entregue"),
    CANCELLED("Cancelado"),
    FAILED("Falhou");

    private final String description;

    OrderStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
} 