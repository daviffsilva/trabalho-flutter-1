package com.entregas.autenticacao.config;

import com.entregas.autenticacao.model.User;
import com.entregas.autenticacao.model.UserType;
import com.entregas.autenticacao.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataLoader implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        if (!userRepository.existsByEmail("cliente@teste.com")) {
            User cliente = new User();
            cliente.setEmail("cliente@teste.com");
            cliente.setPassword(passwordEncoder.encode("senha123"));
            cliente.setName("Cliente Teste");
            cliente.setUserType(UserType.CLIENT);
            userRepository.save(cliente);
        }

        if (!userRepository.existsByEmail("motorista@teste.com")) {
            User motorista = new User();
            motorista.setEmail("motorista@teste.com");
            motorista.setPassword(passwordEncoder.encode("senha123"));
            motorista.setName("Motorista Teste");
            motorista.setUserType(UserType.DRIVER);
            userRepository.save(motorista);
        }
    }
} 