package com.apartment.website.communication.repository;

import com.apartment.website.communication.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository
        extends JpaRepository<Notification, Long> {

    List<Notification> findByUserUserIdOrderByCreatedAtDesc(
            Long userId
    );

    List<Notification> findByUserUserIdAndReadFalseOrderByCreatedAtDesc(
            Long userId
    );

    long countByUserUserIdAndReadFalse(Long userId);
}