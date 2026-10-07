package com.apartment.website.interaction.entity;

import com.apartment.website.auth.entity.Customer;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "SEARCH_HISTORIES")
public class SearchHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "SEARCH_HISTORY_ID")
    private Long searchHistoryId;

    @Column(name = "KEYWORD", length = 255)
    private String keyword;

    @Column(name = "MIN_PRICE", precision = 15, scale = 2)
    private BigDecimal minPrice;

    @Column(name = "MAX_PRICE", precision = 15, scale = 2)
    private BigDecimal maxPrice;

    @Column(name = "MIN_AREA")
    private Double minArea;

    @Column(name = "MAX_AREA")
    private Double maxArea;

    @Column(name = "BEDROOMS")
    private Integer bedrooms;

    @Column(name = "LOCATION", length = 255)
    private String location;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CUSTOMER_ID", nullable = false)
    private Customer customer;


    // =========================================================
    // Constructors
    // =========================================================

    public SearchHistory() {
        this.createdAt = LocalDateTime.now();
    }

    public SearchHistory(
            String keyword,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Double minArea,
            Double maxArea,
            Integer bedrooms,
            String location,
            Customer customer
    ) {
        validateRanges(
                minPrice,
                maxPrice,
                minArea,
                maxArea
        );

        if (customer == null) {
            throw new IllegalArgumentException(
                    "Customer cannot be null."
            );
        }

        this.keyword = keyword;
        this.minPrice = minPrice;
        this.maxPrice = maxPrice;
        this.minArea = minArea;
        this.maxArea = maxArea;
        this.bedrooms = bedrooms;
        this.location = location;
        this.customer = customer;
        this.createdAt = LocalDateTime.now();
    }


    // =========================================================
    // Business methods
    // =========================================================

    public void updateSearch(
            String keyword,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Double minArea,
            Double maxArea,
            Integer bedrooms,
            String location
    ) {
        validateRanges(
                minPrice,
                maxPrice,
                minArea,
                maxArea
        );

        this.keyword = keyword;
        this.minPrice = minPrice;
        this.maxPrice = maxPrice;
        this.minArea = minArea;
        this.maxArea = maxArea;
        this.bedrooms = bedrooms;
        this.location = location;
        this.createdAt = LocalDateTime.now();
    }

    public boolean hasPriceRange() {
        return minPrice != null || maxPrice != null;
    }

    public boolean hasAreaRange() {
        return minArea != null || maxArea != null;
    }


    // =========================================================
    // Validation
    // =========================================================

    private void validateRanges(
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Double minArea,
            Double maxArea
    ) {

        if (minPrice != null
                && minPrice.compareTo(BigDecimal.ZERO) < 0) {

            throw new IllegalArgumentException(
                    "Minimum price cannot be negative."
            );
        }

        if (maxPrice != null
                && maxPrice.compareTo(BigDecimal.ZERO) < 0) {

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


    // =========================================================
    // Getters and Setters
    // =========================================================

    public Long getSearchHistoryId() {
        return searchHistoryId;
    }

    public void setSearchHistoryId(Long searchHistoryId) {
        this.searchHistoryId = searchHistoryId;
    }

    public String getKeyword() {
        return keyword;
    }

    public void setKeyword(String keyword) {
        this.keyword = keyword;
    }

    public BigDecimal getMinPrice() {
        return minPrice;
    }

    public void setMinPrice(BigDecimal minPrice) {
        this.minPrice = minPrice;
    }

    public BigDecimal getMaxPrice() {
        return maxPrice;
    }

    public void setMaxPrice(BigDecimal maxPrice) {
        this.maxPrice = maxPrice;
    }

    public Double getMinArea() {
        return minArea;
    }

    public void setMinArea(Double minArea) {
        this.minArea = minArea;
    }

    public Double getMaxArea() {
        return maxArea;
    }

    public void setMaxArea(Double maxArea) {
        this.maxArea = maxArea;
    }

    public Integer getBedrooms() {
        return bedrooms;
    }

    public void setBedrooms(Integer bedrooms) {
        this.bedrooms = bedrooms;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }
}