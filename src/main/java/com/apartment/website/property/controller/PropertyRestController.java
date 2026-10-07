package com.apartment.website.property.controller;

import com.apartment.website.property.dto.PropertyRequest;
import com.apartment.website.property.entity.Property;
import com.apartment.website.property.service.PropertyService;
import com.apartment.website.property.service.SearchService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/properties")
public class PropertyRestController {

    private final PropertyService propertyService;
    private final SearchService searchService;

    public PropertyRestController(
            PropertyService propertyService,
            SearchService searchService
    ) {
        this.propertyService = propertyService;
        this.searchService = searchService;
    }


    // =========================================================
    // SEARCH
    // =========================================================

    @GetMapping
    public ResponseEntity<List<Property>> search(
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
            Property.PropertyType propertyType
    ) {

        return ResponseEntity.ok(
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
                )
        );
    }


    // =========================================================
    // DETAIL
    // =========================================================

    @GetMapping("/{propertyId}")
    public ResponseEntity<Property> getById(
            @PathVariable Long propertyId
    ) {

        return ResponseEntity.ok(
                propertyService.getPropertyById(
                        propertyId
                )
        );
    }


    // =========================================================
    // CREATE
    // =========================================================

    @PostMapping
    public ResponseEntity<Property> create(
            @Valid @RequestBody PropertyRequest request
    ) {

        Property property =
                propertyService.createProperty(
                        request.toEntity()
                );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(property);
    }


    // =========================================================
    // UPDATE
    // =========================================================

    @PutMapping("/{propertyId}")
    public ResponseEntity<Property> update(
            @PathVariable Long propertyId,
            @Valid @RequestBody PropertyRequest request
    ) {

        return ResponseEntity.ok(
                propertyService.updateProperty(
                        propertyId,
                        request.toEntity()
                )
        );
    }


    // =========================================================
    // DELETE
    // =========================================================

    @DeleteMapping("/{propertyId}")
    public ResponseEntity<Void> delete(
            @PathVariable Long propertyId
    ) {

        propertyService.deleteProperty(
                propertyId
        );

        return ResponseEntity.noContent().build();
    }
}