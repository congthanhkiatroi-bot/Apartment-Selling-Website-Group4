package com.apartment.website.interaction.repository;

import com.apartment.website.interaction.entity.Comment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CommentRepository extends JpaRepository<Comment, Long> {

    List<Comment> findByPropertyPropertyIdOrderByCreatedAtDesc(
            Long propertyId
    );

    List<Comment> findByCustomerUserIdOrderByCreatedAtDesc(
            Long customerId
    );

    boolean existsByCustomerUserIdAndPropertyPropertyId(
            Long customerId,
            Long propertyId
    );
}