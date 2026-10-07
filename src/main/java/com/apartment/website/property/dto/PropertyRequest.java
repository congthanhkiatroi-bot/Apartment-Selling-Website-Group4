package com.apartment.website.property.dto;

import com.apartment.website.property.entity.Property;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;

public class PropertyRequest {

    @NotNull(message = "Price is required.")
    @DecimalMin(
            value = "0.01",
            message = "Price must be greater than 0."
    )
    private BigDecimal price;

    @NotNull(message = "Area is required.")
    @Positive(message = "Area must be greater than 0.")
    private Double area;

    @NotNull(message = "Bedrooms is required.")
    @Min(value = 0, message = "Bedrooms cannot be negative.")
    private Integer bedrooms;

    @NotNull(message = "Bathrooms is required.")
    @Min(value = 0, message = "Bathrooms cannot be negative.")
    private Integer bathrooms;

    private Integer floor;

    @NotBlank(message = "Address is required.")
    private String address;

    @NotBlank(message = "City is required.")
    private String city;

    private String district;

    private String ward;

    @NotNull(message = "Property type is required.")
    private Property.PropertyType propertyType;

    public PropertyRequest() {
    }

    public Property toEntity() {

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

    public void setBedrooms(Integer bedrooms) {
        this.bedrooms = bedrooms;
    }

    public Integer getBathrooms() {
        return bathrooms;
    }

    public void setBathrooms(Integer bathrooms) {
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

    public void setAddress(String address) {
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

    public void setDistrict(String district) {
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