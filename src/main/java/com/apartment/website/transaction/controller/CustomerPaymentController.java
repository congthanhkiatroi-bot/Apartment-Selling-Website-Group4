package com.apartment.website.transaction.controller;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.service.CurrentUserService;

import com.apartment.website.transaction.dto.CustomerPaymentRequest;
import com.apartment.website.transaction.entity.Payment;
import com.apartment.website.transaction.entity.Transaction;
import com.apartment.website.transaction.service.PaymentService;
import com.apartment.website.transaction.service.TransactionService;

import jakarta.validation.Valid;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/customer/transactions")
public class CustomerPaymentController {

    private final TransactionService transactionService;
    private final PaymentService paymentService;
    private final CurrentUserService currentUserService;

    public CustomerPaymentController(
            TransactionService transactionService,
            PaymentService paymentService,
            CurrentUserService currentUserService
    ) {
        this.transactionService = transactionService;
        this.paymentService = paymentService;
        this.currentUserService = currentUserService;
    }


    // =========================================================
    // PAYMENT FORM
    // =========================================================

    @GetMapping("/{transactionId}/payments/create")
    public String paymentForm(
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

        if (transaction.getStatus()
                != Transaction.TransactionStatus.CONFIRMED) {

            throw new IllegalStateException(
                    "Only confirmed transactions can be paid."
            );
        }

        CustomerPaymentRequest request =
                new CustomerPaymentRequest();

        request.setAmount(
                transaction.getAgreedPrice()
        );

        model.addAttribute(
                "paymentRequest",
                request
        );

        model.addAttribute(
                "transaction",
                transaction
        );

        model.addAttribute(
                "paymentMethods",
                Payment.PaymentMethod.values()
        );

        return "customer/payment-form";
    }


    // =========================================================
    // CREATE PAYMENT
    // =========================================================

    @PostMapping("/{transactionId}/payments")
    public String createPayment(
            @PathVariable Long transactionId,

            @Valid
            @ModelAttribute("paymentRequest")
            CustomerPaymentRequest request,

            BindingResult bindingResult,

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

        if (bindingResult.hasErrors()) {

            model.addAttribute(
                    "transaction",
                    transaction
            );

            model.addAttribute(
                    "paymentMethods",
                    Payment.PaymentMethod.values()
            );

            return "customer/payment-form";
        }

        Payment payment =
                paymentService.createPayment(
                        transactionId,
                        request.getAmount(),
                        request.getMethod()
                );

        return "redirect:/customer/transactions/"
                + transactionId
                + "/payments/"
                + payment.getPaymentId();
    }


    // =========================================================
    // PAYMENT DETAIL
    // =========================================================

    @GetMapping(
            "/{transactionId}/payments/{paymentId}"
    )
    public String paymentDetail(
            @PathVariable Long transactionId,
            @PathVariable Long paymentId,
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

        model.addAttribute(
                "transaction",
                transaction
        );

        model.addAttribute(
                "payment",
                payment
        );

        return "customer/payment-detail";
    }
}