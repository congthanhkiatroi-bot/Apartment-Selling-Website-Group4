package com.apartment.website.interaction.service;

import com.apartment.website.common.exception.ReviewException;
import com.apartment.website.interaction.dto.ReviewSummary;
import com.apartment.website.interaction.entity.Review;
import com.apartment.website.interaction.repository.ReviewRepository;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/** Quy tắc đánh giá: kiểm tra dữ liệu form, tính điểm trung bình. writeReview() / update() trong diagram nằm ở đây. */
public class ReviewService {
    private static final Pattern EMAIL = Pattern.compile("^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+$");
    private static final int MAX_NAME = 40;   // users.username tối đa 50, chừa chỗ cho hậu tố " 2", " 3"...

    private final ReviewRepository repository;

    public ReviewService(ReviewRepository repository) { this.repository = repository; }

    public List<Review> reviews(long propertyId) { return repository.findByProperty(propertyId); }

    /** Điểm trung bình + số lượt theo từng mức sao (5 -> 1). */
    public ReviewSummary summary(List<Review> reviews) {
        int[] byStar = new int[Review.MAX_RATING + 1];
        int sum = 0;
        for (Review r : reviews) { byStar[r.getRating()]++; sum += r.getRating(); }
        int n = reviews.size();
        List<ReviewSummary.StarRow> rows = new ArrayList<>();
        for (int s = Review.MAX_RATING; s >= Review.MIN_RATING; s--)
            rows.add(new ReviewSummary.StarRow(s, byStar[s], n == 0 ? 0 : Math.round(byStar[s] * 100f / n)));
        return new ReviewSummary(n == 0 ? 0 : (double) sum / n, n, rows);
    }

    /** Gửi đánh giá. Trả về true nếu là đánh giá mới, false nếu khách (cùng email) sửa lại đánh giá cũ. */
    public boolean submit(long propertyId, String name, String email, String ratingText, String comment) {
        name = name == null ? "" : name.trim().replaceAll("\\s+", " ");
        email = email == null ? "" : email.trim();
        comment = comment == null ? "" : comment.trim();
        int rating;
        try { rating = Integer.parseInt(ratingText); } catch (Exception e) { rating = 0; }

        if (rating < Review.MIN_RATING || rating > Review.MAX_RATING) throw new ReviewException("Vui lòng chọn số sao từ 1 đến 5.");
        if (name.isEmpty()) throw new ReviewException("Vui lòng nhập họ tên.");
        if (name.length() > MAX_NAME) throw new ReviewException("Họ tên tối đa " + MAX_NAME + " ký tự.");
        if (!EMAIL.matcher(email).matches() || email.length() > 100) throw new ReviewException("Email không hợp lệ.");
        if (comment.isEmpty()) throw new ReviewException("Vui lòng nhập nhận xét.");
        if (comment.length() > Review.MAX_COMMENT) throw new ReviewException("Nhận xét tối đa " + Review.MAX_COMMENT + " ký tự.");

        long customerId = repository.findOrCreateCustomer(name, email);
        return repository.save(customerId, propertyId, rating, comment);
    }
}
