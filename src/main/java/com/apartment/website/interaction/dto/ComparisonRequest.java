package com.apartment.website.interaction.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class ComparisonRequest {

    @Size(
            max = 100,
            message = "Comparison name cannot exceed 100 characters."
    )
    private String name;

    @NotNull(message = "Customer ID is required.")
    private Long customerId;

    public ComparisonRequest() {
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }
}