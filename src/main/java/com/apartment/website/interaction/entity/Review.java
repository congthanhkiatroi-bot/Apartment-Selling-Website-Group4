package com.apartment.website.interaction.entity;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Đánh giá của khách cho 1 căn (bảng reviews). Diagram: Customer 1 --writes-- 0..* Review 0..* --receives-- 1 Property.
 * DB ràng buộc: rating 1..5, mỗi khách chỉ có 1 đánh giá / căn (gửi lại = update() trong diagram).
 * reviewerName không phải cột của reviews: lấy từ users.username khi JOIN.
 */
public class Review {
    public static final int MIN_RATING = 1, MAX_RATING = 5, MAX_COMMENT = 1000;
    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final long reviewId, customerId, propertyId; private final int rating;
    private final String comment, reviewerName; private final LocalDateTime reviewDate;

    public Review(long reviewId, long customerId, long propertyId, int rating, String comment,
                  LocalDateTime reviewDate, String reviewerName) {
        this.reviewId = reviewId; this.customerId = customerId; this.propertyId = propertyId; this.rating = rating;
        this.comment = comment; this.reviewDate = reviewDate; this.reviewerName = reviewerName;
    }

    public long getReviewId() { return reviewId; }      public long getCustomerId() { return customerId; }
    public long getPropertyId() { return propertyId; }  public int getRating() { return rating; }
    public String getComment() { return comment; }      public LocalDateTime getReviewDate() { return reviewDate; }
    public String getReviewerName() { return reviewerName; }

    /** Cho JSP: ${r.dateText}, ${r.stars} -> "★★★★☆", ${r.initial} -> chữ cái đầu làm avatar. */
    public String getDateText() { return reviewDate == null ? "" : reviewDate.format(DATE); }
    public String getStars() { return "★".repeat(rating) + "☆".repeat(MAX_RATING - rating); }
    public String getInitial() {
        return reviewerName == null || reviewerName.isBlank() ? "?" : reviewerName.trim().substring(0, 1).toUpperCase();
    }
}
