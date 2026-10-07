package com.apartment.website.appointment.service;

import com.apartment.website.appointment.entity.ViewingAppointment;
import com.apartment.website.appointment.entity.ViewingAppointment.AppointmentStatus;
import com.apartment.website.appointment.repository.ViewingAppointmentRepository;
import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.entity.Owner;
import com.apartment.website.listing.entity.Posting;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@Transactional
public class ViewingService {

    private final ViewingAppointmentRepository viewingAppointmentRepository;

    public ViewingService(
            ViewingAppointmentRepository viewingAppointmentRepository
    ) {
        this.viewingAppointmentRepository =
                viewingAppointmentRepository;
    }


    // =========================================================
    // CREATE
    // =========================================================

    public ViewingAppointment createAppointment(
            LocalDateTime appointmentDateTime,
            String timeSlot,
            String note,
            Customer customer,
            Posting posting
    ) {

        validateAppointmentInput(
                appointmentDateTime,
                timeSlot,
                customer,
                posting
        );

        if (!appointmentDateTime.isAfter(LocalDateTime.now())) {
            throw new IllegalArgumentException(
                    "Appointment date must be in the future."
            );
        }

        boolean alreadyExists =
                viewingAppointmentRepository
                        .existsByCustomerUserIdAndPostingPostingIdAndAppointmentDateTime(
                                customer.getUserId(),
                                posting.getPostingId(),
                                appointmentDateTime
                        );

        if (alreadyExists) {
            throw new IllegalStateException(
                    "Customer already has an appointment at this time for this posting."
            );
        }

        ViewingAppointment appointment =
                new ViewingAppointment(
                        appointmentDateTime,
                        timeSlot,
                        note,
                        customer,
                        posting
                );

        return viewingAppointmentRepository.save(
                appointment
        );
    }


    // =========================================================
    // READ
    // =========================================================

