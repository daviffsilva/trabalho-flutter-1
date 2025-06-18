package com.entregas.pedidos.controller;

import com.entregas.pedidos.dto.*;
import com.entregas.pedidos.model.OrderStatus;
import com.entregas.pedidos.service.OrderService;
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

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
@Tag(name = "Pedidos", description = "APIs de gerenciamento de pedidos")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @Operation(summary = "Criar novo pedido", description = "Cria um novo pedido com informações de origem, destino e carga")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pedido criado com sucesso",
                content = @Content(schema = @Schema(implementation = OrderResponse.class))),
        @ApiResponse(responseCode = "400", description = "Dados inválidos",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping
    public ResponseEntity<OrderResponse> createOrder(@Valid @RequestBody CreateOrderRequest request) {
        OrderResponse response = orderService.createOrder(request);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Buscar pedido por ID", description = "Retorna os detalhes de um pedido específico")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pedido encontrado",
                content = @Content(schema = @Schema(implementation = OrderResponse.class))),
        @ApiResponse(responseCode = "404", description = "Pedido não encontrado",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/{id}")
    public ResponseEntity<OrderResponse> getOrderById(@PathVariable Long id) {
        OrderResponse response = orderService.getOrderById(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Buscar pedidos por cliente", description = "Retorna todos os pedidos de um cliente específico")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pedidos encontrados",
                content = @Content(schema = @Schema(implementation = OrderResponse.class)))
    })
    @GetMapping("/customer/{email}")
    public ResponseEntity<List<OrderResponse>> getOrdersByCustomer(@PathVariable String email) {
        List<OrderResponse> responses = orderService.getOrdersByCustomerEmail(email);
        return ResponseEntity.ok(responses);
    }

    @Operation(summary = "Buscar pedidos por motorista", description = "Retorna todos os pedidos atribuídos a um motorista")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pedidos encontrados",
                content = @Content(schema = @Schema(implementation = OrderResponse.class)))
    })
    @GetMapping("/driver/{driverId}")
    public ResponseEntity<List<OrderResponse>> getOrdersByDriver(@PathVariable Long driverId) {
        List<OrderResponse> responses = orderService.getOrdersByDriverId(driverId);
        return ResponseEntity.ok(responses);
    }

    @Operation(summary = "Buscar pedidos disponíveis", description = "Retorna todos os pedidos pendentes disponíveis para motoristas")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pedidos disponíveis encontrados",
                content = @Content(schema = @Schema(implementation = OrderResponse.class)))
    })
    @GetMapping("/available")
    public ResponseEntity<List<OrderResponse>> getAvailableOrders() {
        List<OrderResponse> responses = orderService.getAvailableOrders();
        return ResponseEntity.ok(responses);
    }

    @Operation(summary = "Buscar pedidos por status", description = "Retorna todos os pedidos com um status específico")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pedidos encontrados",
                content = @Content(schema = @Schema(implementation = OrderResponse.class)))
    })
    @GetMapping("/status/{status}")
    public ResponseEntity<List<OrderResponse>> getOrdersByStatus(@PathVariable OrderStatus status) {
        List<OrderResponse> responses = orderService.getOrdersByStatus(status);
        return ResponseEntity.ok(responses);
    }

    @Operation(summary = "Atualizar status do pedido", description = "Atualiza o status de um pedido específico")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Status atualizado com sucesso",
                content = @Content(schema = @Schema(implementation = OrderResponse.class))),
        @ApiResponse(responseCode = "404", description = "Pedido não encontrado",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/{id}/status")
    public ResponseEntity<OrderResponse> updateOrderStatus(
            @PathVariable Long id,
            @Valid @RequestBody UpdateOrderStatusRequest request) {
        OrderResponse response = orderService.updateOrderStatus(id, request);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Calcular rota", description = "Calcula a rota otimizada entre dois pontos")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Rota calculada com sucesso",
                content = @Content(schema = @Schema(implementation = RouteResponse.class)))
    })
    @GetMapping("/route")
    public ResponseEntity<RouteResponse> calculateRoute(
            @RequestParam Double originLat,
            @RequestParam Double originLng,
            @RequestParam Double destLat,
            @RequestParam Double destLng) {
        RouteResponse response = orderService.calculateRoute(originLat, originLng, destLat, destLng);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Excluir pedido", description = "Exclui um pedido pendente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pedido excluído com sucesso"),
        @ApiResponse(responseCode = "400", description = "Não é possível excluir o pedido",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Pedido não encontrado",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteOrder(@PathVariable Long id) {
        orderService.deleteOrder(id);
        return ResponseEntity.ok().build();
    }
} 