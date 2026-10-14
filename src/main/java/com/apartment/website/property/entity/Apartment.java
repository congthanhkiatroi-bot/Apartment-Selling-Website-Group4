package com.apartment.website.property.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Căn hộ vật lý trong một tòa nhà (bảng apartments). Diagram: Apartment thuộc 1 Building, Property rao bán 1 Apartment. */
public class Apartment {
    private final long apartmentId; private final Building building; private final String apartmentCode, roomNumber;
    private final int floorNumber, bedrooms, bathrooms; private final BigDecimal area, balconyArea;
    private final String direction, viewType, legalStatus, status; private final LocalDateTime createdAt;

    public Apartment(long apartmentId, Building building, String apartmentCode, int floorNumber, String roomNumber,
                     BigDecimal area, int bedrooms, int bathrooms, BigDecimal balconyArea, String direction,
                     String viewType, String legalStatus, String status, LocalDateTime createdAt) {
        this.apartmentId = apartmentId; this.building = building; this.apartmentCode = apartmentCode;
        this.floorNumber = floorNumber; this.roomNumber = roomNumber; this.area = area; this.bedrooms = bedrooms;
        this.bathrooms = bathrooms; this.balconyArea = balconyArea; this.direction = direction; this.viewType = viewType;
        this.legalStatus = legalStatus; this.status = status; this.createdAt = createdAt;
    }

    public long getApartmentId() { return apartmentId; }   public Building getBuilding() { return building; }
    public String getApartmentCode() { return apartmentCode; }  public int getFloorNumber() { return floorNumber; }
    public String getRoomNumber() { return roomNumber; }   public BigDecimal getArea() { return area; }
    public int getBedrooms() { return bedrooms; }          public int getBathrooms() { return bathrooms; }
    public BigDecimal getBalconyArea() { return balconyArea; }  public String getDirection() { return direction; }
    public String getViewType() { return viewType; }       public String getLegalStatus() { return legalStatus; }
    public String getStatus() { return status; }           public LocalDateTime getCreatedAt() { return createdAt; }

    /** getDetails() trong diagram. */
    public String getDetails() {
        return "Căn " + apartmentCode + " - tầng " + floorNumber + ", " + area.stripTrailingZeros().toPlainString()
                + " m², " + bedrooms + " PN, " + bathrooms + " WC";
    }
}
