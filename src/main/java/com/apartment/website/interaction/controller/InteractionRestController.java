package com.apartment.website.interaction.controller;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.repository.CustomerRepository;
import com.apartment.website.interaction.dto.*;
import com.apartment.website.interaction.entity.*;
import com.apartment.website.interaction.service.InteractionService;
import com.apartment.website.property.entity.Property;
import com.apartment.website.property.service.PropertyService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/interactions")
public class InteractionRestController {

    private final InteractionService interactionService;
    private final CustomerRepository customerRepository;
    private final PropertyService propertyService;

    public InteractionRestController(
            InteractionService interactionService,
            CustomerRepository customerRepository,
            PropertyService propertyService
    ) {
        this.interactionService = interactionService;
        this.customerRepository = customerRepository;
        this.propertyService = propertyService;
    }


    // =========================================================
    // FAVORITES
    // =========================================================

    @GetMapping("/favorites/customer/{customerId}")
    public ResponseEntity<List<Favorite>>
    getFavorites(
            @PathVariable Long customerId
    ) {

        return ResponseEntity.ok(
                interactionService
                        .getFavoritesByCustomer(customerId)
        );
    }


    @GetMapping("/favorites/check")
    public ResponseEntity<Boolean>
    isFavorite(
            @RequestParam Long customerId,
            @RequestParam Long propertyId
    ) {

        return ResponseEntity.ok(
                interactionService.isFavorite(
                        customerId,
                        propertyId
                )
        );
    }


    @PostMapping("/favorites")
    public ResponseEntity<Favorite>
    addFavorite(
            @Valid
            @RequestBody FavoriteRequest request
    ) {

        Customer customer =
                getCustomer(
                        request.getCustomerId()
                );

        Property property =
                propertyService.getPropertyById(
                        request.getPropertyId()
                );

        Favorite favorite =
                interactionService.addFavorite(
                        customer,
                        property
                );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(favorite);
    }


    @DeleteMapping("/favorites")
    public ResponseEntity<Void>
    removeFavorite(
            @RequestParam Long customerId,
            @RequestParam Long propertyId
    ) {

        interactionService.removeFavorite(
                customerId,
                propertyId
        );

        return ResponseEntity.noContent().build();
    }


    // =========================================================
    // COMMENTS
    // =========================================================

    @GetMapping("/comments/property/{propertyId}")
    public ResponseEntity<List<Comment>>
    getCommentsByProperty(
            @PathVariable Long propertyId
    ) {

        return ResponseEntity.ok(
                interactionService
                        .getCommentsByProperty(propertyId)
        );
    }


    @PostMapping("/comments")
    public ResponseEntity<Comment>
    addComment(
            @Valid
            @RequestBody CommentRequest request
    ) {

        Customer customer =
                getCustomer(
                        request.getCustomerId()
                );

        Property property =
                propertyService.getPropertyById(
                        request.getPropertyId()
                );

        Comment comment =
                interactionService.addComment(
                        request.getRating(),
                        request.getContent(),
                        customer,
                        property
                );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(comment);
    }


    @PutMapping("/comments/{commentId}")
    public ResponseEntity<Comment>
    updateComment(
            @PathVariable Long commentId,

            @Valid
            @RequestBody
            CommentUpdateRequest request
    ) {

        return ResponseEntity.ok(
                interactionService.updateComment(
                        commentId,
                        request.getContent(),
                        request.getRating()
                )
        );
    }


    @DeleteMapping("/comments/{commentId}")
    public ResponseEntity<Void>
    deleteComment(
            @PathVariable Long commentId
    ) {

        interactionService.deleteComment(
                commentId
        );

        return ResponseEntity.noContent().build();
    }


    // =========================================================
    // COMPARISON
    // =========================================================

    @GetMapping("/comparisons/customer/{customerId}")
    public ResponseEntity<List<Comparison>>
    getComparisons(
            @PathVariable Long customerId
    ) {

        return ResponseEntity.ok(
                interactionService
                        .getComparisonsByCustomer(customerId)
        );
    }


