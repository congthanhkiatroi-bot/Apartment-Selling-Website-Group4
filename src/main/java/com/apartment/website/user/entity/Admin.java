package com.apartment.website.user.entity;

import java.time.LocalDateTime;

/**
 * Quản trị viên (users.role = 'ADMIN') -> kế thừa User. DB không có bảng admins riêng nên adminId = userId.
 * manageSystem() / manageUsers() / manageProperties() của diagram sẽ nằm ở AdminService.
 */
public class Admin extends User {
    public Admin(long userId, String username, String email, String passwordHash, LocalDateTime createdAt, boolean active) {
        super(userId, username, email, passwordHash, ROLE_ADMIN, createdAt, active);
    }

    public long getAdminId() { return getUserId(); }
}
