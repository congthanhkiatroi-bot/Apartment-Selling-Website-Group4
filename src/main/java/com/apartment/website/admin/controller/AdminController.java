package com.apartment.website.admin.controller;

import com.apartment.website.admin.service.AdminManagementService;

import com.apartment.website.communication.entity.Report;
import com.apartment.website.listing.entity.Posting;
import com.apartment.website.transaction.entity.Payment;
import com.apartment.website.transaction.entity.Transaction;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/admin")
public class AdminController {

    private final AdminManagementService adminService;

    public AdminController(
            AdminManagementService adminService
    ) {
        this.adminService = adminService;
    }


    // =========================================================
    // DASHBOARD
    // =========================================================

    @GetMapping
    public String dashboard(
            Model model
    ) {

        model.addAttribute(
                "users",
                adminService.getAllUsers()
        );

        model.addAttribute(
                "pendingPostings",
                adminService.getPendingPostings()
        );

        model.addAttribute(
                "reports",
                adminService.getAllReports()
        );

        model.addAttribute(
                "transactions",
                adminService.getAllTransactions()
        );

        model.addAttribute(
                "payments",
                adminService.getAllPayments()
        );

        return "admin/dashboard";
    }


    // =========================================================
    // USERS
    // =========================================================

    @GetMapping("/users")
    public String users(
            Model model
    ) {

        model.addAttribute(
                "users",
                adminService.getAllUsers()
        );

        return "admin/users";
    }


    @PostMapping("/users/{userId}/activate")
    public String activateUser(
            @PathVariable Long userId
    ) {

        adminService.activateUser(userId);

        return "redirect:/admin/users";
    }


    @PostMapping("/users/{userId}/deactivate")
    public String deactivateUser(
            @PathVariable Long userId
    ) {

        adminService.deactivateUser(userId);

        return "redirect:/admin/users";
    }


    // =========================================================
    // POSTINGS
    // =========================================================

    @GetMapping("/postings")
    public String postings(
            Model model
    ) {

        model.addAttribute(
                "postings",
                adminService.getAllPostings()
        );

        return "admin/postings";
    }


    @GetMapping("/postings/pending")
    public String pendingPostings(
            Model model
    ) {

        model.addAttribute(
                "postings",
                adminService.getPendingPostings()
        );

        return "admin/pending-postings";
    }


    @PostMapping("/postings/{postingId}/approve")
    public String approvePosting(
            @PathVariable Long postingId
    ) {

        adminService.approvePosting(postingId);

        return "redirect:/admin/postings/pending";
    }


    @PostMapping("/postings/{postingId}/reject")
    public String rejectPosting(
            @PathVariable Long postingId,

            @RequestParam String reason
    ) {

        adminService.rejectPosting(
                postingId,
                reason
        );

        return "redirect:/admin/postings/pending";
    }


    // =========================================================
    // REPORTS
    // =========================================================

    @GetMapping("/reports")
    public String reports(
            Model model
    ) {

        model.addAttribute(
                "reports",
                adminService.getAllReports()
        );

        return "admin/reports";
    }


    @PostMapping("/reports/{reportId}/review")
    public String reviewReport(
            @PathVariable Long reportId
    ) {

        adminService.startReviewReport(
                reportId
        );

        return "redirect:/admin/reports";
    }


    @PostMapping("/reports/{reportId}/resolve")
    public String resolveReport(
            @PathVariable Long reportId
    ) {

        adminService.resolveReport(
                reportId
        );

        return "redirect:/admin/reports";
    }


    @PostMapping("/reports/{reportId}/reject")
    public String rejectReport(
            @PathVariable Long reportId
    ) {

        adminService.rejectReport(
                reportId
        );

        return "redirect:/admin/reports";
    }


    @PostMapping("/reports/{reportId}/reopen")
    public String reopenReport(
            @PathVariable Long reportId
    ) {

        adminService.reopenReport(
                reportId
        );

        return "redirect:/admin/reports";
    }


    // =========================================================
    // TRANSACTIONS
    // =========================================================

    @GetMapping("/transactions")
    public String transactions(
            Model model
    ) {

        model.addAttribute(
                "transactions",
                adminService.getAllTransactions()
        );

        return "admin/transactions";
    }


    @PostMapping(
            "/transactions/{transactionId}/complete"
    )
    public String completeTransaction(
            @PathVariable Long transactionId
    ) {

        adminService.completeTransaction(
                transactionId
        );

        return "redirect:/admin/transactions";
    }


    // =========================================================
    // PAYMENTS
    // =========================================================

    @GetMapping("/payments")
    public String payments(
            Model model
    ) {

        model.addAttribute(
                "payments",
                adminService.getAllPayments()
        );

        return "admin/payments";
    }


    @PostMapping("/payments/{paymentId}/process")
    public String processPayment(
            @PathVariable Long paymentId
    ) {

        adminService.processPayment(paymentId);

        return "redirect:/admin/payments";
    }


    @PostMapping("/payments/{paymentId}/complete")
    public String completePayment(
            @PathVariable Long paymentId,

            @RequestParam
            String paymentReference
    ) {

        adminService.completePayment(
                paymentId,
                paymentReference
        );

        return "redirect:/admin/payments";
    }


    @PostMapping("/payments/{paymentId}/fail")
    public String failPayment(
            @PathVariable Long paymentId
    ) {

        adminService.failPayment(paymentId);

        return "redirect:/admin/payments";
    }
}