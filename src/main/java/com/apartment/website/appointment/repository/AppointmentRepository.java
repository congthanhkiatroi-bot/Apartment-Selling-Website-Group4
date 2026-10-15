package com.apartment.website.appointment.repository;

import com.apartment.website.appointment.entity.Appointment;

import java.time.LocalDate;
import java.util.Map;
import java.util.Set;

public interface AppointmentRepository {
    /** Các khung giờ đã có người đặt (không tính lịch đã hủy) của căn hộ trong 1 ngày. */
    Set<String> bookedSlots(long propertyId, LocalDate date);

    /** Số lịch đã đặt theo từng ngày trong khoảng [from, to]. */
    Map<LocalDate, Integer> bookedCountByDay(long propertyId, LocalDate from, LocalDate to);

    /** Lưu lịch hẹn, trả về id. Ném SlotTakenException nếu khung giờ đã bị đặt. */
    long create(Appointment appointment);

    /** Trả về null nếu không có lịch hẹn với id này. */
    Appointment findById(long id);
}