    @GetMapping("/comparisons/{comparisonId}")
    public ResponseEntity<Comparison>
    getComparison(
            @PathVariable Long comparisonId
    ) {

        return ResponseEntity.ok(
                interactionService
                        .getComparisonById(comparisonId)
        );
    }


    @PostMapping("/comparisons")
    public ResponseEntity<Comparison>
    createComparison(
            @Valid
            @RequestBody ComparisonRequest request
    ) {

        Customer customer =
                getCustomer(
                        request.getCustomerId()
                );

        Comparison comparison =
                interactionService.createComparison(
                        request.getName(),
                        customer
                );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(comparison);
    }


    @PostMapping(
            "/comparisons/{comparisonId}/properties/{propertyId}"
    )
    public ResponseEntity<ComparisonItem>
    addPropertyToComparison(
            @PathVariable Long comparisonId,
            @PathVariable Long propertyId
    ) {

        Property property =
                propertyService.getPropertyById(
                        propertyId
                );

        ComparisonItem item =
                interactionService
                        .addPropertyToComparison(
                                comparisonId,
                                property
                        );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(item);
    }


    @DeleteMapping(
            "/comparisons/{comparisonId}/properties/{propertyId}"
    )
    public ResponseEntity<Void>
    removePropertyFromComparison(
            @PathVariable Long comparisonId,
            @PathVariable Long propertyId
    ) {

        interactionService
                .removePropertyFromComparison(
                        comparisonId,
                        propertyId
                );

        return ResponseEntity.noContent().build();
    }


    @DeleteMapping("/comparisons/{comparisonId}")
    public ResponseEntity<Void>
    deleteComparison(
            @PathVariable Long comparisonId
    ) {

        interactionService.deleteComparison(
                comparisonId
        );

        return ResponseEntity.noContent().build();
    }


    // =========================================================
    // SEARCH HISTORY
    // =========================================================

    @GetMapping("/search-history/customer/{customerId}")
    public ResponseEntity<List<SearchHistory>>
    getSearchHistory(
            @PathVariable Long customerId
    ) {

        return ResponseEntity.ok(
                interactionService
                        .getSearchHistory(customerId)
        );
    }


    @GetMapping(
            "/search-history/customer/{customerId}/recent"
    )
    public ResponseEntity<List<SearchHistory>>
    getRecentSearchHistory(
            @PathVariable Long customerId
    ) {

        return ResponseEntity.ok(
                interactionService
                        .getRecentSearchHistory(customerId)
        );
    }


    @PostMapping("/search-history")
    public ResponseEntity<SearchHistory>
    saveSearchHistory(
            @Valid
            @RequestBody SearchHistoryRequest request
    ) {

        Customer customer =
                getCustomer(
                        request.getCustomerId()
                );

        SearchHistory history =
                interactionService.saveSearchHistory(
                        request.getKeyword(),
                        request.getMinPrice(),
                        request.getMaxPrice(),
                        request.getMinArea(),
                        request.getMaxArea(),
                        request.getBedrooms(),
                        request.getLocation(),
                        customer
                );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(history);
    }


    @DeleteMapping(
            "/search-history/customer/{customerId}"
    )
    public ResponseEntity<Void>
    clearSearchHistory(
            @PathVariable Long customerId
    ) {

        interactionService.clearSearchHistory(
                customerId
        );

        return ResponseEntity.noContent().build();
    }


    // =========================================================
    // HELPER
    // =========================================================

    private Customer getCustomer(Long customerId) {

        if (customerId == null) {
            throw new IllegalArgumentException(
                    "Customer ID cannot be null."
            );
        }

        return customerRepository
                .findById(customerId)
                .orElseThrow(
                        () -> new IllegalArgumentException(
                                "Customer not found with ID: "
                                        + customerId
                        )
                );
    }
}