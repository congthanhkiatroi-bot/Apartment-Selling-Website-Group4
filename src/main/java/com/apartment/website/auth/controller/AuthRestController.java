package com.apartment.website.auth.controller;

import com.apartment.website.auth.dto.AuthResponse;
import com.apartment.website.auth.dto.LoginRequest;
import com.apartment.website.auth.dto.RegisterRequest;
import com.apartment.website.auth.entity.Admin;
import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.entity.Owner;
import com.apartment.website.auth.entity.User;
import com.apartment.website.auth.repository.UserRepository;
import com.apartment.website.auth.service.AuthService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthRestController {

    private final AuthService authService;
    private final UserRepository userRepository;
    private final AuthenticationManager authenticationManager;

    public AuthRestController(
            AuthService authService,
            UserRepository userRepository,
            AuthenticationManager authenticationManager
    ) {
        this.authService = authService;
        this.userRepository = userRepository;
        this.authenticationManager = authenticationManager;
    }


    // =========================================================
    // REGISTER
    // =========================================================

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(
            @Valid @RequestBody RegisterRequest request
    ) {

        String role =
                request.getRole()
                        .trim()
                        .toUpperCase();

        User user;

        if ("CUSTOMER".equals(role)) {

            user = authService.registerCustomer(
                    request.getUsername(),
                    request.getEmail(),
                    request.getPassword(),
                    request.getPhone()
            );

        } else if ("OWNER".equals(role)) {

            user = authService.registerOwner(
                    request.getUsername(),
                    request.getEmail(),
                    request.getPassword(),
                    request.getPhone()
            );

        } else {

            return ResponseEntity
                    .badRequest()
                    .body(
                            AuthResponse.error(
                                    "Role must be CUSTOMER or OWNER."
                            )
                    );
        }

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        AuthResponse.success(
                                "Registration successful.",
                                user.getUserId(),
                                user.getUsername(),
                                user.getEmail(),
                                determineRole(user)
                        )
                );
    }


    // =========================================================
    // LOGIN
    // =========================================================

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest httpRequest,
            HttpServletResponse httpResponse
    ) {

        String loginValue =
                request.getUsernameOrEmail().trim();

        try {

            Authentication authentication =
                    authenticationManager.authenticate(
                            new UsernamePasswordAuthenticationToken(
                                    loginValue,
                                    request.getPassword()
                            )
                    );

            SecurityContext securityContext =
                    SecurityContextHolder
                            .createEmptyContext();

            securityContext.setAuthentication(
                    authentication
            );

            SecurityContextHolder.setContext(
                    securityContext
            );

            HttpSessionSecurityContextRepository
                    securityContextRepository =
                    new HttpSessionSecurityContextRepository();

            securityContextRepository.saveContext(
                    securityContext,
                    httpRequest,
                    httpResponse
            );

            User user = userRepository
                    .findByUsernameOrEmail(
                            loginValue,
                            loginValue
                    )
                    .orElseThrow(
                            () -> new IllegalStateException(
                                    "Authenticated user not found."
                            )
                    );

            return ResponseEntity.ok(
                    AuthResponse.success(
                            "Login successful.",
                            user.getUserId(),
                            user.getUsername(),
                            user.getEmail(),
                            determineRole(user)
                    )
            );

        } catch (AuthenticationException exception) {

            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(
                            AuthResponse.error(
                                    "Username/email or password is incorrect."
                            )
                    );
        }
    }


    // =========================================================
    // CURRENT USER
    // =========================================================

    @GetMapping("/me")
    public ResponseEntity<AuthResponse> currentUser(
            Authentication authentication
    ) {

        if (authentication == null
                || !authentication.isAuthenticated()
                || "anonymousUser".equals(
                authentication.getPrincipal()
        )) {

            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(
                            AuthResponse.error(
                                    "Not logged in."
                            )
                    );
        }

        String username =
                authentication.getName();

        User user = userRepository
                .findByUsername(username)
                .orElseThrow(
                        () -> new IllegalStateException(
                                "Authenticated user not found."
                        )
                );

        return ResponseEntity.ok(
                AuthResponse.success(
                        "Current user retrieved successfully.",
                        user.getUserId(),
                        user.getUsername(),
                        user.getEmail(),
                        determineRole(user)
                )
        );
    }


    // =========================================================
    // LOGOUT
    // =========================================================

    @PostMapping("/logout")
    public ResponseEntity<AuthResponse> logout(
            HttpServletRequest request
    ) {

        SecurityContextHolder.clearContext();

        if (request.getSession(false) != null) {
            request.getSession(false).invalidate();
        }

        return ResponseEntity.ok(
                AuthResponse.success(
                        "Logout successful.",
                        null,
                        null,
                        null,
                        null
                )
        );
    }


    // =========================================================
    // DETERMINE ROLE
    // =========================================================

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

        return "USER";
    }
}