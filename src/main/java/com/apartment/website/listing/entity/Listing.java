package com.apartment.website.listing.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Tin đăng của chủ sở hữu (bảng listings). Diagram: Owner 1 --- 0..* Listing, Listing --- 1 Property.
 * publish() / expire() của diagram sẽ nằm ở ListingService (đổi status thành ACTIVE / EXPIRED).
 */
public class Listing {
    public static final String ACTIVE = "ACTIVE";
    public static final String EXPIRED = "EXPIRED";
    public static final String SOLD = "SOLD";
    public static final String HIDDEN = "HIDDEN";
    public static final String CANCELLED = "CANCELLED";

    private final long listingId;
    private final String listingCode;
    private final long ownerId;
    private final long propertyId;
    private final String title;
    private final BigDecimal askingPrice;
    private final String description;
    private final LocalDateTime postDate;
    private final LocalDateTime expiryDate;
    private final String status;
    private final String listingType;

    public Listing(long listingId, String listingCode, long ownerId, long propertyId, String title, BigDecimal askingPrice,
                   String description, LocalDateTime postDate, LocalDateTime expiryDate, String status, String listingType) {
        this.listingId = listingId;
        this.listingCode = listingCode;
        this.ownerId = ownerId;
        this.propertyId = propertyId;
        this.title = title;
        this.askingPrice = askingPrice;
        this.description = description;
        this.postDate = postDate;
        this.expiryDate = expiryDate;
        this.status = status;
        this.listingType = listingType;
    }

    public long getListingId() {
        return listingId;
    }

    public String getListingCode() {
        return listingCode;
    }

    public long getOwnerId() {
        return ownerId;
    }

    public long getPropertyId() {
        return propertyId;
    }

    public String getTitle() {
        return title;
    }

    public BigDecimal getAskingPrice() {
        return askingPrice;
    }

    public String getDescription() {
        return description;
    }

    public LocalDateTime getPostDate() {
        return postDate;
    }

    public LocalDateTime getExpiryDate() {
        return expiryDate;
    }

    public String getStatus() {
        return status;
    }

    public String getListingType() {
        return listingType;
    }

    /** Tin còn hiệu lực: đang ACTIVE và chưa quá hạn. */
    public boolean isActive() {
        if (!ACTIVE.equals(status)) {
            return false;
        }
        if (expiryDate == null) {
            return true;
        }
        return expiryDate.isAfter(LocalDateTime.now());
    }
}
