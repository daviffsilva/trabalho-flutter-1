package com.entregas.notificacao.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

@Service
public class AuthValidationService {

    private static final Logger logger = LoggerFactory.getLogger(AuthValidationService.class);
    private final WebClient webClient;
    private final AtomicInteger consecutiveFailures = new AtomicInteger(0);
    private final AtomicReference<LocalDateTime> lastFailureTime = new AtomicReference<>();
    private static final int MAX_CONSECUTIVE_FAILURES = 3;
    private static final Duration CIRCUIT_BREAKER_TIMEOUT = Duration.ofMinutes(2);

    @Value("${services.auth.url}")
    private String authServiceUrl;

    public AuthValidationService(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder
                .codecs(configurer -> configurer.defaultCodecs().maxInMemorySize(1024 * 1024))
                .build();
    }

    public TokenValidationResult validateToken(String token) {
        if (isCircuitOpen()) {
            logger.warn("Authentication service circuit breaker is OPEN - denying access");
            return new TokenValidationResult(false, null, null, "AUTH_SERVICE_UNAVAILABLE");
        }

        try {
            logger.debug("Validating token with authentication service at: {}", authServiceUrl);
            
            Map<String, Object> response = webClient
                    .post()
                    .uri(authServiceUrl + "/api/auth/validate")
                    .header("Authorization", "Bearer " + token)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .timeout(Duration.ofSeconds(5))
                    .block();

            if (response != null && Boolean.TRUE.equals(response.get("valid"))) {
                String userId = String.valueOf(response.get("userId"));
                String userType = String.valueOf(response.get("userType"));
                
                consecutiveFailures.set(0);
                lastFailureTime.set(null);
                
                logger.debug("Token validation successful for user: {} (type: {})", userId, userType);
                return new TokenValidationResult(true, userId, userType, null);
            } else {
                logger.debug("Token validation failed - invalid token");
                return new TokenValidationResult(false, null, null, "INVALID_TOKEN");
            }

        } catch (WebClientResponseException e) {
            recordFailure();
            logger.warn("Token validation failed with HTTP error: {} - {}", e.getStatusCode(), e.getMessage());
            return new TokenValidationResult(false, null, null, "AUTH_SERVICE_ERROR");
            
        } catch (Exception e) {
            recordFailure();
            logger.error("Token validation failed due to error: {}", e.getMessage());
            return new TokenValidationResult(false, null, null, "CONNECTION_ERROR");
        }
    }

    private void recordFailure() {
        consecutiveFailures.incrementAndGet();
        lastFailureTime.set(LocalDateTime.now());
        
        if (consecutiveFailures.get() >= MAX_CONSECUTIVE_FAILURES) {
            logger.error("Authentication service circuit breaker opened after {} consecutive failures", 
                        MAX_CONSECUTIVE_FAILURES);
        }
    }

    private boolean isCircuitOpen() {
        if (consecutiveFailures.get() < MAX_CONSECUTIVE_FAILURES) {
            return false;
        }
        
        LocalDateTime lastFailure = lastFailureTime.get();
        if (lastFailure == null) {
            return false;
        }
        
        boolean circuitOpen = LocalDateTime.now().isBefore(lastFailure.plus(CIRCUIT_BREAKER_TIMEOUT));
        
        if (!circuitOpen) {
            logger.info("Authentication service circuit breaker attempting to close - resetting counters");
            consecutiveFailures.set(0);
            lastFailureTime.set(null);
        }
        
        return circuitOpen;
    }

    public boolean isAuthServiceHealthy() {
        return !isCircuitOpen();
    }

    public static class TokenValidationResult {
        private final boolean valid;
        private final String userId;
        private final String userType;
        private final String errorCode;

        public TokenValidationResult(boolean valid, String userId, String userType, String errorCode) {
            this.valid = valid;
            this.userId = userId;
            this.userType = userType;
            this.errorCode = errorCode;
        }

        public boolean isValid() {
            return valid;
        }

        public String getUserId() {
            return userId;
        }

        public String getUserType() {
            return userType;
        }

        public String getErrorCode() {
            return errorCode;
        }
    }
} 