package com.entregas.pedidos.repository;

import com.entregas.pedidos.model.Order;
import com.entregas.pedidos.model.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    List<Order> findByCustomerEmail(String customerEmail);

    List<Order> findByStatus(OrderStatus status);

    List<Order> findByDriverId(Long driverId);

    @Query("SELECT o FROM Order o WHERE o.status = :status AND o.driverId IS NULL")
    List<Order> findAvailableOrders(@Param("status") OrderStatus status);

    @Query("SELECT o FROM Order o WHERE o.customerEmail = :email ORDER BY o.createdAt DESC")
    List<Order> findOrdersByCustomerEmailOrderByCreatedAtDesc(@Param("email") String email);

    @Query("SELECT o FROM Order o WHERE o.driverId = :driverId ORDER BY o.updatedAt DESC")
    List<Order> findOrdersByDriverIdOrderByUpdatedAtDesc(@Param("driverId") Long driverId);

    @Query("SELECT o FROM Order o WHERE o.status IN ('PENDING', 'ACCEPTED', 'IN_TRANSIT', 'OUT_FOR_DELIVERY')")
    List<Order> findActiveOrders();
} 