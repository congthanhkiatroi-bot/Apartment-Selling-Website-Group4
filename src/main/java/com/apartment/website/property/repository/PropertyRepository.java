package com.apartment.website.property.repository;

import com.apartment.website.property.entity.Property;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.math.BigDecimal;
import java.util.List;

public interface PropertyRepository
        extends JpaRepository<Property, Long>,
        JpaSpecificationExecutor<Property> {

    List<Property> findByStatus(Property.PropertyStatus status);

    List<Property> findByCityIgnoreCase(String city);

    List<Property> findByDistrictIgnoreCase(String district);

    List<Property> findByPropertyType(Property.PropertyType propertyType);

    List<Property> findByBedrooms(Integer bedrooms);

    List<Property> findByPriceBetween(
            BigDecimal minPrice,
            BigDecimal maxPrice
    );

    List<Property> findByAreaBetween(
            Double minArea,
            Double maxArea
    );

    List<Property> findByCityIgnoreCaseAndStatus(
            String city,
            Property.PropertyStatus status
    );
}