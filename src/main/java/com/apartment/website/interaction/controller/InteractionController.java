package com.apartment.website.interaction.controller;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.repository.CustomerRepository;
import com.apartment.website.interaction.entity.Comparison;
import com.apartment.website.interaction.service.InteractionService;
import com.apartment.website.property.entity.Property;
import com.apartment.website.property.service.PropertyService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/interaction")
public class InteractionController {

    private final InteractionService interactionService;
    private final CustomerRepository customerRepository;
    private final PropertyService propertyService;

    public InteractionController(
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

    @GetMapping("/favorites/{customerId}")
    public String favorites(
            @PathVariable Long customerId,
            Model model
    ) {

        model.addAttribute(
                "favorites",
                interactionService
                        .getFavoritesByCustomer(customerId)
        );

        return "interaction/favorites";
    }


    @PostMapping("/favorites/add")
    public String addFavorite(
            @RequestParam Long customerId,
            @RequestParam Long propertyId
    ) {

        Customer customer =
                getCustomer(customerId);

        Property property =
                propertyService.getPropertyById(
                        propertyId
                );

        interactionService.addFavorite(
                customer,
                property
        );

        return "redirect:/properties/" + propertyId;
    }


    @PostMapping("/favorites/remove")
    public String removeFavorite(
            @RequestParam Long customerId,
            @RequestParam Long propertyId
    ) {

        interactionService.removeFavorite(
                customerId,
                propertyId
        );

        return "redirect:/interaction/favorites/"
                + customerId;
    }


    // =========================================================
    // COMMENTS
    // =========================================================

    @PostMapping("/comments/add")
    public String addComment(
            @RequestParam Long customerId,
            @RequestParam Long propertyId,
            @RequestParam Integer rating,
            @RequestParam String content
    ) {

        Customer customer =
                getCustomer(customerId);

        Property property =
                propertyService.getPropertyById(
                        propertyId
                );

        interactionService.addComment(
                rating,
                content,
                customer,
                property
        );

        return "redirect:/properties/" + propertyId;
    }


    @PostMapping("/comments/{commentId}/update")
    public String updateComment(
            @PathVariable Long commentId,
            @RequestParam Integer rating,
            @RequestParam String content,
            @RequestParam Long propertyId
    ) {

        interactionService.updateComment(
                commentId,
                content,
                rating
        );

        return "redirect:/properties/" + propertyId;
    }


    @PostMapping("/comments/{commentId}/delete")
    public String deleteComment(
            @PathVariable Long commentId,
            @RequestParam Long propertyId
    ) {

        interactionService.deleteComment(
                commentId
        );

        return "redirect:/properties/" + propertyId;
    }


    // =========================================================
    // COMPARISONS
    // =========================================================

    @GetMapping("/comparisons/{customerId}")
    public String comparisons(
            @PathVariable Long customerId,
            Model model
    ) {

        model.addAttribute(
                "comparisons",
                interactionService
                        .getComparisonsByCustomer(customerId)
        );

        return "interaction/comparisons";
    }


    @GetMapping("/comparisons/detail/{comparisonId}")
    public String comparisonDetail(
            @PathVariable Long comparisonId,
            Model model
    ) {

        Comparison comparison =
                interactionService
                        .getComparisonById(comparisonId);

        model.addAttribute(
                "comparison",
                comparison
        );

        return "interaction/comparison-detail";
    }


    @PostMapping("/comparisons/create")
    public String createComparison(
            @RequestParam Long customerId,
            @RequestParam(required = false) String name
    ) {

        Customer customer =
                getCustomer(customerId);

        interactionService.createComparison(
                name,
                customer
        );

        return "redirect:/interaction/comparisons/"
                + customerId;
    }


    @PostMapping("/comparisons/{comparisonId}/add")
    public String addToComparison(
            @PathVariable Long comparisonId,
            @RequestParam Long propertyId
    ) {

        Property property =
                propertyService.getPropertyById(
                        propertyId
                );

        interactionService
                .addPropertyToComparison(
                        comparisonId,
                        property
                );

        return "redirect:/interaction/comparisons/detail/"
                + comparisonId;
    }


    @PostMapping("/comparisons/{comparisonId}/remove")
    public String removeFromComparison(
            @PathVariable Long comparisonId,
            @RequestParam Long propertyId
    ) {

        interactionService
                .removePropertyFromComparison(
                        comparisonId,
                        propertyId
                );

        return "redirect:/interaction/comparisons/detail/"
                + comparisonId;
    }


    @PostMapping("/comparisons/{comparisonId}/delete")
    public String deleteComparison(
            @PathVariable Long comparisonId,
            @RequestParam Long customerId
    ) {

        interactionService.deleteComparison(
                comparisonId
        );

        return "redirect:/interaction/comparisons/"
                + customerId;
    }


    // =========================================================
    // SEARCH HISTORY
    // =========================================================

    @GetMapping("/search-history/{customerId}")
    public String searchHistory(
            @PathVariable Long customerId,
            Model model
    ) {

        model.addAttribute(
                "searchHistories",
                interactionService
                        .getSearchHistory(customerId)
        );

        return "interaction/search-history";
    }


    @PostMapping("/search-history/{customerId}/clear")
    public String clearSearchHistory(
            @PathVariable Long customerId
    ) {

        interactionService.clearSearchHistory(
                customerId
        );

        return "redirect:/interaction/search-history/"
                + customerId;
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