    @Transactional(readOnly = true)
    public ViewingAppointment getAppointmentById(
            Long appointmentId
    ) {

        validateId(appointmentId, "Appointment");

        return viewingAppointmentRepository
                .findById(appointmentId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Appointment not found with ID: "
                                        + appointmentId
                        )
                );
    }


    @Transactional(readOnly = true)
    public List<ViewingAppointment> getAllAppointments() {

        return viewingAppointmentRepository.findAll();
    }


    @Transactional(readOnly = true)
    public List<ViewingAppointment> getAppointmentsByCustomer(
            Long customerId
    ) {

        validateId(customerId, "Customer");

        return viewingAppointmentRepository
                .findByCustomerUserIdOrderByAppointmentDateTimeDesc(
                        customerId
                );
    }


    @Transactional(readOnly = true)
    public List<ViewingAppointment> getAppointmentsByPosting(
            Long postingId
    ) {

        validateId(postingId, "Posting");

        return viewingAppointmentRepository
                .findByPostingPostingIdOrderByAppointmentDateTimeAsc(
                        postingId
                );
    }


    @Transactional(readOnly = true)
    public List<ViewingAppointment> getAppointmentsByStatus(
            AppointmentStatus status
    ) {

        if (status == null) {
            throw new IllegalArgumentException(
                    "Appointment status cannot be null."
            );
        }

        return viewingAppointmentRepository
                .findByStatusOrderByAppointmentDateTimeAsc(
                        status
                );
    }


    // =========================================================
    // UPDATE
    // =========================================================

    public ViewingAppointment updateAppointment(
            Long appointmentId,
            LocalDateTime appointmentDateTime,
            String timeSlot,
            String note
    ) {

        ViewingAppointment appointment =
                getAppointmentById(appointmentId);

        if (appointmentDateTime == null) {
            throw new IllegalArgumentException(
                    "Appointment date cannot be null."
            );
        }

        if (!appointmentDateTime.isAfter(LocalDateTime.now())) {
            throw new IllegalArgumentException(
                    "Appointment date must be in the future."
            );
        }

        appointment.updateAppointment(
                appointmentDateTime,
                timeSlot,
                note
        );

        return viewingAppointmentRepository.save(
                appointment
        );
    }


    // =========================================================
    // CONFIRM
    // =========================================================

    public ViewingAppointment confirmAppointment(
            Long appointmentId
    ) {

        ViewingAppointment appointment =
                getAppointmentById(appointmentId);

        appointment.confirm();

        return viewingAppointmentRepository.save(
                appointment
        );
    }


    // =========================================================
    // COMPLETE
    // =========================================================

    public ViewingAppointment completeAppointment(
            Long appointmentId
    ) {

        ViewingAppointment appointment =
                getAppointmentById(appointmentId);

        appointment.complete();

        return viewingAppointmentRepository.save(
                appointment
        );
    }


    // =========================================================
    // CANCEL
    // =========================================================

    public ViewingAppointment cancelAppointment(
            Long appointmentId
    ) {

        ViewingAppointment appointment =
                getAppointmentById(appointmentId);

        appointment.cancel();

        return viewingAppointmentRepository.save(
                appointment
        );
    }


    // =========================================================
    // DELETE
    // =========================================================

    public void deleteAppointment(
            Long appointmentId
    ) {

        ViewingAppointment appointment =
                getAppointmentById(appointmentId);

        viewingAppointmentRepository.delete(
                appointment
        );
    }


    // =========================================================
    // VALIDATION
    // =========================================================

    private void validateAppointmentInput(
            LocalDateTime appointmentDateTime,
            String timeSlot,
            Customer customer,
            Posting posting
    ) {

        if (appointmentDateTime == null) {
            throw new IllegalArgumentException(
                    "Appointment date cannot be null."
            );
        }

        if (timeSlot == null || timeSlot.isBlank()) {
            throw new IllegalArgumentException(
                    "Time slot cannot be empty."
            );
        }

        if (customer == null
                || customer.getUserId() == null) {

            throw new IllegalArgumentException(
                    "Customer must be a persisted customer."
            );
        }

        if (posting == null
                || posting.getPostingId() == null) {

            throw new IllegalArgumentException(
                    "Posting must be a persisted posting."
            );
        }
    }


    private void validateId(
            Long id,
            String entityName
    ) {

        if (id == null) {
            throw new IllegalArgumentException(
                    entityName + " ID cannot be null."
            );
        }
    }


    // =========================================================
    // CUSTOMER OWNERSHIP
    // =========================================================

    @Transactional(readOnly = true)
    public ViewingAppointment getAppointmentOwnedByCustomer(
            Long appointmentId,
            Customer customer
    ) {

        if (customer == null
                || customer.getUserId() == null) {

            throw new IllegalArgumentException(
                    "Customer cannot be null."
            );
        }

        ViewingAppointment appointment =
                getAppointmentById(appointmentId);

        if (appointment.getCustomer() == null
                || appointment.getCustomer().getUserId() == null
                || !appointment.getCustomer()
                .getUserId()
                .equals(customer.getUserId())) {

            throw new IllegalStateException(
                    "You do not own this appointment."
            );
        }

        return appointment;
    }


    public ViewingAppointment updateAppointmentByCustomer(
            Long appointmentId,
            LocalDateTime appointmentDateTime,
            String timeSlot,
            String note,
            Customer customer
    ) {

        getAppointmentOwnedByCustomer(
                appointmentId,
                customer
        );

        return updateAppointment(
                appointmentId,
                appointmentDateTime,
                timeSlot,
                note
        );
    }


    public ViewingAppointment cancelAppointmentByCustomer(
            Long appointmentId,
            Customer customer
    ) {

        getAppointmentOwnedByCustomer(
                appointmentId,
                customer
        );

        return cancelAppointment(
                appointmentId
        );
    }


    // =========================================================
    // OWNER OWNERSHIP
    // =========================================================

    @Transactional(readOnly = true)
    public ViewingAppointment getAppointmentOwnedByOwner(
            Long appointmentId,
            Owner owner
    ) {

        if (owner == null
                || owner.getUserId() == null) {

            throw new IllegalArgumentException(
                    "Owner cannot be null."
            );
        }

        ViewingAppointment appointment =
                getAppointmentById(appointmentId);

        if (appointment.getPosting() == null
                || appointment.getPosting().getOwner() == null
                || appointment.getPosting()
                .getOwner()
                .getUserId() == null
                || !appointment.getPosting()
                .getOwner()
                .getUserId()
                .equals(owner.getUserId())) {

            throw new IllegalStateException(
                    "You do not own the posting of this appointment."
            );
        }

        return appointment;
    }


    public ViewingAppointment confirmAppointmentByOwner(
            Long appointmentId,
            Owner owner
    ) {

        getAppointmentOwnedByOwner(
                appointmentId,
                owner
        );

        return confirmAppointment(
                appointmentId
        );
    }


    public ViewingAppointment completeAppointmentByOwner(
            Long appointmentId,
            Owner owner
    ) {

        getAppointmentOwnedByOwner(
                appointmentId,
                owner
        );

        return completeAppointment(
                appointmentId
        );
    }


    public ViewingAppointment cancelAppointmentByOwner(
            Long appointmentId,
            Owner owner
    ) {

        getAppointmentOwnedByOwner(
                appointmentId,
                owner
        );

        return cancelAppointment(
                appointmentId
        );
    }
}