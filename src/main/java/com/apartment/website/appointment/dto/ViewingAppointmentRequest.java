package com.apartment.website.appointment.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

public class ViewingAppointmentRequest {

    @NotNull(message = "Customer ID is required.")
    private Long customerId;

    @NotNull(message = "Posting ID is required.")
    private Long postingId;

    @NotNull(message = "Appointment date and time is required.")
    @Future(message = "Appointment date must be in the future.")
    private LocalDateTime appointmentDateTime;

    @NotBlank(message = "Time slot cannot be empty.")
    @Size(
            max = 50,
            message = "Time slot cannot exceed 50 characters."
    )
    private String timeSlot;

    @Size(
            max = 500,
            message = "Note cannot exceed 500 characters."
    )
    private String note;

    public ViewingAppointmentRequest() {
    }

    public Long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }

    public Long getPostingId() {
        return postingId;
    }

    public void setPostingId(Long postingId) {
        this.postingId = postingId;
    }

    public LocalDateTime getAppointmentDateTime() {
        return appointmentDateTime;
    }

    public void setAppointmentDateTime(
            LocalDateTime appointmentDateTime
    ) {
        this.appointmentDateTime = appointmentDateTime;
    }

    public String getTimeSlot() {
        return timeSlot;
    }

    public void setTimeSlot(String timeSlot) {
        this.timeSlot = timeSlot;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}