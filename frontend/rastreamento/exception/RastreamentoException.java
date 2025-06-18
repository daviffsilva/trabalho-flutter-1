package com.entregas.rastreamento.exception;

public class RastreamentoException extends RuntimeException {
    
    public RastreamentoException(String message) {
        super(message);
    }
    
    public static RastreamentoException localizacaoNaoEncontrada() {
        return new RastreamentoException("Localização não encontrada");
    }
    
    public static RastreamentoException coordenadasInvalidas() {
        return new RastreamentoException("Coordenadas inválidas");
    }
    
    public static RastreamentoException motoristaNaoEncontrado() {
        return new RastreamentoException("Motorista não encontrado");
    }
    
    public static RastreamentoException pedidoNaoEncontrado() {
        return new RastreamentoException("Pedido não encontrado");
    }
    
    public static RastreamentoException rastreamentoNaoAtivo() {
        return new RastreamentoException("Rastreamento não está ativo");
    }
} 