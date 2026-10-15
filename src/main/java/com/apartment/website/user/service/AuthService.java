package com.apartment.website.user.service;

import com.apartment.website.common.exception.AuthException;
import com.apartment.website.common.util.PasswordHasher; // Thêm import PasswordHasher
import com.apartment.website.user.dto.RegisterRequest;
import com.apartment.website.user.entity.Customer;
import com.apartment.website.user.entity.Owner;
import com.apartment.website.user.entity.User;
import com.apartment.website.user.repository.UserRepository;

public class AuthService {
    private static final String PHONE_PATTERN = "^0\\d{9}$";
    private static final String CCCD_PATTERN = "^(\\d{9}|\\d{12})$";
    private static final String EMAIL_PATTERN = "^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+$";
    private static final int MAX_FULL_NAME = 150;
    private static final int MAX_EMAIL = 150;
    private static final int MIN_PASSWORD = 8;
    private static final int MAX_PASSWORD = 100;
    private final UserRepository repository;

    public AuthService(UserRepository repository) {
        this.repository = repository;
    }

    public User login(String phoneOrEmail, String password) {
        String identifier = trimText(phoneOrEmail);
        if (!identifier.isEmpty() && password != null && !password.isEmpty()) {
            User user = this.repository.findByPhoneOrEmail(identifier);

            // SỬA: Thay vì so sánh chuỗi thô, dùng PasswordHasher.checkPassword(...) để đối chiếu với mật khẩu đã băm
            if (user != null && PasswordHasher.checkPassword(password, user.getPasswordHash())) {
                if (!user.isActive()) {
                    String message = "Tài khoản đã bị khóa.";
                    if (user.getBlockedReason() != null) {
                        message = message + " Lý do: " + user.getBlockedReason();
                    }

                    throw new AuthException(message);
                } else {
                    this.repository.updateLastLogin(user.getUserId());
                    user.setPasswordHash((String)null);
                    return user;
                }
            } else {
                throw new AuthException("Số điện thoại/email hoặc mật khẩu không đúng.");
            }
        } else {
            throw new AuthException("Vui lòng nhập số điện thoại (hoặc email) và mật khẩu.");
        }
    }

    public User register(RegisterRequest request) {
        String role = trimText(request.getRole());
        String fullName = trimText(request.getFullName()).replaceAll("\\s+", " ");
        String phone = trimText(request.getPhone()).replaceAll("[\\s.\\-]", "");
        String cccd = trimText(request.getCccd());
        String email = trimText(request.getEmail()).toLowerCase();
        String password = request.getPassword();
        if (password == null) {
            password = "";
        }

        if (!"CUSTOMER".equals(role) && !"OWNER".equals(role)) {
            throw new AuthException("Vui lòng chọn vai trò Khách hàng hoặc Chủ căn hộ.");
        } else if (fullName.isEmpty()) {
            throw new AuthException("Vui lòng nhập họ và tên.");
        } else if (fullName.length() > 150) {
            throw new AuthException("Họ và tên tối đa 150 ký tự.");
        } else if (!phone.matches("^0\\d{9}$")) {
            throw new AuthException("Số điện thoại phải gồm 10 chữ số và bắt đầu bằng 0.");
        } else if (!cccd.isEmpty() && !cccd.matches("^(\\d{9}|\\d{12})$")) {
            throw new AuthException("Số CCCD / CMND phải gồm 9 hoặc 12 chữ số.");
        } else if (email.length() <= 150 && email.matches("^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+$")) {
            if (password.length() >= 8 && password.length() <= 100) {
                if (password.matches(".*[A-Za-z].*") && password.matches(".*\\d.*")) {
                    if (!password.equals(request.getConfirmPassword())) {
                        throw new AuthException("Xác nhận mật khẩu không khớp.");
                    } else if (this.repository.existsByPhone(phone)) {
                        throw new AuthException("Số điện thoại này đã được đăng ký.");
                    } else if (this.repository.existsByEmail(email)) {
                        throw new AuthException("Email này đã được đăng ký.");
                    } else if (!cccd.isEmpty() && this.repository.existsByCccd(cccd)) {
                        throw new AuthException("Số CCCD / CMND này đã được đăng ký.");
                    } else {
                        User user;
                        if ("OWNER".equals(role)) {
                            user = new Owner();
                        } else {
                            user = new Customer();
                        }

                        user.setUsername(phone);
                        user.setFullName(fullName);
                        user.setPhone(phone);
                        if (cccd.isEmpty()) {
                            user.setCccd((String)null);
                        } else {
                            user.setCccd(cccd);
                        }

                        user.setEmail(email);

                        // SỬA: Gọi PasswordHasher.hashPassword(...) để băm mật khẩu trước khi lưu vào DB
                        user.setPasswordHash(PasswordHasher.hashPassword(password));

                        user.setActive(true);
                        long userId = this.repository.create(user);
                        user.setUserId(userId);
                        user.setPasswordHash((String)null);
                        return user;
                    }
                } else {
                    throw new AuthException("Mật khẩu phải có cả chữ và số.");
                }
            } else {
                throw new AuthException("Mật khẩu phải từ 8 đến 100 ký tự.");
            }
        } else {
            throw new AuthException("Email không hợp lệ.");
        }
    }

    private static String trimText(String text) {
        return text == null ? "" : text.trim();
    }
}