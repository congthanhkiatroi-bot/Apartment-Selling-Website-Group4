package com.apartment.website.property.entity;

import java.time.LocalDateTime;

/** Tòa nhà / chung cư (bảng buildings). Diagram: Building 1 --- 1..* Apartment. */
public class Building {
    private final long buildingId;
    private final String buildingCode;
    private final String buildingName;
    private final String address;
    private final String ward;
    private final String district;
    private final String city;
    private final int totalFloors;
    private final int totalApartments;
    private final Integer yearBuilt;
    private final String description;
    private final String status;
    private final LocalDateTime createdAt;

    public Building(long buildingId, String buildingCode, String buildingName, String address, String ward,
                    String district, String city, int totalFloors, int totalApartments, Integer yearBuilt,
                    String description, String status, LocalDateTime createdAt) {
        this.buildingId = buildingId;
        this.buildingCode = buildingCode;
        this.buildingName = buildingName;
        this.address = address;
        this.ward = ward;
        this.district = district;
        this.city = city;
        this.totalFloors = totalFloors;
        this.totalApartments = totalApartments;
        this.yearBuilt = yearBuilt;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
    }

    public long getBuildingId() {
        return buildingId;
    }

    public String getBuildingCode() {
        return buildingCode;
    }

    public String getBuildingName() {
        return buildingName;
    }

    public String getAddress() {
        return address;
    }

    public String getWard() {
        return ward;
    }

    public String getDistrict() {
        return district;
    }

    public String getCity() {
        return city;
    }

    public int getTotalFloors() {
        return totalFloors;
    }

    public int getTotalApartments() {
        return totalApartments;
    }

    public Integer getYearBuilt() {
        return yearBuilt;
    }

    public String getDescription() {
        return description;
    }

    public String getStatus() {
        return status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    /** getDetails() trong diagram. */
    public String getDetails() {
        return buildingName + " - " + address + ", " + district + ", " + city + " (" + totalFloors + " tầng)";
    }
}
