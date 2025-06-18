package com.entregas.gateway.filter;

import com.entregas.gateway.dto.TokenValidationResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;

@Component
public class JwtAuthenticationFilter implements WebFilter {
    @Value("${AUTH_SERVICE_URL:http://localhost:8081}")
    private String authServiceUrl;

    private final WebClient webClient = WebClient.builder().build();

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getPath().toString();
        if (path.startsWith("/swagger-ui") || 
            path.startsWith("/api-docs") || 
            path.startsWith("/v3/api-docs") ||
            path.startsWith("/swagger-resources") ||
            path.startsWith("/webjars")) {
            return chain.filter(exchange);
        }
        String authHeader = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }
        return webClient.post()
                .uri(authServiceUrl + "/api/auth/validate")
                .header(HttpHeaders.AUTHORIZATION, authHeader)
                .accept(MediaType.APPLICATION_JSON)
                .retrieve()
                .onStatus(status -> status != HttpStatus.OK, response -> {
                    exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                    return Mono.error(new RuntimeException("Authentication service returned non-200 status"));
                })
                .bodyToMono(TokenValidationResponse.class)
                .flatMap(response -> {
                    if (response.getValid()) {
                        return chain.filter(exchange);
                    } else {
                        exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                        return exchange.getResponse().setComplete();
                    }
                })
                .onErrorResume(e -> {
                    exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                    return exchange.getResponse().setComplete();
                });
    }
} 