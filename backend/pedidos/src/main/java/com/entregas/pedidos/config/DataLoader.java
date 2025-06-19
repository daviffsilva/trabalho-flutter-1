package com.entregas.pedidos.config;

import com.entregas.pedidos.model.Pedido;
import com.entregas.pedidos.model.PedidoStatus;
import com.entregas.pedidos.repository.PedidoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class DataLoader implements CommandLineRunner {

    @Autowired
    private PedidoRepository pedidoRepository;

    @Override
    public void run(String... args) throws Exception {
        if (pedidoRepository.count() == 0) {
            createSamplePedidos();
        }
    }

    private void createSamplePedidos() {
        Pedido pedido1 = new Pedido();
        pedido1.setOriginAddress("Rua das Flores, 123 - São Paulo, SP");
        pedido1.setDestinationAddress("Av. Paulista, 1000 - São Paulo, SP");
        pedido1.setOriginLatitude(-23.5505);
        pedido1.setOriginLongitude(-46.6333);
        pedido1.setDestinationLatitude(-23.5631);
        pedido1.setDestinationLongitude(-46.6544);
        pedido1.setClienteNome("João Silva");
        pedido1.setClienteEmail("joao@exemplo.com");
        pedido1.setClienteTelefone("(11) 99999-9999");
        pedido1.setCargoType("Eletrônicos");
        pedido1.setCargoWeight(5.5);
        pedido1.setCargoDimensions("30x20x15 cm");
        pedido1.setSpecialInstructions("Fragil, manuseio com cuidado");
        pedido1.setStatus(PedidoStatus.PENDING);
        pedido1.setEstimatedDistance(15.5);
        pedido1.setEstimatedDuration(45);
        pedido1.setTotalPrice(75.50);
        pedido1.setCreatedAt(LocalDateTime.now());
        pedido1.setUpdatedAt(LocalDateTime.now());
        pedidoRepository.save(pedido1);

        Pedido pedido2 = new Pedido();
        pedido2.setOriginAddress("Rua Augusta, 500 - São Paulo, SP");
        pedido2.setDestinationAddress("Rua Oscar Freire, 200 - São Paulo, SP");
        pedido2.setOriginLatitude(-23.5489);
        pedido2.setOriginLongitude(-46.6388);
        pedido2.setDestinationLatitude(-23.5617);
        pedido2.setDestinationLongitude(-46.6684);
        pedido2.setClienteNome("Maria Santos");
        pedido2.setClienteEmail("maria@exemplo.com");
        pedido2.setClienteTelefone("(11) 88888-8888");
        pedido2.setCargoType("Documentos");
        pedido2.setCargoWeight(0.5);
        pedido2.setCargoDimensions("A4");
        pedido2.setSpecialInstructions("Urgente");
        pedido2.setStatus(PedidoStatus.ACCEPTED);
        pedido2.setMotoristaId(1L);
        pedido2.setEstimatedDistance(8.2);
        pedido2.setEstimatedDuration(25);
        pedido2.setTotalPrice(45.80);
        pedido2.setCreatedAt(LocalDateTime.now());
        pedido2.setUpdatedAt(LocalDateTime.now());
        pedidoRepository.save(pedido2);

        Pedido pedido3 = new Pedido();
        pedido3.setOriginAddress("Av. Brigadeiro Faria Lima, 1500 - São Paulo, SP");
        pedido3.setDestinationAddress("Rua Pamplona, 1000 - São Paulo, SP");
        pedido3.setOriginLatitude(-23.5676);
        pedido3.setOriginLongitude(-46.6914);
        pedido3.setDestinationLatitude(-23.5687);
        pedido3.setDestinationLongitude(-46.6692);
        pedido3.setClienteNome("Pedro Costa");
        pedido3.setClienteEmail("pedro@exemplo.com");
        pedido3.setClienteTelefone("(11) 77777-7777");
        pedido3.setCargoType("Alimentos");
        pedido3.setCargoWeight(10.0);
        pedido3.setCargoDimensions("50x30x20 cm");
        pedido3.setSpecialInstructions("Manter refrigerado");
        pedido3.setStatus(PedidoStatus.IN_TRANSIT);
        pedido3.setMotoristaId(2L);
        pedido3.setEstimatedDistance(12.8);
        pedido3.setEstimatedDuration(35);
        pedido3.setTotalPrice(65.20);
        pedido3.setCreatedAt(LocalDateTime.now());
        pedido3.setUpdatedAt(LocalDateTime.now());
        pedidoRepository.save(pedido3);
    }
} 