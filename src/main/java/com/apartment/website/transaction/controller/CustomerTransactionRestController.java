package com.apartment.website.transaction.controller;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.service.CurrentUserService;

import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.service.PostingService;

import com.apartment.website.transaction.dto.CustomerTransactionRequest;
import com.apartment.website.transaction.entity.Transaction;
import com.apartment.website.transaction.service.TransactionService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customer/transactions")
public class CustomerTransactionRestController {

    private final TransactionService transactionService;
    private final PostingService postingService;
    private final CurrentUserService currentUserService;

    public CustomerTransactionRestController(
            TransactionService transactionService,
            PostingService postingService,
            CurrentUserService currentUserService
    ) {
        this.transactionService = transactionService;
        this.postingService = postingService;
        this.currentUserService = currentUserService;
    }


    @GetMapping
    public List<Transaction> getMyTransactions() {

        Customer customer =
                currentUserService.getCurrentCustomer();

        return transactionService
                .getTransactionsByCustomer(
                        customer.getUserId()
                );
    }


    @GetMapping("/{transactionId}")
    public Transaction getTransaction(
            @PathVariable Long transactionId
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer();

        return transactionService
                .getTransactionOwnedByCustomer(
                        transactionId,
                        customer
                );
    }


    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Transaction createTransaction(
            @Valid
            @RequestBody
            CustomerTransactionRequest request
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer();

        Posting posting =
                postingService
                        .getPublishedPostingById(
                                request.getPostingId()
                        );

        return transactionService
                .createTransaction(
                        request.getAgreedPrice(),
                        customer,
                        posting
                );
    }


    @PatchMapping("/{transactionId}/cancel")
    public Transaction cancelTransaction(
            @PathVariable Long transactionId
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer();

        return transactionService
                .cancelTransactionByCustomer(
                        transactionId,
                        customer
                );
    }
}