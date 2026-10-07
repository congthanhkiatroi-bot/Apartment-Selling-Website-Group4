package com.apartment.website.auth.security;

import com.apartment.website.auth.entity.Admin;
import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.entity.Owner;
import com.apartment.website.auth.entity.User;
import com.apartment.website.auth.repository.UserRepository;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailsService
        implements UserDetailsService {

    private final UserRepository userRepository;

    public CustomUserDetailsService(
            UserRepository userRepository
    ) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(
            String usernameOrEmail
    ) throws UsernameNotFoundException {

        User user = userRepository
                .findByUsernameOrEmail(
                        usernameOrEmail,
                        usernameOrEmail
                )
                .orElseThrow(
                        () -> new UsernameNotFoundException(
                                "User not found: "
                                        + usernameOrEmail
                        )
                );

        String role = determineRole(user);

        return org.springframework.security.core.userdetails.User
                .withUsername(user.getUsername())
                .password(user.getPasswordHash())
                .roles(role)
                .disabled(!user.isActive())
                .build();
    }

    private String determineRole(User user) {

        if (user instanceof Admin) {
            return "ADMIN";
        }

        if (user instanceof Owner) {
            return "OWNER";
        }

        if (user instanceof Customer) {
            return "CUSTOMER";
        }

        throw new IllegalStateException(
                "Unknown user role."
        );
    }
}