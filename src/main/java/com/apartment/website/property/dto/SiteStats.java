package com.apartment.website.property.dto;

/** Các con số thống kê toàn trang, hiện ở trang Về chúng tôi (đếm thật từ database). */
public class SiteStats {
    private long saleCount;      // căn đang bán
    private long rentCount;      // căn đang cho thuê
    private long buildingCount;  // số tòa nhà / dự án
    private long districtCount;  // số quận có căn hộ
    private long userCount;      // tài khoản đang hoạt động
    private long ownerCount;     // chủ căn hộ
    private long viewingCount;   // lượt đặt lịch xem nhà

    public SiteStats() {
    }

    /** Tổng căn đang mở giao dịch (bán + thuê). */
    public long getApartmentCount() {
        return saleCount + rentCount;
    }

    public long getSaleCount() {
        return saleCount;
    }

    public void setSaleCount(long saleCount) {
        this.saleCount = saleCount;
    }

    public long getRentCount() {
        return rentCount;
    }

    public void setRentCount(long rentCount) {
        this.rentCount = rentCount;
    }

    public long getBuildingCount() {
        return buildingCount;
    }

    public void setBuildingCount(long buildingCount) {
        this.buildingCount = buildingCount;
    }

    public long getDistrictCount() {
        return districtCount;
    }

    public void setDistrictCount(long districtCount) {
        this.districtCount = districtCount;
    }

    public long getUserCount() {
        return userCount;
    }

    public void setUserCount(long userCount) {
        this.userCount = userCount;
    }

    public long getOwnerCount() {
        return ownerCount;
    }

    public void setOwnerCount(long ownerCount) {
        this.ownerCount = ownerCount;
    }

    public long getViewingCount() {
        return viewingCount;
    }

    public void setViewingCount(long viewingCount) {
        this.viewingCount = viewingCount;
    }
}
