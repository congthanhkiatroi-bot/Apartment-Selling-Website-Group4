package com.apartment.website.transaction.controller;

import com.apartment.website.transaction.entity.Payment;
import com.apartment.website.transaction.entity.Payment.PaymentMethod;
import com.apartment.website.transaction.service.PaymentService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@Controller
@RequestMapping("/payments")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(
            PaymentService paymentService
    ) {
        this.paymentService = paymentService;
    }


    // =========================================================
    // PAYMENT DETAIL
    // =========================================================

    @GetMapping("/{paymentId}")
    public String paymentDetail(
            @PathVariable Long paymentId,
            Model model
    ) {

        Payment payment =
                paymentService.getPaymentById(
                        paymentId
                );

        model.addAttribute(
                "payment",
                payment
        );

        return "transaction/payment-detail";
    }


    // =========================================================
    // TRANSACTION PAYMENTS
    // =========================================================

    @GetMapping("/transaction/{transactionId}")
    public String transactionPayments(
            @PathVariable Long transactionId,
            Model model
    ) {

        model.addAttribute(
                "payments",
                paymentService
                        .getPaymentsByTransaction(
                                transactionId
                        )
        );

        model.addAttribute(
                "transactionId",
                transactionId
        );

        return "transaction/payments";
    }


    // =========================================================
    // CREATE PAYMENT
    // =========================================================

    @PostMapping("/create")
    public String createPayment(
            @RequestParam Long transactionId,
            @RequestParam BigDecimal amount,
            @RequestParam PaymentMethod method
    ) {

        Payment payment =
                paymentService.createPayment(
                        transactionId,
                        amount,
                        method
                );

        return "redirect:/payments/"
                + payment.getPaymentId();
    }


    // =========================================================
    // PROCESS
    // =========================================================

    @PostMapping("/{paymentId}/process")
    public String processPayment(
            @PathVariable Long paymentId
    ) {

        paymentService.processPayment(
                paymentId
        );

        return "redirect:/payments/"
                + paymentId;
    }


    // =========================================================
    // COMPLETE PAYMENT
    // =========================================================

    @PostMapping("/{paymentId}/complete")
    public String completePayment(
            @PathVariable Long paymentId,
            @RequestParam String paymentReference
    ) {

        paymentService.completePayment(
                paymentId,
                paymentReference
        );

        return "redirect:/payments/"
                + paymentId;
    }


    // =========================================================
    // FAIL
    // =========================================================

    @PostMapping("/{paymentId}/fail")
    public String failPayment(
            @PathVariable Long paymentId
    ) {

        paymentService.failPayment(
                paymentId
        );

        return "redirect:/payments/"
                + paymentId;
    }


    // =========================================================
    // REFUND
    // =========================================================

    @PostMapping("/{paymentId}/refund")
    public String refundPayment(
            @PathVariable Long paymentId
    ) {

        paymentService.refundPayment(
                paymentId
        );

        return "redirect:/payments/"
                + paymentId;
    }


    // =========================================================
    // DELETE
    // =========================================================

    @PostMapping("/{paymentId}/delete")
    public String deletePayment(
            @PathVariable Long paymentId,
            @RequestParam Long transactionId
    ) {

        paymentService.deletePayment(
                paymentId
        );

        return "redirect:/payments/transaction/"
                + transactionId;
    }
}