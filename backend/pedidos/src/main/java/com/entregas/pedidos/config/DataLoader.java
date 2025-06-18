package com.entregas.pedidos.config;

import com.entregas.pedidos.model.Order;
import com.entregas.pedidos.model.OrderStatus;
import com.entregas.pedidos.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class DataLoader implements CommandLineRunner {

    @Autowired
    private OrderRepository orderRepository;

    @Override
    public void run(String... args) throws Exception {
        if (orderRepository.count() == 0) {
            createSampleOrders();
        }
    }

    private void createSampleOrders() {
        Order order1 = new Order();
        order1.setOriginAddress("Rua das Flores, 123 - São Paulo, SP");
        order1.setDestinationAddress("Av. Paulista, 1000 - São Paulo, SP");
        order1.setOriginLatitude(-23.5505);
        order1.setOriginLongitude(-46.6333);
        order1.setDestinationLatitude(-23.5631);
        order1.setDestinationLongitude(-46.6544);
        order1.setCustomerName("João Silva");
        order1.setCustomerEmail("joao@exemplo.com");
        order1.setCustomerPhone("(11) 99999-9999");
        order1.setCargoType("Eletrônicos");
        order1.setCargoWeight(5.5);
        order1.setCargoDimensions("30x20x15 cm");
        order1.setSpecialInstructions("Fragil, manuseio com cuidado");
        order1.setStatus(OrderStatus.PENDING);
        order1.setEstimatedDistance(15.5);
        order1.setEstimatedDuration(45);
        order1.setTotalPrice(75.50);
        orderRepository.save(order1);

        Order order2 = new Order();
        order2.setOriginAddress("Rua Augusta, 500 - São Paulo, SP");
        order2.setDestinationAddress("Rua Oscar Freire, 200 - São Paulo, SP");
        order2.setOriginLatitude(-23.5489);
        order2.setOriginLongitude(-46.6388);
        order2.setDestinationLatitude(-23.5617);
        order2.setDestinationLongitude(-46.6684);
        order2.setCustomerName("Maria Santos");
        order2.setCustomerEmail("maria@exemplo.com");
        order2.setCustomerPhone("(11) 88888-8888");
        order2.setCargoType("Documentos");
        order2.setCargoWeight(0.5);
        order2.setCargoDimensions("A4");
        order2.setSpecialInstructions("Urgente");
        order2.setStatus(OrderStatus.ACCEPTED);
        order2.setDriverId(1L);
        order2.setEstimatedDistance(8.2);
        order2.setEstimatedDuration(25);
        order2.setTotalPrice(45.80);
        orderRepository.save(order2);

        Order order3 = new Order();
        order3.setOriginAddress("Av. Brigadeiro Faria Lima, 1500 - São Paulo, SP");
        order3.setDestinationAddress("Rua Pamplona, 1000 - São Paulo, SP");
        order3.setOriginLatitude(-23.5676);
        order3.setOriginLongitude(-46.6914);
        order3.setDestinationLatitude(-23.5687);
        order3.setDestinationLongitude(-46.6692);
        order3.setCustomerName("Pedro Costa");
        order3.setCustomerEmail("pedro@exemplo.com");
        order3.setCustomerPhone("(11) 77777-7777");
        order3.setCargoType("Alimentos");
        order3.setCargoWeight(10.0);
        order3.setCargoDimensions("50x30x20 cm");
        order3.setSpecialInstructions("Manter refrigerado");
        order3.setStatus(OrderStatus.IN_TRANSIT);
        order3.setDriverId(2L);
        order3.setEstimatedDistance(12.8);
        order3.setEstimatedDuration(35);
        order3.setTotalPrice(65.20);
        orderRepository.save(order3);
    }
} 