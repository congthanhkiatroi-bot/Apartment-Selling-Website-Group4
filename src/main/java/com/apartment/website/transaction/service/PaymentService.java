package com.apartment.website.transaction.service;

import com.apartment.website.transaction.entity.Payment;
import com.apartment.website.transaction.entity.Payment.PaymentMethod;
import com.apartment.website.transaction.entity.Payment.PaymentStatus;
import com.apartment.website.transaction.entity.Transaction;
import com.apartment.website.transaction.entity.Transaction.TransactionStatus;
import com.apartment.website.transaction.repository.PaymentRepository;
import com.apartment.website.transaction.repository.TransactionRepository;
import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.entity.Owner;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import java.math.BigDecimal;
import java.util.List;

@Service
@Transactional
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final TransactionRepository transactionRepository;

    public PaymentService(
            PaymentRepository paymentRepository,
            TransactionRepository transactionRepository
    ) {
        this.paymentRepository = paymentRepository;
        this.transactionRepository = transactionRepository;
    }


    // =========================================================
    // CREATE PAYMENT
    // =========================================================

    public Payment createPayment(
            Long transactionId,
            BigDecimal amount,
            PaymentMethod method
    ) {

        if (transactionId == null) {
            throw new IllegalArgumentException(
                    "Transaction ID cannot be null."
            );
        }

        if (amount == null
                || amount.compareTo(BigDecimal.ZERO) <= 0) {

            throw new IllegalArgumentException(
                    "Payment amount must be greater than zero."
            );
        }

        if (method == null) {
            throw new IllegalArgumentException(
                    "Payment method cannot be null."
            );
        }

        Transaction transaction =
                transactionRepository.findById(transactionId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Transaction not found with ID: "
                                                + transactionId
                                )
                        );

        if (transaction.getStatus()
                != TransactionStatus.CONFIRMED) {

            throw new IllegalStateException(
                    "Transaction must be confirmed before payment."
            );
        }

        Payment payment = new Payment(
                amount,
                method,
                transaction
        );

        return paymentRepository.save(payment);
    }


    // =========================================================
    // READ
    // =========================================================

    @Transactional(readOnly = true)
    public Payment getPaymentById(Long paymentId) {

        validatePaymentId(paymentId);

        return paymentRepository.findById(paymentId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Payment not found with ID: "
                                        + paymentId
                        )
                );
    }


    @Transactional(readOnly = true)
    public List<Payment> getAllPayments() {
        return paymentRepository.findAll();
    }


    @Transactional(readOnly = true)
    public List<Payment> getPaymentsByTransaction(
            Long transactionId
    ) {

        if (transactionId == null) {
            throw new IllegalArgumentException(
                    "Transaction ID cannot be null."
            );
        }

        return paymentRepository
                .findByTransactionTransactionId(
                        transactionId
                );
    }


    @Transactional(readOnly = true)
    public List<Payment> getPaymentsByStatus(
            PaymentStatus status
    ) {

        if (status == null) {
            throw new IllegalArgumentException(
                    "Payment status cannot be null."
            );
        }

        return paymentRepository.findByStatus(status);
    }


    @Transactional(readOnly = true)
    public Payment getPaymentByReference(
            String paymentReference
    ) {

        if (paymentReference == null
                || paymentReference.isBlank()) {

            throw new IllegalArgumentException(
                    "Payment reference cannot be empty."
            );
        }

        return paymentRepository
                .findByPaymentReference(paymentReference)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Payment not found with reference: "
                                        + paymentReference
                        )
                );
    }


    // =========================================================
    // PROCESS PAYMENT
    // PENDING -> PROCESSING
    // =========================================================

    public Payment processPayment(Long paymentId) {

        Payment payment = getPaymentById(paymentId);

        payment.markAsProcessing();

        return paymentRepository.save(payment);
    }


    // =========================================================
    // PAYMENT SUCCESS
    // PROCESSING/PENDING -> PAID
    // Transaction CONFIRMED -> PAID
    // =========================================================

    public Payment completePayment(
            Long paymentId,
            String paymentReference
    ) {

        if (paymentReference == null
                || paymentReference.isBlank()) {

            throw new IllegalArgumentException(
                    "Payment reference cannot be empty."
            );
        }

        Payment payment = getPaymentById(paymentId);

        Transaction transaction =
                payment.getTransaction();

        if (transaction.getStatus()
                != TransactionStatus.CONFIRMED) {

            throw new IllegalStateException(
                    "Transaction must be confirmed before payment."
            );
        }

        payment.markAsPaid(
                paymentReference.trim()
        );

        transaction.markAsPaid();

        transactionRepository.save(transaction);

        return paymentRepository.save(payment);
    }


    // =========================================================
    // PAYMENT FAILED
    // =========================================================

    public Payment failPayment(Long paymentId) {

        Payment payment = getPaymentById(paymentId);

        payment.fail();

        return paymentRepository.save(payment);
    }


    // =========================================================
    // REFUND
    // =========================================================

    public Payment refundPayment(Long paymentId) {

        Payment payment = getPaymentById(paymentId);

        payment.refund();

        return paymentRepository.save(payment);
    }


    // =========================================================
    // DELETE
    // =========================================================

    public void deletePayment(Long paymentId) {

        Payment payment = getPaymentById(paymentId);

        paymentRepository.delete(payment);
    }


    // =========================================================
    // VALIDATION
    // =========================================================

    private void validatePaymentId(Long paymentId) {

        if (paymentId == null) {
            throw new IllegalArgumentException(
                    "Payment ID cannot be null."
            );
        }
    }
    // =========================================================
// CUSTOMER OWNERSHIP
// =========================================================

    @Transactional(readOnly = true)
    public Payment getPaymentOwnedByCustomer(
            Long paymentId,
            Customer customer
    ) {

        if (customer == null
                || customer.getUserId() == null) {

            throw new IllegalArgumentException(
                    "Customer cannot be null."
            );
        }

        Payment payment =
                getPaymentById(paymentId);

        Transaction transaction =
                payment.getTransaction();

        if (transaction == null
                || transaction.getCustomer() == null
                || transaction.getCustomer()
                .getUserId() == null
                || !transaction.getCustomer()
                .getUserId()
                .equals(customer.getUserId())) {

            throw new IllegalStateException(
                    "You do not own this payment."
            );
        }

        return payment;
    }


// =========================================================
// OWNER OWNERSHIP
// =========================================================

    @Transactional(readOnly = true)
    public Payment getPaymentOwnedByOwner(
            Long paymentId,
            Owner owner
    ) {

        if (owner == null
                || owner.getUserId() == null) {

            throw new IllegalArgumentException(
                    "Owner cannot be null."
            );
        }

        Payment payment =
                getPaymentById(paymentId);

        Transaction transaction =
                payment.getTransaction();

        if (transaction == null
                || transaction.getPosting() == null
                || transaction.getPosting()
                .getOwner() == null
                || transaction.getPosting()
                .getOwner()
                .getUserId() == null
                || !transaction.getPosting()
                .getOwner()
                .getUserId()
                .equals(owner.getUserId())) {

            throw new IllegalStateException(
                    "You do not own the transaction of this payment."
            );
        }

        return payment;
    }
}