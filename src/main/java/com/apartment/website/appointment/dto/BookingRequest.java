package com.apartment.website.appointment.dto;

/** Dữ liệu người dùng gửi từ form đặt lịch (chưa kiểm tra). */
public class BookingRequest {
    private final long propertyId;
    private final String date;
    private final String time;
    private final String fullName;
    private final String phone;
    private final String email;
    private final String attendees;
    private final String note;

    public BookingRequest(long propertyId, String date, String time, String fullName, String phone,
                          String email, String attendees, String note) {
        this.propertyId = propertyId;
        this.date = date;
        this.time = time;
        this.fullName = fullName;
        this.phone = phone;
        this.email = email;
        this.attendees = attendees;
        this.note = note;
    }

    public long getPropertyId() {
        return propertyId;
    }

    public String getDate() {
        return date;
    }

    public String getTime() {
        return time;
    }

    public String getFullName() {
        return fullName;
    }

    public String getPhone() {
        return phone;
    }

    public String getEmail() {
        return email;
    }

    public String getAttendees() {
        return attendees;
    }

    public String getNote() {
        return note;
    }
}
