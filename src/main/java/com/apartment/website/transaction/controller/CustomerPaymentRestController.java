package com.apartment.website.transaction.controller;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.service.CurrentUserService;

import com.apartment.website.transaction.dto.CustomerPaymentRequest;
import com.apartment.website.transaction.entity.Payment;
import com.apartment.website.transaction.entity.Transaction;
import com.apartment.website.transaction.service.PaymentService;
import com.apartment.website.transaction.service.TransactionService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customer/transactions")
public class CustomerPaymentRestController {

    private final TransactionService transactionService;
    private final PaymentService paymentService;
    private final CurrentUserService currentUserService;

    public CustomerPaymentRestController(
            TransactionService transactionService,
            PaymentService paymentService,
            CurrentUserService currentUserService
    ) {
        this.transactionService = transactionService;
        this.paymentService = paymentService;
        this.currentUserService = currentUserService;
    }


    @GetMapping("/{transactionId}/payments")
    public List<Payment> getPayments(
            @PathVariable Long transactionId
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer();

        transactionService
                .getTransactionOwnedByCustomer(
                        transactionId,
                        customer
                );

        return paymentService
                .getPaymentsByTransaction(
                        transactionId
                );
    }


    @PostMapping("/{transactionId}/payments")
    @ResponseStatus(HttpStatus.CREATED)
    public Payment createPayment(
            @PathVariable Long transactionId,

            @Valid
            @RequestBody
            CustomerPaymentRequest request
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer();

        Transaction transaction =
                transactionService
                        .getTransactionOwnedByCustomer(
                                transactionId,
                                customer
                        );

        if (transaction.getStatus()
                != Transaction.TransactionStatus.CONFIRMED) {

            throw new IllegalStateException(
                    "Only confirmed transactions can be paid."
            );
        }

        return paymentService.createPayment(
                transactionId,
                request.getAmount(),
                request.getMethod()
        );
    }


    @GetMapping(
            "/{transactionId}/payments/{paymentId}"
    )
    public Payment getPayment(
            @PathVariable Long transactionId,
            @PathVariable Long paymentId
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer();

        Transaction transaction =
                transactionService
                        .getTransactionOwnedByCustomer(
                                transactionId,
                                customer
                        );

        Payment payment =
                paymentService
                        .getPaymentOwnedByCustomer(
                                paymentId,
                                customer
                        );

        if (!payment.getTransaction()
                .getTransactionId()
                .equals(transaction.getTransactionId())) {

            throw new IllegalStateException(
                    "Payment does not belong to this transaction."
            );
        }

        return payment;
    }
}