package com.apartment.website.interaction.service;

import com.apartment.website.common.exception.ReviewException;
import com.apartment.website.interaction.dto.ReviewSummary;
import com.apartment.website.interaction.entity.Review;
import com.apartment.website.interaction.repository.ReviewRepository;

import java.util.ArrayList;
import java.util.List;

/** Quy tắc đánh giá: kiểm tra dữ liệu form, tính điểm trung bình. writeReview() / update() trong diagram nằm ở đây. */
public class ReviewService {
    private static final String EMAIL_PATTERN = "^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+$";
    // users.username tối đa 50, chừa chỗ cho hậu tố " 2", " 3"...
    private static final int MAX_NAME = 40;
    private static final int MAX_EMAIL = 100;

    private final ReviewRepository repository;

    public ReviewService(ReviewRepository repository) {
        this.repository = repository;
    }

    public List<Review> reviews(long propertyId) {
        return repository.findByProperty(propertyId);
    }

    /** Điểm trung bình + số lượt theo từng mức sao (5 -> 1). */
    public ReviewSummary summary(List<Review> reviews) {
        // countByStar[5] = số lượt 5 sao, countByStar[4] = số lượt 4 sao...
        int[] countByStar = new int[Review.MAX_RATING + 1];
        int sum = 0;
        for (int i = 0; i < reviews.size(); i++) {
            int rating = reviews.get(i).getRating();
            countByStar[rating]++;
            sum = sum + rating;
        }
        int total = reviews.size();

        List<ReviewSummary.StarRow> rows = new ArrayList<ReviewSummary.StarRow>();
        for (int star = Review.MAX_RATING; star >= Review.MIN_RATING; star--) {
            int percent = 0;
            if (total > 0) {
                percent = Math.round(countByStar[star] * 100f / total);
            }
            rows.add(new ReviewSummary.StarRow(star, countByStar[star], percent));
        }

        double average = 0;
        if (total > 0) {
            average = (double) sum / total;
        }
        return new ReviewSummary(average, total, rows);
    }

    /** Gửi đánh giá. Trả về true nếu là đánh giá mới, false nếu khách (cùng email) sửa lại đánh giá cũ. */
    public boolean submit(long propertyId, String name, String email, String ratingText, String comment) {
        // 1. Chuẩn hóa dữ liệu: null -> "", bỏ khoảng trắng thừa
        if (name == null) {
            name = "";
        }
        name = name.trim().replaceAll("\\s+", " ");
        if (email == null) {
            email = "";
        }
        email = email.trim();
        if (comment == null) {
            comment = "";
        }
        comment = comment.trim();
        int rating;
        try {
            rating = Integer.parseInt(ratingText);
        } catch (NumberFormatException e) {
            rating = 0;
        }

        // 2. Kiểm tra dữ liệu, sai thì báo lỗi bằng tiếng Việt
        if (rating < Review.MIN_RATING || rating > Review.MAX_RATING) {
            throw new ReviewException("Vui lòng chọn số sao từ 1 đến 5.");
        }
        if (name.isEmpty()) {
            throw new ReviewException("Vui lòng nhập họ tên.");
        }
        if (name.length() > MAX_NAME) {
            throw new ReviewException("Họ tên tối đa " + MAX_NAME + " ký tự.");
        }
        if (!email.matches(EMAIL_PATTERN) || email.length() > MAX_EMAIL) {
            throw new ReviewException("Email không hợp lệ.");
        }
        if (comment.isEmpty()) {
            throw new ReviewException("Vui lòng nhập nhận xét.");
        }
        if (comment.length() > Review.MAX_COMMENT) {
            throw new ReviewException("Nhận xét tối đa " + Review.MAX_COMMENT + " ký tự.");
        }

        // 3. Lưu xuống DB
        long customerId = repository.findOrCreateCustomer(name, email);
        return repository.save(customerId, propertyId, rating, comment);
    }
}
