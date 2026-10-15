package com.apartment.website.appointment.dto;

/** Dữ liệu khách gửi từ form đặt lịch (chưa kiểm tra). Ứng với các cột của property_viewings. */
public class BookingRequest {
    private final long propertyId;
    private final String date;
    private final String time;
    private final String customerName;
    private final String customerPhone;
    private final String note;

    public BookingRequest(long propertyId, String date, String time, String customerName, String customerPhone,
                          String note) {
        this.propertyId = propertyId;
        this.date = date;
        this.time = time;
        this.customerName = customerName;
        this.customerPhone = customerPhone;
        this.note = note;
    }

    public long getPropertyId() {
        return propertyId;
    }

    /** "2026-11-05" */
    public String getDate() {
        return date;
    }

    /** "09:30" */
    public String getTime() {
        return time;
    }

    public String getCustomerName() {
        return customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public String getNote() {
        return note;
    }
}
