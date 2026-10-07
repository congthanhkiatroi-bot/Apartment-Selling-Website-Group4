package com.apartment.website.property.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "PROPERTY_IMAGES")
public class PropertyImage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "IMAGE_ID")
    private Long imageId;

    @Column(name = "IMAGE_URL", nullable = false, length = 1000)
    private String imageUrl;

    @Column(name = "IS_THUMBNAIL", nullable = false)
    private boolean thumbnail = false;

    @Column(name = "DISPLAY_ORDER")
    private Integer displayOrder;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "PROPERTY_ID", nullable = false)
    private Property property;


    // =========================================================
    // Constructors
    // =========================================================

    public PropertyImage() {
    }

    public PropertyImage(
            String imageUrl,
            boolean thumbnail,
            Integer displayOrder,
            Property property
    ) {
        validateImageUrl(imageUrl);

        if (property == null) {
            throw new IllegalArgumentException(
                    "Property cannot be null."
            );
        }

        this.imageUrl = imageUrl;
        this.thumbnail = thumbnail;
        this.displayOrder = displayOrder;
        this.property = property;
    }


    // =========================================================
    // Business methods
    // =========================================================

    public void markAsThumbnail() {
        this.thumbnail = true;
    }

    public void removeThumbnail() {
        this.thumbnail = false;
    }


    // =========================================================
    // Validation
    // =========================================================

    private void validateImageUrl(String imageUrl) {

        if (imageUrl == null || imageUrl.isBlank()) {
            throw new IllegalArgumentException(
                    "Image URL cannot be empty."
            );
        }

        if (imageUrl.length() > 1000) {
            throw new IllegalArgumentException(
                    "Image URL cannot exceed 1000 characters."
            );
        }
    }


    // =========================================================
    // Getters and Setters
    // =========================================================

    public Long getImageId() {
        return imageId;
    }

    public void setImageId(Long imageId) {
        this.imageId = imageId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        validateImageUrl(imageUrl);
        this.imageUrl = imageUrl;
    }

    public boolean isThumbnail() {
        return thumbnail;
    }

    public void setThumbnail(boolean thumbnail) {
        this.thumbnail = thumbnail;
    }

    public Integer getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(Integer displayOrder) {
        this.displayOrder = displayOrder;
    }

    public Property getProperty() {
        return property;
    }

    public void setProperty(Property property) {
        this.property = property;
    }
}