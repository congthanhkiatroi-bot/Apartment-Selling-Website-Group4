package com.apartment.website.auth.repository;

import com.apartment.website.auth.entity.Owner;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface OwnerRepository extends JpaRepository<Owner, Long> {

    Optional<Owner> findByUsername(String username);

    Optional<Owner> findByEmail(String email);
}