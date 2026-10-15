package com.apartment.website.property.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Căn hộ vật lý trong một tòa nhà (bảng apartments). Diagram: Apartment thuộc 1 Building và 1 Owner, Property rao bán 1 Apartment. */
public class Apartment {
    private final long apartmentId;
    private final Building building;
    private final long ownerId;
    private final String apartmentCode;
    private final int floorNumber;
    private final String roomNumber;
    private final BigDecimal area;
    private final int bedrooms;
    private final int bathrooms;
    private final BigDecimal balconyArea;
    private final String direction;
    private final String viewType;
    private final String legalStatus;
    private final String status;
    private final LocalDateTime createdAt;

    public Apartment(long apartmentId, Building building, long ownerId, String apartmentCode, int floorNumber, String roomNumber,
                     BigDecimal area, int bedrooms, int bathrooms, BigDecimal balconyArea, String direction,
                     String viewType, String legalStatus, String status, LocalDateTime createdAt) {
        this.apartmentId = apartmentId;
        this.building = building;
        this.ownerId = ownerId;
        this.apartmentCode = apartmentCode;
        this.floorNumber = floorNumber;
        this.roomNumber = roomNumber;
        this.area = area;
        this.bedrooms = bedrooms;
        this.bathrooms = bathrooms;
        this.balconyArea = balconyArea;
        this.direction = direction;
        this.viewType = viewType;
        this.legalStatus = legalStatus;
        this.status = status;
        this.createdAt = createdAt;
    }

    public long getApartmentId() {
        return apartmentId;
    }

    public Building getBuilding() {
        return building;
    }

    /** Cột apartments.owner_id: chủ của căn hộ. */
    public long getOwnerId() {
        return ownerId;
    }

    public String getApartmentCode() {
        return apartmentCode;
    }

    public int getFloorNumber() {
        return floorNumber;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public BigDecimal getArea() {
        return area;
    }

    public int getBedrooms() {
        return bedrooms;
    }

    public int getBathrooms() {
        return bathrooms;
    }

    public BigDecimal getBalconyArea() {
        return balconyArea;
    }

    public String getDirection() {
        return direction;
    }

    public String getViewType() {
        return viewType;
    }

    public String getLegalStatus() {
        return legalStatus;
    }

    public String getStatus() {
        return status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    /** getDetails() trong diagram. */
    public String getDetails() {
        String areaText = area.stripTrailingZeros().toPlainString();
        return "Căn " + apartmentCode + " - tầng " + floorNumber + ", " + areaText
                + " m², " + bedrooms + " PN, " + bathrooms + " WC";
    }
}
