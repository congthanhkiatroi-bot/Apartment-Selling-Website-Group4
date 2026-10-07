package com.apartment.website.transaction.controller;

import com.apartment.website.transaction.service.TransactionWorkflowService;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/admin/payments")
public class AdminPaymentWorkflowController {

    private final TransactionWorkflowService workflowService;

    public AdminPaymentWorkflowController(
            TransactionWorkflowService workflowService
    ) {
        this.workflowService = workflowService;
    }


    @PostMapping("/{paymentId}/process")
    public String process(
            @PathVariable Long paymentId
    ) {

        workflowService.processPayment(
                paymentId
        );

        return "redirect:/admin/payments";
    }


    @PostMapping("/{paymentId}/complete")
    public String complete(
            @PathVariable Long paymentId,

            @RequestParam
            String paymentReference
    ) {

        workflowService.completePayment(
                paymentId,
                paymentReference
        );

        return "redirect:/admin/payments";
    }


    @PostMapping("/{paymentId}/fail")
    public String fail(
            @PathVariable Long paymentId
    ) {

        workflowService.failPayment(
                paymentId
        );

        return "redirect:/admin/payments";
    }
}