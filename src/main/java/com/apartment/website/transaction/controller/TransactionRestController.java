package com.apartment.website.transaction.controller;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.repository.CustomerRepository;
import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.service.PostingService;
import com.apartment.website.transaction.dto.TransactionRequest;
import com.apartment.website.transaction.entity.Transaction;
import com.apartment.website.transaction.entity.Transaction.TransactionStatus;
import com.apartment.website.transaction.service.TransactionService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/transactions")
public class TransactionRestController {

    private final TransactionService transactionService;
    private final CustomerRepository customerRepository;
    private final PostingService postingService;

    public TransactionRestController(
            TransactionService transactionService,
            CustomerRepository customerRepository,
            PostingService postingService
    ) {
        this.transactionService = transactionService;
        this.customerRepository = customerRepository;
        this.postingService = postingService;
    }


    // =========================================================
    // GET ALL
    // =========================================================

    @GetMapping
    public ResponseEntity<List<Transaction>>
    getAllTransactions() {

        return ResponseEntity.ok(
                transactionService.getAllTransactions()
        );
    }


    // =========================================================
    // GET BY ID
    // =========================================================

    @GetMapping("/{transactionId}")
    public ResponseEntity<Transaction>
    getTransactionById(
            @PathVariable Long transactionId
    ) {

        return ResponseEntity.ok(
                transactionService
                        .getTransactionById(transactionId)
        );
    }


    // =========================================================
    // GET BY CUSTOMER
    // =========================================================

    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<Transaction>>
    getTransactionsByCustomer(
            @PathVariable Long customerId
    ) {

        return ResponseEntity.ok(
                transactionService
                        .getTransactionsByCustomer(customerId)
        );
    }


    // =========================================================
    // GET BY POSTING
    // =========================================================

    @GetMapping("/posting/{postingId}")
    public ResponseEntity<List<Transaction>>
    getTransactionsByPosting(
            @PathVariable Long postingId
    ) {

        return ResponseEntity.ok(
                transactionService
                        .getTransactionsByPosting(postingId)
        );
    }


    // =========================================================
    // GET BY STATUS
    // =========================================================

    @GetMapping("/status/{status}")
    public ResponseEntity<List<Transaction>>
    getTransactionsByStatus(
            @PathVariable TransactionStatus status
    ) {

        return ResponseEntity.ok(
                transactionService
                        .getTransactionsByStatus(status)
        );
    }


    // =========================================================
    // CREATE
    // =========================================================

    @PostMapping
    public ResponseEntity<Transaction>
    createTransaction(
            @Valid
            @RequestBody TransactionRequest request
    ) {

        Customer customer =
                getCustomer(
                        request.getCustomerId()
                );

        Posting posting =
                postingService.getPostingById(
                        request.getPostingId()
                );

        Transaction transaction =
                transactionService.createTransaction(
                        request.getAgreedPrice(),
                        customer,
                        posting
                );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(transaction);
    }


    // =========================================================
    // CONFIRM
    // =========================================================

    @PatchMapping("/{transactionId}/confirm")
    public ResponseEntity<Transaction>
    confirmTransaction(
            @PathVariable Long transactionId
    ) {

        return ResponseEntity.ok(
                transactionService
                        .confirmTransaction(transactionId)
        );
    }


    // =========================================================
    // COMPLETE
    // =========================================================

    @PatchMapping("/{transactionId}/complete")
    public ResponseEntity<Transaction>
    completeTransaction(
            @PathVariable Long transactionId
    ) {

        return ResponseEntity.ok(
                transactionService
                        .completeTransaction(transactionId)
        );
    }


    // =========================================================
    // CANCEL
    // =========================================================

    @PatchMapping("/{transactionId}/cancel")
    public ResponseEntity<Transaction>
    cancelTransaction(
            @PathVariable Long transactionId
    ) {

        return ResponseEntity.ok(
                transactionService
                        .cancelTransaction(transactionId)
        );
    }


    // =========================================================
    // DELETE
    // =========================================================

    @DeleteMapping("/{transactionId}")
    public ResponseEntity<Void>
    deleteTransaction(
            @PathVariable Long transactionId
    ) {

        transactionService.deleteTransaction(
                transactionId
        );

        return ResponseEntity.noContent().build();
    }


    // =========================================================
    // HELPER
    // =========================================================

    private Customer getCustomer(Long customerId) {

        if (customerId == null) {
            throw new IllegalArgumentException(
                    "Customer ID cannot be null."
            );
        }

        return customerRepository
                .findById(customerId)
                .orElseThrow(
                        () -> new IllegalArgumentException(
                                "Customer not found with ID: "
                                        + customerId
                        )
                );
    }
}