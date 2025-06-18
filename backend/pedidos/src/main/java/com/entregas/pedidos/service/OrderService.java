package com.entregas.pedidos.service;

import com.entregas.pedidos.dto.CreatepedidoRequest;
import com.entregas.pedidos.dto.pedidoResponse;
import com.entregas.pedidos.dto.RouteResponse;
import com.entregas.pedidos.dto.UpdatepedidoStatusRequest;
import com.entregas.pedidos.exception.pedidoException;
import com.entregas.pedidos.model.pedido;
import com.entregas.pedidos.model.pedidoStatus;
import com.entregas.pedidos.repository.pedidoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class pedidoService {

    @Autowired
    private pedidoRepository pedidoRepository;

    @Autowired
    private RouteService routeService;

    public pedidoResponse createpedido(CreatepedidoRequest request) {
        pedido pedido = new pedido();
        pedido.setOriginAddress(request.getOriginAddress());
        pedido.setDestinationAddress(request.getDestinationAddress());
        pedido.setOriginLatitude(request.getOriginLatitude());
        pedido.setOriginLongitude(request.getOriginLongitude());
        pedido.setDestinationLatitude(request.getDestinationLatitude());
        pedido.setDestinationLongitude(request.getDestinationLongitude());
        pedido.setCustomerName(request.getCustomerName());
        pedido.setCustomerEmail(request.getCustomerEmail());
        pedido.setCustomerPhone(request.getCustomerPhone());
        pedido.setCargoType(request.getCargoType());
        pedido.setCargoWeight(request.getCargoWeight());
        pedido.setCargoDimensions(request.getCargoDimensions());
        pedido.setSpecialInstructions(request.getSpecialInstructions());
        pedido.setStatus(pedidoStatus.PENDING);

        RouteResponse route = routeService.calculateRoute(
                request.getOriginLatitude(), request.getOriginLongitude(),
                request.getDestinationLatitude(), request.getDestinationLongitude()
        );

        pedido.setEstimatedDistance(route.getDistance());
        pedido.setEstimatedDuration(route.getDuration());
        pedido.setTotalPrice(calculatePrice(route.getDistance(), request.getCargoWeight()));

        pedido savedpedido = pedidoRepository.save(pedido);
        return convertToResponse(savedpedido);
    }

    public pedidoResponse getpedidoById(Long id) {
        pedido pedido = pedidoRepository.findById(id)
                .orElseThrow(() -> pedidoException.pedidoNotFound());
        return convertToResponse(pedido);
    }

    public List<pedidoResponse> getpedidosByCustomerEmail(String email) {
        List<pedido> pedidos = pedidoRepository.findpedidosByCustomerEmailpedidoByCreatedAtDesc(email);
        return pedidos.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<pedidoResponse> getpedidosByDriverId(Long driverId) {
        List<pedido> pedidos = pedidoRepository.findpedidosByDriverIdpedidoByUpdatedAtDesc(driverId);
        return pedidos.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<pedidoResponse> getAvailablepedidos() {
        List<pedido> pedidos = pedidoRepository.findAvailablepedidos(pedidoStatus.PENDING);
        return pedidos.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<pedidoResponse> getpedidosByStatus(pedidoStatus status) {
        List<pedido> pedidos = pedidoRepository.findByStatus(status);
        return pedidos.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public pedidoResponse updatepedidoStatus(Long pedidoId, UpdatepedidoStatusRequest request) {
        pedido pedido = pedidoRepository.findById(pedidoId)
                .orElseThrow(() -> pedidoException.pedidoNotFound());

        pedido.setStatus(request.getStatus());

        if (request.getDriverId() != null) {
            pedido.setDriverId(request.getDriverId());
        }

        if (request.getDeliveryPhotoUrl() != null) {
            pedido.setDeliveryPhotoUrl(request.getDeliveryPhotoUrl());
        }

        if (request.getDeliverySignature() != null) {
            pedido.setDeliverySignature(request.getDeliverySignature());
        }

        if (request.getStatus() == pedidoStatus.DELIVERED) {
            pedido.setDeliveredAt(LocalDateTime.now());
        }

        pedido updatedpedido = pedidoRepository.save(pedido);
        return convertToResponse(updatedpedido);
    }

    public void deletepedido(Long id) {
        pedido pedido = pedidoRepository.findById(id)
                .orElseThrow(() -> pedidoException.pedidoNotFound());

        if (pedido.getStatus() != pedidoStatus.PENDING) {
            throw pedidoException.cannotDeletepedido();
        }

        pedidoRepository.delete(pedido);
    }

    public RouteResponse calculateRoute(Double originLat, Double originLng,
                                      Double destLat, Double destLng) {
        return routeService.calculateRoute(originLat, originLng, destLat, destLng);
    }

    private pedidoResponse convertToResponse(pedido pedido) {
        pedidoResponse response = new pedidoResponse();
        response.setId(pedido.getId());
        response.setOriginAddress(pedido.getOriginAddress());
        response.setDestinationAddress(pedido.getDestinationAddress());
        response.setOriginLatitude(pedido.getOriginLatitude());
        response.setOriginLongitude(pedido.getOriginLongitude());
        response.setDestinationLatitude(pedido.getDestinationLatitude());
        response.setDestinationLongitude(pedido.getDestinationLongitude());
        response.setCustomerName(pedido.getCustomerName());
        response.setCustomerEmail(pedido.getCustomerEmail());
        response.setCustomerPhone(pedido.getCustomerPhone());
        response.setCargoType(pedido.getCargoType());
        response.setCargoWeight(pedido.getCargoWeight());
        response.setCargoDimensions(pedido.getCargoDimensions());
        response.setSpecialInstructions(pedido.getSpecialInstructions());
        response.setStatus(pedido.getStatus());
        response.setDriverId(pedido.getDriverId());
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

    private Double calculatePrice(Double distance, Double weight) {
        double basePrice = 10.0;
        double distancePrice = distance * 2.0;
        double weightPrice = (weight != null) ? weight * 1.5 : 0.0;
        return basePrice + distancePrice + weightPrice;
    }
}
