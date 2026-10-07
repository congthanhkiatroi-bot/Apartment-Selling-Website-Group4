package com.apartment.website.communication.dto;

import com.apartment.website.communication.entity.Notification.NotificationType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class NotificationRequest {

    @NotBlank(message = "Title is required.")
    @Size(
            max = 150,
            message = "Title cannot exceed 150 characters."
    )
    private String title;

    @NotBlank(message = "Message is required.")
    @Size(
            max = 500,
            message = "Message cannot exceed 500 characters."
    )
    private String message;

    @NotNull(message = "Notification type is required.")
    private NotificationType type;

    @NotNull(message = "User ID is required.")
    private Long userId;

    public NotificationRequest() {
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

    public NotificationType getType() {
        return type;
    }

    public void setType(NotificationType type) {
        this.type = type;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }
}