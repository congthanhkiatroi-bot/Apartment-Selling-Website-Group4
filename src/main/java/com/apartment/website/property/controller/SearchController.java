package com.apartment.website.property.controller;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.entity.User;
import com.apartment.website.auth.service.CurrentUserService;
import com.apartment.website.interaction.service.InteractionService;
import com.apartment.website.property.dto.PropertySearchRequest;
import com.apartment.website.property.entity.Property;
import com.apartment.website.property.service.SearchService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Controller
@RequestMapping("/search")
public class SearchController {

    private final SearchService searchService;
    private final InteractionService interactionService;
    private final CurrentUserService currentUserService;

    public SearchController(
            SearchService searchService,
            InteractionService interactionService,
            CurrentUserService currentUserService
    ) {
        this.searchService = searchService;
        this.interactionService = interactionService;
        this.currentUserService = currentUserService;
    }

    // =========================================================
    // SEARCH PAGE + RESULTS
    // =========================================================

    @GetMapping
    public String search(
            @ModelAttribute("search") PropertySearchRequest request,
            Model model
    ) {
        List<Property> properties = searchService.searchProperties(
                request.getKeyword(),
                request.getMinPrice(),
                request.getMaxPrice(),
                request.getMinArea(),
                request.getMaxArea(),
                request.getBedrooms(),
                request.getBathrooms(),
                request.getCity(),
                request.getDistrict(),
                request.getWard(),
                request.getPropertyType()
        );

        if (currentUserService.isAuthenticated()) {
            User currentUser = currentUserService.getCurrentUser();

            if (currentUser instanceof Customer customer) {
                String location = buildLocation(request);

                interactionService.saveSearchHistory(
                        request.getKeyword(),
                        request.getMinPrice(),
                        request.getMaxPrice(),
                        request.getMinArea(),
                        request.getMaxArea(),
                        request.getBedrooms(),
                        location,
                        customer
                );
            }
        }

        model.addAttribute("properties", properties);
        model.addAttribute("propertyTypes", Property.PropertyType.values());
        model.addAttribute("resultCount", properties.size());

        return "property/search";
    }

    // =========================================================
    // HELPER METHODS
    // =========================================================

    private String buildLocation(PropertySearchRequest request) {
        if (request == null) {
            return null;
        }

        String location = Stream.of(request.getWard(), request.getDistrict(), request.getCity())
                .filter(Objects::nonNull)
                .map(String::trim)
                .filter(s -> !s.isBlank())
                .collect(Collectors.joining(", "));

        return location.isEmpty() ? null : location;
    }
}