package com.apartment.website.communication.controller;

import com.apartment.website.auth.entity.User;
import com.apartment.website.auth.repository.UserRepository;
import com.apartment.website.communication.dto.NotificationRequest;
import com.apartment.website.communication.entity.Notification;
import com.apartment.website.communication.service.NotificationService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationRestController {

    private final NotificationService notificationService;
    private final UserRepository userRepository;

    public NotificationRestController(
            NotificationService notificationService,
            UserRepository userRepository
    ) {
        this.notificationService = notificationService;
        this.userRepository = userRepository;
    }


    // =========================================================
    // GET BY ID
    // =========================================================

    @GetMapping("/{notificationId}")
    public ResponseEntity<Notification>
    getNotificationById(
            @PathVariable Long notificationId
    ) {

        return ResponseEntity.ok(
                notificationService
                        .getNotificationById(notificationId)
        );
    }


    // =========================================================
    // GET USER NOTIFICATIONS
    // =========================================================

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Notification>>
    getNotificationsByUser(
            @PathVariable Long userId
    ) {

        return ResponseEntity.ok(
                notificationService
                        .getNotificationsByUser(userId)
        );
    }


    // =========================================================
    // GET UNREAD
    // =========================================================

    @GetMapping("/user/{userId}/unread")
    public ResponseEntity<List<Notification>>
    getUnreadNotifications(
            @PathVariable Long userId
    ) {

        return ResponseEntity.ok(
                notificationService
                        .getUnreadNotifications(userId)
        );
    }


    // =========================================================
    // UNREAD COUNT
    // =========================================================

    @GetMapping("/user/{userId}/unread/count")
    public ResponseEntity<Map<String, Long>>
    countUnreadNotifications(
            @PathVariable Long userId
    ) {

        long count =
                notificationService
                        .countUnreadNotifications(userId);

        return ResponseEntity.ok(
                Map.of("unreadCount", count)
        );
    }


    // =========================================================
    // CREATE
    // =========================================================

    @PostMapping
    public ResponseEntity<Notification>
    createNotification(
            @Valid
            @RequestBody NotificationRequest request
    ) {

        User user =
                getUser(request.getUserId());

        Notification notification =
                notificationService.createNotification(
                        request.getTitle(),
                        request.getMessage(),
                        request.getType(),
                        user
                );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(notification);
    }


    // =========================================================
    // MARK READ
    // =========================================================

    @PatchMapping("/{notificationId}/read")
    public ResponseEntity<Notification>
    markAsRead(
            @PathVariable Long notificationId
    ) {

        return ResponseEntity.ok(
                notificationService
                        .markAsRead(notificationId)
        );
    }


    // =========================================================
    // MARK UNREAD
    // =========================================================

    @PatchMapping("/{notificationId}/unread")
    public ResponseEntity<Notification>
    markAsUnread(
            @PathVariable Long notificationId
    ) {

        return ResponseEntity.ok(
                notificationService
                        .markAsUnread(notificationId)
        );
    }


    // =========================================================
    // MARK ALL READ
    // =========================================================

    @PatchMapping("/user/{userId}/read-all")
    public ResponseEntity<Void>
    markAllAsRead(
            @PathVariable Long userId
    ) {

        notificationService.markAllAsRead(userId);

        return ResponseEntity.noContent().build();
    }


    // =========================================================
    // DELETE
    // =========================================================

    @DeleteMapping("/{notificationId}")
    public ResponseEntity<Void>
    deleteNotification(
            @PathVariable Long notificationId
    ) {

        notificationService
                .deleteNotification(notificationId);

        return ResponseEntity.noContent().build();
    }


    // =========================================================
    // HELPER
    // =========================================================

    private User getUser(Long userId) {

        if (userId == null) {
            throw new IllegalArgumentException(
                    "User ID cannot be null."
            );
        }

        return userRepository
                .findById(userId)
                .orElseThrow(
                        () -> new IllegalArgumentException(
                                "User not found with ID: "
                                        + userId
                        )
                );
    }
}