package com.apartment.website.communication.test;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.repository.CustomerRepository;
import com.apartment.website.communication.entity.Notification;
import com.apartment.website.communication.entity.Notification.NotificationType;
import com.apartment.website.communication.entity.Report;
import com.apartment.website.communication.service.NotificationService;
import com.apartment.website.communication.service.ReportService;
import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.repository.PostingRepository;

import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@Order(100)
public class CommunicationServiceTest implements CommandLineRunner {

    private final NotificationService notificationService;
    private final ReportService reportService;

    private final CustomerRepository customerRepository;
    private final PostingRepository postingRepository;

    public CommunicationServiceTest(
            NotificationService notificationService,
            ReportService reportService,
            CustomerRepository customerRepository,
            PostingRepository postingRepository
    ) {
        this.notificationService = notificationService;
        this.reportService = reportService;
        this.customerRepository = customerRepository;
        this.postingRepository = postingRepository;
    }


    @Override
    public void run(String... args) {

        System.out.println();
        System.out.println("======================================");
        System.out.println("COMMUNICATION SERVICE TEST");
        System.out.println("======================================");

        Customer customer = null;
        boolean temporaryCustomer = false;

        Notification notification1 = null;
        Notification notification2 = null;
        Report report = null;

        try {

            // =====================================================
            // 1. FIND OR CREATE CUSTOMER
            // =====================================================

            List<Customer> customers =
                    customerRepository.findAll();

            if (customers.isEmpty()) {

                System.out.println(
                        "No customer found. Creating temporary customer..."
                );

                customer = new Customer(
                        "communication_test_customer",
                        "communication_test@example.com",
                        "test_password_hash",
                        "0900000000"
                );

                customer =
                        customerRepository.save(customer);

                temporaryCustomer = true;

                System.out.println(
                        "Temporary customer created: ID = "
                                + customer.getUserId()
                );

            } else {

                customer = customers.get(0);

                System.out.println(
                        "Customer found: ID = "
                                + customer.getUserId()
                );
            }


            // =====================================================
            // 2. FIND POSTING
            // =====================================================

            List<Posting> postings =
                    postingRepository.findAll();

            if (postings.isEmpty()) {
                System.out.println(
                        "No posting found. Communication test skipped."
                );
                return;
            }

            Posting posting = postings.get(0);

            System.out.println(
                    "Posting found: ID = "
                            + posting.getPostingId()
            );


            // =====================================================
            // 3. CREATE NOTIFICATION
            // =====================================================

            notification1 =
                    notificationService.createNotification(
                            "Test notification",
                            "Communication service test message.",
                            NotificationType.SYSTEM,
                            customer
                    );

            System.out.println(
                    "Create notification: PASS"
            );

            System.out.println(
                    "Initial notification read status: "
                            + notification1.isRead()
            );


            // =====================================================
            // 4. GET NOTIFICATION BY ID
            // =====================================================

            Notification foundNotification =
                    notificationService.getNotificationById(
                            notification1.getNotificationId()
                    );

            if (foundNotification == null) {
                throw new IllegalStateException(
                        "Notification lookup failed."
                );
            }

            System.out.println(
                    "Find notification by ID: PASS"
            );


            // =====================================================
            // 5. MARK AS READ
            // =====================================================

            notification1 =
                    notificationService.markAsRead(
                            notification1.getNotificationId()
                    );

            if (!notification1.isRead()) {
                throw new IllegalStateException(
                        "Notification was not marked as read."
                );
            }

            System.out.println(
                    "Mark notification as read: PASS"
            );


            // =====================================================
            // 6. MARK AS UNREAD
            // =====================================================

            notification1 =
                    notificationService.markAsUnread(
                            notification1.getNotificationId()
                    );

            if (notification1.isRead()) {
                throw new IllegalStateException(
                        "Notification was not marked as unread."
                );
            }

            System.out.println(
                    "Mark notification as unread: PASS"
            );


            // =====================================================
            // 7. CREATE SECOND NOTIFICATION
            // =====================================================

            notification2 =
                    notificationService.createNotification(
                            "Second notification",
                            "Testing mark all notifications as read.",
                            NotificationType.POSTING,
                            customer
                    );

            System.out.println(
                    "Create second notification: PASS"
            );


            // =====================================================
            // 8. GET UNREAD NOTIFICATIONS
            // =====================================================

            List<Notification> unreadNotifications =
                    notificationService.getUnreadNotifications(
                            customer.getUserId()
                    );

            System.out.println(
                    "Unread notifications: "
                            + unreadNotifications.size()
            );

            if (unreadNotifications.isEmpty()) {
                throw new IllegalStateException(
                        "Unread notification query failed."
                );
            }


            // =====================================================
            // 9. COUNT UNREAD
            // =====================================================

            long unreadCount =
                    notificationService.countUnreadNotifications(
                            customer.getUserId()
                    );

            System.out.println(
                    "Unread notification count: "
                            + unreadCount
            );

            if (unreadCount <= 0) {
                throw new IllegalStateException(
                        "Unread notification count failed."
                );
            }


            // =====================================================
            // 10. MARK ALL AS READ
            // =====================================================

            notificationService.markAllAsRead(
                    customer.getUserId()
            );

            long unreadAfterMarkAll =
                    notificationService.countUnreadNotifications(
                            customer.getUserId()
                    );

            if (unreadAfterMarkAll != 0) {
                throw new IllegalStateException(
                        "Mark all notifications as read failed."
                );
            }

            System.out.println(
                    "Mark all notifications as read: PASS"
            );


            // =====================================================
            // 11. CREATE REPORT
            // =====================================================

            report =
                    reportService.createReport(
                            "Incorrect information",
                            "Communication service test report.",
                            customer,
                            posting
                    );

            System.out.println(
                    "Create report: PASS"
            );

            System.out.println(
                    "Initial report status: "
                            + report.getStatus()
            );

            if (report.getStatus()
                    != Report.ReportStatus.PENDING) {

                throw new IllegalStateException(
                        "Initial report status must be PENDING."
                );
            }


            // =====================================================
            // 12. FIND REPORT BY ID
            // =====================================================

            Report foundReport =
                    reportService.getReportById(
                            report.getReportId()
                    );

            if (foundReport == null) {
                throw new IllegalStateException(
                        "Report lookup failed."
                );
            }

            System.out.println(
                    "Find report by ID: PASS"
            );


            // =====================================================
            // 13. START REVIEW
            // =====================================================

            report =
                    reportService.startReview(
                            report.getReportId()
                    );

            System.out.println(
                    "After start review: "
                            + report.getStatus()
            );

            if (report.getStatus()
                    != Report.ReportStatus.REVIEWING) {

                throw new IllegalStateException(
                        "Report should be REVIEWING."
                );
            }


            // =====================================================
            // 14. RESOLVE
            // =====================================================

            report =
                    reportService.resolveReport(
                            report.getReportId()
                    );

            System.out.println(
                    "After resolve: "
                            + report.getStatus()
            );

            if (report.getStatus()
                    != Report.ReportStatus.RESOLVED) {

                throw new IllegalStateException(
                        "Report should be RESOLVED."
                );
            }


            // =====================================================
            // 15. REOPEN
            // =====================================================

            report =
                    reportService.reopenReport(
                            report.getReportId()
                    );

            System.out.println(
                    "After reopen: "
                            + report.getStatus()
            );

            if (report.getStatus()
                    != Report.ReportStatus.PENDING) {

                throw new IllegalStateException(
                        "Reopened report should be PENDING."
                );
            }


            // =====================================================
            // 16. REVIEW AGAIN
            // =====================================================

            report =
                    reportService.startReview(
                            report.getReportId()
                    );

            if (report.getStatus()
                    != Report.ReportStatus.REVIEWING) {

                throw new IllegalStateException(
                        "Report should be REVIEWING."
                );
            }

            System.out.println(
                    "Review reopened report: PASS"
            );


            // =====================================================
            // 17. REJECT
            // =====================================================

            report =
                    reportService.rejectReport(
                            report.getReportId()
                    );

            System.out.println(
                    "After reject: "
                            + report.getStatus()
            );

            if (report.getStatus()
                    != Report.ReportStatus.REJECTED) {

                throw new IllegalStateException(
                        "Report should be REJECTED."
                );
            }


            // =====================================================
            // 18. QUERY REPORTS
            // =====================================================

            List<Report> rejectedReports =
                    reportService.getReportsByStatus(
                            Report.ReportStatus.REJECTED
                    );

            if (rejectedReports.isEmpty()) {
                throw new IllegalStateException(
                        "Report status query failed."
                );
            }

            System.out.println(
                    "Find reports by status: PASS"
            );


            List<Report> postingReports =
                    reportService.getReportsByPosting(
                            posting.getPostingId()
                    );

            if (postingReports.isEmpty()) {
                throw new IllegalStateException(
                        "Report posting query failed."
                );
            }

            System.out.println(
                    "Find reports by posting: PASS"
            );


            List<Report> reporterReports =
                    reportService.getReportsByReporter(
                            customer.getUserId()
                    );

            if (reporterReports.isEmpty()) {
                throw new IllegalStateException(
                        "Report reporter query failed."
                );
            }

            System.out.println(
                    "Find reports by reporter: PASS"
            );


            // =====================================================
            // SUCCESS
            // =====================================================

            System.out.println();
            System.out.println(
                    "======================================"
            );
            System.out.println(
                    "COMMUNICATION SERVICE TEST SUCCESS"
            );
            System.out.println(
                    "======================================"
            );

        } catch (Exception e) {

            System.out.println();
            System.out.println(
                    "COMMUNICATION SERVICE TEST FAILED"
            );

            System.out.println(
                    "Reason: " + e.getMessage()
            );

            e.printStackTrace();

        } finally {

            // =====================================================
            // CLEANUP
            // =====================================================

            System.out.println();
            System.out.println(
                    "Cleaning communication test data..."
            );

            try {

                if (report != null
                        && report.getReportId() != null) {

                    reportService.deleteReport(
                            report.getReportId()
                    );

                    System.out.println(
                            "Test report deleted."
                    );
                }

            } catch (Exception e) {

                System.out.println(
                        "Could not delete test report: "
                                + e.getMessage()
                );
            }


            try {

                if (notification1 != null
                        && notification1.getNotificationId() != null) {

                    notificationService.deleteNotification(
                            notification1.getNotificationId()
                    );
                }

                if (notification2 != null
                        && notification2.getNotificationId() != null) {

                    notificationService.deleteNotification(
                            notification2.getNotificationId()
                    );
                }

                System.out.println(
                        "Test notifications deleted."
                );

            } catch (Exception e) {

                System.out.println(
                        "Could not delete test notifications: "
                                + e.getMessage()
                );
            }


            try {

                if (temporaryCustomer
                        && customer != null
                        && customer.getUserId() != null) {

                    customerRepository.deleteById(
                            customer.getUserId()
                    );

                    System.out.println(
                            "Temporary customer deleted."
                    );
                }

            } catch (Exception e) {

                System.out.println(
                        "Could not delete temporary customer: "
                                + e.getMessage()
                );
            }

            System.out.println(
                    "Communication test data cleaned up."
            );
        }
    }
}