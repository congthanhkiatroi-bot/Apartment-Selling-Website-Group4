package com.apartment.website.appointment.controller;

import com.apartment.website.appointment.entity.ViewingAppointment;
import com.apartment.website.appointment.service.ViewingService;

import com.apartment.website.auth.entity.Owner;
import com.apartment.website.auth.service.CurrentUserService;

import com.apartment.website.listing.service.PostingService;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/owner/appointments")
public class OwnerViewingRestController {

    private final ViewingService viewingService;
    private final PostingService postingService;
    private final CurrentUserService currentUserService;

    public OwnerViewingRestController(
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


    @GetMapping("/posting/{postingId}")
    public List<ViewingAppointment> byPosting(
            @PathVariable Long postingId
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        postingService.getPostingOwnedBy(
                postingId,
                owner
        );

        return viewingService
                .getAppointmentsByPosting(
                        postingId
                );
    }


    @GetMapping("/{appointmentId}")
    public ViewingAppointment appointment(
            @PathVariable Long appointmentId
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        return viewingService
                .getAppointmentOwnedByOwner(
                        appointmentId,
                        owner
                );
    }


    @PatchMapping("/{appointmentId}/confirm")
    public ViewingAppointment confirm(
            @PathVariable Long appointmentId
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        return viewingService
                .confirmAppointmentByOwner(
                        appointmentId,
                        owner
                );
    }


    @PatchMapping("/{appointmentId}/complete")
    public ViewingAppointment complete(
            @PathVariable Long appointmentId
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        return viewingService
                .completeAppointmentByOwner(
                        appointmentId,
                        owner
                );
    }


    @PatchMapping("/{appointmentId}/cancel")
    public ViewingAppointment cancel(
            @PathVariable Long appointmentId
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        return viewingService
                .cancelAppointmentByOwner(
                        appointmentId,
                        owner
                );
    }
}