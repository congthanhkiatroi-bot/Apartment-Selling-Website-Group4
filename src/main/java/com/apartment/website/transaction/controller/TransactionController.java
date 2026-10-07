package com.apartment.website.transaction.controller;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.repository.CustomerRepository;
import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.service.PostingService;
import com.apartment.website.transaction.entity.Transaction;
import com.apartment.website.transaction.service.TransactionService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@Controller
@RequestMapping("/transactions")
public class TransactionController {

    private final TransactionService transactionService;
    private final CustomerRepository customerRepository;
    private final PostingService postingService;

    public TransactionController(
            TransactionService transactionService,
            CustomerRepository customerRepository,
            PostingService postingService
    ) {
        this.transactionService = transactionService;
        this.customerRepository = customerRepository;
        this.postingService = postingService;
    }


    // =========================================================
    // CUSTOMER TRANSACTIONS
    // =========================================================

    @GetMapping("/customer/{customerId}")
    public String customerTransactions(
            @PathVariable Long customerId,
            Model model
    ) {

        model.addAttribute(
                "transactions",
                transactionService
                        .getTransactionsByCustomer(customerId)
        );

        return "transaction/customer-transactions";
    }


    // =========================================================
    // TRANSACTION DETAIL
    // =========================================================

    @GetMapping("/{transactionId}")
    public String transactionDetail(
            @PathVariable Long transactionId,
            Model model
    ) {

        Transaction transaction =
                transactionService
                        .getTransactionById(transactionId);

        model.addAttribute(
                "transaction",
                transaction
        );

        return "transaction/detail";
    }


    // =========================================================
    // CREATE
    // =========================================================

    @PostMapping("/create")
    public String createTransaction(
            @RequestParam Long customerId,
            @RequestParam Long postingId,
            @RequestParam BigDecimal agreedPrice
    ) {

        Customer customer =
                getCustomer(customerId);

        Posting posting =
                postingService.getPostingById(postingId);

        Transaction transaction =
                transactionService.createTransaction(
                        agreedPrice,
                        customer,
                        posting
                );

        return "redirect:/transactions/"
                + transaction.getTransactionId();
    }


    // =========================================================
    // CONFIRM
    // =========================================================

    @PostMapping("/{transactionId}/confirm")
    public String confirmTransaction(
            @PathVariable Long transactionId
    ) {

        transactionService.confirmTransaction(
                transactionId
        );

        return "redirect:/transactions/"
                + transactionId;
    }


    // =========================================================
    // COMPLETE
    // =========================================================

    @PostMapping("/{transactionId}/complete")
    public String completeTransaction(
            @PathVariable Long transactionId
    ) {

        transactionService.completeTransaction(
                transactionId
        );

        return "redirect:/transactions/"
                + transactionId;
    }


    // =========================================================
    // CANCEL
    // =========================================================

    @PostMapping("/{transactionId}/cancel")
    public String cancelTransaction(
            @PathVariable Long transactionId
    ) {

        transactionService.cancelTransaction(
                transactionId
        );

        return "redirect:/transactions/"
                + transactionId;
    }


    // =========================================================
    // DELETE
    // =========================================================

    @PostMapping("/{transactionId}/delete")
    public String deleteTransaction(
            @PathVariable Long transactionId,
            @RequestParam Long customerId
    ) {

        transactionService.deleteTransaction(
                transactionId
        );

        return "redirect:/transactions/customer/"
                + customerId;
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