package com.entregas.notificacao.repository;

import com.entregas.notificacao.model.NotificationLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface NotificationLogRepository extends JpaRepository<NotificationLog, Long> {

    List<NotificationLog> findByUserIdOrderBySentAtDesc(Long userId);

    List<NotificationLog> findByStatusOrderBySentAtDesc(String status);

    List<NotificationLog> findByTypeOrderBySentAtDesc(String type);

    @Query("SELECT n FROM NotificationLog n WHERE n.sentAt BETWEEN :startDate AND :endDate ORDER BY n.sentAt DESC")
    List<NotificationLog> findByDateRange(@Param("startDate") LocalDateTime startDate, 
                                         @Param("endDate") LocalDateTime endDate);

    @Query("SELECT COUNT(n) FROM NotificationLog n WHERE n.userId = :userId AND n.status = :status")
    Long countByUserIdAndStatus(@Param("userId") Long userId, @Param("status") String status);

    @Query("SELECT COUNT(n) FROM NotificationLog n WHERE n.status = 'SENT' AND n.sentAt >= :since")
    Long countSuccessfulNotificationsSince(@Param("since") LocalDateTime since);
} 