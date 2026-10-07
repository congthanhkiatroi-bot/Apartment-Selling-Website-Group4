package com.apartment.website.appointment.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

public class CustomerViewingRequest {

    @NotNull
    private Long postingId;

    @NotNull
    @Future
    private LocalDateTime appointmentDateTime;

    @NotBlank
    @Size(max = 50)
    private String timeSlot;

    @Size(max = 500)
    private String note;


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
        this.appointmentDateTime =
                appointmentDateTime;
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