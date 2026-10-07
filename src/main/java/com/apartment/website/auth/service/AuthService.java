package com.apartment.website.auth.service;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.entity.Owner;
import com.apartment.website.auth.repository.CustomerRepository;
import com.apartment.website.auth.repository.OwnerRepository;
import com.apartment.website.auth.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class AuthService {

    private final UserRepository userRepository;
    private final CustomerRepository customerRepository;
    private final OwnerRepository ownerRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthService(
            UserRepository userRepository,
            CustomerRepository customerRepository,
            OwnerRepository ownerRepository,
            PasswordEncoder passwordEncoder
    ) {
        this.userRepository = userRepository;
        this.customerRepository = customerRepository;
        this.ownerRepository = ownerRepository;
        this.passwordEncoder = passwordEncoder;
    }


    // =========================================================
    // REGISTER CUSTOMER
    // =========================================================

    public Customer registerCustomer(
            String username,
            String email,
            String password,
            String phone
    ) {

        validateRegistration(
                username,
                email,
                password
        );

        String passwordHash =
                passwordEncoder.encode(password);

        Customer customer = new Customer(
                username.trim(),
                email.trim(),
                passwordHash,
                normalizePhone(phone)
        );

        return customerRepository.save(customer);
    }


    // =========================================================
    // REGISTER OWNER
    // =========================================================

    public Owner registerOwner(
            String username,
            String email,
            String password,
            String phone
    ) {

        validateRegistration(
                username,
                email,
                password
        );

        String passwordHash =
                passwordEncoder.encode(password);

        Owner owner = new Owner(
                username.trim(),
                email.trim(),
                passwordHash,
                normalizePhone(phone)
        );

        return ownerRepository.save(owner);
    }


    // =========================================================
    // PASSWORD CHECK
    // =========================================================

    @Transactional(readOnly = true)
    public boolean checkPassword(
            String rawPassword,
            String encodedPassword
    ) {

        if (rawPassword == null
                || encodedPassword == null) {
            return false;
        }

        return passwordEncoder.matches(
                rawPassword,
                encodedPassword
        );
    }


    // =========================================================
    // REGISTRATION VALIDATION
    // =========================================================

    private void validateRegistration(
            String username,
            String email,
            String password
    ) {

        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException(
                    "Username cannot be empty."
            );
        }

        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException(
                    "Email cannot be empty."
            );
        }

        if (password == null || password.isBlank()) {
            throw new IllegalArgumentException(
                    "Password cannot be empty."
            );
        }

        if (username.trim().length() < 3) {
            throw new IllegalArgumentException(
                    "Username must contain at least 3 characters."
            );
        }

        if (password.length() < 6) {
            throw new IllegalArgumentException(
                    "Password must contain at least 6 characters."
            );
        }

        if (!email.contains("@")) {
            throw new IllegalArgumentException(
                    "Invalid email address."
            );
        }

        if (userRepository.existsByUsername(
                username.trim()
        )) {
            throw new IllegalArgumentException(
                    "Username is already in use."
            );
        }

        if (userRepository.existsByEmail(
                email.trim()
        )) {
            throw new IllegalArgumentException(
                    "Email is already in use."
            );
        }
    }


    // =========================================================
    // PHONE NORMALIZATION
    // =========================================================

    private String normalizePhone(String phone) {

        if (phone == null || phone.isBlank()) {
            return null;
        }

        return phone.trim();
    }
}