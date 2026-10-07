package com.apartment.website.listing.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class RejectPostingRequest {

    @NotBlank(message = "Rejection reason cannot be empty.")
    @Size(
            max = 1000,
            message = "Rejection reason cannot exceed 1000 characters."
    )
    private String reason;

    public RejectPostingRequest() {
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }
}