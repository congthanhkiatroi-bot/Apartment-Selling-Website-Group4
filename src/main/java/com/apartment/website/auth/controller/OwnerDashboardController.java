package com.apartment.website.auth.controller;

import com.apartment.website.auth.entity.Owner;
import com.apartment.website.auth.service.CurrentUserService;
import com.apartment.website.listing.service.PostingService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/owner")
public class OwnerDashboardController {

    private final CurrentUserService currentUserService;
    private final PostingService postingService;

    public OwnerDashboardController(
            CurrentUserService currentUserService,
            PostingService postingService
    ) {
        this.currentUserService =
                currentUserService;

        this.postingService =
                postingService;
    }


    // =========================================================
    // OWNER DASHBOARD
    // =========================================================

    @GetMapping("/dashboard")
    public String dashboard(
            Model model
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        model.addAttribute(
                "owner",
                owner
        );

        model.addAttribute(
                "postings",
                postingService
                        .getPostingsByOwner(owner)
        );

        return "owner/dashboard";
    }
}