package com.apartment.website.transaction.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class PaymentCompleteRequest {

    @NotBlank(message = "Payment reference is required.")
    @Size(
            max = 255,
            message = "Payment reference cannot exceed 255 characters."
    )
    private String paymentReference;

    public PaymentCompleteRequest() {
    }

    public String getPaymentReference() {
        return paymentReference;
    }

    public void setPaymentReference(String paymentReference) {
        this.paymentReference = paymentReference;
    }
}