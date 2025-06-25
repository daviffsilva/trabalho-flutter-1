package com.entregas.pedidos.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

@Service
public class NotificationClientService {

    private static final Logger logger = LoggerFactory.getLogger(NotificationClientService.class);
    private final WebClient webClient;

    @Value("${services.notification.url}")
    private String notificationServiceUrl;

    public NotificationClientService(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder
                .codecs(configurer -> configurer.defaultCodecs().maxInMemorySize(1024 * 1024))
                .build();
    }

    public void notifyDriversOfNewPedido(String token, Long pedidoId, String originAddress, String destinationAddress) {
        try {
            Map<String, Object> notificationRequest = new HashMap<>();
            notificationRequest.put("title", "Novo pedido disponível!");
            notificationRequest.put("message", String.format("Nova entrega de %s para %s", originAddress, destinationAddress));
            notificationRequest.put("type", "NOVO_PEDIDO");
            notificationRequest.put("priority", "NORMAL");
            
            Map<String, Object> data = new HashMap<>();
            data.put("pedidoId", pedidoId);
            data.put("originAddress", originAddress);
            data.put("destinationAddress", destinationAddress);
            notificationRequest.put("data", data);

            logger.debug("Notifying drivers of new pedido: {}", pedidoId);
            
            webClient.post()
                    .uri(notificationServiceUrl + "/api/notification/send-motoristas")
                    .header("Authorization", "Bearer " + token)
                    .header("Content-Type", "application/json")
                    .bodyValue(notificationRequest)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .timeout(Duration.ofSeconds(10))
                    .subscribe(
                        response -> logger.debug("Successfully notified drivers of new pedido: {}", pedidoId),
                        error -> logger.warn("Failed to notify drivers of new pedido {}: {}", pedidoId, error.getMessage())
                    );

        } catch (Exception e) {
            logger.error("Error notifying drivers of new pedido {}: {}", pedidoId, e.getMessage());
        }
    }

    public void notifyClientOfPedidoPickup(String token, Long clienteId, Long pedidoId, String originAddress, String destinationAddress) {
        try {
            Map<String, Object> notificationRequest = new HashMap<>();
            notificationRequest.put("userId", clienteId);
            notificationRequest.put("title", "Pedido aceito por motorista!");
            notificationRequest.put("message", String.format("Seu pedido de %s para %s foi aceito e o motorista está a caminho", originAddress, destinationAddress));
            notificationRequest.put("type", "PEDIDO_ACEITO");
            notificationRequest.put("priority", "HIGH");
            
            Map<String, Object> data = new HashMap<>();
            data.put("pedidoId", pedidoId);
            data.put("originAddress", originAddress);
            data.put("destinationAddress", destinationAddress);
            notificationRequest.put("data", data);

            logger.debug("Notifying client {} of pedido pickup: {}", clienteId, pedidoId);
            
            webClient.post()
                    .uri(notificationServiceUrl + "/api/notification/send")
                    .header("Authorization", "Bearer " + token)
                    .header("Content-Type", "application/json")
                    .bodyValue(notificationRequest)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .timeout(Duration.ofSeconds(10))
                    .subscribe(
                        response -> logger.debug("Successfully notified client {} of pedido pickup: {}", clienteId, pedidoId),
                        error -> logger.warn("Failed to notify client {} of pedido pickup {}: {}", clienteId, pedidoId, error.getMessage())
                    );

        } catch (Exception e) {
            logger.error("Error notifying client {} of pedido pickup {}: {}", clienteId, pedidoId, e.getMessage());
        }
    }

    public void notifyClientOfPedidoCompletion(String token, Long clienteId, Long pedidoId, String destinationAddress) {
        try {
            Map<String, Object> notificationRequest = new HashMap<>();
            notificationRequest.put("userId", clienteId);
            notificationRequest.put("title", "Pedido entregue!");
            notificationRequest.put("message", String.format("Seu pedido foi entregue com sucesso em %s. Por favor, avalie sua experiência.", destinationAddress));
            notificationRequest.put("type", "PEDIDO_FINALIZADO");
            notificationRequest.put("priority", "HIGH");
            
            Map<String, Object> data = new HashMap<>();
            data.put("pedidoId", pedidoId);
            data.put("destinationAddress", destinationAddress);
            data.put("action", "AVALIAR_ENTREGA");
            notificationRequest.put("data", data);

            logger.debug("Notifying client {} of pedido completion: {}", clienteId, pedidoId);
            
            webClient.post()
                    .uri(notificationServiceUrl + "/api/notification/send")
                    .header("Authorization", "Bearer " + token)
                    .header("Content-Type", "application/json")
                    .bodyValue(notificationRequest)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .timeout(Duration.ofSeconds(10))
                    .subscribe(
                        response -> logger.debug("Successfully notified client {} of pedido completion: {}", clienteId, pedidoId),
                        error -> logger.warn("Failed to notify client {} of pedido completion {}: {}", clienteId, pedidoId, error.getMessage())
                    );

        } catch (Exception e) {
            logger.error("Error notifying client {} of pedido completion {}: {}", clienteId, pedidoId, e.getMessage());
        }
    }
} 