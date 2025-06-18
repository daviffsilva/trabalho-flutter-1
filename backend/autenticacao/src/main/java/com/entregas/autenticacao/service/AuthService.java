package com.entregas.autenticacao.service;

import com.entregas.autenticacao.dto.AuthResponse;
import com.entregas.autenticacao.dto.LoginRequest;
import com.entregas.autenticacao.dto.RegisterRequest;
import com.entregas.autenticacao.exception.AuthenticationException;
import com.entregas.autenticacao.model.User;
import com.entregas.autenticacao.repository.UserRepository;
import com.entregas.autenticacao.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw AuthenticationException.userAlreadyExists();
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setName(request.getName());
        user.setUserType(request.getUserType());

        User savedUser = userRepository.save(user);

        String token = jwtUtil.generateToken(savedUser.getEmail(), savedUser.getId(), savedUser.getUserType().name());
        String refreshToken = jwtUtil.generateRefreshToken(savedUser.getEmail(), savedUser.getId());

        return new AuthResponse(
                token,
                refreshToken,
                savedUser.getId(),
                savedUser.getEmail(),
                savedUser.getName(),
                savedUser.getUserType(),
                86400000L
        );
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(AuthenticationException::invalidCredentials);

        if (!user.isActive()) {
            throw AuthenticationException.userDeactivated();
        }

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw AuthenticationException.invalidCredentials();
        }

        String token = jwtUtil.generateToken(user.getEmail(), user.getId(), user.getUserType().name());
        String refreshToken = jwtUtil.generateRefreshToken(user.getEmail(), user.getId());

        return new AuthResponse(
                token,
                refreshToken,
                user.getId(),
                user.getEmail(),
                user.getName(),
                user.getUserType(),
                86400000L
        );
    }

    public AuthResponse refreshToken(String refreshToken) {
        if (!jwtUtil.validateToken(refreshToken) || !jwtUtil.isRefreshToken(refreshToken)) {
            throw AuthenticationException.invalidRefreshToken();
        }

        String email = jwtUtil.extractUsername(refreshToken);
        Long userId = jwtUtil.extractUserId(refreshToken);

        User user = userRepository.findById(userId)
                .orElseThrow(AuthenticationException::userNotFound);

        if (!user.isActive()) {
            throw AuthenticationException.userDeactivated();
        }

        String newToken = jwtUtil.generateToken(user.getEmail(), user.getId(), user.getUserType().name());
        String newRefreshToken = jwtUtil.generateRefreshToken(user.getEmail(), user.getId());

        return new AuthResponse(
                newToken,
                newRefreshToken,
                user.getId(),
                user.getEmail(),
                user.getName(),
                user.getUserType(),
                86400000L
        );
    }

    public boolean validateToken(String token) {
        return jwtUtil.validateToken(token);
    }

    public Long getUserIdFromToken(String token) {
        if (!jwtUtil.validateToken(token)) {
            throw AuthenticationException.invalidToken();
        }
        return jwtUtil.extractUserId(token);
    }

    public String getUserTypeFromToken(String token) {
        if (!jwtUtil.validateToken(token)) {
            throw AuthenticationException.invalidToken();
        }
        return jwtUtil.extractUserType(token);
    }
} 