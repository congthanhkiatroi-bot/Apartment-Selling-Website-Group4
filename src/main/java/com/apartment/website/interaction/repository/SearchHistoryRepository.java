package com.apartment.website.interaction.repository;

import com.apartment.website.interaction.entity.SearchHistory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SearchHistoryRepository
        extends JpaRepository<SearchHistory, Long> {

    List<SearchHistory> findByCustomerUserIdOrderByCreatedAtDesc(
            Long customerId
    );

    List<SearchHistory> findTop10ByCustomerUserIdOrderByCreatedAtDesc(
            Long customerId
    );

    void deleteByCustomerUserId(Long customerId);
}