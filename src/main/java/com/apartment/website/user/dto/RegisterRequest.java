package com.apartment.website.user.dto;

/**
 * Dữ liệu form đăng ký (chưa kiểm tra). Chỉ gồm các cột có trong bảng users:
 * role, full_name, phone (= username), cccd, email, password_hash (= password).
 */
public class RegisterRequest {
    private final String role;
    private final String fullName;
    private final String phone;
    private final String cccd;
    private final String email;
    private final String password;
    private final String confirmPassword;

    public RegisterRequest(String role, String fullName, String phone, String cccd, String email,
                           String password, String confirmPassword) {
        this.role = role;
        this.fullName = fullName;
        this.phone = phone;
        this.cccd = cccd;
        this.email = email;
        this.password = password;
        this.confirmPassword = confirmPassword;
    }

    public String getRole() {
        return role;
    }

    public String getFullName() {
        return fullName;
    }

    public String getPhone() {
        return phone;
    }

    public String getCccd() {
        return cccd;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getConfirmPassword() {
        return confirmPassword;
    }
}
