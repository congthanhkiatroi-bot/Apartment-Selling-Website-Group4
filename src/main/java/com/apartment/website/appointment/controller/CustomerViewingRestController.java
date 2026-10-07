package com.apartment.website.appointment.controller;

import com.apartment.website.appointment.dto.CustomerViewingRequest;
import com.apartment.website.appointment.dto.ViewingAppointmentUpdateRequest;
import com.apartment.website.appointment.entity.ViewingAppointment;
import com.apartment.website.appointment.service.ViewingService;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.service.CurrentUserService;

import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.service.PostingService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customer/appointments")
public class CustomerViewingRestController {

    private final ViewingService viewingService;
    private final PostingService postingService;
    private final CurrentUserService currentUserService;


    // =========================================================
    // CONSTRUCTOR
    // =========================================================

    public CustomerViewingRestController(
            ViewingService viewingService,
            PostingService postingService,
            CurrentUserService currentUserService
    ) {
        this.viewingService = viewingService;
        this.postingService = postingService;
        this.currentUserService = currentUserService;
    }


    // =========================================================
    // GET MY APPOINTMENTS
    // =========================================================

    @GetMapping
    public List<ViewingAppointment> getMyAppointments() {

        Customer customer =
                currentUserService.getCurrentCustomer();

        return viewingService.getAppointmentsByCustomer(
                customer.getUserId()
        );
    }


    // =========================================================
    // GET MY APPOINTMENT BY ID
    // =========================================================

    @GetMapping("/{appointmentId}")
    public ViewingAppointment getAppointment(
            @PathVariable Long appointmentId
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer();

        return viewingService.getAppointmentOwnedByCustomer(
                appointmentId,
                customer
        );
    }


    // =========================================================
    // CREATE APPOINTMENT
    // =========================================================

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ViewingAppointment createAppointment(
            @Valid
            @RequestBody
            CustomerViewingRequest request
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer();

        /*
         * Chỉ cho phép đặt lịch đối với Posting
         * đang được công khai.
         */
        Posting posting =
                postingService.getPublishedPostingById(
                        request.getPostingId()
                );

        return viewingService.createAppointment(
                request.getAppointmentDateTime(),
                request.getTimeSlot(),
                request.getNote(),
                customer,
                posting
        );
    }


    // =========================================================
    // UPDATE APPOINTMENT
    // =========================================================

    @PutMapping("/{appointmentId}")
    public ViewingAppointment updateAppointment(
            @PathVariable Long appointmentId,

            @Valid
            @RequestBody
            ViewingAppointmentUpdateRequest request
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer();

        return viewingService.updateAppointmentByCustomer(
                appointmentId,
                request.getAppointmentDateTime(),
                request.getTimeSlot(),
                request.getNote(),
                customer
        );
    }


    // =========================================================
    // CANCEL APPOINTMENT
    // =========================================================

    @PatchMapping("/{appointmentId}/cancel")
    public ViewingAppointment cancelAppointment(
            @PathVariable Long appointmentId
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer();

        return viewingService.cancelAppointmentByCustomer(
                appointmentId,
                customer
        );
    }
}