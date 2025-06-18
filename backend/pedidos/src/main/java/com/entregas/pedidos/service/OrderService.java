package com.entregas.pedidos.service;

import com.entregas.pedidos.dto.CreateOrderRequest;
import com.entregas.pedidos.dto.OrderResponse;
import com.entregas.pedidos.dto.RouteResponse;
import com.entregas.pedidos.dto.UpdateOrderStatusRequest;
import com.entregas.pedidos.exception.OrderException;
import com.entregas.pedidos.model.Order;
import com.entregas.pedidos.model.OrderStatus;
import com.entregas.pedidos.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private RouteService routeService;

    public OrderResponse createOrder(CreateOrderRequest request) {
        Order order = new Order();
        order.setOriginAddress(request.getOriginAddress());
        order.setDestinationAddress(request.getDestinationAddress());
        order.setOriginLatitude(request.getOriginLatitude());
        order.setOriginLongitude(request.getOriginLongitude());
        order.setDestinationLatitude(request.getDestinationLatitude());
        order.setDestinationLongitude(request.getDestinationLongitude());
        order.setCustomerName(request.getCustomerName());
        order.setCustomerEmail(request.getCustomerEmail());
        order.setCustomerPhone(request.getCustomerPhone());
        order.setCargoType(request.getCargoType());
        order.setCargoWeight(request.getCargoWeight());
        order.setCargoDimensions(request.getCargoDimensions());
        order.setSpecialInstructions(request.getSpecialInstructions());
        order.setStatus(OrderStatus.PENDING);

        RouteResponse route = routeService.calculateRoute(
                request.getOriginLatitude(), request.getOriginLongitude(),
                request.getDestinationLatitude(), request.getDestinationLongitude()
        );

        order.setEstimatedDistance(route.getDistance());
        order.setEstimatedDuration(route.getDuration());
        order.setTotalPrice(calculatePrice(route.getDistance(), request.getCargoWeight()));

        Order savedOrder = orderRepository.save(order);
        return convertToResponse(savedOrder);
    }

    public OrderResponse getOrderById(Long id) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> OrderException.orderNotFound());
        return convertToResponse(order);
    }

    public List<OrderResponse> getOrdersByCustomerEmail(String email) {
        List<Order> orders = orderRepository.findOrdersByCustomerEmailOrderByCreatedAtDesc(email);
        return orders.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<OrderResponse> getOrdersByDriverId(Long driverId) {
        List<Order> orders = orderRepository.findOrdersByDriverIdOrderByUpdatedAtDesc(driverId);
        return orders.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<OrderResponse> getAvailableOrders() {
        List<Order> orders = orderRepository.findAvailableOrders(OrderStatus.PENDING);
        return orders.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<OrderResponse> getOrdersByStatus(OrderStatus status) {
        List<Order> orders = orderRepository.findByStatus(status);
        return orders.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public OrderResponse updateOrderStatus(Long orderId, UpdateOrderStatusRequest request) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> OrderException.orderNotFound());

        order.setStatus(request.getStatus());

        if (request.getDriverId() != null) {
            order.setDriverId(request.getDriverId());
        }

        if (request.getDeliveryPhotoUrl() != null) {
            order.setDeliveryPhotoUrl(request.getDeliveryPhotoUrl());
        }

        if (request.getDeliverySignature() != null) {
            order.setDeliverySignature(request.getDeliverySignature());
        }

        if (request.getStatus() == OrderStatus.DELIVERED) {
            order.setDeliveredAt(LocalDateTime.now());
        }

        Order updatedOrder = orderRepository.save(order);
        return convertToResponse(updatedOrder);
    }

    public void deleteOrder(Long id) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> OrderException.orderNotFound());

        if (order.getStatus() != OrderStatus.PENDING) {
            throw OrderException.cannotDeleteOrder();
        }

        orderRepository.delete(order);
    }

    public RouteResponse calculateRoute(Double originLat, Double originLng, 
                                      Double destLat, Double destLng) {
        return routeService.calculateRoute(originLat, originLng, destLat, destLng);
    }

    private OrderResponse convertToResponse(Order order) {
        OrderResponse response = new OrderResponse();
        response.setId(order.getId());
        response.setOriginAddress(order.getOriginAddress());
        response.setDestinationAddress(order.getDestinationAddress());
        response.setOriginLatitude(order.getOriginLatitude());
        response.setOriginLongitude(order.getOriginLongitude());
        response.setDestinationLatitude(order.getDestinationLatitude());
        response.setDestinationLongitude(order.getDestinationLongitude());
        response.setCustomerName(order.getCustomerName());
        response.setCustomerEmail(order.getCustomerEmail());
        response.setCustomerPhone(order.getCustomerPhone());
        response.setCargoType(order.getCargoType());
        response.setCargoWeight(order.getCargoWeight());
        response.setCargoDimensions(order.getCargoDimensions());
        response.setSpecialInstructions(order.getSpecialInstructions());
        response.setStatus(order.getStatus());
        response.setDriverId(order.getDriverId());
        response.setEstimatedDistance(order.getEstimatedDistance());
        response.setEstimatedDuration(order.getEstimatedDuration());
        response.setTotalPrice(order.getTotalPrice());
        response.setCreatedAt(order.getCreatedAt());
        response.setUpdatedAt(order.getUpdatedAt());
        response.setDeliveredAt(order.getDeliveredAt());
        response.setDeliveryPhotoUrl(order.getDeliveryPhotoUrl());
        response.setDeliverySignature(order.getDeliverySignature());
        return response;
    }

    private Double calculatePrice(Double distance, Double weight) {
        double basePrice = 10.0;
        double distancePrice = distance * 2.0;
        double weightPrice = (weight != null) ? weight * 1.5 : 0.0;
        return basePrice + distancePrice + weightPrice;
    }
} 