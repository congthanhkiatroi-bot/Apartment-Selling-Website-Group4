package com.apartment.website.property.service;

import com.apartment.website.property.entity.Property;
import com.apartment.website.property.repository.PropertyRepository;

import jakarta.persistence.EntityNotFoundException;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class PropertyService {

    private final PropertyRepository propertyRepository;

    public PropertyService(
            PropertyRepository propertyRepository
    ) {
        this.propertyRepository = propertyRepository;
    }


    // =========================================================
    // QUERY
    // =========================================================

    @Transactional(readOnly = true)
    public List<Property> getAllProperties() {
        return propertyRepository.findAll();
    }


    @Transactional(readOnly = true)
    public Property getPropertyById(
            Long propertyId
    ) {

        if (propertyId == null) {
            throw new IllegalArgumentException(
                    "Property ID cannot be null."
            );
        }

        return propertyRepository
                .findById(propertyId)
                .orElseThrow(() ->
                        new EntityNotFoundException(
                                "Property not found with ID: "
                                        + propertyId
                        )
                );
    }


    @Transactional(readOnly = true)
    public List<Property> getAvailableProperties() {

        return propertyRepository.findByStatus(
                Property.PropertyStatus.AVAILABLE
        );
    }


    // =========================================================
    // CREATE
    // =========================================================

    public Property createProperty(
            Property property
    ) {

        if (property == null) {
            throw new IllegalArgumentException(
                    "Property cannot be null."
            );
        }

        validateProperty(property);

        property.setPropertyId(null);

        if (property.getStatus() == null) {
            property.setStatus(
                    Property.PropertyStatus.AVAILABLE
            );
        }

        return propertyRepository.save(
                property
        );
    }


    // =========================================================
    // UPDATE
    // =========================================================

    public Property updateProperty(
            Long propertyId,
            Property updatedProperty
    ) {

        if (updatedProperty == null) {
            throw new IllegalArgumentException(
                    "Property data cannot be null."
            );
        }

        validateProperty(updatedProperty);

        Property property =
                getPropertyById(propertyId);

        property.setPrice(
                updatedProperty.getPrice()
        );

        property.setArea(
                updatedProperty.getArea()
        );

        property.setBedrooms(
                updatedProperty.getBedrooms()
        );

        property.setBathrooms(
                updatedProperty.getBathrooms()
        );

        property.setFloor(
                updatedProperty.getFloor()
        );

        property.setAddress(
                normalizeText(
                        updatedProperty.getAddress()
                )
        );

        property.setCity(
                normalizeText(
                        updatedProperty.getCity()
                )
        );

        property.setDistrict(
                normalizeText(
                        updatedProperty.getDistrict()
                )
        );

        property.setWard(
                normalizeText(
                        updatedProperty.getWard()
                )
        );

        property.setPropertyType(
                updatedProperty.getPropertyType()
        );

        return property;
    }


    // =========================================================
    // STATUS
    // =========================================================

    public Property markAsAvailable(
            Long propertyId
    ) {

        Property property =
                getPropertyById(propertyId);

        property.markAsAvailable();

        return property;
    }


    public Property markAsReserved(
            Long propertyId
    ) {

        Property property =
                getPropertyById(propertyId);

        property.markAsReserved();

        return property;
    }


    public Property markAsSold(
            Long propertyId
    ) {

        Property property =
                getPropertyById(propertyId);

        property.markAsSold();

        return property;
    }


    // =========================================================
    // DELETE
    // =========================================================

    public void deleteProperty(
            Long propertyId
    ) {

        Property property =
                getPropertyById(propertyId);

        propertyRepository.delete(
                property
        );
    }


    // =========================================================
    // VALIDATION
    // =========================================================

    private void validateProperty(
            Property property
    ) {

        if (property.getPrice() == null
                || property.getPrice().signum() <= 0) {

            throw new IllegalArgumentException(
                    "Property price must be greater than 0."
            );
        }


        if (property.getArea() == null
                || property.getArea() <= 0) {

            throw new IllegalArgumentException(
                    "Property area must be greater than 0."
            );
        }


        if (property.getBedrooms() == null
                || property.getBedrooms() < 0) {

            throw new IllegalArgumentException(
                    "Bedrooms cannot be negative."
            );
        }


        if (property.getBathrooms() == null
                || property.getBathrooms() < 0) {

            throw new IllegalArgumentException(
                    "Bathrooms cannot be negative."
            );
        }


        if (property.getAddress() == null
                || property.getAddress().isBlank()) {

            throw new IllegalArgumentException(
                    "Property address is required."
            );
        }


        if (property.getCity() == null
                || property.getCity().isBlank()) {

            throw new IllegalArgumentException(
                    "Property city is required."
            );
        }


        if (property.getPropertyType() == null) {

            throw new IllegalArgumentException(
                    "Property type is required."
            );
        }
    }


    private String normalizeText(
            String value
    ) {

        if (value == null) {
            return null;
        }

        String normalized =
                value.trim();

        return normalized.isEmpty()
                ? null
                : normalized;
    }
}