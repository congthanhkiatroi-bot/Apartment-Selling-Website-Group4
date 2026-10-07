    package com.apartment.website.communication.service;

    import com.apartment.website.auth.entity.User;
    import com.apartment.website.communication.entity.Report;
    import com.apartment.website.communication.entity.Report.ReportStatus;
    import com.apartment.website.communication.repository.ReportRepository;
    import com.apartment.website.listing.entity.Posting;
    import org.springframework.stereotype.Service;
    import org.springframework.transaction.annotation.Transactional;

    import java.util.List;

    @Service
    @Transactional
    public class ReportService {

        private final ReportRepository reportRepository;

        public ReportService(
                ReportRepository reportRepository
        ) {
            this.reportRepository = reportRepository;
        }


        // =========================================================
        // CREATE
        // =========================================================

        public Report createReport(
                String reason,
                String description,
                User reporter,
                Posting posting
        ) {

            if (reporter == null
                    || reporter.getUserId() == null) {

                throw new IllegalArgumentException(
                        "Reporter cannot be null."
                );
            }

            if (posting == null
                    || posting.getPostingId() == null) {

                throw new IllegalArgumentException(
                        "Posting cannot be null."
                );
            }

            Report report = new Report(
                    reason,
                    description,
                    reporter,
                    posting
            );

            return reportRepository.save(report);
        }


        // =========================================================
        // READ
        // =========================================================

        @Transactional(readOnly = true)
        public Report getReportById(Long reportId) {

            if (reportId == null) {
                throw new IllegalArgumentException(
                        "Report ID cannot be null."
                );
            }

            return reportRepository
                    .findById(reportId)
                    .orElseThrow(() ->
                            new IllegalArgumentException(
                                    "Report not found with ID: "
                                            + reportId
                            )
                    );
        }


        @Transactional(readOnly = true)
        public List<Report> getAllReports() {
            return reportRepository.findAll();
        }


        @Transactional(readOnly = true)
        public List<Report> getReportsByStatus(
                ReportStatus status
        ) {

            if (status == null) {
                throw new IllegalArgumentException(
                        "Report status cannot be null."
                );
            }

            return reportRepository.findByStatus(status);
        }


        @Transactional(readOnly = true)
        public List<Report> getReportsByPosting(
                Long postingId
        ) {

            validateId(postingId, "Posting");

            return reportRepository
                    .findByPostingPostingId(postingId);
        }


        @Transactional(readOnly = true)
        public List<Report> getReportsByReporter(
                Long reporterId
        ) {

            validateId(reporterId, "Reporter");

            return reportRepository
                    .findByReporterUserIdOrderByCreatedAtDesc(
                            reporterId
                    );
        }


        // =========================================================
        // START REVIEW
        // =========================================================

        public Report startReview(Long reportId) {

            Report report = getReportById(reportId);

            report.startReview();

            return reportRepository.save(report);
        }


        // =========================================================
        // RESOLVE
        // =========================================================

        public Report resolveReport(Long reportId) {

            Report report = getReportById(reportId);

            report.resolve();

            return reportRepository.save(report);
        }


        // =========================================================
        // REJECT
        // =========================================================

        public Report rejectReport(Long reportId) {

            Report report = getReportById(reportId);

            report.reject();

            return reportRepository.save(report);
        }


        // =========================================================
        // REOPEN
        // =========================================================

        public Report reopenReport(Long reportId) {

            Report report = getReportById(reportId);

            report.reopen();

            return reportRepository.save(report);
        }


        // =========================================================
        // DELETE
        // =========================================================

        public void deleteReport(Long reportId) {

            Report report = getReportById(reportId);

            reportRepository.delete(report);
        }


        // =========================================================
        // VALIDATION
        // =========================================================

        private void validateId(
                Long id,
                String entityName
        ) {

            if (id == null) {
                throw new IllegalArgumentException(
                        entityName + " ID cannot be null."
                );
            }
        }
    }