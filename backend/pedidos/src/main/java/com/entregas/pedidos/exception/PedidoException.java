package com.entregas.pedidos.exception;

public class PedidoException extends RuntimeException {

    public PedidoException(String message) {
        super(message);
    }

    public static PedidoException pedidoNotFound() {
        return new PedidoException("Pedido não encontrado");
    }

    public static PedidoException cannotDeletePedido() {
        return new PedidoException("Não é possível excluir um pedido que não está pendente");
    }

    public static PedidoException invalidStatusTransition() {
        return new PedidoException("Transição de status inválida");
    }

    public static PedidoException pedidoAlreadyAssigned() {
        return new PedidoException("Pedido já foi atribuído a um motorista");
    }

    public static PedidoException pedidoAlreadyClaimed() {
        return new PedidoException("Pedido já foi reivindicado por outro motorista");
    }

    public static PedidoException pedidoNotAvailableForClaiming() {
        return new PedidoException("Pedido não está disponível para reivindicação");
    }

    public static PedidoException invalidCoordinates() {
        return new PedidoException("Coordenadas inválidas");
    }
}
