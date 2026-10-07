package com.apartment.website.property.repository;

import com.apartment.website.property.entity.PropertyImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PropertyImageRepository
        extends JpaRepository<PropertyImage, Long> {

    List<PropertyImage> findByPropertyPropertyIdOrderByDisplayOrderAsc(
            Long propertyId
    );

    Optional<PropertyImage> findByPropertyPropertyIdAndThumbnailTrue(
            Long propertyId
    );
}