package com.apartment.website.appointment.dto;

import java.time.LocalDate;

/** Trạng thái 1 ngày trên lịch. state: PAST (đã qua) | FULL (hết lịch) | FEW (ít chỗ) | OPEN (còn lịch). */
public class DaySlot {
    public static final String PAST = "PAST";
    public static final String FULL = "FULL";
    public static final String FEW = "FEW";
    public static final String OPEN = "OPEN";

    private final LocalDate date;
    private final String state;
    private final int free;

    public DaySlot(LocalDate date, String state, int free) {
        this.date = date;
        this.state = state;
        this.free = free;
    }

    public LocalDate getDate() {
        return date;
    }

    public String getState() {
        return state;
    }

    /** Số khung giờ còn trống trong ngày. */
    public int getFree() {
        return free;
    }
}
