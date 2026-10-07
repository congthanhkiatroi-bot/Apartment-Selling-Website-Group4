package com.apartment.website.communication.repository;

import com.apartment.website.communication.entity.Report;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReportRepository extends JpaRepository<Report, Long> {

    List<Report> findByStatus(Report.ReportStatus status);

    List<Report> findByPostingPostingId(Long postingId);

    List<Report> findByReporterUserIdOrderByCreatedAtDesc(
            Long reporterId
    );
}