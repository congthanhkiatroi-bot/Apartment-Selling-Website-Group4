package com.apartment.website.auth.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;

import org.springframework.security.authentication.dao.DaoAuthenticationProvider;

import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    private final CustomUserDetailsService userDetailsService;
    private final CustomAuthenticationSuccessHandler successHandler;


    public SecurityConfig(
            CustomUserDetailsService userDetailsService,
            CustomAuthenticationSuccessHandler successHandler
    ) {
        this.userDetailsService = userDetailsService;
        this.successHandler = successHandler;
    }


    // =========================================================
    // PASSWORD ENCODER
    // =========================================================

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }


    // =========================================================
    // AUTHENTICATION PROVIDER
    // Spring Security mới:
    // UserDetailsService truyền trực tiếp vào constructor
    // =========================================================

    @Bean
    public AuthenticationProvider authenticationProvider(
            PasswordEncoder passwordEncoder
    ) {

        DaoAuthenticationProvider provider =
                new DaoAuthenticationProvider(
                        userDetailsService
                );

        provider.setPasswordEncoder(
                passwordEncoder
        );

        return provider;
    }


    // =========================================================
    // AUTHENTICATION MANAGER
    // =========================================================

    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration configuration
    ) {

        return configuration.getAuthenticationManager();
    }


    // =========================================================
    // SECURITY FILTER CHAIN
    // =========================================================

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http,
            AuthenticationProvider authenticationProvider
    ) {

        http.authenticationProvider(
                authenticationProvider
        );


        // =====================================================
        // AUTHORIZATION
        // =====================================================

        http.authorizeHttpRequests(auth -> auth

                // =================================================
                // PUBLIC
                // =================================================

                .requestMatchers(
                        "/",
                        "/login",
                        "/register",

                        "/search",
                        "/search/**",

                        "/api/search",
                        "/api/search/**",

                        "/api/auth/register",
                        "/api/auth/login",

                        "/css/**",
                        "/js/**",
                        "/images/**",
                        "/favicon.ico"
                )
                .permitAll()


                // =================================================
                // PUBLIC MARKETPLACE
                // =================================================

                .requestMatchers(
                        "/properties",
                        "/properties/*",

                        "/postings",
                        "/postings/*"
                )
                .permitAll()


                // =================================================
                // ADMIN
                // =================================================

                .requestMatchers(
                        "/admin/**",
                        "/api/admin/**"
                )
                .hasRole("ADMIN")


                // =================================================
                // OWNER
                // =================================================

                .requestMatchers(
                        "/owner/**",
                        "/api/owner/**"
                )
                .hasRole("OWNER")


                // =================================================
                // CUSTOMER
                // =================================================

                .requestMatchers(
                        "/customer/**",
                        "/api/customer/**"
                )
                .hasRole("CUSTOMER")


                // =================================================
                // OLD OWNER ROUTES
                // Giữ nếu PostingController cũ vẫn còn sử dụng
                // =================================================

                .requestMatchers(
                        "/postings/create",
                        "/postings/*/edit",
                        "/postings/*/submit",
                        "/postings/*/hide",
                        "/postings/*/republish",
                        "/postings/*/remove",
                        "/postings/owner/**"
                )
                .hasRole("OWNER")


                // =================================================
                // OLD CUSTOMER ROUTES
                // Giữ tạm nếu controller cũ vẫn tồn tại
                // =================================================

                .requestMatchers(
                        "/interaction/**",
                        "/api/interactions/**"
                )
                .hasRole("CUSTOMER")


                // =================================================
                // AUTHENTICATED USERS
                // =================================================

                .requestMatchers(
                        "/profile",
                        "/api/auth/me",
                        "/api/auth/logout",

                        "/notifications/**",
                        "/reports/**",

                        "/api/notifications/**",
                        "/api/reports/**"
                )
                .authenticated()


                // =================================================
                // OTHER REQUESTS
                // =================================================

                .anyRequest()
                .authenticated()
        );


        // =====================================================
        // FORM LOGIN
        // =====================================================

        http.formLogin(form -> form

                .loginPage("/login")

                .loginProcessingUrl("/login")

                .usernameParameter(
                        "usernameOrEmail"
                )

                .passwordParameter(
                        "password"
                )

                .successHandler(
                        successHandler
                )

                .failureUrl(
                        "/login?error"
                )

                .permitAll()
        );


        // =====================================================
        // LOGOUT
        // =====================================================

        http.logout(logout -> logout

                .logoutUrl(
                        "/logout"
                )

                .logoutSuccessUrl(
                        "/login?logout"
                )

                .invalidateHttpSession(
                        true
                )

                .deleteCookies(
                        "JSESSIONID"
                )

                .permitAll()
        );


        // =====================================================
        // BUILD
        // =====================================================

        return http.build();
    }
}