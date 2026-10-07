package com.apartment.website.property.controller;

import com.apartment.website.property.entity.Property;
import com.apartment.website.property.service.SearchService;

import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/search")
public class SearchRestController {

    private final SearchService searchService;

    public SearchRestController(
            SearchService searchService
    ) {
        this.searchService = searchService;
    }


    @GetMapping
    public List<Property> search(
            @RequestParam(required = false)
            String keyword,

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
            String city,

            @RequestParam(required = false)
            String district,

            @RequestParam(required = false)
            String ward,

            @RequestParam(required = false)
            Property.PropertyType propertyType
    ) {

        return searchService.searchProperties(
                keyword,
                minPrice,
                maxPrice,
                minArea,
                maxArea,
                bedrooms,
                bathrooms,
                city,
                district,
                ward,
                propertyType
        );
    }
}