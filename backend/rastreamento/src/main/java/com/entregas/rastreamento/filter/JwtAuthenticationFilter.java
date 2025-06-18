package com.entregas.rastreamento.filter;

import com.entregas.rastreamento.service.TokenValidationService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.Map;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    @Autowired
    private TokenValidationService tokenValidationService;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        
        try {
            String token = extractTokenFromRequest(request);
            
            if (StringUtils.hasText(token)) {
                logger.debug("Processing JWT token for request: {}", request.getRequestURI());
                
                Map<String, Object> tokenInfo = tokenValidationService.getTokenInfo(token);
                
                if ((Boolean) tokenInfo.get("valid")) {
                    Long userId = (Long) tokenInfo.get("userId");
                    String userType = (String) tokenInfo.get("userType");
                    
                    UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                        userId,
                        null,
                        Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + userType.toUpperCase()))
                    );
                    
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                    logger.debug("User {} authenticated with role {} for request: {}", userId, userType, request.getRequestURI());
                } else {
                    logger.warn("Invalid token provided for request: {}", request.getRequestURI());
                    SecurityContextHolder.clearContext();
                }
            } else {
                logger.debug("No token provided for request: {}", request.getRequestURI());
                SecurityContextHolder.clearContext();
            }
        } catch (Exception e) {
            logger.error("Error processing JWT token for request {}: {}", request.getRequestURI(), e.getMessage(), e);
            SecurityContextHolder.clearContext();
        }
        
        filterChain.doFilter(request, response);
    }

    private String extractTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
} 