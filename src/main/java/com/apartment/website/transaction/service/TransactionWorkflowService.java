package com.apartment.website.transaction.service;

import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.service.PostingService;

import com.apartment.website.transaction.entity.Payment;
import com.apartment.website.transaction.entity.Transaction;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class TransactionWorkflowService {

    private final TransactionService transactionService;
    private final PaymentService paymentService;
    private final PostingService postingService;

    public TransactionWorkflowService(
            TransactionService transactionService,
            PaymentService paymentService,
            PostingService postingService
    ) {
        this.transactionService = transactionService;
        this.paymentService = paymentService;
        this.postingService = postingService;
    }


    // =========================================================
    // PROCESS PAYMENT
    // =========================================================

    public Payment processPayment(
            Long paymentId
    ) {

        return paymentService
                .processPayment(paymentId);
    }


    // =========================================================
    // CONFIRM PAYMENT SUCCESS
    // =========================================================

    public Payment completePayment(
            Long paymentId,
            String paymentReference
    ) {

        return paymentService
                .completePayment(
                        paymentId,
                        paymentReference
                );
    }


    // =========================================================
    // FAIL PAYMENT
    // =========================================================

    public Payment failPayment(
            Long paymentId
    ) {

        return paymentService
                .failPayment(paymentId);
    }


    // =========================================================
    // COMPLETE TRANSACTION
    // =========================================================

    public Transaction completeTransaction(
            Long transactionId
    ) {

        Transaction transaction =
                transactionService
                        .getTransactionById(
                                transactionId
                        );

        if (transaction.getStatus()
                != Transaction.TransactionStatus.PAID) {

            throw new IllegalStateException(
                    "Only paid transactions can be completed."
            );
        }

        Transaction completed =
                transactionService
                        .completeTransaction(
                                transactionId
                        );

        Posting posting =
                transaction.getPosting();

        postingService.markPostingAsSold(
                posting.getPostingId()
        );

        return completed;
    }
}