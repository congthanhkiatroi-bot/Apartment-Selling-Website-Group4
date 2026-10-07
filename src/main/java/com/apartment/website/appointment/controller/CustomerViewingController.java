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

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/customer/appointments")
public class CustomerViewingController {

    private final ViewingService viewingService;
    private final PostingService postingService;
    private final CurrentUserService currentUserService;

    public CustomerViewingController(
            ViewingService viewingService,
            PostingService postingService,
            CurrentUserService currentUserService
    ) {
        this.viewingService =
                viewingService;

        this.postingService =
                postingService;

        this.currentUserService =
                currentUserService;
    }


    // =========================================================
    // MY APPOINTMENTS
    // =========================================================

    @GetMapping
    public String appointments(
            Model model
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        model.addAttribute(
                "appointments",
                viewingService
                        .getAppointmentsByCustomer(
                                customer.getUserId()
                        )
        );

        return "customer/appointments";
    }


    // =========================================================
    // DETAIL
    // =========================================================

    @GetMapping("/{appointmentId}")
    public String detail(
            @PathVariable Long appointmentId,
            Model model
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        ViewingAppointment appointment =
                viewingService
                        .getAppointmentOwnedByCustomer(
                                appointmentId,
                                customer
                        );

        model.addAttribute(
                "appointment",
                appointment
        );

        return "customer/appointment-detail";
    }


    // =========================================================
    // CREATE FORM
    // =========================================================

    @GetMapping("/create/{postingId}")
    public String createForm(
            @PathVariable Long postingId,
            Model model
    ) {

        Posting posting =
                postingService
                        .getPublishedPostingById(
                                postingId
                        );

        CustomerViewingRequest request =
                new CustomerViewingRequest();

        request.setPostingId(
                postingId
        );

        model.addAttribute(
                "viewingRequest",
                request
        );

        model.addAttribute(
                "posting",
                posting
        );

        return "customer/appointment-form";
    }


    // =========================================================
    // CREATE
    // =========================================================

    @PostMapping("/create")
    public String create(
            @Valid
            @ModelAttribute("viewingRequest")
            CustomerViewingRequest request,

            BindingResult bindingResult,

            Model model
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        Posting posting =
                postingService
                        .getPublishedPostingById(
                                request.getPostingId()
                        );

        if (bindingResult.hasErrors()) {

            model.addAttribute(
                    "posting",
                    posting
            );

            return "customer/appointment-form";
        }

        ViewingAppointment appointment =
                viewingService.createAppointment(
                        request.getAppointmentDateTime(),
                        request.getTimeSlot(),
                        request.getNote(),
                        customer,
                        posting
                );

        return "redirect:/customer/appointments/"
                + appointment.getAppointmentId();
    }


    // =========================================================
    // UPDATE
    // =========================================================

    @PostMapping("/{appointmentId}/update")
    public String update(
            @PathVariable Long appointmentId,

            @Valid
            @ModelAttribute("viewingRequest")
            ViewingAppointmentUpdateRequest request,

            BindingResult bindingResult,

            Model model
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        ViewingAppointment appointment =
                viewingService
                        .getAppointmentOwnedByCustomer(
                                appointmentId,
                                customer
                        );

        if (bindingResult.hasErrors()) {

            model.addAttribute(
                    "appointment",
                    appointment
            );

            return "customer/appointment-detail";
        }

        viewingService
                .updateAppointmentByCustomer(
                        appointmentId,
                        request.getAppointmentDateTime(),
                        request.getTimeSlot(),
                        request.getNote(),
                        customer
                );

        return "redirect:/customer/appointments/"
                + appointmentId;
    }


    // =========================================================
    // CANCEL
    // =========================================================

    @PostMapping("/{appointmentId}/cancel")
    public String cancel(
            @PathVariable Long appointmentId
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        viewingService
                .cancelAppointmentByCustomer(
                        appointmentId,
                        customer
                );

        return "redirect:/customer/appointments/"
                + appointmentId;
    }
}