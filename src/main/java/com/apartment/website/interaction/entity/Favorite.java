package com.apartment.website.interaction.entity;

import java.time.LocalDateTime;

/** Căn hộ khách đã lưu yêu thích (bảng favorites, khóa chính = customer_id + property_id). */
public class Favorite {
    private final long customerId, propertyId; private final LocalDateTime createdAt;

    public Favorite(long customerId, long propertyId, LocalDateTime createdAt) {
        this.customerId = customerId; this.propertyId = propertyId; this.createdAt = createdAt;
    }

    public long getCustomerId() { return customerId; }  public long getPropertyId() { return propertyId; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
