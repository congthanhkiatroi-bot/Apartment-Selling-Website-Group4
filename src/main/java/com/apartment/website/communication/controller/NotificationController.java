package com.apartment.website.communication.controller;

import com.apartment.website.auth.entity.User;
import com.apartment.website.auth.repository.UserRepository;
import com.apartment.website.communication.entity.Notification.NotificationType;
import com.apartment.website.communication.service.NotificationService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/notifications")
public class NotificationController {

    private final NotificationService notificationService;
    private final UserRepository userRepository;

    public NotificationController(
            NotificationService notificationService,
            UserRepository userRepository
    ) {
        this.notificationService = notificationService;
        this.userRepository = userRepository;
    }


    // =========================================================
    // USER NOTIFICATIONS
    // =========================================================

    @GetMapping("/user/{userId}")
    public String userNotifications(
            @PathVariable Long userId,
            Model model
    ) {

        model.addAttribute(
                "notifications",
                notificationService
                        .getNotificationsByUser(userId)
        );

        model.addAttribute(
                "unreadCount",
                notificationService
                        .countUnreadNotifications(userId)
        );

        model.addAttribute(
                "userId",
                userId
        );

        return "communication/notifications";
    }


    // =========================================================
    // UNREAD NOTIFICATIONS
    // =========================================================

    @GetMapping("/user/{userId}/unread")
    public String unreadNotifications(
            @PathVariable Long userId,
            Model model
    ) {

        model.addAttribute(
                "notifications",
                notificationService
                        .getUnreadNotifications(userId)
        );

        model.addAttribute(
                "unreadCount",
                notificationService
                        .countUnreadNotifications(userId)
        );

        model.addAttribute(
                "userId",
                userId
        );

        return "communication/notifications";
    }


    // =========================================================
    // CREATE
    // =========================================================

    @PostMapping("/create")
    public String createNotification(
            @RequestParam String title,
            @RequestParam String message,
            @RequestParam NotificationType type,
            @RequestParam Long userId
    ) {

        User user = getUser(userId);

        notificationService.createNotification(
                title,
                message,
                type,
                user
        );

        return "redirect:/notifications/user/"
                + userId;
    }


    // =========================================================
    // MARK AS READ
    // =========================================================

    @PostMapping("/{notificationId}/read")
    public String markAsRead(
            @PathVariable Long notificationId,
            @RequestParam Long userId
    ) {

        notificationService.markAsRead(
                notificationId
        );

        return "redirect:/notifications/user/"
                + userId;
    }


    // =========================================================
    // MARK AS UNREAD
    // =========================================================

    @PostMapping("/{notificationId}/unread")
    public String markAsUnread(
            @PathVariable Long notificationId,
            @RequestParam Long userId
    ) {

        notificationService.markAsUnread(
                notificationId
        );

        return "redirect:/notifications/user/"
                + userId;
    }


    // =========================================================
    // MARK ALL AS READ
    // =========================================================

    @PostMapping("/user/{userId}/read-all")
    public String markAllAsRead(
            @PathVariable Long userId
    ) {

        notificationService.markAllAsRead(
                userId
        );

        return "redirect:/notifications/user/"
                + userId;
    }


    // =========================================================
    // DELETE
    // =========================================================

    @PostMapping("/{notificationId}/delete")
    public String deleteNotification(
            @PathVariable Long notificationId,
            @RequestParam Long userId
    ) {

        notificationService.deleteNotification(
                notificationId
        );

        return "redirect:/notifications/user/"
                + userId;
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