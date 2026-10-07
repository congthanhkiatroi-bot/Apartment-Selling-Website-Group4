package com.apartment.website.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class RegisterRequest {

    @NotBlank(message = "Username cannot be empty.")
    @Size(min = 3, max = 50,
            message = "Username must contain from 3 to 50 characters.")
    private String username;

    @NotBlank(message = "Email cannot be empty.")
    @Email(message = "Invalid email address.")
    private String email;

    @NotBlank(message = "Password cannot be empty.")
    @Size(min = 6,
            message = "Password must contain at least 6 characters.")
    private String password;

    private String phone;

    @NotBlank(message = "Role cannot be empty.")
    private String role;

    public RegisterRequest() {
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
}