package com.apartment.website.interaction.controller;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.service.CurrentUserService;

import com.apartment.website.interaction.entity.Comparison;
import com.apartment.website.interaction.service.InteractionService;

import com.apartment.website.property.entity.Property;
import com.apartment.website.property.service.PropertyService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/customer")
public class CustomerInteractionController {

    private final InteractionService interactionService;
    private final PropertyService propertyService;
    private final CurrentUserService currentUserService;

    public CustomerInteractionController(
            InteractionService interactionService,
            PropertyService propertyService,
            CurrentUserService currentUserService
    ) {
        this.interactionService =
                interactionService;

        this.propertyService =
                propertyService;

        this.currentUserService =
                currentUserService;
    }


    // =========================================================
    // FAVORITES
    // =========================================================

    @GetMapping("/favorites")
    public String favorites(
            Model model
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        model.addAttribute(
                "favorites",
                interactionService
                        .getFavoritesByCustomer(
                                customer.getUserId()
                        )
        );

        return "customer/favorites";
    }


    @PostMapping("/favorites/{propertyId}/add")
    public String addFavorite(
            @PathVariable Long propertyId
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        Property property =
                propertyService
                        .getPropertyById(
                                propertyId
                        );

        if (!interactionService.isFavorite(
                customer.getUserId(),
                propertyId
        )) {

            interactionService.addFavorite(
                    customer,
                    property
            );
        }

        return "redirect:/postings";
    }


    @PostMapping("/favorites/{propertyId}/remove")
    public String removeFavorite(
            @PathVariable Long propertyId
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        interactionService.removeFavorite(
                customer.getUserId(),
                propertyId
        );

        return "redirect:/customer/favorites";
    }


    // =========================================================
    // COMMENTS
    // =========================================================

    @PostMapping("/properties/{propertyId}/comments")
    public String addComment(
            @PathVariable Long propertyId,

            @RequestParam Integer rating,

            @RequestParam String content
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        Property property =
                propertyService
                        .getPropertyById(
                                propertyId
                        );

        interactionService.addComment(
                rating,
                content,
                customer,
                property
        );

        return "redirect:/properties/"
                + propertyId;
    }


    @PostMapping("/comments/{commentId}/edit")
    public String updateComment(
            @PathVariable Long commentId,

            @RequestParam Integer rating,

            @RequestParam String content,

            @RequestParam Long propertyId
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        interactionService
                .updateCommentByCustomer(
                        commentId,
                        content,
                        rating,
                        customer
                );

        return "redirect:/properties/"
                + propertyId;
    }


    @PostMapping("/comments/{commentId}/delete")
    public String deleteComment(
            @PathVariable Long commentId,

            @RequestParam Long propertyId
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        interactionService
                .deleteCommentByCustomer(
                        commentId,
                        customer
                );

        return "redirect:/properties/"
                + propertyId;
    }


    // =========================================================
    // COMPARISONS
    // =========================================================

    @GetMapping("/comparisons")
    public String comparisons(
            Model model
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        model.addAttribute(
                "comparisons",
                interactionService
                        .getComparisonsByCustomer(
                                customer.getUserId()
                        )
        );

        return "customer/comparisons";
    }


    @PostMapping("/comparisons/create")
    public String createComparison(
            @RequestParam String name
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        Comparison comparison =
                interactionService
                        .createComparison(
                                name,
                                customer
                        );

        return "redirect:/customer/comparisons/"
                + comparison.getComparisonId();
    }


    @GetMapping("/comparisons/{comparisonId}")
    public String comparisonDetail(
            @PathVariable Long comparisonId,
            Model model
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        Comparison comparison =
                interactionService
                        .getComparisonOwnedBy(
                                comparisonId,
                                customer
                        );

        model.addAttribute(
                "comparison",
                comparison
        );

        return "customer/comparison-detail";
    }


    @PostMapping(
            "/comparisons/{comparisonId}/properties/{propertyId}/add"
    )
    public String addToComparison(
            @PathVariable Long comparisonId,
            @PathVariable Long propertyId
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        Property property =
                propertyService
                        .getPropertyById(
                                propertyId
                        );

        interactionService
                .addPropertyToComparisonByCustomer(
                        comparisonId,
                        property,
                        customer
                );

        return "redirect:/customer/comparisons/"
                + comparisonId;
    }


    @PostMapping(
            "/comparisons/{comparisonId}/properties/{propertyId}/remove"
    )
    public String removeFromComparison(
            @PathVariable Long comparisonId,
            @PathVariable Long propertyId
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        interactionService
                .removePropertyFromComparisonByCustomer(
                        comparisonId,
                        propertyId,
                        customer
                );

        return "redirect:/customer/comparisons/"
                + comparisonId;
    }


    @PostMapping(
            "/comparisons/{comparisonId}/delete"
    )
    public String deleteComparison(
            @PathVariable Long comparisonId
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        interactionService
                .deleteComparisonByCustomer(
                        comparisonId,
                        customer
                );

        return "redirect:/customer/comparisons";
    }


    // =========================================================
    // SEARCH HISTORY
    // =========================================================

    @GetMapping("/search-history")
    public String searchHistory(
            Model model
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        model.addAttribute(
                "searchHistory",
                interactionService
                        .getSearchHistory(
                                customer.getUserId()
                        )
        );

        return "customer/search-history";
    }


    @PostMapping("/search-history/clear")
    public String clearSearchHistory() {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        interactionService.clearSearchHistory(
                customer.getUserId()
        );

        return "redirect:/customer/search-history";
    }
}