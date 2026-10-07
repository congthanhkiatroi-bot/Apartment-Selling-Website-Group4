package com.apartment.website.listing.entity;

import com.apartment.website.transaction.entity.Transaction;
import com.apartment.website.appointment.entity.ViewingAppointment;
import com.apartment.website.auth.entity.Owner;
import com.apartment.website.communication.entity.Report;
import com.apartment.website.property.entity.Property;
import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "POSTINGS")
public class Posting {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "POSTING_ID")
    private Long postingId;

    @Column(name = "TITLE", nullable = false, length = 200)
    private String title;

    @Column(name = "DESCRIPTION", nullable = false, length = 2000)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "STATUS", nullable = false, length = 30)
    private PostingStatus status;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "UPDATED_AT")
    private LocalDateTime updatedAt;

    /*
     * Lý do Admin từ chối bài đăng.
     * Chỉ sử dụng khi trạng thái là REJECTED.
     */
    @Column(name = "REJECTION_REASON", length = 1000)
    private String rejectionReason;

    /*
     * Chủ sở hữu/người bán tạo bài đăng.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "OWNER_ID", nullable = false)
    private Owner owner;

    /*
     * Căn hộ được rao bán trong bài đăng.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "PROPERTY_ID", nullable = false)
    private Property property;

    /*
     * Các lịch xem căn hộ được đặt thông qua bài đăng này.
     */
    @OneToMany(
            mappedBy = "posting",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<ViewingAppointment> viewingAppointments = new ArrayList<>();

    /*
     * Các báo cáo liên quan đến bài đăng.
     */
    @OneToMany(
            mappedBy = "posting",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<Report> reports = new ArrayList<>();

    @OneToMany(
            mappedBy = "posting",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<Transaction> transactions = new ArrayList<>();

    // =========================================================
    // Constructors
    // =========================================================

    public Posting() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.status = PostingStatus.DRAFT;
    }

    public Posting(
            String title,
            String description,
            Owner owner,
            Property property
    ) {
        validateTitle(title);
        validateDescription(description);

        if (owner == null) {
            throw new IllegalArgumentException(
                    "Posting must have an owner."
            );
        }

        if (property == null) {
            throw new IllegalArgumentException(
                    "Posting must have a property."
            );
        }

        this.title = title;
        this.description = description;
        this.owner = owner;
        this.property = property;

        this.status = PostingStatus.DRAFT;

        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }


    // =========================================================
    // Business methods
    // =========================================================

    /*
     * Owner gửi bài đăng cho hệ thống để chờ Admin kiểm duyệt.
     */

    public void submitForApproval() {

        if (status != PostingStatus.DRAFT
                && status != PostingStatus.REJECTED) {

            throw new IllegalStateException(
                    "Only draft or rejected postings can be submitted for approval."
            );
        }

        validatePostingForSubmission();

        this.status = PostingStatus.PENDING_APPROVAL;
        this.rejectionReason = null;
        touch();
    }


    /*
     * Admin duyệt bài đăng.
     */
    public void approve() {

        if (status != PostingStatus.PENDING_APPROVAL) {
            throw new IllegalStateException(
                    "Only postings pending approval can be approved."
            );
        }

        this.status = PostingStatus.PUBLISHED;
        this.rejectionReason = null;
        touch();
    }


    /*
     * Admin từ chối bài đăng và ghi rõ lý do.
     */
    public void reject(String reason) {

        if (status != PostingStatus.PENDING_APPROVAL) {
            throw new IllegalStateException(
                    "Only postings pending approval can be rejected."
            );
        }

        if (reason == null || reason.isBlank()) {
            throw new IllegalArgumentException(
                    "Rejection reason cannot be empty."
            );
        }

        this.status = PostingStatus.REJECTED;
        this.rejectionReason = reason.trim();
        touch();
    }


    /*
     * Cập nhật nội dung bài đăng.
     *
     * Chỉ cho phép sửa khi bài đang ở trạng thái DRAFT
     * hoặc đã bị REJECTED.
     */
    public void updatePosting(
            String title,
            String description
    ) {

        if (status != PostingStatus.DRAFT
                && status != PostingStatus.REJECTED) {

            throw new IllegalStateException(
                    "Only draft or rejected postings can be edited."
            );
        }

        validateTitle(title);
        validateDescription(description);

        this.title = title;
        this.description = description;

        /*
         * Nếu Owner sửa bài bị từ chối thì xóa lý do cũ.
         * Sau khi sửa xong vẫn phải submitForApproval() lại.
         */
        if (status == PostingStatus.REJECTED) {
            this.rejectionReason = null;
        }

        touch();
    }


    /*
     * Ẩn bài đăng đang được công khai.
     */
    public void hide() {

        if (status != PostingStatus.PUBLISHED) {
            throw new IllegalStateException(
                    "Only published postings can be hidden."
            );
        }

        this.status = PostingStatus.HIDDEN;
        touch();
    }


    /*
     * Đăng lại một bài đang bị ẩn.
     *
     * Vì bài này trước đó đã được Admin duyệt,
     * không cần kiểm duyệt lại nếu chỉ đơn giản mở lại.
     */
    public void republish() {

        if (status != PostingStatus.HIDDEN) {
            throw new IllegalStateException(
                    "Only hidden postings can be republished."
            );
        }

        this.status = PostingStatus.PUBLISHED;
        touch();
    }


    /*
     * Đánh dấu bài đăng đã bán thành công.
     *
     * Đồng thời cập nhật trạng thái Property thành SOLD.
     */
    public void markAsSold() {

        if (status != PostingStatus.PUBLISHED
                && status != PostingStatus.HIDDEN) {

            throw new IllegalStateException(
                    "Only published or hidden postings can be marked as sold."
            );
        }

        this.status = PostingStatus.SOLD;

        if (this.property != null) {
            this.property.markAsSold();
        }

        touch();
    }


    /*
     * Gỡ bài khỏi hệ thống.
     *
     * Đây là soft-delete bằng trạng thái REMOVED,
     * không xóa record khỏi database.
     */
    public void remove() {

        if (status == PostingStatus.SOLD) {
            throw new IllegalStateException(
                    "Sold postings cannot be removed."
            );
        }

        if (status == PostingStatus.REMOVED) {
            throw new IllegalStateException(
                    "Posting is already removed."
            );
        }

        this.status = PostingStatus.REMOVED;
        touch();
    }


    public boolean isPublished() {
        return status == PostingStatus.PUBLISHED;
    }

    public boolean isPendingApproval() {
        return status == PostingStatus.PENDING_APPROVAL;
    }

    public boolean isSold() {
        return status == PostingStatus.SOLD;
    }

    public boolean isEditable() {
        return status == PostingStatus.DRAFT
                || status == PostingStatus.REJECTED;
    }


    // =========================================================
    // Validation helpers
    // =========================================================

    private void validatePostingForSubmission() {

        validateTitle(this.title);
        validateDescription(this.description);

        if (this.owner == null) {
            throw new IllegalStateException(
                    "Posting must have an owner."
            );
        }

        if (this.property == null) {
            throw new IllegalStateException(
                    "Posting must have a property."
            );
        }

        if (this.property.getStatus()
                == Property.PropertyStatus.SOLD) {

            throw new IllegalStateException(
                    "A sold property cannot be posted for sale."
            );
        }
    }


    private void validateTitle(String title) {

        if (title == null || title.isBlank()) {
            throw new IllegalArgumentException(
                    "Posting title cannot be empty."
            );
        }

        if (title.length() > 200) {
            throw new IllegalArgumentException(
                    "Posting title cannot exceed 200 characters."
            );
        }
    }


    private void validateDescription(String description) {

        if (description == null || description.isBlank()) {
            throw new IllegalArgumentException(
                    "Posting description cannot be empty."
            );
        }

        if (description.length() > 2000) {
            throw new IllegalArgumentException(
                    "Posting description cannot exceed 2000 characters."
            );
        }
    }


    private void touch() {
        this.updatedAt = LocalDateTime.now();
    }


    // =========================================================
    // Getters and Setters
    // =========================================================

    public Long getPostingId() {
        return postingId;
    }

    public void setPostingId(Long postingId) {
        this.postingId = postingId;
    }

    public String getTitle() {
        return title;
    }

    public List<Transaction> getTransactions() {
        return transactions;
    }

    public void setTransactions(List<Transaction> transactions) {
        this.transactions = transactions;
    }

    public void setTitle(String title) {
        validateTitle(title);
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        validateDescription(description);
        this.description = description;
    }

    public PostingStatus getStatus() {
        return status;
    }

    public void setStatus(PostingStatus status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }

    public Owner getOwner() {
        return owner;
    }

    public void setOwner(Owner owner) {
        this.owner = owner;
    }

    public Property getProperty() {
        return property;
    }

    public void setProperty(Property property) {
        this.property = property;
    }

    public List<ViewingAppointment> getViewingAppointments() {
        return viewingAppointments;
    }

    public void setViewingAppointments(
            List<ViewingAppointment> viewingAppointments
    ) {
        this.viewingAppointments = viewingAppointments;
    }

    public List<Report> getReports() {
        return reports;
    }

    public void setReports(List<Report> reports) {
        this.reports = reports;
    }



    // =========================================================
    // Posting Status
    // =========================================================

    public enum PostingStatus {

        /*
         * Owner đang soạn bài.
         */
        DRAFT,

        /*
         * Owner đã gửi và đang chờ Admin duyệt.
         */
        PENDING_APPROVAL,

        /*
         * Admin đã duyệt, người mua có thể xem.
         */
        PUBLISHED,

        /*
         * Admin từ chối.
         */
        REJECTED,

        /*
         * Bài tạm thời không hiển thị công khai.
         */
        HIDDEN,

        /*
         * Căn hộ đã bán thành công.
         */
        SOLD,

        /*
         * Bài đã bị gỡ.
         */
        REMOVED
    }
}