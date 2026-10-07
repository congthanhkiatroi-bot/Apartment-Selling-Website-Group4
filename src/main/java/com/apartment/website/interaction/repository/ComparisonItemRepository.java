package com.apartment.website.interaction.repository;

import com.apartment.website.interaction.entity.ComparisonItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ComparisonItemRepository
        extends JpaRepository<ComparisonItem, Long> {

    List<ComparisonItem> findByComparisonComparisonId(
            Long comparisonId
    );

    boolean existsByComparisonComparisonIdAndPropertyPropertyId(
            Long comparisonId,
            Long propertyId
    );

    void deleteByComparisonComparisonIdAndPropertyPropertyId(
            Long comparisonId,
            Long propertyId
    );
}