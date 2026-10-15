package com.apartment.website.property.entity;

import java.time.LocalDateTime;

/** Ảnh của tin rao (bảng property_images). Diagram: Property 1 --- 0..* PropertyImage; isPrimary = is_thumbnail. */
public class PropertyImage {
    private final long imageId;
    private final long propertyId;
    private final String imageUrl;
    private final boolean primary;
    private final LocalDateTime uploadedAt;

    public PropertyImage(long imageId, long propertyId, String imageUrl, boolean primary, LocalDateTime uploadedAt) {
        this.imageId = imageId;
        this.propertyId = propertyId;
        this.imageUrl = Property.imageUrl(imageUrl);
        this.primary = primary;
        this.uploadedAt = uploadedAt;
    }

    public long getImageId() {
        return imageId;
    }

    public long getPropertyId() {
        return propertyId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public boolean isPrimary() {
        return primary;
    }

    public LocalDateTime getUploadedAt() {
        return uploadedAt;
    }
}
