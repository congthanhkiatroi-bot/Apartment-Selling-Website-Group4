package com.apartment.website.interaction.repository;

import com.apartment.website.config.Database;
import com.apartment.website.interaction.entity.Review;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/** Lưu đánh giá trong PostgreSQL (bảng reviews, JOIN users để lấy tên người đánh giá). */
public class ReviewRepositoryJdbc implements ReviewRepository {
    /** Tài khoản tạo từ form đánh giá chưa có mật khẩu -> không đăng nhập được cho tới khi làm chức năng đăng ký. */
    private static final String NO_PASSWORD = "NO_LOGIN";
    /** Thử tối đa "Tên", "Tên 2" ... "Tên 20" khi username bị trùng. */
    private static final int MAX_USERNAME_TRIES = 20;

    @Override
    public List<Review> findByProperty(long propertyId) {
        String sql = "SELECT r.review_id, r.customer_id, r.property_id, r.rating, r.comment_text, r.review_date, u.username "
                + "FROM reviews r "
                + "JOIN users u ON u.user_id = r.customer_id "
                + "WHERE r.property_id = ? "
                + "ORDER BY r.review_date DESC, r.review_id DESC";

        List<Review> reviews = new ArrayList<Review>();
        try (Connection connection = Database.getConnection()) {
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setLong(1, propertyId);
                try (ResultSet rs = statement.executeQuery()) {
                    while (rs.next()) {
                        long reviewId = rs.getLong("review_id");
                        long customerId = rs.getLong("customer_id");
                        long reviewPropertyId = rs.getLong("property_id");
                        int rating = rs.getInt("rating");
                        String comment = rs.getString("comment_text");
                        LocalDateTime reviewDate = rs.getObject("review_date", LocalDateTime.class);
                        String reviewerName = rs.getString("username");

                        Review review = new Review(reviewId, customerId, reviewPropertyId, rating, comment,
                                reviewDate, reviewerName);
                        reviews.add(review);
                    }
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return reviews;
    }

    @Override
    public long findOrCreateCustomer(String name, String email) {
        String insertUserSql = "INSERT INTO users (username, email, password_hash, role) "
                + "VALUES (?, ?, ?, 'CUSTOMER') "
                + "ON CONFLICT DO NOTHING "
                + "RETURNING user_id";
        String insertCustomerSql = "INSERT INTO customers (customer_id) "
                + "VALUES (?) "
                + "ON CONFLICT DO NOTHING";

        try (Connection connection = Database.getConnection()) {
            // tạo users + customers cùng 1 transaction: lỗi giữa chừng thì không để lại dữ liệu rác
            connection.setAutoCommit(false);

            // 1. Email đã có tài khoản thì dùng luôn
            Long userId = findUserIdByEmail(connection, email);

            // 2. Chưa có -> tạo user mới. username là UNIQUE: trùng tên người khác thì thử "Tên 2", "Tên 3"...
            int attempt = 1;
            while (userId == null && attempt <= MAX_USERNAME_TRIES) {
                String username = name;
                if (attempt > 1) {
                    username = name + " " + attempt;
                }
                try (PreparedStatement statement = connection.prepareStatement(insertUserSql)) {
                    statement.setString(1, username);
                    statement.setString(2, email);
                    statement.setString(3, NO_PASSWORD);
                    try (ResultSet rs = statement.executeQuery()) {
                        if (rs.next()) {
                            userId = rs.getLong("user_id");
                        }
                    }
                }
                // có thể người khác vừa tạo đúng email này
                if (userId == null) {
                    userId = findUserIdByEmail(connection, email);
                }
                attempt++;
            }
            if (userId == null) {
                throw new SQLException("Không tạo được tài khoản khách cho " + email);
            }

            // 3. Đảm bảo user này có dòng trong bảng customers
            try (PreparedStatement statement = connection.prepareStatement(insertCustomerSql)) {
                statement.setLong(1, userId);
                statement.executeUpdate();
            }

            connection.commit();
            return userId;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    /** Tìm user_id theo email (không phân biệt hoa thường). Không có thì trả về null. */
    private static Long findUserIdByEmail(Connection connection, String email) throws SQLException {
        String sql = "SELECT user_id "
                + "FROM users "
                + "WHERE LOWER(email) = LOWER(?)";

        Long userId = null;
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    userId = rs.getLong("user_id");
                }
            }
        }
        return userId;
    }

    @Override
    public boolean save(long customerId, long propertyId, int rating, String comment) {
        // UNIQUE (customer_id, property_id) -> gửi lại thì UPDATE.
        // xmax = 0 nghĩa là dòng vừa được INSERT (không phải UPDATE).
        String sql = "INSERT INTO reviews (customer_id, property_id, rating, comment_text) "
                + "VALUES (?, ?, ?, ?) "
                + "ON CONFLICT (customer_id, property_id) DO UPDATE "
                + "SET rating = EXCLUDED.rating, "
                + "comment_text = EXCLUDED.comment_text, "
                + "review_date = CURRENT_TIMESTAMP "
                + "RETURNING (xmax = 0) AS inserted";

        boolean inserted = false;
        try (Connection connection = Database.getConnection()) {
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setLong(1, customerId);
                statement.setLong(2, propertyId);
                statement.setInt(3, rating);
                statement.setString(4, comment);
                try (ResultSet rs = statement.executeQuery()) {
                    if (rs.next()) {
                        inserted = rs.getBoolean("inserted");
                    }
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return inserted;
    }
}
