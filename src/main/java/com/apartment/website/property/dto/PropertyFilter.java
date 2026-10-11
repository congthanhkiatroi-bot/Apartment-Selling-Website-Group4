package com.apartment.website.property.dto;

import java.math.BigDecimal;

/** Điều kiện lọc từ thanh lọc ở trang danh sách. type = "SALE" (mặc định) hoặc "RENT". */
public record PropertyFilter(String keyword, String district, Integer bedrooms, String price, String type) {
    /** Giữ constructor cũ (4 tham số) -> mặc định chỉ lấy căn BÁN, PropertyService không phải sửa. */
    public PropertyFilter(String keyword, String district, Integer bedrooms, String price) {
        this(keyword, district, bedrooms, price, "SALE");
    }
    public boolean hasKeyword() { return keyword != null && !keyword.isBlank(); }
    public boolean hasDistrict() { return district != null && !district.isBlank(); }
    public boolean isRent() { return "RENT".equalsIgnoreCase(type); }
    public String listingType() { return isRent() ? "RENT" : "SALE"; }
    /** Các mức giá (2 tỷ, 4 tỷ) chỉ có nghĩa với căn BÁN; căn thuê tính theo tháng nên bỏ qua. */
    public BigDecimal min() { if (isRent()) return null; return switch (price == null ? "" : price) {
        case "2to4" -> new BigDecimal("2000000000"); case "over4" -> new BigDecimal("4000000000"); default -> null; }; }
    public BigDecimal max() { if (isRent()) return null; return switch (price == null ? "" : price) {
        case "under2" -> new BigDecimal("2000000000"); case "2to4" -> new BigDecimal("4000000000"); default -> null; }; }
}