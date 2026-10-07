package com.apartment.website.transaction.controller;

import com.apartment.website.auth.entity.Owner;
import com.apartment.website.auth.service.CurrentUserService;

import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.service.PostingService;

import com.apartment.website.transaction.entity.Transaction;
import com.apartment.website.transaction.service.TransactionService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/owner/transactions")
public class OwnerTransactionController {

    private final TransactionService transactionService;
    private final PostingService postingService;
    private final CurrentUserService currentUserService;

    public OwnerTransactionController(
            TransactionService transactionService,
            PostingService postingService,
            CurrentUserService currentUserService
    ) {
        this.transactionService = transactionService;
        this.postingService = postingService;
        this.currentUserService = currentUserService;
    }


    @GetMapping("/posting/{postingId}")
    public String byPosting(
            @PathVariable Long postingId,
            Model model
    ) {

        Owner owner =
                currentUserService.getCurrentOwner();

        Posting posting =
                postingService.getPostingOwnedBy(
                        postingId,
                        owner
                );

        model.addAttribute(
                "posting",
                posting
        );

        model.addAttribute(
                "transactions",
                transactionService
                        .getTransactionsByPosting(
                                postingId
                        )
        );

        return "owner/transactions";
    }


    @GetMapping("/{transactionId}")
    public String detail(
            @PathVariable Long transactionId,
            Model model
    ) {

        Owner owner =
                currentUserService.getCurrentOwner();

        Transaction transaction =
                transactionService
                        .getTransactionOwnedByOwner(
                                transactionId,
                                owner
                        );

        model.addAttribute(
                "transaction",
                transaction
        );

        return "owner/transaction-detail";
    }


    @PostMapping("/{transactionId}/confirm")
    public String confirm(
            @PathVariable Long transactionId
    ) {

        Owner owner =
                currentUserService.getCurrentOwner();

        transactionService
                .confirmTransactionByOwner(
                        transactionId,
                        owner
                );

        return "redirect:/owner/transactions/"
                + transactionId;
    }


    @PostMapping("/{transactionId}/cancel")
    public String cancel(
            @PathVariable Long transactionId
    ) {

        Owner owner =
                currentUserService.getCurrentOwner();

        transactionService
                .cancelTransactionByOwner(
                        transactionId,
                        owner
                );

        return "redirect:/owner/transactions/"
                + transactionId;
    }
}