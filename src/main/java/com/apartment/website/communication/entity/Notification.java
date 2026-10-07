package com.apartment.website.communication.entity;

import com.apartment.website.auth.entity.User;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "NOTIFICATIONS")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "NOTIFICATION_ID")
    private Long notificationId;

    @Column(name = "TITLE", nullable = false, length = 150)
    private String title;

    @Column(name = "MESSAGE", nullable = false, length = 500)
    private String message;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "IS_READ", nullable = false)
    private boolean read;

    @Column(name = "READ_AT")
    private LocalDateTime readAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "TYPE", nullable = false, length = 30)
    private NotificationType type;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "USER_ID", nullable = false)
    private User user;


    // =========================================================
    // Constructors
    // =========================================================

    public Notification() {
        this.createdAt = LocalDateTime.now();
        this.read = false;
        this.type = NotificationType.SYSTEM;
    }

    public Notification(
            String title,
            String message,
            NotificationType type,
            User user
    ) {
        if (title == null || title.isBlank()) {
            throw new IllegalArgumentException(
                    "Notification title cannot be empty."
            );
        }

        if (message == null || message.isBlank()) {
            throw new IllegalArgumentException(
                    "Notification message cannot be empty."
            );
        }

        if (user == null) {
            throw new IllegalArgumentException(
                    "Notification user cannot be null."
            );
        }

        this.title = title;
        this.message = message;
        this.type = type != null
                ? type
                : NotificationType.SYSTEM;
        this.user = user;
        this.createdAt = LocalDateTime.now();
        this.read = false;
    }


    // =========================================================
    // Business methods
    // =========================================================

    public void markAsRead() {
        this.read = true;
        this.readAt = LocalDateTime.now();
    }

    public void markAsUnread() {
        this.read = false;
        this.readAt = null;
    }

    public boolean isUnread() {
        return !read;
    }


    // =========================================================
    // Getters and Setters
    // =========================================================

    public Long getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(Long notificationId) {
        this.notificationId = notificationId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isRead() {
        return read;
    }

    public void setRead(boolean read) {
        this.read = read;
    }

    public LocalDateTime getReadAt() {
        return readAt;
    }

    public void setReadAt(LocalDateTime readAt) {
        this.readAt = readAt;
    }

    public NotificationType getType() {
        return type;
    }

    public void setType(NotificationType type) {
        this.type = type;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }


    // =========================================================
    // Enum
    // =========================================================

    public enum NotificationType {
        SYSTEM,
        POSTING,
        APPOINTMENT,
        TRANSACTION,
        PAYMENT,
        COMMENT,
        VERIFICATION
    }
}