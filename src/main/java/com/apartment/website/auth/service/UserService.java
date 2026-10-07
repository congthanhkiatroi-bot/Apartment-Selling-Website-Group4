package com.apartment.website.auth.service;

import com.apartment.website.auth.entity.User;
import com.apartment.website.auth.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }


    // =========================================================
    // READ
    // =========================================================

    @Transactional(readOnly = true)
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }


    @Transactional(readOnly = true)
    public User getUserById(Long userId) {

        if (userId == null) {
            throw new IllegalArgumentException(
                    "User ID cannot be null."
            );
        }

        return userRepository.findById(userId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "User not found with ID: " + userId
                        )
                );
    }


    @Transactional(readOnly = true)
    public User getUserByUsername(String username) {

        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException(
                    "Username cannot be empty."
            );
        }

        return userRepository.findByUsername(username)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "User not found with username: "
                                        + username
                        )
                );
    }


    @Transactional(readOnly = true)
    public User getUserByEmail(String email) {

        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException(
                    "Email cannot be empty."
            );
        }

        return userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "User not found with email: "
                                        + email
                        )
                );
    }


    // =========================================================
    // CHECK DUPLICATE
    // =========================================================

    @Transactional(readOnly = true)
    public boolean usernameExists(String username) {

        if (username == null || username.isBlank()) {
            return false;
        }

        return userRepository.existsByUsername(username);
    }


    @Transactional(readOnly = true)
    public boolean emailExists(String email) {

        if (email == null || email.isBlank()) {
            return false;
        }

        return userRepository.existsByEmail(email);
    }


    // =========================================================
    // UPDATE PROFILE
    // =========================================================

    public User updateProfile(
            Long userId,
            String email,
            String phone
    ) {

        User user = getUserById(userId);

        if (email != null
                && !email.isBlank()
                && !email.equalsIgnoreCase(user.getEmail())
                && userRepository.existsByEmail(email)) {

            throw new IllegalArgumentException(
                    "Email is already in use."
            );
        }

        user.updateProfile(email, phone);

        return userRepository.save(user);
    }


    // =========================================================
    // ACCOUNT STATUS
    // =========================================================

    public User activateUser(Long userId) {

        User user = getUserById(userId);

        user.activate();

        return userRepository.save(user);
    }


    public User deactivateUser(Long userId) {

        User user = getUserById(userId);

        user.deactivate();

        return userRepository.save(user);
    }
}