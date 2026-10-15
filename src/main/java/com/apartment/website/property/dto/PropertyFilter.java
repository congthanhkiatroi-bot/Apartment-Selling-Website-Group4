package com.apartment.website.property.dto;

import java.math.BigDecimal;

/** Điều kiện lọc từ thanh lọc ở trang danh sách. type = "SALE" (mặc định) hoặc "RENT". */
public class PropertyFilter {
    private final String keyword;
    private final String district;
    private final Integer bedrooms;
    private final String price;
    private final String type;

    public PropertyFilter(String keyword, String district, Integer bedrooms, String price, String type) {
        this.keyword = keyword;
        this.district = district;
        this.bedrooms = bedrooms;
        this.price = price;
        this.type = type;
    }

    /** Không truyền type -> mặc định chỉ lấy căn BÁN. */
    public PropertyFilter(String keyword, String district, Integer bedrooms, String price) {
        this(keyword, district, bedrooms, price, "SALE");
    }

    public String getKeyword() {
        return keyword;
    }

    public String getDistrict() {
        return district;
    }

    public Integer getBedrooms() {
        return bedrooms;
    }

    public String getPrice() {
        return price;
    }

    public String getType() {
        return type;
    }

    public boolean hasKeyword() {
        return keyword != null && !keyword.isBlank();
    }

    public boolean hasDistrict() {
        return district != null && !district.isBlank();
    }

    public boolean isRent() {
        return "RENT".equalsIgnoreCase(type);
    }

    public String getListingType() {
        if (isRent()) {
            return "RENT";
        }
        return "SALE";
    }

    /** Giá thấp nhất. Các mức giá (2 tỷ, 4 tỷ) chỉ có nghĩa với căn BÁN; căn thuê tính theo tháng nên bỏ qua. */
    public BigDecimal getMinPrice() {
        if (isRent()) {
            return null;
        }
        if ("2to4".equals(price)) {
            return new BigDecimal("2000000000");
        }
        if ("over4".equals(price)) {
            return new BigDecimal("4000000000");
        }
        return null;
    }

    /** Giá cao nhất (null = không giới hạn). */
    public BigDecimal getMaxPrice() {
        if (isRent()) {
            return null;
        }
        if ("under2".equals(price)) {
            return new BigDecimal("2000000000");
        }
        if ("2to4".equals(price)) {
            return new BigDecimal("4000000000");
        }
        return null;
    }
}
