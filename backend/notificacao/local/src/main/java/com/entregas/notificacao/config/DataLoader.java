package com.entregas.notificacao.config;

import com.entregas.notificacao.model.NotificationLog;
import com.entregas.notificacao.repository.NotificationLogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
@Profile("dev") // Only runs in development profile
public class DataLoader implements CommandLineRunner {

    @Autowired
    private NotificationLogRepository notificationLogRepository;

    @Override
    public void run(String... args) throws Exception {
        if (notificationLogRepository.count() == 0) {
            loadTestData();
        }
    }

    private void loadTestData() {
        NotificationLog log1 = new NotificationLog(1L, "Pedido Finalizado", 
                "Seu pedido foi entregue com sucesso!", "PEDIDO_FINALIZADO", "HIGH");
        log1.setStatus("SENT");
        log1.setSqsMessageId("sample-message-id-1");

        NotificationLog log2 = new NotificationLog(2L, "Promoção Especial", 
                "Aproveite 20% de desconto em sua próxima entrega!", "PROMOCIONAL", "LOW");
        log2.setStatus("SENT");
        log2.setSqsMessageId("sample-message-id-2");

        NotificationLog log3 = new NotificationLog(1L, "Avaliação Solicitada", 
                "Por favor, avalie sua última entrega", "AVALIACAO_SOLICITADA", "NORMAL");
        log3.setStatus("PENDING");

        notificationLogRepository.save(log1);
        notificationLogRepository.save(log2);
        notificationLogRepository.save(log3);

        System.out.println("Test notification data loaded successfully!");
    }
} 