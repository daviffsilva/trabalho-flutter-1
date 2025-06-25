package com.entregas.notificacao.controller;

import com.entregas.notificacao.dto.BulkNotificationRequest;
import com.entregas.notificacao.dto.ErrorResponse;
import com.entregas.notificacao.dto.NotificationRequest;
import com.entregas.notificacao.dto.NotificationResponse;
import com.entregas.notificacao.model.NotificationLog;
import com.entregas.notificacao.service.NotificationService;
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
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notification")
@CrossOrigin(origins = "*")
@Tag(name = "Notificações", description = "APIs de gerenciamento de notificações push")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @Operation(summary = "Enviar notificação individual", 
               description = "Envia uma notificação push para um usuário específico via SQS")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Notificação enviada com sucesso",
                content = @Content(schema = @Schema(implementation = NotificationResponse.class))),
        @ApiResponse(responseCode = "400", description = "Dados inválidos",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/send")
    public ResponseEntity<NotificationResponse> sendNotification(@Valid @RequestBody NotificationRequest request) {
        NotificationResponse response = notificationService.sendNotification(request);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Enviar notificações em massa", 
               description = "Envia notificações push para múltiplos usuários via SQS")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Notificações processadas",
                content = @Content(schema = @Schema(implementation = NotificationResponse.class))),
        @ApiResponse(responseCode = "400", description = "Dados inválidos",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/send-bulk")
    public ResponseEntity<List<NotificationResponse>> sendBulkNotifications(@Valid @RequestBody BulkNotificationRequest request) {
        List<NotificationResponse> responses = notificationService.sendBulkNotifications(request);
        return ResponseEntity.ok(responses);
    }

    @Operation(summary = "Enviar notificação para todos os usuários", 
               description = "Envia uma notificação para todos os usuários do sistema via SQS")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Notificação enviada com sucesso",
                content = @Content(schema = @Schema(implementation = NotificationResponse.class))),
        @ApiResponse(responseCode = "400", description = "Dados inválidos",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/send-all")
    public ResponseEntity<NotificationResponse> sendNotificationToAll(@Valid @RequestBody NotificationRequest request) {
        request.setTargetAudience("ALL_USERS");
        request.setUserId(0L); // Default user ID for general notifications
        NotificationResponse response = notificationService.sendNotification(request);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Enviar notificação para clientes", 
               description = "Envia uma notificação para todos os clientes via SQS")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Notificação enviada com sucesso",
                content = @Content(schema = @Schema(implementation = NotificationResponse.class))),
        @ApiResponse(responseCode = "400", description = "Dados inválidos",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/send-clientes")
    public ResponseEntity<NotificationResponse> sendNotificationToClientes(@Valid @RequestBody NotificationRequest request) {
        request.setTargetAudience("CLIENTES");
        request.setUserId(0L); // Default user ID for role-based notifications
        NotificationResponse response = notificationService.sendNotification(request);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Enviar notificação para motoristas", 
               description = "Envia uma notificação para todos os motoristas via SQS")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Notificação enviada com sucesso",
                content = @Content(schema = @Schema(implementation = NotificationResponse.class))),
        @ApiResponse(responseCode = "400", description = "Dados inválidos",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/send-motoristas")
    public ResponseEntity<NotificationResponse> sendNotificationToMotoristas(@Valid @RequestBody NotificationRequest request) {
        request.setTargetAudience("MOTORISTAS");
        request.setUserId(0L); // Default user ID for role-based notifications
        NotificationResponse response = notificationService.sendNotification(request);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Histórico de notificações do usuário", 
               description = "Retorna o histórico de notificações enviadas para um usuário")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Histórico retornado com sucesso"),
        @ApiResponse(responseCode = "404", description = "Usuário não encontrado")
    })
    @GetMapping("/history/{userId}")
    public ResponseEntity<List<NotificationLog>> getNotificationHistory(@PathVariable Long userId) {
        List<NotificationLog> history = notificationService.getNotificationHistory(userId);
        return ResponseEntity.ok(history);
    }

    @Operation(summary = "Notificações por status", 
               description = "Retorna notificações filtradas por status (SENT, FAILED, PENDING)")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Notificações retornadas com sucesso")
    })
    @GetMapping("/status/{status}")
    public ResponseEntity<List<NotificationLog>> getNotificationsByStatus(@PathVariable String status) {
        List<NotificationLog> notifications = notificationService.getNotificationsByStatus(status);
        return ResponseEntity.ok(notifications);
    }

    @Operation(summary = "Notificações por tipo", 
               description = "Retorna notificações filtradas por tipo (PEDIDO_FINALIZADO, PROMOCIONAL, etc.)")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Notificações retornadas com sucesso")
    })
    @GetMapping("/type/{type}")
    public ResponseEntity<List<NotificationLog>> getNotificationsByType(@PathVariable String type) {
        List<NotificationLog> notifications = notificationService.getNotificationsByType(type);
        return ResponseEntity.ok(notifications);
    }

    @Operation(summary = "Estatísticas das notificações", 
               description = "Retorna estatísticas gerais sobre as notificações enviadas")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Estatísticas retornadas com sucesso")
    })
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getNotificationStats() {
        Map<String, Object> stats = notificationService.getNotificationStats();
        return ResponseEntity.ok(stats);
    }

    @Operation(summary = "Verificação de saúde", 
               description = "Retorna o status de saúde do serviço de notificação")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Serviço está saudável")
    })
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "Notification Service");
        response.put("version", "1.0.0");
        
        boolean authServiceHealthy = notificationService.isAuthServiceHealthy();
        response.put("authServiceHealthy", authServiceHealthy);
        
        if (!authServiceHealthy) {
            response.put("warning", "Authentication service is experiencing issues - token validation may fail");
        }
        
        return ResponseEntity.ok(response);
    }
} 