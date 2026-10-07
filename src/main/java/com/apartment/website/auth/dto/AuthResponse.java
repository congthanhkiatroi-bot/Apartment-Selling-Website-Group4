package com.apartment.website.auth.dto;

public class AuthResponse {

    private boolean success;
    private String message;
    private Long userId;
    private String username;
    private String email;
    private String role;

    public AuthResponse() {
    }

    public AuthResponse(
            boolean success,
            String message,
            Long userId,
            String username,
            String email,
            String role
    ) {
        this.success = success;
        this.message = message;
        this.userId = userId;
        this.username = username;
        this.email = email;
        this.role = role;
    }

    public static AuthResponse success(
            String message,
            Long userId,
            String username,
            String email,
            String role
    ) {
        return new AuthResponse(
                true,
                message,
                userId,
                username,
                email,
                role
        );
    }

    public static AuthResponse error(String message) {
        return new AuthResponse(
                false,
                message,
                null,
                null,
                null,
                null
        );
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
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

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
}