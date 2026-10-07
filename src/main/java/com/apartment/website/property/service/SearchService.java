package com.apartment.website.property.service;

import com.apartment.website.property.entity.Property;
import com.apartment.website.property.repository.PropertyRepository;

import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class SearchService {

    private final PropertyRepository propertyRepository;

    public SearchService(
            PropertyRepository propertyRepository
    ) {
        this.propertyRepository = propertyRepository;
    }


    // =========================================================
    // SEARCH / FILTER
    // =========================================================

    public List<Property> search(
            String city,
            String district,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Double minArea,
            Double maxArea,
            Integer bedrooms,
            Integer bathrooms,
            Property.PropertyType propertyType
    ) {

        validateRange(
                minPrice,
                maxPrice,
                minArea,
                maxArea
        );

        Specification<Property> specification =
                (root, query, criteriaBuilder) ->
                        criteriaBuilder.equal(
                                root.get("status"),
                                Property.PropertyStatus.AVAILABLE
                        );


        // CITY
        if (hasText(city)) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.equal(
                                    criteriaBuilder.lower(
                                            root.get("city")
                                    ),
                                    city.trim().toLowerCase()
                            )
            );
        }


        // DISTRICT
        if (hasText(district)) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.equal(
                                    criteriaBuilder.lower(
                                            root.get("district")
                                    ),
                                    district.trim().toLowerCase()
                            )
            );
        }


        // MIN PRICE
        if (minPrice != null) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.greaterThanOrEqualTo(
                                    root.get("price"),
                                    minPrice
                            )
            );
        }


        // MAX PRICE
        if (maxPrice != null) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.lessThanOrEqualTo(
                                    root.get("price"),
                                    maxPrice
                            )
            );
        }


        // MIN AREA
        if (minArea != null) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.greaterThanOrEqualTo(
                                    root.get("area"),
                                    minArea
                            )
            );
        }


        // MAX AREA
        if (maxArea != null) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.lessThanOrEqualTo(
                                    root.get("area"),
                                    maxArea
                            )
            );
        }


        // BEDROOMS
        if (bedrooms != null) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.equal(
                                    root.get("bedrooms"),
                                    bedrooms
                            )
            );
        }


        // BATHROOMS
        if (bathrooms != null) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.equal(
                                    root.get("bathrooms"),
                                    bathrooms
                            )
            );
        }


        // PROPERTY TYPE
        if (propertyType != null) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.equal(
                                    root.get("propertyType"),
                                    propertyType
                            )
            );
        }


        return propertyRepository.findAll(
                specification
        );
    }

    public List<Property> searchProperties(
            String keyword,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Double minArea,
            Double maxArea,
            Integer bedrooms,
            Integer bathrooms,
            String city,
            String district,
            String ward,
            Property.PropertyType propertyType
    ) {

        validateRange(
                minPrice,
                maxPrice,
                minArea,
                maxArea
        );


        // Chỉ lấy property đang AVAILABLE
        Specification<Property> specification =
                (root, query, criteriaBuilder) ->
                        criteriaBuilder.equal(
                                root.get("status"),
                                Property.PropertyStatus.AVAILABLE
                        );


        // =========================================================
        // KEYWORD
        // Tìm trong address, city, district, ward
        // =========================================================

        if (hasText(keyword)) {

            String pattern =
                    "%" + keyword.trim().toLowerCase() + "%";

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.or(

                                    criteriaBuilder.like(
                                            criteriaBuilder.lower(
                                                    root.get("address")
                                            ),
                                            pattern
                                    ),

                                    criteriaBuilder.like(
                                            criteriaBuilder.lower(
                                                    root.get("city")
                                            ),
                                            pattern
                                    ),

                                    criteriaBuilder.like(
                                            criteriaBuilder.lower(
                                                    root.get("district")
                                            ),
                                            pattern
                                    ),

                                    criteriaBuilder.like(
                                            criteriaBuilder.lower(
                                                    root.get("ward")
                                            ),
                                            pattern
                                    )
                            )
            );
        }


        // =========================================================
        // PRICE
        // =========================================================

        if (minPrice != null) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.greaterThanOrEqualTo(
                                    root.get("price"),
                                    minPrice
                            )
            );
        }


        if (maxPrice != null) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.lessThanOrEqualTo(
                                    root.get("price"),
                                    maxPrice
                            )
            );
        }


        // =========================================================
        // AREA
        // =========================================================

        if (minArea != null) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.greaterThanOrEqualTo(
                                    root.get("area"),
                                    minArea
                            )
            );
        }


        if (maxArea != null) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.lessThanOrEqualTo(
                                    root.get("area"),
                                    maxArea
                            )
            );
        }


        // =========================================================
        // BEDROOMS / BATHROOMS
        // =========================================================

        if (bedrooms != null) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.equal(
                                    root.get("bedrooms"),
                                    bedrooms
                            )
            );
        }


        if (bathrooms != null) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.equal(
                                    root.get("bathrooms"),
                                    bathrooms
                            )
            );
        }


        // =========================================================
        // CITY
        // =========================================================

        if (hasText(city)) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.equal(
                                    criteriaBuilder.lower(
                                            root.get("city")
                                    ),
                                    city.trim().toLowerCase()
                            )
            );
        }


        // =========================================================
        // DISTRICT
        // =========================================================

        if (hasText(district)) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.equal(
                                    criteriaBuilder.lower(
                                            root.get("district")
                                    ),
                                    district.trim().toLowerCase()
                            )
            );
        }


        // =========================================================
        // WARD
        // =========================================================

        if (hasText(ward)) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.equal(
                                    criteriaBuilder.lower(
                                            root.get("ward")
                                    ),
                                    ward.trim().toLowerCase()
                            )
            );
        }


        // =========================================================
        // PROPERTY TYPE
        // =========================================================

        if (propertyType != null) {

            specification = specification.and(
                    (root, query, criteriaBuilder) ->
                            criteriaBuilder.equal(
                                    root.get("propertyType"),
                                    propertyType
                            )
            );
        }


        return propertyRepository.findAll(
                specification
        );
    }

    // =========================================================
    // SIMPLE SEARCH METHODS
    // =========================================================


    public List<Property> searchByCity(String city) {

        if (!hasText(city)) {
            return propertyRepository.findByStatus(
                    Property.PropertyStatus.AVAILABLE
            );
        }

        return search(
                city,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null
        );
    }


    public List<Property> searchByPriceRange(
            BigDecimal minPrice,
            BigDecimal maxPrice
    ) {

        return search(
                null,
                null,
                minPrice,
                maxPrice,
                null,
                null,
                null,
                null,
                null
        );
    }


    public List<Property> searchByAreaRange(
            Double minArea,
            Double maxArea
    ) {

        return search(
                null,
                null,
                null,
                null,
                minArea,
                maxArea,
                null,
                null,
                null
        );
    }


    public List<Property> searchByBedrooms(
            Integer bedrooms
    ) {

        return search(
                null,
                null,
                null,
                null,
                null,
                null,
                bedrooms,
                null,
                null
        );
    }


    // =========================================================
    // VALIDATION
    // =========================================================

    private void validateRange(
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Double minArea,
            Double maxArea
    ) {

        if (minPrice != null
                && minPrice.signum() < 0) {

            throw new IllegalArgumentException(
                    "Minimum price cannot be negative."
            );
        }

        if (maxPrice != null
                && maxPrice.signum() < 0) {

            throw new IllegalArgumentException(
                    "Maximum price cannot be negative."
            );
        }

        if (minPrice != null
                && maxPrice != null
                && minPrice.compareTo(maxPrice) > 0) {

            throw new IllegalArgumentException(
                    "Minimum price cannot be greater than maximum price."
            );
        }

        if (minArea != null && minArea < 0) {

            throw new IllegalArgumentException(
                    "Minimum area cannot be negative."
            );
        }

        if (maxArea != null && maxArea < 0) {

            throw new IllegalArgumentException(
                    "Maximum area cannot be negative."
            );
        }

        if (minArea != null
                && maxArea != null
                && minArea > maxArea) {

            throw new IllegalArgumentException(
                    "Minimum area cannot be greater than maximum area."
            );
        }
    }


    private boolean hasText(String value) {

        return value != null
                && !value.isBlank();
    }
}