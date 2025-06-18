package com.entregas.autenticacao.dto;

import com.entregas.autenticacao.model.UserType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

@Schema(description = "Objeto de requisição para registro de usuário")
public class RegisterRequest {
    
    @Schema(description = "Endereço de email do usuário", example = "usuario@exemplo.com", required = true)
    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;
    
    @Schema(description = "Senha do usuário (mínimo 6 caracteres)", example = "senha123", required = true, minLength = 6)
    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters long")
    private String password;
    
    @Schema(description = "Nome completo do usuário", example = "João Silva", required = true)
    @NotBlank(message = "Name is required")
    private String name;
    
    @Schema(description = "Tipo de usuário", example = "CLIENT", required = true, allowableValues = {"CLIENT", "DRIVER"})
    @NotNull(message = "User type is required")
    private UserType userType;
    
    public RegisterRequest() {}
    
    public RegisterRequest(String email, String password, String name, UserType userType) {
        this.email = email;
        this.password = password;
        this.name = name;
        this.userType = userType;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public UserType getUserType() {
        return userType;
    }
    
    public void setUserType(UserType userType) {
        this.userType = userType;
    }
} 