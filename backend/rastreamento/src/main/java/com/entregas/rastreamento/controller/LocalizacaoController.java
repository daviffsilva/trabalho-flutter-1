package com.entregas.rastreamento.controller;

import com.entregas.rastreamento.dto.LocalizacaoResponse;
import com.entregas.rastreamento.dto.LocalizacaoUpdateRequest;
import com.entregas.rastreamento.service.LocalizacaoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/localizacoes")
@Tag(name = "Localização", description = "APIs para gerenciamento de localizações em tempo real")
@CrossOrigin(origins = "*")
public class LocalizacaoController {

    @Autowired
    private LocalizacaoService localizacaoService;

    @PostMapping("/update")
    @Operation(summary = "Atualizar localização", description = "Atualiza a localização de um motorista")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Localização atualizada com sucesso",
                    content = @Content(schema = @Schema(implementation = LocalizacaoResponse.class))),
            @ApiResponse(responseCode = "400", description = "Dados inválidos"),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor")
    })
    public ResponseEntity<LocalizacaoResponse> updateLocation(@Valid @RequestBody LocalizacaoUpdateRequest request) {
        LocalizacaoResponse response = localizacaoService.updateLocation(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/driver/{driverId}/latest")
    @Operation(summary = "Obter última localização do motorista", description = "Retorna a última localização conhecida de um motorista")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Localização encontrada",
                    content = @Content(schema = @Schema(implementation = LocalizacaoResponse.class))),
            @ApiResponse(responseCode = "404", description = "Localização não encontrada"),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor")
    })
    public ResponseEntity<LocalizacaoResponse> getLatestLocationByDriverId(@PathVariable Long driverId) {
        LocalizacaoResponse response = localizacaoService.getLatestLocationByDriverId(driverId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/pedido/{pedidoId}/latest")
    @Operation(summary = "Obter última localização do pedido", description = "Retorna a última localização conhecida de um pedido")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Localização encontrada",
                    content = @Content(schema = @Schema(implementation = LocalizacaoResponse.class))),
            @ApiResponse(responseCode = "404", description = "Localização não encontrada"),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor")
    })
    public ResponseEntity<LocalizacaoResponse> getLatestLocationByPedidoId(@PathVariable Long pedidoId) {
        LocalizacaoResponse response = localizacaoService.getLatestLocationByPedidoId(pedidoId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/driver/{driverId}")
    @Operation(summary = "Obter todas as localizações do motorista", description = "Retorna todas as localizações de um motorista")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Localizações encontradas",
                    content = @Content(schema = @Schema(implementation = LocalizacaoResponse.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor")
    })
    public ResponseEntity<List<LocalizacaoResponse>> getLocationsByDriverId(@PathVariable Long driverId) {
        List<LocalizacaoResponse> responses = localizacaoService.getLocationsByDriverId(driverId);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/pedido/{pedidoId}")
    @Operation(summary = "Obter todas as localizações do pedido", description = "Retorna todas as localizações de um pedido")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Localizações encontradas",
                    content = @Content(schema = @Schema(implementation = LocalizacaoResponse.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor")
    })
    public ResponseEntity<List<LocalizacaoResponse>> getLocationsByPedidoId(@PathVariable Long pedidoId) {
        List<LocalizacaoResponse> responses = localizacaoService.getLocationsByPedidoId(pedidoId);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/driver/{driverId}/timerange")
    @Operation(summary = "Obter localizações do motorista por período", description = "Retorna localizações de um motorista em um período específico")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Localizações encontradas",
                    content = @Content(schema = @Schema(implementation = LocalizacaoResponse.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor")
    })
    public ResponseEntity<List<LocalizacaoResponse>> getLocationsByDriverIdAndTimeRange(
            @PathVariable Long driverId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime) {
        List<LocalizacaoResponse> responses = localizacaoService.getLocationsByDriverIdAndTimeRange(driverId, startTime);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/pedido/{pedidoId}/timerange")
    @Operation(summary = "Obter localizações do pedido por período", description = "Retorna localizações de um pedido em um período específico")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Localizações encontradas",
                    content = @Content(schema = @Schema(implementation = LocalizacaoResponse.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor")
    })
    public ResponseEntity<List<LocalizacaoResponse>> getLocationsByPedidoIdAndTimeRange(
            @PathVariable Long pedidoId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime) {
        List<LocalizacaoResponse> responses = localizacaoService.getLocationsByPedidoIdAndTimeRange(pedidoId, startTime);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/active/since")
    @Operation(summary = "Obter localizações ativas desde", description = "Retorna todas as localizações ativas desde um momento específico")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Localizações encontradas",
                    content = @Content(schema = @Schema(implementation = LocalizacaoResponse.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor")
    })
    public ResponseEntity<List<LocalizacaoResponse>> getActiveLocationsSince(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime) {
        List<LocalizacaoResponse> responses = localizacaoService.getActiveLocationsSince(startTime);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/driver/{driverId}/pedido/{pedidoId}")
    @Operation(summary = "Obter localizações por motorista e pedido", description = "Retorna localizações de um motorista para um pedido específico")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Localizações encontradas",
                    content = @Content(schema = @Schema(implementation = LocalizacaoResponse.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor")
    })
    public ResponseEntity<List<LocalizacaoResponse>> getLocationsByDriverAndPedido(
            @PathVariable Long driverId,
            @PathVariable Long pedidoId) {
        List<LocalizacaoResponse> responses = localizacaoService.getLocationsByDriverAndPedido(driverId, pedidoId);
        return ResponseEntity.ok(responses);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Desativar localização", description = "Desativa uma localização específica")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Localização desativada com sucesso"),
            @ApiResponse(responseCode = "404", description = "Localização não encontrada"),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor")
    })
    public ResponseEntity<Void> deactivateLocation(@PathVariable Long id) {
        localizacaoService.deactivateLocation(id);
        return ResponseEntity.ok().build();
    }
} 