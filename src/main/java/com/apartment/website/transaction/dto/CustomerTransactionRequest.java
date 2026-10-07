package com.apartment.website.transaction.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public class CustomerTransactionRequest {

    @NotNull
    private Long postingId;

    @NotNull
    @DecimalMin("0.01")
    private BigDecimal agreedPrice;


    public Long getPostingId() {
        return postingId;
    }

    public void setPostingId(Long postingId) {
        this.postingId = postingId;
    }

    public BigDecimal getAgreedPrice() {
        return agreedPrice;
    }

    public void setAgreedPrice(
            BigDecimal agreedPrice
    ) {
        this.agreedPrice = agreedPrice;
    }
}