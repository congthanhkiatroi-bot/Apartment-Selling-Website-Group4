package com.apartment.website.communication.entity;

import com.apartment.website.auth.entity.User;
import com.apartment.website.listing.entity.Posting;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "REPORTS")
public class Report {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "REPORT_ID")
    private Long reportId;

    @Column(name = "REASON", nullable = false, length = 100)
    private String reason;

    @Column(name = "DESCRIPTION", length = 500)
    private String description;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "RESOLVED_AT")
    private LocalDateTime resolvedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "STATUS", nullable = false, length = 20)
    private ReportStatus status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "REPORTER_ID", nullable = false)
    private User reporter;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "POSTING_ID", nullable = false)
    private Posting posting;


    // =========================================================
    // Constructors
    // =========================================================

    public Report() {
        this.createdAt = LocalDateTime.now();
        this.status = ReportStatus.PENDING;
    }

    public Report(
            String reason,
            String description,
            User reporter,
            Posting posting
    ) {
        if (reason == null || reason.isBlank()) {
            throw new IllegalArgumentException(
                    "Report reason cannot be empty."
            );
        }

        if (reporter == null) {
            throw new IllegalArgumentException(
                    "Reporter cannot be null."
            );
        }

        if (posting == null) {
            throw new IllegalArgumentException(
                    "Posting cannot be null."
            );
        }

        this.reason = reason;
        this.description = description;
        this.reporter = reporter;
        this.posting = posting;
        this.createdAt = LocalDateTime.now();
        this.status = ReportStatus.PENDING;
    }


    // =========================================================
    // Business methods
    // =========================================================

    public void startReview() {
        if (status != ReportStatus.PENDING) {
            throw new IllegalStateException(
                    "Only pending reports can be reviewed."
            );
        }

        this.status = ReportStatus.REVIEWING;
    }

    public void resolve() {
        if (status == ReportStatus.RESOLVED) {
            throw new IllegalStateException(
                    "Report is already resolved."
            );
        }

        this.status = ReportStatus.RESOLVED;
        this.resolvedAt = LocalDateTime.now();
    }

    public void reject() {
        this.status = ReportStatus.REJECTED;
        this.resolvedAt = LocalDateTime.now();
    }

    public void reopen() {
        this.status = ReportStatus.PENDING;
        this.resolvedAt = null;
    }


    // =========================================================
    // Getters and Setters
    // =========================================================

    public Long getReportId() {
        return reportId;
    }

    public void setReportId(Long reportId) {
        this.reportId = reportId;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getResolvedAt() {
        return resolvedAt;
    }

    public void setResolvedAt(LocalDateTime resolvedAt) {
        this.resolvedAt = resolvedAt;
    }

    public ReportStatus getStatus() {
        return status;
    }

    public void setStatus(ReportStatus status) {
        this.status = status;
    }

    public User getReporter() {
        return reporter;
    }

    public void setReporter(User reporter) {
        this.reporter = reporter;
    }

    public Posting getPosting() {
        return posting;
    }

    public void setPosting(Posting posting) {
        this.posting = posting;
    }


    // =========================================================
    // Enum
    // =========================================================

    public enum ReportStatus {
        PENDING,
        REVIEWING,
        RESOLVED,
        REJECTED
    }
}