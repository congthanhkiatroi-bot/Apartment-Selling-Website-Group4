package com.apartment.website.auth.repository;

import com.apartment.website.auth.entity.UserVerification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserVerificationRepository
        extends JpaRepository<UserVerification, Long> {

    List<UserVerification> findByUserUserId(Long userId);

    Optional<UserVerification>
    findTopByUserUserIdAndVerificationTypeOrderByVerificationIdDesc(
            Long userId,
            UserVerification.VerificationType verificationType
    );
}