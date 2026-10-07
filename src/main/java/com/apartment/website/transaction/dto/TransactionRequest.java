package com.apartment.website.transaction.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public class TransactionRequest {

    @NotNull(message = "Agreed price is required.")
    @DecimalMin(
            value = "0.01",
            message = "Agreed price must be greater than zero."
    )
    private BigDecimal agreedPrice;

    @NotNull(message = "Customer ID is required.")
    private Long customerId;

    @NotNull(message = "Posting ID is required.")
    private Long postingId;

    public TransactionRequest() {
    }

    public BigDecimal getAgreedPrice() {
        return agreedPrice;
    }

    public void setAgreedPrice(BigDecimal agreedPrice) {
        this.agreedPrice = agreedPrice;
    }

    public Long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }

    public Long getPostingId() {
        return postingId;
    }

    public void setPostingId(Long postingId) {
        this.postingId = postingId;
    }
}