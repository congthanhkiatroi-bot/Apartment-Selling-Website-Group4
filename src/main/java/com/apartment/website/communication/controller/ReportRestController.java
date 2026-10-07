package com.apartment.website.communication.controller;

import com.apartment.website.auth.entity.User;
import com.apartment.website.auth.repository.UserRepository;
import com.apartment.website.communication.dto.ReportRequest;
import com.apartment.website.communication.entity.Report;
import com.apartment.website.communication.entity.Report.ReportStatus;
import com.apartment.website.communication.service.ReportService;
import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.service.PostingService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reports")
public class ReportRestController {

    private final ReportService reportService;
    private final UserRepository userRepository;
    private final PostingService postingService;

    public ReportRestController(
            ReportService reportService,
            UserRepository userRepository,
            PostingService postingService
    ) {
        this.reportService = reportService;
        this.userRepository = userRepository;
        this.postingService = postingService;
    }


    // =========================================================
    // GET ALL
    // =========================================================

    @GetMapping
    public ResponseEntity<List<Report>>
    getAllReports() {

        return ResponseEntity.ok(
                reportService.getAllReports()
        );
    }


    // =========================================================
    // GET BY ID
    // =========================================================

    @GetMapping("/{reportId}")
    public ResponseEntity<Report>
    getReportById(
            @PathVariable Long reportId
    ) {

        return ResponseEntity.ok(
                reportService.getReportById(reportId)
        );
    }


    // =========================================================
    // GET BY STATUS
    // =========================================================

    @GetMapping("/status/{status}")
    public ResponseEntity<List<Report>>
    getReportsByStatus(
            @PathVariable ReportStatus status
    ) {

        return ResponseEntity.ok(
                reportService.getReportsByStatus(status)
        );
    }


    // =========================================================
    // GET BY POSTING
    // =========================================================

    @GetMapping("/posting/{postingId}")
    public ResponseEntity<List<Report>>
    getReportsByPosting(
            @PathVariable Long postingId
    ) {

        return ResponseEntity.ok(
                reportService
                        .getReportsByPosting(postingId)
        );
    }


    // =========================================================
    // GET BY REPORTER
    // =========================================================

    @GetMapping("/reporter/{reporterId}")
    public ResponseEntity<List<Report>>
    getReportsByReporter(
            @PathVariable Long reporterId
    ) {

        return ResponseEntity.ok(
                reportService
                        .getReportsByReporter(reporterId)
        );
    }


    // =========================================================
    // CREATE
    // =========================================================

    @PostMapping
    public ResponseEntity<Report>
    createReport(
            @Valid
            @RequestBody ReportRequest request
    ) {

        User reporter =
                getUser(request.getReporterId());

        Posting posting =
                postingService.getPostingById(
                        request.getPostingId()
                );

        Report report =
                reportService.createReport(
                        request.getReason(),
                        request.getDescription(),
                        reporter,
                        posting
                );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(report);
    }


    // =========================================================
    // START REVIEW
    // =========================================================

    @PatchMapping("/{reportId}/review")
    public ResponseEntity<Report>
    startReview(
            @PathVariable Long reportId
    ) {

        return ResponseEntity.ok(
                reportService.startReview(reportId)
        );
    }


    // =========================================================
    // RESOLVE
    // =========================================================

    @PatchMapping("/{reportId}/resolve")
    public ResponseEntity<Report>
    resolveReport(
            @PathVariable Long reportId
    ) {

        return ResponseEntity.ok(
                reportService.resolveReport(reportId)
        );
    }


    // =========================================================
    // REJECT
    // =========================================================

    @PatchMapping("/{reportId}/reject")
    public ResponseEntity<Report>
    rejectReport(
            @PathVariable Long reportId
    ) {

        return ResponseEntity.ok(
                reportService.rejectReport(reportId)
        );
    }


    // =========================================================
    // REOPEN
    // =========================================================

    @PatchMapping("/{reportId}/reopen")
    public ResponseEntity<Report>
    reopenReport(
            @PathVariable Long reportId
    ) {

        return ResponseEntity.ok(
                reportService.reopenReport(reportId)
        );
    }


    // =========================================================
    // DELETE
    // =========================================================

    @DeleteMapping("/{reportId}")
    public ResponseEntity<Void>
    deleteReport(
            @PathVariable Long reportId
    ) {

        reportService.deleteReport(reportId);

        return ResponseEntity.noContent().build();
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