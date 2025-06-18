package com.entregas.autenticacao.controller;

import com.entregas.autenticacao.dto.AuthResponse;
import com.entregas.autenticacao.dto.ErrorResponse;
import com.entregas.autenticacao.dto.LoginRequest;
import com.entregas.autenticacao.dto.RegisterRequest;
import com.entregas.autenticacao.dto.ValidationErrorResponse;
import com.entregas.autenticacao.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
@Tag(name = "Autenticação", description = "APIs de gerenciamento de autenticação")
public class AuthController {

    @Autowired
    private AuthService authService;

    @Operation(summary = "Registrar novo usuário", description = "Cria uma nova conta de usuário com as informações fornecidas")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Usuário registrado com sucesso",
                content = @Content(schema = @Schema(implementation = AuthResponse.class))),
        @ApiResponse(responseCode = "400", description = "Entrada inválida ou usuário já existe",
                content = @Content(schema = @Schema(oneOf = {ErrorResponse.class, ValidationErrorResponse.class})))
    })
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Login do usuário", description = "Autentica as credenciais do usuário e retorna tokens JWT")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Login realizado com sucesso",
                content = @Content(schema = @Schema(implementation = AuthResponse.class))),
        @ApiResponse(responseCode = "400", description = "Credenciais inválidas",
                content = @Content(schema = @Schema(oneOf = {ErrorResponse.class, ValidationErrorResponse.class})))
    })
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Renovar token JWT", description = "Gera novos tokens de acesso e refresh usando um token de refresh válido")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Token renovado com sucesso",
                content = @Content(schema = @Schema(implementation = AuthResponse.class))),
        @ApiResponse(responseCode = "400", description = "Token de refresh inválido",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refreshToken(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        AuthResponse response = authService.refreshToken(token);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Validar token JWT", description = "Valida um token JWT e retorna informações do usuário se válido")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Validação do token concluída"),
        @ApiResponse(responseCode = "400", description = "Token inválido",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/validate")
    public ResponseEntity<Map<String, Object>> validateToken(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        boolean isValid = authService.validateToken(token);
        
        Map<String, Object> response = new HashMap<>();
        response.put("valid", isValid);
        
        if (isValid) {
            response.put("userId", authService.getUserIdFromToken(token));
            response.put("userType", authService.getUserTypeFromToken(token));
        }
        
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Verificação de saúde", description = "Retorna o status de saúde do serviço de autenticação")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Serviço está saudável")
    })
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "Authentication Service");
        return ResponseEntity.ok(response);
    }
} 