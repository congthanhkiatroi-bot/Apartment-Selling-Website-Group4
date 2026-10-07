package com.apartment.website.appointment.repository;

import com.apartment.website.appointment.entity.ViewingAppointment;
import com.apartment.website.appointment.entity.ViewingAppointment.AppointmentStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface ViewingAppointmentRepository
        extends JpaRepository<ViewingAppointment, Long> {

    List<ViewingAppointment>
    findByCustomerUserIdOrderByAppointmentDateTimeDesc(
            Long customerId
    );

    List<ViewingAppointment>
    findByPostingPostingIdOrderByAppointmentDateTimeAsc(
            Long postingId
    );

    List<ViewingAppointment>
    findByStatusOrderByAppointmentDateTimeAsc(
            AppointmentStatus status
    );

    boolean existsByCustomerUserIdAndPostingPostingIdAndAppointmentDateTime(
            Long customerId,
            Long postingId,
            LocalDateTime appointmentDateTime
    );
}