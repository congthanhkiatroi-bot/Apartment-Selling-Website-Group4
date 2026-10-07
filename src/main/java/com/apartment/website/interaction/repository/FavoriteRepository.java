package com.apartment.website.interaction.repository;

import com.apartment.website.interaction.entity.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

    List<Favorite> findByCustomerUserIdOrderByCreatedAtDesc(
            Long customerId
    );

    Optional<Favorite> findByCustomerUserIdAndPropertyPropertyId(
            Long customerId,
            Long propertyId
    );

    boolean existsByCustomerUserIdAndPropertyPropertyId(
            Long customerId,
            Long propertyId
    );

    void deleteByCustomerUserIdAndPropertyPropertyId(
            Long customerId,
            Long propertyId
    );
}