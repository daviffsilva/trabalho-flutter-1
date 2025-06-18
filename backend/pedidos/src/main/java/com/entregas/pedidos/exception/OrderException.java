package com.entregas.pedidos.exception;

public class OrderException extends RuntimeException {
    
    public OrderException(String message) {
        super(message);
    }
    
    public static OrderException orderNotFound() {
        return new OrderException("Pedido não encontrado");
    }
    
    public static OrderException cannotDeleteOrder() {
        return new OrderException("Não é possível excluir um pedido que não está pendente");
    }
    
    public static OrderException invalidStatusTransition() {
        return new OrderException("Transição de status inválida");
    }
    
    public static OrderException orderAlreadyAssigned() {
        return new OrderException("Pedido já foi atribuído a um motorista");
    }
    
    public static OrderException invalidCoordinates() {
        return new OrderException("Coordenadas inválidas");
    }
} 