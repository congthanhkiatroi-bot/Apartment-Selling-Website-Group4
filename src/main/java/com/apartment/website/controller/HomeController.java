package com.apartment.website.controller;

import com.apartment.website.property.service.PropertyService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    private final PropertyService propertyService;

    public HomeController(PropertyService propertyService) {
        this.propertyService = propertyService;
    }

    @GetMapping("/")
    public String home(Model model) {

        // =========================
        // Hero section
        // =========================

        model.addAttribute(
                "heroTitle",
                "Find Your Perfect Apartment"
        );

        model.addAttribute(
                "heroSubtitle",
                "Discover apartments that match your lifestyle and budget."
        );


        // =========================
        // Property data from Database
        // =========================

        model.addAttribute(
                "featuredProperties",
                propertyService.getAvailableProperties()
        );


        // =========================
        // Temporary UI data
        // =========================

        model.addAttribute(
                "services",
                java.util.List.of()
        );

        model.addAttribute(
                "notifications",
                java.util.List.of()
        );


        return "home";
    }
}