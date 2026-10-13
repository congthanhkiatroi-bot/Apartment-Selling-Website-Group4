package com.apartment.website.appointment.repository;

import com.apartment.website.appointment.entity.Appointment;
import com.apartment.website.common.exception.SlotTakenException;
import com.apartment.website.config.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.*;

/** Lưu lịch hẹn trong PostgreSQL (bảng viewing_appointments, xem database/04_...sql). */
public class AppointmentRepositoryJdbc implements AppointmentRepository {

    @Override
    public Set<String> bookedSlots(long propertyId, LocalDate date) {
        String sql = "SELECT time_slot FROM viewing_appointments "
                + "WHERE property_id = ? AND viewing_date = ? AND status <> 'CANCELLED'";
        try (Connection c = Database.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, propertyId);
            ps.setObject(2, date);
            Set<String> out = new HashSet<>();
            try (ResultSet rs = ps.executeQuery()) { while (rs.next()) out.add(rs.getString(1)); }
            return out;
        } catch (SQLException e) { throw new RuntimeException(e); }
    }

    @Override
    public Map<LocalDate, Integer> bookedCountByDay(long propertyId, LocalDate from, LocalDate to) {
        String sql = "SELECT viewing_date, COUNT(*) FROM viewing_appointments "
                + "WHERE property_id = ? AND viewing_date BETWEEN ? AND ? AND status <> 'CANCELLED' GROUP BY viewing_date";
        try (Connection c = Database.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, propertyId);
            ps.setObject(2, from);
            ps.setObject(3, to);
            Map<LocalDate, Integer> out = new HashMap<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.put(rs.getObject(1, LocalDate.class), rs.getInt(2));
            }
            return out;
        } catch (SQLException e) { throw new RuntimeException(e); }
    }

    @Override
    public long create(Appointment a) {
        String sql = "INSERT INTO viewing_appointments (property_id, full_name, phone, email, attendees, note, "
                + "viewing_date, time_slot, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING appointment_id";
        try (Connection c = Database.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, a.getPropertyId());
            ps.setString(2, a.getFullName());
            ps.setString(3, a.getPhone());
            ps.setString(4, a.getEmail());
            ps.setInt(5, a.getAttendees());
            ps.setString(6, a.getNote());
            ps.setObject(7, a.getDate());
            ps.setString(8, a.getTimeSlot());
            ps.setString(9, a.getStatus());
            try (ResultSet rs = ps.executeQuery()) { rs.next(); return rs.getLong(1); }
        } catch (SQLException e) {
            if ("23505".equals(e.getSQLState())) throw new SlotTakenException();   // vi phạm unique index uq_appointment_slot
            throw new RuntimeException(e);
        }
    }

    @Override
    public Optional<Appointment> findById(long id) {
        String sql = "SELECT appointment_id, property_id, full_name, phone, email, attendees, note, viewing_date, "
                + "time_slot, status FROM viewing_appointments WHERE appointment_id = ?";
        try (Connection c = Database.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return Optional.empty();
                return Optional.of(new Appointment(rs.getLong(1), rs.getLong(2), rs.getString(3), rs.getString(4),
                        rs.getString(5), rs.getInt(6), rs.getString(7), rs.getObject(8, LocalDate.class),
                        rs.getString(9), rs.getString(10)));
            }
        } catch (SQLException e) { throw new RuntimeException(e); }
    }
}
