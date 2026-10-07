package com.apartment.website.transaction.dto;

import com.apartment.website.transaction.entity.Payment.PaymentMethod;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public class PaymentRequest {

    @NotNull(message = "Transaction ID is required.")
    private Long transactionId;

    @NotNull(message = "Payment amount is required.")
    @DecimalMin(
            value = "0.01",
            message = "Payment amount must be greater than zero."
    )
    private BigDecimal amount;

    @NotNull(message = "Payment method is required.")
    private PaymentMethod method;

    public PaymentRequest() {
    }

    public Long getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(Long transactionId) {
        this.transactionId = transactionId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public PaymentMethod getMethod() {
        return method;
    }

    public void setMethod(PaymentMethod method) {
        this.method = method;
    }
}