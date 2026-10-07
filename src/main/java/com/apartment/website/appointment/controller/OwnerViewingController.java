package com.apartment.website.appointment.controller;

import com.apartment.website.appointment.entity.ViewingAppointment;
import com.apartment.website.appointment.service.ViewingService;

import com.apartment.website.auth.entity.Owner;
import com.apartment.website.auth.service.CurrentUserService;

import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.service.PostingService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/owner/appointments")
public class OwnerViewingController {

    private final ViewingService viewingService;
    private final PostingService postingService;
    private final CurrentUserService currentUserService;

    public OwnerViewingController(
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
    // APPOINTMENTS OF A POSTING
    // =========================================================

    @GetMapping("/posting/{postingId}")
    public String appointmentsByPosting(
            @PathVariable Long postingId,
            Model model
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        Posting posting =
                postingService
                        .getPostingOwnedBy(
                                postingId,
                                owner
                        );

        model.addAttribute(
                "posting",
                posting
        );

        model.addAttribute(
                "appointments",
                viewingService
                        .getAppointmentsByPosting(
                                postingId
                        )
        );

        return "owner/appointments";
    }


    // =========================================================
    // DETAIL
    // =========================================================

    @GetMapping("/{appointmentId}")
    public String detail(
            @PathVariable Long appointmentId,
            Model model
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        ViewingAppointment appointment =
                viewingService
                        .getAppointmentOwnedByOwner(
                                appointmentId,
                                owner
                        );

        model.addAttribute(
                "appointment",
                appointment
        );

        return "owner/appointment-detail";
    }


    // =========================================================
    // CONFIRM
    // =========================================================

    @PostMapping("/{appointmentId}/confirm")
    public String confirm(
            @PathVariable Long appointmentId
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        ViewingAppointment appointment =
                viewingService
                        .confirmAppointmentByOwner(
                                appointmentId,
                                owner
                        );

        return "redirect:/owner/appointments/"
                + appointment.getAppointmentId();
    }


    // =========================================================
    // COMPLETE
    // =========================================================

    @PostMapping("/{appointmentId}/complete")
    public String complete(
            @PathVariable Long appointmentId
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        ViewingAppointment appointment =
                viewingService
                        .completeAppointmentByOwner(
                                appointmentId,
                                owner
                        );

        return "redirect:/owner/appointments/"
                + appointment.getAppointmentId();
    }


    // =========================================================
    // CANCEL
    // =========================================================

    @PostMapping("/{appointmentId}/cancel")
    public String cancel(
            @PathVariable Long appointmentId
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        ViewingAppointment appointment =
                viewingService
                        .cancelAppointmentByOwner(
                                appointmentId,
                                owner
                        );

        return "redirect:/owner/appointments/"
                + appointment.getAppointmentId();
    }
}