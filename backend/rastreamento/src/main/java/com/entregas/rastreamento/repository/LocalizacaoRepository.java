package com.entregas.rastreamento.repository;

import com.entregas.rastreamento.model.Localizacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface LocalizacaoRepository extends JpaRepository<Localizacao, Long> {

    List<Localizacao> findByDriverIdOrderByTimestampDesc(Long driverId);

    List<Localizacao> findByPedidoIdOrderByTimestampDesc(Long pedidoId);

    @Query("SELECT l FROM Localizacao l WHERE l.driverId = :driverId AND l.isActive = true ORDER BY l.timestamp DESC")
    List<Localizacao> findActiveLocationsByDriverId(@Param("driverId") Long driverId);

    @Query("SELECT l FROM Localizacao l WHERE l.pedidoId = :pedidoId AND l.isActive = true ORDER BY l.timestamp DESC")
    List<Localizacao> findActiveLocationsByPedidoId(@Param("pedidoId") Long pedidoId);

    @Query("SELECT l FROM Localizacao l WHERE l.driverId = :driverId AND l.isActive = true ORDER BY l.timestamp DESC LIMIT 1")
    Optional<Localizacao> findLatestLocationByDriverId(@Param("driverId") Long driverId);

    @Query("SELECT l FROM Localizacao l WHERE l.pedidoId = :pedidoId AND l.isActive = true ORDER BY l.timestamp DESC LIMIT 1")
    Optional<Localizacao> findLatestLocationByPedidoId(@Param("pedidoId") Long pedidoId);

    @Query("SELECT l FROM Localizacao l WHERE l.driverId = :driverId AND l.timestamp >= :startTime ORDER BY l.timestamp DESC")
    List<Localizacao> findLocationsByDriverIdAndTimeRange(@Param("driverId") Long driverId, @Param("startTime") LocalDateTime startTime);

    @Query("SELECT l FROM Localizacao l WHERE l.pedidoId = :pedidoId AND l.timestamp >= :startTime ORDER BY l.timestamp DESC")
    List<Localizacao> findLocationsByPedidoIdAndTimeRange(@Param("pedidoId") Long pedidoId, @Param("startTime") LocalDateTime startTime);

    @Query("SELECT l FROM Localizacao l WHERE l.isActive = true AND l.timestamp >= :startTime ORDER BY l.timestamp DESC")
    List<Localizacao> findActiveLocationsSince(@Param("startTime") LocalDateTime startTime);

    @Query("SELECT l FROM Localizacao l WHERE l.driverId = :driverId AND l.pedidoId = :pedidoId AND l.isActive = true ORDER BY l.timestamp DESC")
    List<Localizacao> findLocationsByDriverAndPedido(@Param("driverId") Long driverId, @Param("pedidoId") Long pedidoId);

    @Query("SELECT l FROM Localizacao l WHERE l.driverId = :driverId AND l.pedidoId = :pedidoId AND l.isActive = true ORDER BY l.timestamp DESC LIMIT 1")
    Optional<Localizacao> findLatestLocationByDriverAndPedido(@Param("driverId") Long driverId, @Param("pedidoId") Long pedidoId);

    boolean existsByDriverIdAndIsActiveTrue(Long driverId);

    boolean existsByPedidoIdAndIsActiveTrue(Long pedidoId);
} 