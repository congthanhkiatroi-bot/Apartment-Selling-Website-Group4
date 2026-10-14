package com.apartment.website.interaction.repository;

import com.apartment.website.config.Database;
import com.apartment.website.interaction.entity.Review;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/** Lưu đánh giá trong PostgreSQL (bảng reviews, JOIN users để lấy tên người đánh giá). */
public class ReviewRepositoryJdbc implements ReviewRepository {
    /** Tài khoản tạo từ form đánh giá chưa có mật khẩu -> không đăng nhập được cho tới khi làm chức năng đăng ký. */
    private static final String NO_PASSWORD = "NO_LOGIN";

    @Override
    public List<Review> findByProperty(long propertyId) {
        String sql = "SELECT r.review_id, r.customer_id, r.property_id, r.rating, r.comment_text, r.review_date, u.username "
                + "FROM reviews r JOIN users u ON u.user_id = r.customer_id "
                + "WHERE r.property_id = ? ORDER BY r.review_date DESC, r.review_id DESC";
        try (Connection c = Database.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, propertyId);
            List<Review> out = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(new Review(rs.getLong("review_id"), rs.getLong("customer_id"), rs.getLong("property_id"),
                        rs.getInt("rating"), rs.getString("comment_text"), rs.getObject("review_date", LocalDateTime.class),
                        rs.getString("username")));
            }
            return out;
        } catch (SQLException e) { throw new RuntimeException(e); }
    }

    @Override
    public long findOrCreateCustomer(String name, String email) {
        try (Connection c = Database.getConnection()) {
            c.setAutoCommit(false);   // tạo users + customers cùng 1 transaction: lỗi giữa chừng thì không còn rác
            Long userId = userIdByEmail(c, email);
            // username là UNIQUE: trùng tên người khác thì thử "Tên 2", "Tên 3"...
            for (int i = 1; userId == null && i <= 20; i++) {
                String username = i == 1 ? name : name + " " + i;
                try (PreparedStatement ps = c.prepareStatement("INSERT INTO users (username, email, password_hash, role) "
                        + "VALUES (?, ?, ?, 'CUSTOMER') ON CONFLICT DO NOTHING RETURNING user_id")) {
                    ps.setString(1, username);
                    ps.setString(2, email);
                    ps.setString(3, NO_PASSWORD);
                    try (ResultSet rs = ps.executeQuery()) { if (rs.next()) userId = rs.getLong(1); }
                }
                if (userId == null) userId = userIdByEmail(c, email);   // có thể người khác vừa tạo đúng email này
            }
            if (userId == null) throw new SQLException("Không tạo được tài khoản khách cho " + email);
            try (PreparedStatement ps = c.prepareStatement("INSERT INTO customers (customer_id) VALUES (?) ON CONFLICT DO NOTHING")) {
                ps.setLong(1, userId);
                ps.executeUpdate();
            }
            c.commit();
            return userId;
        } catch (SQLException e) { throw new RuntimeException(e); }
    }

    private static Long userIdByEmail(Connection c, String email) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement("SELECT user_id FROM users WHERE LOWER(email) = LOWER(?)")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getLong(1) : null; }
        }
    }

    @Override
    public boolean save(long customerId, long propertyId, int rating, String comment) {
        // UNIQUE (customer_id, property_id) -> gửi lại thì UPDATE. xmax = 0 nghĩa là dòng vừa được INSERT (không phải UPDATE).
        String sql = "INSERT INTO reviews (customer_id, property_id, rating, comment_text) VALUES (?, ?, ?, ?) "
                + "ON CONFLICT (customer_id, property_id) DO UPDATE SET rating = EXCLUDED.rating, "
                + "comment_text = EXCLUDED.comment_text, review_date = CURRENT_TIMESTAMP "
                + "RETURNING (xmax = 0) AS inserted";
        try (Connection c = Database.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            ps.setLong(2, propertyId);
            ps.setInt(3, rating);
            ps.setString(4, comment);
            try (ResultSet rs = ps.executeQuery()) { rs.next(); return rs.getBoolean(1); }
        } catch (SQLException e) { throw new RuntimeException(e); }
    }
}
