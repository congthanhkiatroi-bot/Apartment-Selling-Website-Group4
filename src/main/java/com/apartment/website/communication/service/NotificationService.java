package com.apartment.website.communication.service;

import com.apartment.website.auth.entity.User;
import com.apartment.website.communication.entity.Notification;
import com.apartment.website.communication.entity.Notification.NotificationType;
import com.apartment.website.communication.repository.NotificationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class NotificationService {

    private final NotificationRepository notificationRepository;

    public NotificationService(
            NotificationRepository notificationRepository
    ) {
        this.notificationRepository = notificationRepository;
    }


    // =========================================================
    // CREATE
    // =========================================================

    public Notification createNotification(
            String title,
            String message,
            NotificationType type,
            User user
    ) {

        if (user == null || user.getUserId() == null) {
            throw new IllegalArgumentException(
                    "Notification user cannot be null."
            );
        }

        Notification notification = new Notification(
                title,
                message,
                type,
                user
        );

        return notificationRepository.save(notification);
    }


    // =========================================================
    // READ
    // =========================================================

    @Transactional(readOnly = true)
    public Notification getNotificationById(
            Long notificationId
    ) {

        if (notificationId == null) {
            throw new IllegalArgumentException(
                    "Notification ID cannot be null."
            );
        }

        return notificationRepository
                .findById(notificationId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Notification not found with ID: "
                                        + notificationId
                        )
                );
    }


    @Transactional(readOnly = true)
    public List<Notification> getNotificationsByUser(
            Long userId
    ) {

        validateUserId(userId);

        return notificationRepository
                .findByUserUserIdOrderByCreatedAtDesc(
                        userId
                );
    }


    @Transactional(readOnly = true)
    public List<Notification> getUnreadNotifications(
            Long userId
    ) {

        validateUserId(userId);

        return notificationRepository
                .findByUserUserIdAndReadFalseOrderByCreatedAtDesc(
                        userId
                );
    }


    @Transactional(readOnly = true)
    public long countUnreadNotifications(
            Long userId
    ) {

        validateUserId(userId);

        return notificationRepository
                .countByUserUserIdAndReadFalse(userId);
    }


    // =========================================================
    // MARK AS READ
    // =========================================================

    public Notification markAsRead(
            Long notificationId
    ) {

        Notification notification =
                getNotificationById(notificationId);

        notification.markAsRead();

        return notificationRepository.save(notification);
    }


    // =========================================================
    // MARK AS UNREAD
    // =========================================================

    public Notification markAsUnread(
            Long notificationId
    ) {

        Notification notification =
                getNotificationById(notificationId);

        notification.markAsUnread();

        return notificationRepository.save(notification);
    }


    // =========================================================
    // MARK ALL AS READ
    // =========================================================

    public void markAllAsRead(Long userId) {

        validateUserId(userId);

        List<Notification> unreadNotifications =
                notificationRepository
                        .findByUserUserIdAndReadFalseOrderByCreatedAtDesc(
                                userId
                        );

        for (Notification notification : unreadNotifications) {
            notification.markAsRead();
        }

        notificationRepository.saveAll(
                unreadNotifications
        );
    }


    // =========================================================
    // DELETE
    // =========================================================

    public void deleteNotification(
            Long notificationId
    ) {

        Notification notification =
                getNotificationById(notificationId);

        notificationRepository.delete(notification);
    }


    // =========================================================
    // VALIDATION
    // =========================================================

    private void validateUserId(Long userId) {

        if (userId == null) {
            throw new IllegalArgumentException(
                    "User ID cannot be null."
            );
        }
    }
}