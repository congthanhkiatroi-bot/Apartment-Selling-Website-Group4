package com.apartment.website.admin.service;

import com.apartment.website.auth.entity.User;
import com.apartment.website.auth.service.UserService;

import com.apartment.website.communication.entity.Report;
import com.apartment.website.communication.service.ReportService;

import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.service.PostingService;

import com.apartment.website.transaction.entity.Payment;
import com.apartment.website.transaction.entity.Transaction;
import com.apartment.website.transaction.service.PaymentService;
import com.apartment.website.transaction.service.TransactionService;
import com.apartment.website.transaction.service.TransactionWorkflowService;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class AdminManagementService {

    private final UserService userService;
    private final PostingService postingService;
    private final ReportService reportService;
    private final TransactionService transactionService;
    private final PaymentService paymentService;
    private final TransactionWorkflowService workflowService;

    public AdminManagementService(
            UserService userService,
            PostingService postingService,
            ReportService reportService,
            TransactionService transactionService,
            PaymentService paymentService,
            TransactionWorkflowService workflowService
    ) {
        this.userService = userService;
        this.postingService = postingService;
        this.reportService = reportService;
        this.transactionService = transactionService;
        this.paymentService = paymentService;
        this.workflowService = workflowService;
    }


    // =========================================================
    // USERS
    // =========================================================

    @Transactional(readOnly = true)
    public List<User> getAllUsers() {
        return userService.getAllUsers();
    }

    public User activateUser(Long userId) {
        return userService.activateUser(userId);
    }

    public User deactivateUser(Long userId) {
        return userService.deactivateUser(userId);
    }


    // =========================================================
    // POSTINGS
    // =========================================================

    @Transactional(readOnly = true)
    public List<Posting> getAllPostings() {
        return postingService.getAllPostings();
    }

    @Transactional(readOnly = true)
    public List<Posting> getPendingPostings() {
        return postingService.getPendingApprovalPostings();
    }

    public Posting approvePosting(Long postingId) {

        Posting posting =
                postingService.getPostingById(postingId);

        if (posting.getStatus()
                != Posting.PostingStatus.PENDING_APPROVAL) {

            throw new IllegalStateException(
                    "Only pending postings can be approved."
            );
        }

        return postingService.approvePosting(postingId);
    }

    public Posting rejectPosting(
            Long postingId,
            String reason
    ) {

        if (reason == null || reason.isBlank()) {
            throw new IllegalArgumentException(
                    "Rejection reason is required."
            );
        }

        Posting posting =
                postingService.getPostingById(postingId);

        if (posting.getStatus()
                != Posting.PostingStatus.PENDING_APPROVAL) {

            throw new IllegalStateException(
                    "Only pending postings can be rejected."
            );
        }

        return postingService.rejectPosting(
                postingId,
                reason.trim()
        );
    }


    // =========================================================
    // REPORTS
    // =========================================================

    @Transactional(readOnly = true)
    public List<Report> getAllReports() {
        return reportService.getAllReports();
    }

    public Report startReviewReport(
            Long reportId
    ) {
        return reportService.startReview(reportId);
    }

    public Report resolveReport(
            Long reportId
    ) {
        return reportService.resolveReport(reportId);
    }

    public Report rejectReport(
            Long reportId
    ) {
        return reportService.rejectReport(reportId);
    }

    public Report reopenReport(
            Long reportId
    ) {
        return reportService.reopenReport(reportId);
    }


    // =========================================================
    // TRANSACTIONS
    // =========================================================

    @Transactional(readOnly = true)
    public List<Transaction> getAllTransactions() {
        return transactionService.getAllTransactions();
    }

    public Transaction completeTransaction(
            Long transactionId
    ) {
        return workflowService.completeTransaction(
                transactionId
        );
    }


    // =========================================================
    // PAYMENTS
    // =========================================================

    @Transactional(readOnly = true)
    public List<Payment> getAllPayments() {
        return paymentService.getAllPayments();
    }

    public Payment processPayment(
            Long paymentId
    ) {
        return workflowService.processPayment(
                paymentId
        );
    }

    public Payment completePayment(
            Long paymentId,
            String paymentReference
    ) {

        if (paymentReference == null
                || paymentReference.isBlank()) {

            throw new IllegalArgumentException(
                    "Payment reference is required."
            );
        }

        return workflowService.completePayment(
                paymentId,
                paymentReference.trim()
        );
    }

    public Payment failPayment(
            Long paymentId
    ) {
        return workflowService.failPayment(
                paymentId
        );
    }
}