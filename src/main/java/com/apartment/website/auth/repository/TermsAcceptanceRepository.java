package com.apartment.website.auth.repository;

import com.apartment.website.auth.entity.TermsAcceptance;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TermsAcceptanceRepository
        extends JpaRepository<TermsAcceptance, Long> {

    List<TermsAcceptance> findByUserUserId(Long userId);

    boolean existsByUserUserIdAndTermsVersionAndAcceptedTrue(
            Long userId,
            String termsVersion
    );
}