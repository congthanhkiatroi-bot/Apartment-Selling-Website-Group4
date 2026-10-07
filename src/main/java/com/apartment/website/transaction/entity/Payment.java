package com.apartment.website.transaction.entity;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "PAYMENTS")
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "PAYMENT_ID")
    private Long paymentId;

    @Column(
            name = "AMOUNT",
            nullable = false,
            precision = 15,
            scale = 2
    )
    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Column(name = "METHOD", nullable = false, length = 30)
    private PaymentMethod method;

    @Enumerated(EnumType.STRING)
    @Column(name = "STATUS", nullable = false, length = 30)
    private PaymentStatus status;

    @Column(name = "PAYMENT_REFERENCE", length = 255)
    private String paymentReference;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "PAID_AT")
    private LocalDateTime paidAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "TRANSACTION_ID", nullable = false)
    private Transaction transaction;


    // =========================================================
    // Constructors
    // =========================================================

    public Payment() {
        this.createdAt = LocalDateTime.now();
        this.status = PaymentStatus.PENDING;
    }

    public Payment(
            BigDecimal amount,
            PaymentMethod method,
            Transaction transaction
    ) {
        validateAmount(amount);

        if (method == null) {
            throw new IllegalArgumentException(
                    "Payment method cannot be null."
            );
        }

        if (transaction == null) {
            throw new IllegalArgumentException(
                    "Transaction cannot be null."
            );
        }

        this.amount = amount;
        this.method = method;
        this.transaction = transaction;
        this.createdAt = LocalDateTime.now();
        this.status = PaymentStatus.PENDING;
    }


    // =========================================================
    // Business methods
    // =========================================================

    public void markAsProcessing() {
        if (status != PaymentStatus.PENDING) {
            throw new IllegalStateException(
                    "Only pending payments can be processed."
            );
        }

        this.status = PaymentStatus.PROCESSING;
    }

    public void markAsPaid(String paymentReference) {
        if (status != PaymentStatus.PENDING
                && status != PaymentStatus.PROCESSING) {

            throw new IllegalStateException(
                    "Payment cannot be completed in its current status."
            );
        }

        this.paymentReference = paymentReference;
        this.status = PaymentStatus.PAID;
        this.paidAt = LocalDateTime.now();
    }

    public void fail() {
        if (status == PaymentStatus.PAID) {
            throw new IllegalStateException(
                    "Paid payment cannot be marked as failed."
            );
        }

        this.status = PaymentStatus.FAILED;
    }

    public void refund() {
        if (status != PaymentStatus.PAID) {
            throw new IllegalStateException(
                    "Only paid payments can be refunded."
            );
        }

        this.status = PaymentStatus.REFUNDED;
    }


    // =========================================================
    // Validation
    // =========================================================

    private void validateAmount(BigDecimal amount) {
        if (amount == null ||
                amount.compareTo(BigDecimal.ZERO) <= 0) {

            throw new IllegalArgumentException(
                    "Payment amount must be greater than zero."
            );
        }
    }


    // =========================================================
    // Getters and Setters
    // =========================================================

    public Long getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(Long paymentId) {
        this.paymentId = paymentId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        validateAmount(amount);
        this.amount = amount;
    }

    public PaymentMethod getMethod() {
        return method;
    }

    public void setMethod(PaymentMethod method) {
        this.method = method;
    }

    public PaymentStatus getStatus() {
        return status;
    }

    public void setStatus(PaymentStatus status) {
        this.status = status;
    }

    public String getPaymentReference() {
        return paymentReference;
    }

    public void setPaymentReference(String paymentReference) {
        this.paymentReference = paymentReference;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getPaidAt() {
        return paidAt;
    }

    public void setPaidAt(LocalDateTime paidAt) {
        this.paidAt = paidAt;
    }

    public Transaction getTransaction() {
        return transaction;
    }

    public void setTransaction(Transaction transaction) {
        this.transaction = transaction;
    }


    // =========================================================
    // Enums
    // =========================================================

    public enum PaymentMethod {
        QR_CODE,
        BANK_TRANSFER,
        CASH,
        OTHER
    }

    public enum PaymentStatus {
        PENDING,
        PROCESSING,
        PAID,
        FAILED,
        REFUNDED
    }
}