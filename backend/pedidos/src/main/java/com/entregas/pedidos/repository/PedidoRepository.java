package com.entregas.pedidos.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.entregas.pedidos.model.Pedido;
import com.entregas.pedidos.model.PedidoStatus;

@Repository
public interface PedidoRepository extends JpaRepository<Pedido, Long> {

    List<Pedido> findByCustomerEmail(String customerEmail);

    List<Pedido> findByStatus(PedidoStatus status);

    List<Pedido> findByDriverId(Long driverId);

    @Query("SELECT p FROM Pedido p WHERE p.status = :status AND p.driverId IS NULL")
    List<Pedido> findAvailablePedidos(@Param("status") PedidoStatus status);

    @Query("SELECT p FROM Pedido p WHERE p.customerEmail = :email ORDER BY p.createdAt DESC")
    List<Pedido> findPedidosByCustomerEmailOrderByCreatedAtDesc(@Param("email") String email);

    @Query("SELECT p FROM Pedido p WHERE p.driverId = :driverId ORDER BY p.updatedAt DESC")
    List<Pedido> findPedidosByDriverIdOrderByUpdatedAtDesc(@Param("driverId") Long driverId);

    @Query("SELECT p FROM Pedido p WHERE p.status IN ('PENDING', 'ACCEPTED', 'IN_TRANSIT', 'OUT_FOR_DELIVERY')")
    List<Pedido> findActivePedidos();
}
