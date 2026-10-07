package com.apartment.website.communication.controller;

import com.apartment.website.auth.entity.User;
import com.apartment.website.auth.repository.UserRepository;
import com.apartment.website.communication.entity.Report.ReportStatus;
import com.apartment.website.communication.service.ReportService;
import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.service.PostingService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/reports")
public class ReportController {

    private final ReportService reportService;
    private final UserRepository userRepository;
    private final PostingService postingService;

    public ReportController(
            ReportService reportService,
            UserRepository userRepository,
            PostingService postingService
    ) {
        this.reportService = reportService;
        this.userRepository = userRepository;
        this.postingService = postingService;
    }


    // =========================================================
    // ALL REPORTS
    // =========================================================

    @GetMapping
    public String allReports(Model model) {

        model.addAttribute(
                "reports",
                reportService.getAllReports()
        );

        return "communication/reports";
    }


    // =========================================================
    // REPORT DETAIL
    // =========================================================

    @GetMapping("/{reportId}")
    public String reportDetail(
            @PathVariable Long reportId,
            Model model
    ) {

        model.addAttribute(
                "report",
                reportService.getReportById(reportId)
        );

        return "communication/report-detail";
    }


    // =========================================================
    // FILTER BY STATUS
    // =========================================================

    @GetMapping("/status/{status}")
    public String reportsByStatus(
            @PathVariable ReportStatus status,
            Model model
    ) {

        model.addAttribute(
                "reports",
                reportService.getReportsByStatus(status)
        );

        return "communication/reports";
    }


    // =========================================================
    // REPORTS CREATED BY USER
    // =========================================================

    @GetMapping("/reporter/{reporterId}")
    public String reportsByReporter(
            @PathVariable Long reporterId,
            Model model
    ) {

        model.addAttribute(
                "reports",
                reportService
                        .getReportsByReporter(reporterId)
        );

        return "communication/reports";
    }


    // =========================================================
    // CREATE REPORT
    // =========================================================

    @PostMapping("/create")
    public String createReport(
            @RequestParam String reason,
            @RequestParam(required = false)
            String description,
            @RequestParam Long reporterId,
            @RequestParam Long postingId
    ) {

        User reporter =
                getUser(reporterId);

        Posting posting =
                postingService.getPostingById(postingId);

        reportService.createReport(
                reason,
                description,
                reporter,
                posting
        );

        return "redirect:/reports/reporter/"
                + reporterId;
    }


    // =========================================================
    // START REVIEW
    // =========================================================

    @PostMapping("/{reportId}/review")
    public String startReview(
            @PathVariable Long reportId
    ) {

        reportService.startReview(reportId);

        return "redirect:/reports/" + reportId;
    }


    // =========================================================
    // RESOLVE
    // =========================================================

    @PostMapping("/{reportId}/resolve")
    public String resolveReport(
            @PathVariable Long reportId
    ) {

        reportService.resolveReport(reportId);

        return "redirect:/reports/" + reportId;
    }


    // =========================================================
    // REJECT
    // =========================================================

    @PostMapping("/{reportId}/reject")
    public String rejectReport(
            @PathVariable Long reportId
    ) {

        reportService.rejectReport(reportId);

        return "redirect:/reports/" + reportId;
    }


    // =========================================================
    // REOPEN
    // =========================================================

    @PostMapping("/{reportId}/reopen")
    public String reopenReport(
            @PathVariable Long reportId
    ) {

        reportService.reopenReport(reportId);

        return "redirect:/reports/" + reportId;
    }


    // =========================================================
    // DELETE
    // =========================================================

    @PostMapping("/{reportId}/delete")
    public String deleteReport(
            @PathVariable Long reportId
    ) {

        reportService.deleteReport(reportId);

        return "redirect:/reports";
    }


    // =========================================================
    // HELPER
    // =========================================================

    private User getUser(Long userId) {

        if (userId == null) {
            throw new IllegalArgumentException(
                    "User ID cannot be null."
            );
        }

        return userRepository
                .findById(userId)
                .orElseThrow(
                        () -> new IllegalArgumentException(
                                "User not found with ID: "
                                        + userId
                        )
                );
    }
}