package com.apartment.website.appointment.dto;

/** Một khung giờ trong ngày và còn trống hay không. */
public class SlotInfo {
    private final String time;
    private final boolean available;

    public SlotInfo(String time, boolean available) {
        this.time = time;
        this.available = available;
    }

    public String getTime() {
        return time;
    }

    public boolean isAvailable() {
        return available;
    }
}
