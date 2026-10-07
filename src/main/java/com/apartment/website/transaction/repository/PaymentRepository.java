package com.apartment.website.transaction.repository;

import com.apartment.website.transaction.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PaymentRepository
        extends JpaRepository<Payment, Long> {

    List<Payment> findByTransactionTransactionId(
            Long transactionId
    );

    Optional<Payment> findByPaymentReference(
            String paymentReference
    );

    List<Payment> findByStatus(
            Payment.PaymentStatus status
    );
}