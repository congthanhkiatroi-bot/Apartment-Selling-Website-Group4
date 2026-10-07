package com.apartment.website.common.exception;

import jakarta.servlet.http.HttpServletRequest;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice(
        annotations = Controller.class
)
public class GlobalMvcExceptionHandler {


    // =========================================================
    // BAD REQUEST
    // =========================================================

    @ExceptionHandler(IllegalArgumentException.class)
    public String handleIllegalArgument(
            IllegalArgumentException exception,
            HttpServletRequest request,
            Model model
    ) {

        addErrorAttributes(
                model,
                HttpStatus.BAD_REQUEST,
                exception.getMessage(),
                request
        );

        return "error/error";
    }


    // =========================================================
    // CONFLICT / INVALID BUSINESS STATE
    // =========================================================

    @ExceptionHandler(IllegalStateException.class)
    public String handleIllegalState(
            IllegalStateException exception,
            HttpServletRequest request,
            Model model
    ) {

        addErrorAttributes(
                model,
                HttpStatus.CONFLICT,
                exception.getMessage(),
                request
        );

        return "error/error";
    }


    // =========================================================
    // OTHER EXCEPTIONS
    // =========================================================

    @ExceptionHandler(Exception.class)
    public String handleGeneralException(
            Exception exception,
            HttpServletRequest request,
            Model model
    ) {

        addErrorAttributes(
                model,
                HttpStatus.INTERNAL_SERVER_ERROR,
                "An unexpected error occurred.",
                request
        );

        return "error/error";
    }


    // =========================================================
    // HELPER
    // =========================================================

    private void addErrorAttributes(
            Model model,
            HttpStatus status,
            String message,
            HttpServletRequest request
    ) {

        model.addAttribute(
                "status",
                status.value()
        );

        model.addAttribute(
                "error",
                status.getReasonPhrase()
        );

        model.addAttribute(
                "message",
                message
        );

        model.addAttribute(
                "path",
                request.getRequestURI()
        );
    }
}