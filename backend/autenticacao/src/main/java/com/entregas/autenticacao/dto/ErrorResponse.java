package com.entregas.autenticacao.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Resposta de erro genérica")
public class ErrorResponse {

    @Schema(description = "Mensagem de erro", example = "Usuário já existente")
    private String error;

    @Schema(description = "Status da resposta", example = "error")
    private String status;

    public ErrorResponse() {}

    public ErrorResponse(String error, String status) {
        this.error = error;
        this.status = status;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
} 