package com.entregas.pedidos.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.entregas.pedidos.model.Pedido;
import com.entregas.pedidos.model.PedidoStatus;

@Repository
public interface PedidoRepository extends JpaRepository<Pedido, Long> {

    List<Pedido> findByClienteEmail(String clienteEmail);

    List<Pedido> findByStatus(PedidoStatus status);

    List<Pedido> findByMotoristaId(Long motoristaId);

    List<Pedido> findByCreatedAtBetween(LocalDateTime startDate, LocalDateTime endDate);

    @Query("SELECT p FROM Pedido p WHERE p.status = :status AND p.motoristaId IS NULL")
    List<Pedido> findAvailablePedidos(@Param("status") PedidoStatus status);

    @Query("SELECT p FROM Pedido p WHERE p.clienteEmail = :email ORDER BY p.createdAt DESC")
    List<Pedido> findPedidosByClienteEmailOrderByCreatedAtDesc(@Param("email") String email);

    @Query("SELECT p FROM Pedido p WHERE p.motoristaId = :motoristaId ORDER BY p.updatedAt DESC")
    List<Pedido> findPedidosByMotoristaIdOrderByUpdatedAtDesc(@Param("motoristaId") Long motoristaId);

    @Query("SELECT p FROM Pedido p WHERE p.status IN ('PENDING', 'ACCEPTED', 'IN_TRANSIT', 'OUT_FOR_DELIVERY')")
    List<Pedido> findActivePedidos();
}
