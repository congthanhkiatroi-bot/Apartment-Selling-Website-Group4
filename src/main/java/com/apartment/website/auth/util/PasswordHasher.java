package com.apartment.website.auth.util;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/** Băm mật khẩu bằng PBKDF2-HMAC-SHA256 có sẵn trong JDK (không cần thêm thư viện). Định dạng: pbkdf2$lặp$salt$hash */
public final class PasswordHasher {
    private static final int ITERATIONS = 120_000, KEY_BITS = 256, SALT_BYTES = 16;
    private static final SecureRandom RNG = new SecureRandom();

    private PasswordHasher() {}

    public static String hash(String password) {
        byte[] salt = new byte[SALT_BYTES];
        RNG.nextBytes(salt);
        Base64.Encoder b64 = Base64.getEncoder().withoutPadding();
        return "pbkdf2$" + ITERATIONS + "$" + b64.encodeToString(salt) + "$" + b64.encodeToString(derive(password, salt, ITERATIONS));
    }

    /** Dữ liệu cũ kiểu 'admin_hash' (không đúng định dạng) luôn trả về false. */
    public static boolean verify(String password, String stored) {
        if (stored == null) return false;
        String[] p = stored.split("\\$");
        if (p.length != 4 || !"pbkdf2".equals(p[0])) return false;
        try {
            byte[] salt = Base64.getDecoder().decode(p[2]);
            byte[] expected = Base64.getDecoder().decode(p[3]);
            return MessageDigest.isEqual(expected, derive(password, salt, Integer.parseInt(p[1])));
        } catch (IllegalArgumentException e) { return false; }
    }

    private static byte[] derive(String password, byte[] salt, int iterations) {
        try {
            PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, iterations, KEY_BITS);
            return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
        } catch (GeneralSecurityException e) { throw new IllegalStateException(e); }
    }
}
