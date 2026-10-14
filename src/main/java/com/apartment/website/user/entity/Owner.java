package com.apartment.website.user.entity;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Chủ sở hữu / người đăng tin (bảng owners, owner_id = users.user_id) -> kế thừa User.
 * createListing() / manageListings() của diagram sẽ nằm ở ListingService.
 */
public class Owner extends User {
    private static final DateTimeFormatter MONTH = DateTimeFormatter.ofPattern("MM/yyyy");
    private final String phone;

    /** phone = cột owners.phone (số điện thoại chủ sở hữu). */
    public Owner(long userId, String username, String email, String passwordHash, LocalDateTime createdAt,
                 boolean active, String phone) {
        super(userId, username, email, passwordHash, ROLE_OWNER, createdAt, active);
        this.phone = phone;
    }

    public long getOwnerId() { return getUserId(); }
    public String getPhone() { return phone; }

    /** "0901234567" -> "0901 234 567" cho dễ đọc; số dạng khác thì giữ nguyên. */
    public String getPhoneText() {
        if (phone == null) return "";
        return phone.matches("0\\d{9}") ? phone.substring(0, 4) + " " + phone.substring(4, 7) + " " + phone.substring(7) : phone;
    }

    /** Cho JSP: ${owner.initial} làm avatar, ${owner.memberSince} -> "10/2026". */
    public String getInitial() { return getUsername().substring(0, 1).toUpperCase(); }
    public String getMemberSince() { return getCreatedAt() == null ? "" : getCreatedAt().format(MONTH); }
}
