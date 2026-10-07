package com.apartment.website.auth.controller;

import com.apartment.website.auth.dto.LoginRequest;
import com.apartment.website.auth.dto.RegisterRequest;
import com.apartment.website.auth.service.AuthService;

import jakarta.validation.Valid;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
public class AuthController {

    private final AuthService authService;

    public AuthController(
            AuthService authService
    ) {
        this.authService = authService;
    }


    // =========================================================
    // LOGIN PAGE
    // =========================================================

    @GetMapping("/login")
    public String loginPage(
            Model model
    ) {

        model.addAttribute(
                "loginRequest",
                new LoginRequest()
        );

        return "auth/login";
    }


    // =========================================================
    // REGISTER PAGE
    // =========================================================

    @GetMapping("/register")
    public String registerPage(
            Model model
    ) {

        model.addAttribute(
                "registerRequest",
                new RegisterRequest()
        );

        return "auth/register";
    }


    // =========================================================
    // REGISTER
    // =========================================================

    @PostMapping("/register")
    public String register(
            @Valid
            @ModelAttribute("registerRequest")
            RegisterRequest request,

            BindingResult bindingResult,

            Model model
    ) {

        if (bindingResult.hasErrors()) {
            return "auth/register";
        }

        try {

            String role =
                    request.getRole()
                            .trim()
                            .toUpperCase();

            if ("CUSTOMER".equals(role)) {

                authService.registerCustomer(
                        request.getUsername(),
                        request.getEmail(),
                        request.getPassword(),
                        request.getPhone()
                );

            } else if ("OWNER".equals(role)) {

                authService.registerOwner(
                        request.getUsername(),
                        request.getEmail(),
                        request.getPassword(),
                        request.getPhone()
                );

            } else {

                model.addAttribute(
                        "errorMessage",
                        "Invalid registration role."
                );

                return "auth/register";
            }

            return "redirect:/login?registered";

        } catch (IllegalArgumentException exception) {

            model.addAttribute(
                    "errorMessage",
                    exception.getMessage()
            );

            return "auth/register";
        }
    }
}