package com.apartment.website.auth.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class CustomAuthenticationSuccessHandler
        implements AuthenticationSuccessHandler {

    @Override
    public void onAuthenticationSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication
    ) throws IOException, ServletException {

        String redirectUrl = "/";

        for (GrantedAuthority authority :
                authentication.getAuthorities()) {

            String role = authority.getAuthority();

            if ("ROLE_ADMIN".equals(role)) {

                redirectUrl = "/admin";
                break;

            } else if ("ROLE_OWNER".equals(role)) {

                redirectUrl = "/owner/dashboard";
                break;

            } else if ("ROLE_CUSTOMER".equals(role)) {

                redirectUrl = "/";
                break;
            }
        }

        response.sendRedirect(
                request.getContextPath()
                        + redirectUrl
        );
    }
}