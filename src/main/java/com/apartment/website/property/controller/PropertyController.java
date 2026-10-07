package com.apartment.website.property.controller;

import com.apartment.website.property.entity.Property;
import com.apartment.website.property.service.PropertyService;
import com.apartment.website.property.service.SearchService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@Controller
@RequestMapping("/properties")
public class PropertyController {

    private final PropertyService propertyService;
    private final SearchService searchService;

    public PropertyController(
            PropertyService propertyService,
            SearchService searchService
    ) {
        this.propertyService = propertyService;
        this.searchService = searchService;
    }


    // =========================================================
    // LIST / SEARCH
    // =========================================================

    @GetMapping
    public String properties(
            @RequestParam(required = false)
            String city,

            @RequestParam(required = false)
            String district,

            @RequestParam(required = false)
            BigDecimal minPrice,

            @RequestParam(required = false)
            BigDecimal maxPrice,

            @RequestParam(required = false)
            Double minArea,

            @RequestParam(required = false)
            Double maxArea,

            @RequestParam(required = false)
            Integer bedrooms,

            @RequestParam(required = false)
            Integer bathrooms,

            @RequestParam(required = false)
            Property.PropertyType propertyType,

            Model model
    ) {

        List<Property> properties =
                searchService.search(
                        city,
                        district,
                        minPrice,
                        maxPrice,
                        minArea,
                        maxArea,
                        bedrooms,
                        bathrooms,
                        propertyType
                );

        model.addAttribute(
                "properties",
                properties
        );

        model.addAttribute(
                "propertyTypes",
                Property.PropertyType.values()
        );

        model.addAttribute("city", city);
        model.addAttribute("district", district);
        model.addAttribute("minPrice", minPrice);
        model.addAttribute("maxPrice", maxPrice);
        model.addAttribute("minArea", minArea);
        model.addAttribute("maxArea", maxArea);
        model.addAttribute("bedrooms", bedrooms);
        model.addAttribute("bathrooms", bathrooms);
        model.addAttribute("propertyType", propertyType);

        return "property/list";
    }


    // =========================================================
    // DETAIL
    // =========================================================

    @GetMapping("/{propertyId}")
    public String detail(
            @PathVariable Long propertyId,
            Model model
    ) {

        Property property =
                propertyService.getPropertyById(
                        propertyId
                );

        model.addAttribute(
                "property",
                property
        );

        return "property/detail";
    }
}