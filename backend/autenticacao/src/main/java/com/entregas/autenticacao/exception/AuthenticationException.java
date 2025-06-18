package com.entregas.autenticacao.exception;

public class AuthenticationException extends RuntimeException {
    
    public AuthenticationException(String message) {
        super(message);
    }
    
    public static AuthenticationException userAlreadyExists() {
        return new AuthenticationException("Usuário já existente");
    }
    
    public static AuthenticationException invalidCredentials() {
        return new AuthenticationException("Email ou senha inválidos");
    }
    
    public static AuthenticationException userDeactivated() {
        return new AuthenticationException("Conta de usuário desativada");
    }
    
    public static AuthenticationException invalidRefreshToken() {
        return new AuthenticationException("Token de refresh inválido");
    }
    
    public static AuthenticationException userNotFound() {
        return new AuthenticationException("Usuário não encontrado");
    }
    
    public static AuthenticationException invalidToken() {
        return new AuthenticationException("Token inválido");
    }
} 