package com.apartment.website.listing.dto;

import com.apartment.website.property.entity.Property;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public class OwnerListingRequest {

    // =========================================================
    // POSTING
    // =========================================================

    @NotBlank
    @Size(max = 200)
    private String title;

    @NotBlank
    @Size(max = 2000)
    private String description;


    // =========================================================
    // PROPERTY
    // =========================================================

    @NotNull
    @DecimalMin("0.01")
    private BigDecimal price;

    @NotNull
    @DecimalMin("0.01")
    private Double area;

    @NotNull
    @Min(0)
    private Integer bedrooms;

    @NotNull
    @Min(0)
    private Integer bathrooms;

    private Integer floor;

    @NotBlank
    @Size(max = 500)
    private String address;

    @NotBlank
    @Size(max = 100)
    private String city;

    @Size(max = 100)
    private String district;

    @Size(max = 100)
    private String ward;

    @NotNull
    private Property.PropertyType propertyType;


    // =========================================================
    // CONVERT TO PROPERTY
    // =========================================================

    public Property toProperty() {

        return new Property(
                price,
                area,
                bedrooms,
                bathrooms,
                floor,
                address,
                city,
                district,
                ward,
                propertyType
        );
    }


    // =========================================================
    // GETTERS / SETTERS
    // =========================================================

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(
            String description
    ) {
        this.description = description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public Double getArea() {
        return area;
    }

    public void setArea(Double area) {
        this.area = area;
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

    public Integer getFloor() {
        return floor;
    }

    public void setFloor(Integer floor) {
        this.floor = floor;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(
            String address
    ) {
        this.address = address;
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