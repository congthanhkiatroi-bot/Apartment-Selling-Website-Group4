package com.apartment.website.interaction.repository;

import com.apartment.website.interaction.entity.Comparison;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ComparisonRepository
        extends JpaRepository<Comparison, Long> {

    List<Comparison> findByCustomerUserIdOrderByCreatedAtDesc(
            Long customerId
    );
}