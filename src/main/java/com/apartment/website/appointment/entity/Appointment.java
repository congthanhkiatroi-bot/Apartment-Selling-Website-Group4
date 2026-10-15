package com.apartment.website.appointment.entity;

import java.time.LocalDate;

/** Một lịch hẹn xem nhà (bảng viewing_appointments). */
public class Appointment {
    private final long id;
    private final long propertyId;
    private final String fullName;
    private final String phone;
    private final String email;
    private final int attendees;
    private final String note;
    private final LocalDate date;
    private final String timeSlot;
    private final String status;

    public Appointment(long id, long propertyId, String fullName, String phone, String email, int attendees,
                       String note, LocalDate date, String timeSlot, String status) {
        this.id = id;
        this.propertyId = propertyId;
        this.fullName = fullName;
        this.phone = phone;
        this.email = email;
        this.attendees = attendees;
        this.note = note;
        this.date = date;
        this.timeSlot = timeSlot;
        this.status = status;
    }

    public long getId() {
        return id;
    }

    public long getPropertyId() {
        return propertyId;
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

    public int getAttendees() {
        return attendees;
    }

    public String getNote() {
        return note;
    }

    public LocalDate getDate() {
        return date;
    }

    public String getTimeSlot() {
        return timeSlot;
    }

    public String getStatus() {
        return status;
    }
}
