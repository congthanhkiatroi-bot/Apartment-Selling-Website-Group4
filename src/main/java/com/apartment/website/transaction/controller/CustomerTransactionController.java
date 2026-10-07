package com.apartment.website.transaction.controller;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.service.CurrentUserService;

import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.service.PostingService;

import com.apartment.website.transaction.dto.CustomerTransactionRequest;
import com.apartment.website.transaction.entity.Transaction;
import com.apartment.website.transaction.service.TransactionService;

import jakarta.validation.Valid;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/customer/transactions")
public class CustomerTransactionController {

    private final TransactionService transactionService;
    private final PostingService postingService;
    private final CurrentUserService currentUserService;

    public CustomerTransactionController(
            TransactionService transactionService,
            PostingService postingService,
            CurrentUserService currentUserService
    ) {
        this.transactionService = transactionService;
        this.postingService = postingService;
        this.currentUserService = currentUserService;
    }


    @GetMapping
    public String transactions(
            Model model
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer();

        model.addAttribute(
                "transactions",
                transactionService.getTransactionsByCustomer(
                        customer.getUserId()
                )
        );

        return "customer/transactions";
    }


    @GetMapping("/{transactionId}")
    public String detail(
            @PathVariable Long transactionId,
            Model model
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer();

        Transaction transaction =
                transactionService
                        .getTransactionOwnedByCustomer(
                                transactionId,
                                customer
                        );

        model.addAttribute(
                "transaction",
                transaction
        );

        return "customer/transaction-detail";
    }


    @GetMapping("/create/{postingId}")
    public String createForm(
            @PathVariable Long postingId,
            Model model
    ) {

        Posting posting =
                postingService
                        .getPublishedPostingById(
                                postingId
                        );

        CustomerTransactionRequest request =
                new CustomerTransactionRequest();

        request.setPostingId(postingId);

        /*
         * Giá ban đầu lấy từ Property.
         * Sau này nếu nghiệp vụ cho phép thương lượng,
         * Customer có thể chỉnh agreedPrice trên form.
         */
        request.setAgreedPrice(
                posting.getProperty().getPrice()
        );

        model.addAttribute(
                "transactionRequest",
                request
        );

        model.addAttribute(
                "posting",
                posting
        );

        return "customer/transaction-form";
    }


    @PostMapping("/create")
    public String create(
            @Valid
            @ModelAttribute("transactionRequest")
            CustomerTransactionRequest request,

            BindingResult bindingResult,

            Model model
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer();

        Posting posting =
                postingService
                        .getPublishedPostingById(
                                request.getPostingId()
                        );

        if (bindingResult.hasErrors()) {

            model.addAttribute(
                    "posting",
                    posting
            );

            return "customer/transaction-form";
        }

        Transaction transaction =
                transactionService.createTransaction(
                        request.getAgreedPrice(),
                        customer,
                        posting
                );

        return "redirect:/customer/transactions/"
                + transaction.getTransactionId();
    }


    @PostMapping("/{transactionId}/cancel")
    public String cancel(
            @PathVariable Long transactionId
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer();

        transactionService
                .cancelTransactionByCustomer(
                        transactionId,
                        customer
                );

        return "redirect:/customer/transactions/"
                + transactionId;
    }
}