package com.apartment.website.interaction.repository;

import com.apartment.website.interaction.entity.Review;

import java.util.List;

public interface ReviewRepository {
    /** Các đánh giá của 1 căn, mới nhất trước. */
    List<Review> findByProperty(long propertyId);

    /** Tìm khách theo email; chưa có thì tạo tài khoản khách (users + customers). Trả về customer_id. */
    long findOrCreateCustomer(String name, String email);

    /** Lưu đánh giá. Khách đã đánh giá căn này rồi thì cập nhật. Trả về true nếu là đánh giá mới. */
    boolean save(long customerId, long propertyId, int rating, String comment);
}
