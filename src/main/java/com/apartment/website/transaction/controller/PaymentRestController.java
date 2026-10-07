package com.apartment.website.transaction.controller;

import com.apartment.website.transaction.dto.PaymentCompleteRequest;
import com.apartment.website.transaction.dto.PaymentRequest;
import com.apartment.website.transaction.entity.Payment;
import com.apartment.website.transaction.entity.Payment.PaymentStatus;
import com.apartment.website.transaction.service.PaymentService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/payments")
public class PaymentRestController {

    private final PaymentService paymentService;

    public PaymentRestController(
            PaymentService paymentService
    ) {
        this.paymentService = paymentService;
    }


    // =========================================================
    // GET ALL
    // =========================================================

    @GetMapping
    public ResponseEntity<List<Payment>>
    getAllPayments() {

        return ResponseEntity.ok(
                paymentService.getAllPayments()
        );
    }


    // =========================================================
    // GET BY ID
    // =========================================================

    @GetMapping("/{paymentId}")
    public ResponseEntity<Payment>
    getPaymentById(
            @PathVariable Long paymentId
    ) {

        return ResponseEntity.ok(
                paymentService.getPaymentById(
                        paymentId
                )
        );
    }


    // =========================================================
    // GET BY TRANSACTION
    // =========================================================

    @GetMapping("/transaction/{transactionId}")
    public ResponseEntity<List<Payment>>
    getPaymentsByTransaction(
            @PathVariable Long transactionId
    ) {

        return ResponseEntity.ok(
                paymentService
                        .getPaymentsByTransaction(
                                transactionId
                        )
        );
    }


    // =========================================================
    // GET BY STATUS
    // =========================================================

    @GetMapping("/status/{status}")
    public ResponseEntity<List<Payment>>
    getPaymentsByStatus(
            @PathVariable PaymentStatus status
    ) {

        return ResponseEntity.ok(
                paymentService
                        .getPaymentsByStatus(status)
        );
    }


    // =========================================================
    // GET BY REFERENCE
    // =========================================================

    @GetMapping("/reference/{paymentReference}")
    public ResponseEntity<Payment>
    getPaymentByReference(
            @PathVariable String paymentReference
    ) {

        return ResponseEntity.ok(
                paymentService
                        .getPaymentByReference(
                                paymentReference
                        )
        );
    }


    // =========================================================
    // CREATE
    // =========================================================

    @PostMapping
    public ResponseEntity<Payment>
    createPayment(
            @Valid
            @RequestBody PaymentRequest request
    ) {

        Payment payment =
                paymentService.createPayment(
                        request.getTransactionId(),
                        request.getAmount(),
                        request.getMethod()
                );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(payment);
    }


    // =========================================================
    // PROCESS
    // =========================================================

    @PatchMapping("/{paymentId}/process")
    public ResponseEntity<Payment>
    processPayment(
            @PathVariable Long paymentId
    ) {

        return ResponseEntity.ok(
                paymentService.processPayment(
                        paymentId
                )
        );
    }


    // =========================================================
    // COMPLETE PAYMENT
    // =========================================================

    @PatchMapping("/{paymentId}/complete")
    public ResponseEntity<Payment>
    completePayment(
            @PathVariable Long paymentId,

            @Valid
            @RequestBody
            PaymentCompleteRequest request
    ) {

        return ResponseEntity.ok(
                paymentService.completePayment(
                        paymentId,
                        request.getPaymentReference()
                )
        );
    }


    // =========================================================
    // FAIL
    // =========================================================

    @PatchMapping("/{paymentId}/fail")
    public ResponseEntity<Payment>
    failPayment(
            @PathVariable Long paymentId
    ) {

        return ResponseEntity.ok(
                paymentService.failPayment(
                        paymentId
                )
        );
    }


    // =========================================================
    // REFUND
    // =========================================================

    @PatchMapping("/{paymentId}/refund")
    public ResponseEntity<Payment>
    refundPayment(
            @PathVariable Long paymentId
    ) {

        return ResponseEntity.ok(
                paymentService.refundPayment(
                        paymentId
                )
        );
    }


    // =========================================================
    // DELETE
    // =========================================================

    @DeleteMapping("/{paymentId}")
    public ResponseEntity<Void>
    deletePayment(
            @PathVariable Long paymentId
    ) {

        paymentService.deletePayment(
                paymentId
        );

        return ResponseEntity.noContent().build();
    }
}