package com.entregas.rastreamento.config;

import com.entregas.rastreamento.model.Localizacao;
import com.entregas.rastreamento.repository.LocalizacaoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class DataLoader implements CommandLineRunner {

    @Autowired
    private LocalizacaoRepository localizacaoRepository;

    @Override
    public void run(String... args) throws Exception {
        if (localizacaoRepository.count() == 0) {
            createSampleLocations();
        }
    }

    private void createSampleLocations() {
        Localizacao localizacao1 = new Localizacao();
        localizacao1.setDriverId(1L);
        localizacao1.setLatitude(-23.5505);
        localizacao1.setLongitude(-46.6333);
        localizacao1.setAltitude(760.0);
        localizacao1.setSpeed(45.0);
        localizacao1.setHeading(180.0);
        localizacao1.setAccuracy(5.0);
        localizacao1.setPedidoId(1L);
        localizacao1.setTimestamp(LocalDateTime.now().minusMinutes(30));
        localizacao1.setIsActive(true);
        localizacaoRepository.save(localizacao1);

        Localizacao localizacao2 = new Localizacao();
        localizacao2.setDriverId(2L);
        localizacao2.setLatitude(-23.5505);
        localizacao2.setLongitude(-46.6333);
        localizacao2.setSpeed(35.0);
        localizacao2.setHeading(180.0);
        localizacao2.setAltitude(760.0);
        localizacao2.setAccuracy(5.0);
        localizacao2.setPedidoId(2L);
        localizacao2.setTimestamp(LocalDateTime.now().minusMinutes(15));
        localizacao2.setIsActive(true);
        localizacaoRepository.save(localizacao2);

        Localizacao localizacao3 = new Localizacao();
        localizacao3.setDriverId(3L);
        localizacao3.setLatitude(-23.5600);
        localizacao3.setLongitude(-46.6400);
        localizacao3.setSpeed(0.0);
        localizacao3.setHeading(0.0);
        localizacao3.setAltitude(750.0);
        localizacao3.setAccuracy(3.0);
        localizacao3.setPedidoId(3L);
        localizacao3.setTimestamp(LocalDateTime.now().minusMinutes(5));
        localizacao3.setIsActive(true);
        localizacaoRepository.save(localizacao3);
    }
} 