package com.apartment.website.communication.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class ReportRequest {

    @NotBlank(message = "Reason is required.")
    @Size(
            max = 100,
            message = "Reason cannot exceed 100 characters."
    )
    private String reason;

    @Size(
            max = 500,
            message = "Description cannot exceed 500 characters."
    )
    private String description;

    @NotNull(message = "Reporter ID is required.")
    private Long reporterId;

    @NotNull(message = "Posting ID is required.")
    private Long postingId;

    public ReportRequest() {
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

    public Long getReporterId() {
        return reporterId;
    }

    public void setReporterId(Long reporterId) {
        this.reporterId = reporterId;
    }

    public Long getPostingId() {
        return postingId;
    }

    public void setPostingId(Long postingId) {
        this.postingId = postingId;
    }
}