package com.apartment.website.auth.entity;

import java.io.Serializable;

/** Thông tin người dùng lưu trong HttpSession (KHÔNG chứa mật khẩu). JSP đọc qua ${currentUser}. */
public class SessionUser implements Serializable {
    private static final long serialVersionUID = 1L;
    private final long id;
    private final String username, fullName, role;

    public SessionUser(long id, String username, String fullName, String role) {
        this.id = id; this.username = username; this.fullName = fullName; this.role = role;
    }
    public long getId() { return id; }
    public String getUsername() { return username; }
    public String getFullName() { return fullName; }
    public String getRole() { return role; }
    public boolean isOwner() { return "OWNER".equals(role); }
    public boolean isCustomer() { return "CUSTOMER".equals(role); }
    public boolean isAdmin() { return "ADMIN".equals(role); }
    public String getDisplayName() { return fullName != null && !fullName.isBlank() ? fullName : username; }
}
