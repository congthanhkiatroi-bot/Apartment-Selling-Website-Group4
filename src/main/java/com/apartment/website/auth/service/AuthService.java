package com.apartment.website.auth.service;

import com.apartment.website.auth.entity.SessionUser;
import com.apartment.website.auth.entity.User;
import com.apartment.website.auth.repository.UserRepository;
import com.apartment.website.auth.util.PasswordHasher;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Pattern;

/** Kiểm tra dữ liệu đăng ký / đăng nhập (kiểm tra ở server, không tin JavaScript). */
public class AuthService {
    private static final Pattern PHONE = Pattern.compile("^0\\d{9}$");
    private static final Pattern ID_NUMBER = Pattern.compile("^(\\d{9}|\\d{12})$");
    private static final Pattern EMAIL = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");

    private final UserRepository repo;

    public AuthService(UserRepository repo) { this.repo = repo; }

    /** SĐT về dạng 0xxxxxxxxx: bỏ khoảng trắng/dấu chấm/gạch, đổi +84 hoặc 84 thành 0. */
    public static String normalizePhone(String raw) {
        String s = raw == null ? "" : raw.replaceAll("[\\s.\\-]", "");
        if (s.startsWith("+84")) s = "0" + s.substring(3);
        else if (s.startsWith("84") && s.length() == 11) s = "0" + s.substring(2);
        return s;
    }

    /**
     * form gồm: role, fullName, phone, idNumber, taxCode, email, password, confirm.
     * Trả về map lỗi (key = tên ô nhập); rỗng nghĩa là đăng ký thành công.
     */
    public Map<String, String> register(Map<String, String> form) {
        Map<String, String> err = new LinkedHashMap<>();
        String role = form.getOrDefault("role", "");
        String name = form.getOrDefault("fullName", "");
        String phone = normalizePhone(form.get("phone"));
        String idNumber = form.getOrDefault("idNumber", "");
        String taxCode = form.getOrDefault("taxCode", "");
        String email = form.getOrDefault("email", "").toLowerCase();
        String pw = form.getOrDefault("password", "");

        if (!role.equals("CUSTOMER") && !role.equals("OWNER")) err.put("role", "Chọn vai trò Khách hàng hoặc Chủ căn hộ.");
        if (name.length() < 2 || name.length() > 150) err.put("fullName", "Nhập họ và tên đầy đủ.");
        if (!PHONE.matcher(phone).matches()) err.put("phone", "Số điện thoại gồm 10 số, bắt đầu bằng 0 (hoặc +84).");
        if (!ID_NUMBER.matcher(idNumber).matches()) err.put("idNumber", "CCCD gồm 12 số (CMND cũ gồm 9 số).");
        if (taxCode.length() > 50) err.put("taxCode", "Mã số thuế quá dài.");
        if (email.length() > 150 || !EMAIL.matcher(email).matches()) err.put("email", "Email chưa hợp lệ.");
        if (pw.length() < 8 || pw.length() > 100 || !pw.matches(".*[A-Za-z].*") || !pw.matches(".*\\d.*"))
            err.put("password", "Mật khẩu tối thiểu 8 ký tự, gồm cả chữ và số.");
        if (!pw.equals(form.get("confirm"))) err.put("confirm", "Mật khẩu xác nhận không khớp.");
        if (!err.isEmpty()) return err;

        Set<String> taken = repo.findTaken(phone, email, idNumber);
        if (taken.contains("username")) err.put("phone", "Số điện thoại này đã được đăng ký.");
        if (taken.contains("email")) err.put("email", "Email này đã được đăng ký.");
        if (taken.contains("idNumber")) err.put("idNumber", "CCCD/CMND này đã được đăng ký.");
        if (!err.isEmpty()) return err;

        try {
            repo.create(phone, email, PasswordHasher.hash(pw), role, name, phone, idNumber,
                    "OWNER".equals(role) && !taxCode.isEmpty() ? taxCode : null);
        } catch (UserRepository.DuplicateException e) {
            err.put("phone", "SĐT, email hoặc CCCD đã được đăng ký.");
        }
        return err;
    }

    /** identity = SĐT hoặc email. Sai thông tin / tài khoản bị khóa -> Optional.empty(). */
    public Optional<SessionUser> login(String identity, String password) {
        if (identity == null || identity.isBlank() || password == null || password.isEmpty()) return Optional.empty();
        String id = identity.trim();
        Optional<User> found = repo.findForLogin(normalizePhone(id), id.toLowerCase());
        if (found.isEmpty()) return Optional.empty();
        User u = found.get();
        if (!u.isActive() || !PasswordHasher.verify(password, u.getPasswordHash())) return Optional.empty();
        return Optional.of(new SessionUser(u.getId(), u.getUsername(), u.getFullName(), u.getRole()));
    }
}
