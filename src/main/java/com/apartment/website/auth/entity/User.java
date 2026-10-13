package com.apartment.website.auth.entity;

/** Một dòng trong bảng users (dùng khi đăng nhập). */
public class User {
    private final long id;
    private final String username, email, passwordHash, role, fullName;
    private final boolean active;

    public User(long id, String username, String email, String passwordHash, String role, String fullName, boolean active) {
        this.id = id; this.username = username; this.email = email;
        this.passwordHash = passwordHash; this.role = role; this.fullName = fullName; this.active = active;
    }
    public long getId() { return id; }
    public String getUsername() { return username; }
    public String getEmail() { return email; }
    public String getPasswordHash() { return passwordHash; }
    public String getRole() { return role; }
    public String getFullName() { return fullName; }
    public boolean isActive() { return active; }
}
