package com.apartment.website.appointment.dto;

/** Dữ liệu người dùng gửi từ form đặt lịch (chưa kiểm tra). */
public record BookingRequest(long propertyId, String date, String time, String fullName, String phone,
                             String email, String attendees, String note) {}
