package com.apartment.website.auth.repository;

import com.apartment.website.auth.entity.User;
import com.apartment.website.config.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

/** Truy cập bảng users / owners / customers bằng JDBC. */
public class UserRepository {

    /** Ném ra khi vi phạm UNIQUE (trùng SĐT/email/CCCD) lúc 2 người đăng ký cùng lúc. */
    public static class DuplicateException extends RuntimeException {}

    /** Trả về các trường đã bị dùng: "username", "email", "idNumber". */
    public Set<String> findTaken(String username, String email, String idNumber) {
        String sql = "SELECT username, email, id_number FROM users WHERE username = ? OR lower(email) = ? OR id_number = ?";
        try (Connection c = Database.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, idNumber);
            Set<String> taken = new HashSet<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    if (username.equals(rs.getString(1))) taken.add("username");
                    if (email.equalsIgnoreCase(rs.getString(2))) taken.add("email");
                    if (idNumber.equals(rs.getString(3))) taken.add("idNumber");
                }
            }
            return taken;
        } catch (SQLException e) { throw new RuntimeException(e); }
    }

    /** Tạo users + (owners | customers) trong 1 transaction. Trả về user_id mới. */
    public long create(String username, String email, String passwordHash, String role,
                       String fullName, String phone, String idNumber, String taxCode) {
        try (Connection c = Database.getConnection()) {
            c.setAutoCommit(false);   // lỗi giữa chừng -> pool tự rollback khi close()
            long id;
            String sql = "INSERT INTO users (username, email, password_hash, role, full_name, id_number) "
                    + "VALUES (?, ?, ?, ?, ?, ?) RETURNING user_id";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setString(1, username);
                ps.setString(2, email);
                ps.setString(3, passwordHash);
                ps.setString(4, role);
                ps.setString(5, fullName);
                ps.setString(6, idNumber);
                try (ResultSet rs = ps.executeQuery()) { rs.next(); id = rs.getLong(1); }
            }
            if ("OWNER".equals(role)) {
                try (PreparedStatement ps = c.prepareStatement(
                        "INSERT INTO owners (owner_id, tax_code, full_name, phone) VALUES (?, ?, ?, ?)")) {
                    ps.setLong(1, id);
                    ps.setString(2, taxCode);   // null nếu không nhập
                    ps.setString(3, fullName);
                    ps.setString(4, phone);
                    ps.executeUpdate();
                }
            } else {
                try (PreparedStatement ps = c.prepareStatement("INSERT INTO customers (customer_id) VALUES (?)")) {
                    ps.setLong(1, id);
                    ps.executeUpdate();
                }
            }
            c.commit();
            return id;
        } catch (SQLException e) {
            if ("23505".equals(e.getSQLState())) throw new DuplicateException();
            throw new RuntimeException(e);
        }
    }

    /** Tìm theo SĐT (username) hoặc email. */
    public Optional<User> findForLogin(String phoneOrUsername, String emailLower) {
        String sql = "SELECT user_id, username, email, password_hash, role, full_name, is_active "
                + "FROM users WHERE username = ? OR lower(email) = ? LIMIT 1";
        try (Connection c = Database.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, phoneOrUsername);
            ps.setString(2, emailLower);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return Optional.empty();
                return Optional.of(new User(rs.getLong(1), rs.getString(2), rs.getString(3), rs.getString(4),
                        rs.getString(5), rs.getString(6), rs.getInt(7) == 1));
            }
        } catch (SQLException e) { throw new RuntimeException(e); }
    }
}
