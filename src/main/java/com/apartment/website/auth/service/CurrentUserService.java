package com.apartment.website.auth.service;

import com.apartment.website.auth.entity.Admin;
import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.entity.Owner;
import com.apartment.website.auth.entity.User;
import com.apartment.website.auth.repository.UserRepository;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class CurrentUserService {

    private final UserRepository userRepository;

    public CurrentUserService(
            UserRepository userRepository
    ) {
        this.userRepository = userRepository;
    }


    // =========================================================
    // CURRENT USER
    // =========================================================

    public User getCurrentUser() {

        Authentication authentication =
                SecurityContextHolder
                        .getContext()
                        .getAuthentication();

        if (authentication == null
                || !authentication.isAuthenticated()
                || "anonymousUser".equals(
                authentication.getPrincipal()
        )) {

            throw new IllegalStateException(
                    "User is not authenticated."
            );
        }

        String username =
                authentication.getName();

        return userRepository
                .findByUsername(username)
                .orElseThrow(
                        () -> new IllegalStateException(
                                "Authenticated user not found."
                        )
                );
    }


    // =========================================================
    // CURRENT USER ID
    // =========================================================

    public Long getCurrentUserId() {
        return getCurrentUser().getUserId();
    }


    // =========================================================
    // CUSTOMER
    // =========================================================

    public Customer getCurrentCustomer() {

        User user = getCurrentUser();

        if (!(user instanceof Customer customer)) {
            throw new IllegalStateException(
                    "Current user is not a customer."
            );
        }

        return customer;
    }


    // =========================================================
    // OWNER
    // =========================================================

    public Owner getCurrentOwner() {

        User user = getCurrentUser();

        if (!(user instanceof Owner owner)) {
            throw new IllegalStateException(
                    "Current user is not an owner."
            );
        }

        return owner;
    }


    // =========================================================
    // ADMIN
    // =========================================================

    public Admin getCurrentAdmin() {

        User user = getCurrentUser();

        if (!(user instanceof Admin admin)) {
            throw new IllegalStateException(
                    "Current user is not an admin."
            );
        }

        return admin;
    }


    // =========================================================
    // ROLE CHECK
    // =========================================================

    public boolean isCustomer() {
        return getCurrentUser() instanceof Customer;
    }

    public boolean isOwner() {
        return getCurrentUser() instanceof Owner;
    }

    public boolean isAdmin() {
        return getCurrentUser() instanceof Admin;
    }
    public boolean isAuthenticated() {

        Authentication authentication =
                SecurityContextHolder
                        .getContext()
                        .getAuthentication();

        return authentication != null
                && authentication.isAuthenticated()
                && !"anonymousUser".equals(
                authentication.getPrincipal()
        );
    }
}