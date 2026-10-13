package com.apartment.website.appointment.dto;

import java.time.LocalDate;

/** Trạng thái 1 ngày trên lịch. state: PAST (đã qua) | FULL (hết lịch) | FEW (ít chỗ) | OPEN (còn lịch). */
public record DaySlot(LocalDate date, String state, int free) {}
