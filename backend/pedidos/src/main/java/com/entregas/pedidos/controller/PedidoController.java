package com.entregas.pedidos.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.entregas.pedidos.dto.CreateOrderRequest;
import com.entregas.pedidos.dto.ErrorResponse;
import com.entregas.pedidos.dto.PedidoResponse;
import com.entregas.pedidos.dto.RouteResponse;
import com.entregas.pedidos.dto.UpdatePedidoStatusRequest;
import com.entregas.pedidos.model.PedidoStatus;
import com.entregas.pedidos.service.PedidoService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/pedidos")
@CrossOrigin(origins = "*")
@Tag(name = "Pedidos", description = "APIs de gerenciamento de pedidos")
public class PedidoController {

    @Autowired
    private PedidoService pedidoService;

    @Operation(summary = "Criar novo pedido", description = "Cria um novo pedido com informações de origem, destino e carga")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pedido criado com sucesso",
                content = @Content(schema = @Schema(implementation = PedidoResponse.class))),
        @ApiResponse(responseCode = "400", description = "Dados inválidos",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping
    public ResponseEntity<PedidoResponse> createPedido(@Valid @RequestBody CreateOrderRequest request) {
        PedidoResponse response = pedidoService.createPedido(request);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Buscar pedido por ID", description = "Retorna os detalhes de um pedido específico")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pedido encontrado",
                content = @Content(schema = @Schema(implementation = PedidoResponse.class))),
        @ApiResponse(responseCode = "404", description = "Pedido não encontrado",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/{id}")
    public ResponseEntity<PedidoResponse> getPedidoById(@PathVariable Long id) {
        PedidoResponse response = pedidoService.getPedidoById(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Buscar pedidos por cliente", description = "Retorna todos os pedidos de um cliente específico")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pedidos encontrados",
                content = @Content(schema = @Schema(implementation = PedidoResponse.class)))
    })
    @GetMapping("/customer/{email}")
    public ResponseEntity<List<PedidoResponse>> getPedidosByCustomer(@PathVariable String email) {
        List<PedidoResponse> responses = pedidoService.getPedidosByCustomerEmail(email);
        return ResponseEntity.ok(responses);
    }

    @Operation(summary = "Buscar pedidos por motorista", description = "Retorna todos os pedidos atribuídos a um motorista")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pedidos encontrados",
                content = @Content(schema = @Schema(implementation = PedidoResponse.class)))
    })
    @GetMapping("/driver/{driverId}")
    public ResponseEntity<List<PedidoResponse>> getPedidosByDriver(@PathVariable Long driverId) {
        List<PedidoResponse> responses = pedidoService.getPedidosByDriverId(driverId);
        return ResponseEntity.ok(responses);
    }

    @Operation(summary = "Buscar pedidos disponíveis", description = "Retorna todos os pedidos pendentes disponíveis para motoristas")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pedidos disponíveis encontrados",
                content = @Content(schema = @Schema(implementation = PedidoResponse.class)))
    })
    @GetMapping("/available")
    public ResponseEntity<List<PedidoResponse>> getAvailablePedidos() {
        List<PedidoResponse> responses = pedidoService.getAvailablePedidos();
        return ResponseEntity.ok(responses);
    }

    @Operation(summary = "Buscar pedidos por status", description = "Retorna todos os pedidos com um status específico")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pedidos encontrados",
                content = @Content(schema = @Schema(implementation = PedidoResponse.class)))
    })
    @GetMapping("/status/{status}")
    public ResponseEntity<List<PedidoResponse>> getPedidosByStatus(@PathVariable PedidoStatus status) {
        List<PedidoResponse> responses = pedidoService.getPedidosByStatus(status);
        return ResponseEntity.ok(responses);
    }

    @Operation(summary = "Atualizar status do pedido", description = "Atualiza o status de um pedido específico")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Status atualizado com sucesso",
                content = @Content(schema = @Schema(implementation = PedidoResponse.class))),
        @ApiResponse(responseCode = "404", description = "Pedido não encontrado",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/{id}/status")
    public ResponseEntity<PedidoResponse> updatePedidoStatus(
            @PathVariable Long id,
            @Valid @RequestBody UpdatePedidoStatusRequest request) {
        PedidoResponse response = pedidoService.updatePedidoStatus(id, request);
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
        RouteResponse response = pedidoService.calculateRoute(originLat, originLng, destLat, destLng);
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
    public ResponseEntity<Void> deletePedido(@PathVariable Long id) {
        pedidoService.deletePedido(id);
        return ResponseEntity.ok().build();
    }
}
