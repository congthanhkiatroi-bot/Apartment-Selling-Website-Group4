package com.apartment.website.interaction.controller;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.service.CurrentUserService;

import com.apartment.website.interaction.entity.Comment;
import com.apartment.website.interaction.entity.Comparison;
import com.apartment.website.interaction.entity.ComparisonItem;
import com.apartment.website.interaction.entity.Favorite;
import com.apartment.website.interaction.entity.SearchHistory;
import com.apartment.website.interaction.service.InteractionService;

import com.apartment.website.listing.service.PostingService;

import com.apartment.website.property.entity.Property;
import com.apartment.website.property.service.PropertyService;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customer")
public class CustomerInteractionRestController {

    private final InteractionService interactionService;
    private final PropertyService propertyService;
    private final PostingService postingService;
    private final CurrentUserService currentUserService;

    public CustomerInteractionRestController(
            InteractionService interactionService,
            PropertyService propertyService,
            PostingService postingService,
            CurrentUserService currentUserService
    ) {
        this.interactionService =
                interactionService;

        this.propertyService =
                propertyService;

        this.postingService =
                postingService;

        this.currentUserService =
                currentUserService;
    }


    // =========================================================
    // FAVORITES
    // =========================================================

    @GetMapping("/favorites")
    public List<Favorite> favorites() {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        return interactionService
                .getFavoritesByCustomer(
                        customer.getUserId()
                );
    }


    @PostMapping("/favorites/{propertyId}")
    @ResponseStatus(HttpStatus.CREATED)
    public Favorite addFavorite(
            @PathVariable Long propertyId
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        postingService
                .getPublishedPostingByPropertyId(
                        propertyId
                );

        Property property =
                propertyService
                        .getPropertyById(
                                propertyId
                        );

        if (interactionService.isFavorite(
                customer.getUserId(),
                propertyId
        )) {
            throw new IllegalStateException(
                    "Property is already in favorites."
            );
        }

        return interactionService.addFavorite(
                customer,
                property
        );
    }


    @DeleteMapping("/favorites/{propertyId}")
    public void removeFavorite(
            @PathVariable Long propertyId
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        interactionService.removeFavorite(
                customer.getUserId(),
                propertyId
        );
    }


    // =========================================================
    // COMMENTS
    // =========================================================

    @PostMapping("/properties/{propertyId}/comments")
    @ResponseStatus(HttpStatus.CREATED)
    public Comment addComment(
            @PathVariable Long propertyId,

            @RequestParam Integer rating,
            @RequestParam String content
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        postingService
                .getPublishedPostingByPropertyId(
                        propertyId
                );

        Property property =
                propertyService
                        .getPropertyById(
                                propertyId
                        );

        return interactionService.addComment(
                rating,
                content,
                customer,
                property
        );
    }


    @PutMapping("/comments/{commentId}")
    public Comment updateComment(
            @PathVariable Long commentId,

            @RequestParam Integer rating,
            @RequestParam String content
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        return interactionService
                .updateCommentByCustomer(
                        commentId,
                        content,
                        rating,
                        customer
                );
    }


    @DeleteMapping("/comments/{commentId}")
    public void deleteComment(
            @PathVariable Long commentId
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        interactionService
                .deleteCommentByCustomer(
                        commentId,
                        customer
                );
    }


    // =========================================================
    // COMPARISONS
    // =========================================================

    @GetMapping("/comparisons")
    public List<Comparison> comparisons() {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        return interactionService
                .getComparisonsByCustomer(
                        customer.getUserId()
                );
    }


    @PostMapping("/comparisons")
    @ResponseStatus(HttpStatus.CREATED)
    public Comparison createComparison(
            @RequestParam String name
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        return interactionService
                .createComparison(
                        name,
                        customer
                );
    }


    @GetMapping("/comparisons/{comparisonId}")
    public Comparison comparison(
            @PathVariable Long comparisonId
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        return interactionService
                .getComparisonOwnedBy(
                        comparisonId,
                        customer
                );
    }


    @PostMapping(
            "/comparisons/{comparisonId}/properties/{propertyId}"
    )
    @ResponseStatus(HttpStatus.CREATED)
    public ComparisonItem addToComparison(
            @PathVariable Long comparisonId,
            @PathVariable Long propertyId
    ) {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        postingService
                .getPublishedPostingByPropertyId(
                        propertyId
                );

        Property property =
                propertyService
                        .getPropertyById(
                                propertyId
                        );

        return interactionService
                .addPropertyToComparisonByCustomer(
                        comparisonId,
                        property,
                        customer
                );
    }


    @DeleteMapping(
            "/comparisons/{comparisonId}/properties/{propertyId}"
    )
    public void removeFromComparison(
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
    }


    @DeleteMapping("/comparisons/{comparisonId}")
    public void deleteComparison(
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
    }


    // =========================================================
    // SEARCH HISTORY
    // =========================================================

    @GetMapping("/search-history")
    public List<SearchHistory> searchHistory() {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        return interactionService
                .getSearchHistory(
                        customer.getUserId()
                );
    }


    @DeleteMapping("/search-history")
    public void clearSearchHistory() {

        Customer customer =
                currentUserService
                        .getCurrentCustomer();

        interactionService.clearSearchHistory(
                customer.getUserId()
        );
    }
}