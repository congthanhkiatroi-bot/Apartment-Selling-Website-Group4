package com.apartment.website.transaction.controller;

import com.apartment.website.transaction.service.TransactionWorkflowService;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/admin/transactions")
public class AdminTransactionWorkflowController {

    private final TransactionWorkflowService workflowService;

    public AdminTransactionWorkflowController(
            TransactionWorkflowService workflowService
    ) {
        this.workflowService = workflowService;
    }


    @PostMapping("/{transactionId}/complete")
    public String complete(
            @PathVariable Long transactionId
    ) {

        workflowService.completeTransaction(
                transactionId
        );

        return "redirect:/admin/transactions";
    }
}