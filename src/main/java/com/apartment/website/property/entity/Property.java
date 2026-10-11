package com.apartment.website.property.entity;

import java.math.BigDecimal;
import java.util.List;
import java.util.Locale;

/**
 * 1 căn hộ đang rao bán (gom từ properties + apartments + buildings + property_images).
 * JSP đọc qua getter: ${it.title} -> getTitle(), ${property.priceText} -> getPriceText()...
 */
public class Property {
    public static final String NO_IMAGE = "/images/apartment-sample.jpg";

    private final long propertyId; private final String title; private final BigDecimal price;
    private final String priceText, pricePerM2Text, description, address, buildingName, district, city;
    private final int floor; private final String area; private final int bedrooms, bathrooms;
    private final String direction, legalStatus, status, thumbnailUrl; private final List<String> imageUrls;
    private final String listingType;

    public Property(long propertyId, String title, BigDecimal price, String priceText, String pricePerM2Text,
                    String description, String address, String buildingName, String district, String city,
                    int floor, String area, int bedrooms, int bathrooms, String direction, String legalStatus,
                    String status, String thumbnailUrl, List<String> imageUrls, String listingType) {
        this.propertyId = propertyId; this.title = title; this.price = price; this.priceText = priceText;
        this.pricePerM2Text = pricePerM2Text; this.description = description; this.address = address;
        this.buildingName = buildingName; this.district = district; this.city = city; this.floor = floor;
        this.area = area; this.bedrooms = bedrooms; this.bathrooms = bathrooms; this.direction = direction;
        this.legalStatus = legalStatus; this.status = status; this.thumbnailUrl = thumbnailUrl; this.imageUrls = imageUrls;
        this.listingType = listingType == null ? "SALE" : listingType;
    }

    public long getPropertyId() { return propertyId; }   public String getTitle() { return title; }
    public BigDecimal getPrice() { return price; }       public String getPriceText() { return "RENT".equals(listingType) ? priceText + "/tháng" : priceText; }
    public String getPricePerM2Text() { return pricePerM2Text; }  public String getDescription() { return description; }
    public String getAddress() { return address; }       public String getBuildingName() { return buildingName; }
    public String getDistrict() { return district; }     public String getCity() { return city; }
    public int getFloor() { return floor; }              public String getArea() { return area; }
    public int getBedrooms() { return bedrooms; }        public int getBathrooms() { return bathrooms; }
    public String getDirection() { return direction; }   public String getLegalStatus() { return legalStatus; }
    public String getStatus() { return status; }         public String getThumbnailUrl() { return thumbnailUrl; }
    public List<String> getImageUrls() { return imageUrls; }
    public String getListingType() { return listingType; }
    public boolean isRent() { return "RENT".equals(listingType); }

    /** Ảnh trong DB có thể là "images/a.jpg" (thiếu dấu /) -> chuẩn hóa để JSP ghép đúng đường dẫn. */
    public static String imageUrl(String u) {
        if (u == null || u.isBlank()) return NO_IMAGE;
        return (u.startsWith("/") || u.startsWith("http")) ? u : "/" + u;
    }

    /** 2800000000 -> "2.8 Tỷ", 35000000 -> "35 Triệu". */
    public static String priceText(BigDecimal p) {
        if (p == null) return "";
        double v = p.doubleValue();
        if (v >= 1e9) return String.format(Locale.US, "%.1f Tỷ", v / 1e9).replace(".0 ", " ");
        return String.format(Locale.US, "%.0f Triệu", v / 1e6);
    }
}