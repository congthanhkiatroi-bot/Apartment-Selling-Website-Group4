package com.apartment.website.user.entity;

import java.time.LocalDateTime;

/**
 * Tài khoản người dùng (bảng users). Lớp cha của Customer, Owner, Admin -> đúng mũi tên "Inheritance" trong diagram.
 * login() / logout() / updateProfile() của diagram sẽ nằm ở tầng Service (UserService) khi làm chức năng đăng nhập.
 */
public class User {
    public static final String ROLE_ADMIN = "ADMIN";
    public static final String ROLE_CUSTOMER = "CUSTOMER";
    public static final String ROLE_OWNER = "OWNER";

    private final long userId;
    private final String username;
    private final String email;
    private final String passwordHash;
    private final String role;
    private final LocalDateTime createdAt;
    private final boolean active;

    public User(long userId, String username, String email, String passwordHash, String role,
                LocalDateTime createdAt, boolean active) {
        this.userId = userId;
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
        this.createdAt = createdAt;
        this.active = active;
    }

    public long getUserId() {
        return userId;
    }

    public String getUsername() {
        return username;
    }

    public String getEmail() {
        return email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public String getRole() {
        return role;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public boolean isActive() {
        return active;
    }
}
