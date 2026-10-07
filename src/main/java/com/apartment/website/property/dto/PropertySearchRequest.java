package com.apartment.website.property.dto;

import com.apartment.website.property.entity.Property;

import java.math.BigDecimal;

public class PropertySearchRequest {

    private String keyword;

    private BigDecimal minPrice;
    private BigDecimal maxPrice;

    private Double minArea;
    private Double maxArea;

    private Integer bedrooms;
    private Integer bathrooms;

    private String city;
    private String district;
    private String ward;

    private Property.PropertyType propertyType;


    public String getKeyword() {
        return keyword;
    }

    public void setKeyword(String keyword) {
        this.keyword = keyword;
    }

    public BigDecimal getMinPrice() {
        return minPrice;
    }

    public void setMinPrice(
            BigDecimal minPrice
    ) {
        this.minPrice = minPrice;
    }

    public BigDecimal getMaxPrice() {
        return maxPrice;
    }

    public void setMaxPrice(
            BigDecimal maxPrice
    ) {
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

    public void setBedrooms(
            Integer bedrooms
    ) {
        this.bedrooms = bedrooms;
    }

    public Integer getBathrooms() {
        return bathrooms;
    }

    public void setBathrooms(
            Integer bathrooms
    ) {
        this.bathrooms = bathrooms;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(
            String district
    ) {
        this.district = district;
    }

    public String getWard() {
        return ward;
    }

    public void setWard(String ward) {
        this.ward = ward;
    }

    public Property.PropertyType getPropertyType() {
        return propertyType;
    }

    public void setPropertyType(
            Property.PropertyType propertyType
    ) {
        this.propertyType = propertyType;
    }
}