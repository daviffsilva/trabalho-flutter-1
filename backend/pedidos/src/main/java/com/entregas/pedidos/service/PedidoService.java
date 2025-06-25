package com.entregas.pedidos.service;

import com.entregas.pedidos.dto.ClaimPedidoRequest;
import com.entregas.pedidos.dto.CreatePedidoRequest;
import com.entregas.pedidos.dto.PedidoResponse;
import com.entregas.pedidos.dto.UpdatePedidoStatusRequest;
import com.entregas.pedidos.exception.PedidoException;
import com.entregas.pedidos.model.Pedido;
import com.entregas.pedidos.model.PedidoStatus;
import com.entregas.pedidos.repository.PedidoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class PedidoService {

    @Autowired
    private PedidoRepository pedidoRepository;

    @Autowired
    private NotificationClientService notificationClientService;

    public PedidoResponse createPedido(CreatePedidoRequest request, String userToken) {
        Pedido pedido = new Pedido();
        pedido.setOriginAddress(request.getOriginAddress());
        pedido.setDestinationAddress(request.getDestinationAddress());
        pedido.setOriginLatitude(request.getOriginLatitude());
        pedido.setOriginLongitude(request.getOriginLongitude());
        pedido.setDestinationLatitude(request.getDestinationLatitude());
        pedido.setDestinationLongitude(request.getDestinationLongitude());
        pedido.setClienteId(request.getClienteId());
        pedido.setClienteNome(request.getClienteNome());
        pedido.setClienteEmail(request.getClienteEmail());
        pedido.setClienteTelefone(request.getClienteTelefone());
        pedido.setCargoType(request.getCargoType());
        pedido.setCargoWeight(request.getCargoWeight());
        pedido.setCargoDimensions(request.getCargoDimensions());
        pedido.setSpecialInstructions(request.getSpecialInstructions());
        pedido.setStatus(PedidoStatus.PENDING);
        pedido.setCreatedAt(LocalDateTime.now());
        pedido.setUpdatedAt(LocalDateTime.now());

        Pedido savedPedido = pedidoRepository.save(pedido);
        
        if (userToken != null) {
            notificationClientService.notifyDriversOfNewPedido(
                userToken, 
                savedPedido.getId(), 
                savedPedido.getOriginAddress(), 
                savedPedido.getDestinationAddress()
            );
        }
        
        return convertToResponse(savedPedido);
    }

    public PedidoResponse getPedidoById(Long id) {
        Optional<Pedido> pedido = pedidoRepository.findById(id);
        if (pedido.isPresent()) {
            return convertToResponse(pedido.get());
        }
        throw new PedidoException("Pedido não encontrado com ID: " + id);
    }

    public List<PedidoResponse> getAllPedidos() {
        List<Pedido> pedidos = pedidoRepository.findAll();
        return pedidos.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<PedidoResponse> getPedidosByClienteId(Long clienteId) {
        List<Pedido> pedidos = pedidoRepository.findByClienteId(clienteId);
        return pedidos.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<PedidoResponse> getPedidosByClienteEmail(String email) {
        List<Pedido> pedidos = pedidoRepository.findByClienteEmail(email);
        return pedidos.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<PedidoResponse> getPedidosByMotoristaId(Long motoristaId) {
        List<Pedido> pedidos = pedidoRepository.findByMotoristaId(motoristaId);
        return pedidos.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<PedidoResponse> getPedidosByStatus(PedidoStatus status) {
        List<Pedido> pedidos = pedidoRepository.findByStatus(status);
        return pedidos.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public PedidoResponse updatePedidoStatus(Long id, UpdatePedidoStatusRequest request, String userToken) {
        Optional<Pedido> pedidoOpt = pedidoRepository.findById(id);
        if (pedidoOpt.isPresent()) {
            Pedido pedido = pedidoOpt.get();
            PedidoStatus previousStatus = pedido.getStatus();
            pedido.setStatus(request.getStatus());
            pedido.setUpdatedAt(LocalDateTime.now());
            
            if (request.getStatus() == PedidoStatus.DELIVERED) {
                pedido.setDeliveredAt(LocalDateTime.now());
            }
            
            Pedido updatedPedido = pedidoRepository.save(pedido);
            
            if (request.getStatus() == PedidoStatus.DELIVERED && previousStatus != PedidoStatus.DELIVERED && userToken != null) {
                notificationClientService.notifyClientOfPedidoCompletion(
                    userToken,
                    updatedPedido.getClienteId(),
                    updatedPedido.getId(),
                    updatedPedido.getDestinationAddress()
                );
            }
            
            return convertToResponse(updatedPedido);
        }
        throw new PedidoException("Pedido não encontrado com ID: " + id);
    }

    public void deletePedido(Long id) {
        Optional<Pedido> pedido = pedidoRepository.findById(id);
        if (pedido.isPresent()) {
            pedidoRepository.deleteById(id);
        } else {
            throw new PedidoException("Pedido não encontrado com ID: " + id);
        }
    }

    public List<PedidoResponse> getPedidosByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        List<Pedido> pedidos = pedidoRepository.findByCreatedAtBetween(startDate, endDate);
        return pedidos.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<PedidoResponse> getPedidosByClienteAndStatus(Long clienteId, PedidoStatus status) {
        List<Pedido> pedidos = pedidoRepository.findByClienteIdAndStatus(clienteId, status);
        return pedidos.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<PedidoResponse> getAvailablePedidos() {
        List<Pedido> pedidos = pedidoRepository.findAvailablePedidos(PedidoStatus.PENDING);
        return pedidos.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public PedidoResponse claimPedido(Long pedidoId, Long motoristaId, String userToken) {
        Optional<Pedido> pedidoOpt = pedidoRepository.findById(pedidoId);
        if (pedidoOpt.isEmpty()) {
            throw new PedidoException("Pedido não encontrado com ID: " + pedidoId);
        }

        Pedido pedido = pedidoOpt.get();
        
        if (pedido.getStatus() != PedidoStatus.PENDING) {
            throw new PedidoException("Pedido não está disponível para reivindicação. Status atual: " + pedido.getStatus());
        }
        
        if (pedido.getMotoristaId() != null) {
            throw new PedidoException("Pedido já foi atribuído a um motorista");
        }

        pedido.setMotoristaId(motoristaId);
        pedido.setStatus(PedidoStatus.ACCEPTED);
        pedido.setUpdatedAt(LocalDateTime.now());

        Pedido savedPedido = pedidoRepository.save(pedido);
        
        if (userToken != null) {
            notificationClientService.notifyClientOfPedidoPickup(
                userToken,
                savedPedido.getClienteId(),
                savedPedido.getId(),
                savedPedido.getOriginAddress(),
                savedPedido.getDestinationAddress()
            );
        }
        
        return convertToResponse(savedPedido);
    }

    public boolean isPedidoAvailableForClaiming(Long pedidoId) {
        Optional<Pedido> pedidoOpt = pedidoRepository.findById(pedidoId);
        if (pedidoOpt.isEmpty()) {
            return false;
        }

        Pedido pedido = pedidoOpt.get();
        return pedido.getStatus() == PedidoStatus.PENDING && pedido.getMotoristaId() == null;
    }

    public PedidoResponse createPedido(CreatePedidoRequest request) {
        return createPedido(request, null);
    }

    public PedidoResponse updatePedidoStatus(Long id, UpdatePedidoStatusRequest request) {
        return updatePedidoStatus(id, request, null);
    }

    public PedidoResponse claimPedido(Long pedidoId, Long motoristaId) {
        return claimPedido(pedidoId, motoristaId, null);
    }

    private PedidoResponse convertToResponse(Pedido pedido) {
        PedidoResponse response = new PedidoResponse();
        response.setId(pedido.getId());
        response.setClienteId(pedido.getClienteId());
        response.setOriginAddress(pedido.getOriginAddress());
        response.setDestinationAddress(pedido.getDestinationAddress());
        response.setOriginLatitude(pedido.getOriginLatitude());
        response.setOriginLongitude(pedido.getOriginLongitude());
        response.setDestinationLatitude(pedido.getDestinationLatitude());
        response.setDestinationLongitude(pedido.getDestinationLongitude());
        response.setClienteNome(pedido.getClienteNome());
        response.setClienteEmail(pedido.getClienteEmail());
        response.setClienteTelefone(pedido.getClienteTelefone());
        response.setCargoType(pedido.getCargoType());
        response.setCargoWeight(pedido.getCargoWeight());
        response.setCargoDimensions(pedido.getCargoDimensions());
        response.setSpecialInstructions(pedido.getSpecialInstructions());
        response.setStatus(pedido.getStatus());
        response.setMotoristaId(pedido.getMotoristaId());
        response.setEstimatedDistance(pedido.getEstimatedDistance());
        response.setEstimatedDuration(pedido.getEstimatedDuration());
        response.setTotalPrice(pedido.getTotalPrice());
        response.setCreatedAt(pedido.getCreatedAt());
        response.setUpdatedAt(pedido.getUpdatedAt());
        response.setDeliveredAt(pedido.getDeliveredAt());
        response.setDeliveryPhotoUrl(pedido.getDeliveryPhotoUrl());
        response.setDeliverySignature(pedido.getDeliverySignature());
        return response;
    }
} 