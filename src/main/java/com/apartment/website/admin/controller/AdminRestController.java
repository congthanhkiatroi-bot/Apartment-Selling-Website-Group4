package com.apartment.website.admin.controller;

import com.apartment.website.admin.service.AdminManagementService;

import com.apartment.website.auth.entity.User;
import com.apartment.website.communication.entity.Report;
import com.apartment.website.listing.entity.Posting;
import com.apartment.website.transaction.entity.Payment;
import com.apartment.website.transaction.entity.Transaction;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminRestController {

    private final AdminManagementService adminService;

    public AdminRestController(
            AdminManagementService adminService
    ) {
        this.adminService = adminService;
    }


    // =========================================================
    // USERS
    // =========================================================

    @GetMapping("/users")
    public List<User> users() {
        return adminService.getAllUsers();
    }


    @PatchMapping("/users/{userId}/activate")
    public User activateUser(
            @PathVariable Long userId
    ) {
        return adminService.activateUser(userId);
    }


    @PatchMapping("/users/{userId}/deactivate")
    public User deactivateUser(
            @PathVariable Long userId
    ) {
        return adminService.deactivateUser(userId);
    }


    // =========================================================
    // POSTINGS
    // =========================================================

    @GetMapping("/postings")
    public List<Posting> postings() {
        return adminService.getAllPostings();
    }


    @GetMapping("/postings/pending")
    public List<Posting> pendingPostings() {
        return adminService.getPendingPostings();
    }


    @PatchMapping("/postings/{postingId}/approve")
    public Posting approvePosting(
            @PathVariable Long postingId
    ) {
        return adminService.approvePosting(
                postingId
        );
    }


    @PatchMapping("/postings/{postingId}/reject")
    public Posting rejectPosting(
            @PathVariable Long postingId,
            @RequestParam String reason
    ) {
        return adminService.rejectPosting(
                postingId,
                reason
        );
    }


    // =========================================================
    // REPORTS
    // =========================================================

    @GetMapping("/reports")
    public List<Report> reports() {
        return adminService.getAllReports();
    }


    @PatchMapping("/reports/{reportId}/review")
    public Report reviewReport(
            @PathVariable Long reportId
    ) {
        return adminService.startReviewReport(
                reportId
        );
    }


    @PatchMapping("/reports/{reportId}/resolve")
    public Report resolveReport(
            @PathVariable Long reportId
    ) {
        return adminService.resolveReport(
                reportId
        );
    }


    @PatchMapping("/reports/{reportId}/reject")
    public Report rejectReport(
            @PathVariable Long reportId
    ) {
        return adminService.rejectReport(
                reportId
        );
    }


    @PatchMapping("/reports/{reportId}/reopen")
    public Report reopenReport(
            @PathVariable Long reportId
    ) {
        return adminService.reopenReport(
                reportId
        );
    }


    // =========================================================
    // TRANSACTIONS
    // =========================================================

    @GetMapping("/transactions")
    public List<Transaction> transactions() {
        return adminService.getAllTransactions();
    }


    @PatchMapping(
            "/transactions/{transactionId}/complete"
    )
    public Transaction completeTransaction(
            @PathVariable Long transactionId
    ) {
        return adminService.completeTransaction(
                transactionId
        );
    }


    // =========================================================
    // PAYMENTS
    // =========================================================

    @GetMapping("/payments")
    public List<Payment> payments() {
        return adminService.getAllPayments();
    }


    @PatchMapping("/payments/{paymentId}/process")
    public Payment processPayment(
            @PathVariable Long paymentId
    ) {
        return adminService.processPayment(
                paymentId
        );
    }


    @PatchMapping("/payments/{paymentId}/complete")
    public Payment completePayment(
            @PathVariable Long paymentId,
            @RequestParam String paymentReference
    ) {
        return adminService.completePayment(
                paymentId,
                paymentReference
        );
    }


    @PatchMapping("/payments/{paymentId}/fail")
    public Payment failPayment(
            @PathVariable Long paymentId
    ) {
        return adminService.failPayment(
                paymentId
        );
    }
}