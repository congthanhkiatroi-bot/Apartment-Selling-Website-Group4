package com.apartment.website.auth.controller;

import com.apartment.website.auth.entity.User;
import com.apartment.website.auth.service.CurrentUserService;
import com.apartment.website.auth.service.UserService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/profile")
public class ProfileController {

    private final CurrentUserService currentUserService;
    private final UserService userService;

    public ProfileController(
            CurrentUserService currentUserService,
            UserService userService
    ) {
        this.currentUserService =
                currentUserService;

        this.userService =
                userService;
    }


    // =========================================================
    // PROFILE
    // =========================================================

    @GetMapping
    public String profile(
            Model model
    ) {

        User user =
                currentUserService.getCurrentUser();

        model.addAttribute(
                "user",
                user
        );

        return "auth/profile";
    }


    // =========================================================
    // UPDATE PROFILE
    // =========================================================

    @PostMapping("/update")
    public String updateProfile(
            @RequestParam String email,
            @RequestParam(required = false)
            String phone
    ) {

        User currentUser =
                currentUserService.getCurrentUser();

        userService.updateProfile(
                currentUser.getUserId(),
                email,
                phone
        );

        return "redirect:/profile";
    }
}