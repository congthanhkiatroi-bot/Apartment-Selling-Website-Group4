package com.apartment.website.common.util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordHasher {

    // Hàm mã hóa mật khẩu (Hash password)
    public static String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
    }

    // Hàm kiểm tra mật khẩu nhập vào có khớp với mật khẩu đã mã hóa không
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (hashedPassword == null || !hashedPassword.startsWith("$2a$")) {
            return false; // Tránh lỗi nếu chuỗi hash không hợp lệ
        }
        return BCrypt.checkpw(plainPassword, hashedPassword);
    }
}