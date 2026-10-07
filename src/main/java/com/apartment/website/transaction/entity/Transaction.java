package com.apartment.website.transaction.entity;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.listing.entity.Posting;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "TRANSACTIONS")
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "TRANSACTION_ID")
    private Long transactionId;

    @Column(
            name = "AGREED_PRICE",
            nullable = false,
            precision = 15,
            scale = 2
    )
    private BigDecimal agreedPrice;

    @Enumerated(EnumType.STRING)
    @Column(name = "STATUS", nullable = false, length = 30)
    private TransactionStatus status;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "COMPLETED_AT")
    private LocalDateTime completedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CUSTOMER_ID", nullable = false)
    private Customer customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "POSTING_ID", nullable = false)
    private Posting posting;

    @OneToMany(
            mappedBy = "transaction",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<Payment> payments = new ArrayList<>();


    // =========================================================
    // Constructors
    // =========================================================

    public Transaction() {
        this.createdAt = LocalDateTime.now();
        this.status = TransactionStatus.PENDING;
    }

    public Transaction(
            BigDecimal agreedPrice,
            Customer customer,
            Posting posting
    ) {
        validatePrice(agreedPrice);

        if (customer == null) {
            throw new IllegalArgumentException(
                    "Customer cannot be null."
            );
        }

        if (posting == null) {
            throw new IllegalArgumentException(
                    "Posting cannot be null."
            );
        }

        this.agreedPrice = agreedPrice;
        this.customer = customer;
        this.posting = posting;
        this.createdAt = LocalDateTime.now();
        this.status = TransactionStatus.PENDING;
    }


    // =========================================================
    // Business methods
    // =========================================================

    public void confirm() {
        if (status != TransactionStatus.PENDING) {
            throw new IllegalStateException(
                    "Only pending transactions can be confirmed."
            );
        }

        this.status = TransactionStatus.CONFIRMED;
    }

    public void markAsPaid() {
        if (status != TransactionStatus.CONFIRMED) {
            throw new IllegalStateException(
                    "Transaction must be confirmed before payment."
            );
        }

        this.status = TransactionStatus.PAID;
    }

    public void complete() {
        if (status != TransactionStatus.PAID) {
            throw new IllegalStateException(
                    "Transaction must be paid before completion."
            );
        }

        this.status = TransactionStatus.COMPLETED;
        this.completedAt = LocalDateTime.now();
    }

    public void cancel() {
        if (status == TransactionStatus.COMPLETED) {
            throw new IllegalStateException(
                    "Completed transaction cannot be cancelled."
            );
        }

        this.status = TransactionStatus.CANCELLED;
    }

    public void addPayment(Payment payment) {
        if (payment == null) {
            throw new IllegalArgumentException(
                    "Payment cannot be null."
            );
        }

        payments.add(payment);
        payment.setTransaction(this);
    }

    public void removePayment(Payment payment) {
        if (payment != null && payments.remove(payment)) {
            payment.setTransaction(null);
        }
    }


    // =========================================================
    // Validation
    // =========================================================

    private void validatePrice(BigDecimal price) {
        if (price == null ||
                price.compareTo(BigDecimal.ZERO) <= 0) {

            throw new IllegalArgumentException(
                    "Agreed price must be greater than zero."
            );
        }
    }


    // =========================================================
    // Getters and Setters
    // =========================================================

    public Long getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(Long transactionId) {
        this.transactionId = transactionId;
    }

    public BigDecimal getAgreedPrice() {
        return agreedPrice;
    }

    public void setAgreedPrice(BigDecimal agreedPrice) {
        validatePrice(agreedPrice);
        this.agreedPrice = agreedPrice;
    }

    public TransactionStatus getStatus() {
        return status;
    }

    public void setStatus(TransactionStatus status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    public Posting getPosting() {
        return posting;
    }

    public void setPosting(Posting posting) {
        this.posting = posting;
    }

    public List<Payment> getPayments() {
        return payments;
    }

    public void setPayments(List<Payment> payments) {
        this.payments = payments;
    }


    // =========================================================
    // Enum
    // =========================================================

    public enum TransactionStatus {
        PENDING,
        CONFIRMED,
        PAID,
        COMPLETED,
        CANCELLED
    }
}