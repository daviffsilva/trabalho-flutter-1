package com.entregas.rastreamento.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.HttpClientErrorException;

import java.util.HashMap;
import java.util.Map;

@Service
public class TokenValidationService {

    private static final Logger logger = LoggerFactory.getLogger(TokenValidationService.class);

    @Value("${auth.service.url:http://localhost:8081}")
    private String authServiceUrl;

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    public TokenValidationService() {
        this.restTemplate = new RestTemplate();
        this.objectMapper = new ObjectMapper();
    }

    public boolean validateToken(String token) {
        try {
            String url = authServiceUrl + "/api/auth/validate";
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(token);
            
            HttpEntity<String> entity = new HttpEntity<>(headers);
            
            ResponseEntity<String> response = restTemplate.exchange(
                url, 
                HttpMethod.POST, 
                entity, 
                String.class
            );
            
            if (response.getStatusCode() == HttpStatus.OK) {
                JsonNode responseBody = objectMapper.readTree(response.getBody());
                return responseBody.get("valid").asBoolean();
            }
            
            return false;
            
        } catch (HttpClientErrorException e) {
            logger.warn("Token validation failed: {}", e.getMessage());
            return false;
        } catch (Exception e) {
            logger.error("Error validating token: {}", e.getMessage(), e);
            return false;
        }
    }

    public Map<String, Object> getTokenInfo(String token) {
        try {
            String url = authServiceUrl + "/api/auth/validate";
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(token);
            
            HttpEntity<String> entity = new HttpEntity<>(headers);
            
            ResponseEntity<String> response = restTemplate.exchange(
                url, 
                HttpMethod.POST, 
                entity, 
                String.class
            );
            
            if (response.getStatusCode() == HttpStatus.OK) {
                JsonNode responseBody = objectMapper.readTree(response.getBody());
                Map<String, Object> tokenInfo = new HashMap<>();
                tokenInfo.put("valid", responseBody.get("valid").asBoolean());
                tokenInfo.put("userId", responseBody.get("userId").asLong());
                tokenInfo.put("userType", responseBody.get("userType").asText());
                return tokenInfo;
            }
            
            return Map.of("valid", false);
            
        } catch (HttpClientErrorException e) {
            logger.warn("Token info retrieval failed: {}", e.getMessage());
            return Map.of("valid", false);
        } catch (Exception e) {
            logger.error("Error getting token info: {}", e.getMessage(), e);
            return Map.of("valid", false);
        }
    }
} 