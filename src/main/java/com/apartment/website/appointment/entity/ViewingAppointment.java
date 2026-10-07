package com.apartment.website.appointment.entity;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.listing.entity.Posting;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "VIEWING_APPOINTMENTS")
public class ViewingAppointment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "APPOINTMENT_ID")
    private Long appointmentId;

    @Column(name = "APPOINTMENT_DATE_TIME", nullable = false)
    private LocalDateTime appointmentDateTime;

    @Column(name = "TIME_SLOT", nullable = false, length = 50)
    private String timeSlot;

    @Column(name = "NOTE", length = 500)
    private String note;

    @Enumerated(EnumType.STRING)
    @Column(name = "STATUS", nullable = false, length = 20)
    private AppointmentStatus status;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CUSTOMER_ID", nullable = false)
    private Customer customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "POSTING_ID", nullable = false)
    private Posting posting;


    // =========================================================
    // Constructors
    // =========================================================

    public ViewingAppointment() {
        this.status = AppointmentStatus.PENDING;
        this.createdAt = LocalDateTime.now();
    }

    public ViewingAppointment(
            LocalDateTime appointmentDateTime,
            String timeSlot,
            String note,
            Customer customer,
            Posting posting
    ) {
        validateAppointmentDateTime(appointmentDateTime);
        validateTimeSlot(timeSlot);

        if (customer == null) {
            throw new IllegalArgumentException(
                    "Customer cannot be null."
            );
        }

        if (posting == null) {
            throw new IllegalArgumentException(
                    "Posting cannot be null."
            );
        }

        this.appointmentDateTime = appointmentDateTime;
        this.timeSlot = timeSlot.trim();
        this.note = normalizeNote(note);
        this.customer = customer;
        this.posting = posting;
        this.status = AppointmentStatus.PENDING;
        this.createdAt = LocalDateTime.now();
    }


    // =========================================================
    // Business methods
    // =========================================================

    public void confirm() {

        if (this.status != AppointmentStatus.PENDING) {
            throw new IllegalStateException(
                    "Only pending appointments can be confirmed."
            );
        }

        this.status = AppointmentStatus.CONFIRMED;
    }


    public void complete() {

        if (this.status != AppointmentStatus.CONFIRMED) {
            throw new IllegalStateException(
                    "Only confirmed appointments can be completed."
            );
        }

        this.status = AppointmentStatus.COMPLETED;
    }


    public void cancel() {

        if (this.status == AppointmentStatus.COMPLETED) {
            throw new IllegalStateException(
                    "Completed appointment cannot be cancelled."
            );
        }

        if (this.status == AppointmentStatus.CANCELLED) {
            throw new IllegalStateException(
                    "Appointment is already cancelled."
            );
        }

        this.status = AppointmentStatus.CANCELLED;
    }


    public void updateAppointment(
            LocalDateTime appointmentDateTime,
            String timeSlot,
            String note
    ) {

        if (this.status != AppointmentStatus.PENDING) {
            throw new IllegalStateException(
                    "Only pending appointments can be updated."
            );
        }

        validateAppointmentDateTime(appointmentDateTime);
        validateTimeSlot(timeSlot);

        this.appointmentDateTime = appointmentDateTime;
        this.timeSlot = timeSlot.trim();
        this.note = normalizeNote(note);
    }


    // =========================================================
    // Validation
    // =========================================================

    private void validateAppointmentDateTime(
            LocalDateTime appointmentDateTime
    ) {

        if (appointmentDateTime == null) {
            throw new IllegalArgumentException(
                    "Appointment date and time cannot be null."
            );
        }
    }


    private void validateTimeSlot(String timeSlot) {

        if (timeSlot == null || timeSlot.isBlank()) {
            throw new IllegalArgumentException(
                    "Time slot cannot be empty."
            );
        }

        if (timeSlot.trim().length() > 50) {
            throw new IllegalArgumentException(
                    "Time slot cannot exceed 50 characters."
            );
        }
    }


    private String normalizeNote(String note) {

        if (note == null || note.isBlank()) {
            return null;
        }

        String normalizedNote = note.trim();

        if (normalizedNote.length() > 500) {
            throw new IllegalArgumentException(
                    "Note cannot exceed 500 characters."
            );
        }

        return normalizedNote;
    }


    // =========================================================
    // Getters and Setters
    // =========================================================

    public Long getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(Long appointmentId) {
        this.appointmentId = appointmentId;
    }

    public LocalDateTime getAppointmentDateTime() {
        return appointmentDateTime;
    }

    public void setAppointmentDateTime(
            LocalDateTime appointmentDateTime
    ) {
        validateAppointmentDateTime(appointmentDateTime);
        this.appointmentDateTime = appointmentDateTime;
    }

    public String getTimeSlot() {
        return timeSlot;
    }

    public void setTimeSlot(String timeSlot) {
        validateTimeSlot(timeSlot);
        this.timeSlot = timeSlot.trim();
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = normalizeNote(note);
    }

    public AppointmentStatus getStatus() {
        return status;
    }

    public void setStatus(AppointmentStatus status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    public Posting getPosting() {
        return posting;
    }

    public void setPosting(Posting posting) {
        this.posting = posting;
    }


    // =========================================================
    // Enum
    // =========================================================

    public enum AppointmentStatus {
        PENDING,
        CONFIRMED,
        COMPLETED,
        CANCELLED
    }
}