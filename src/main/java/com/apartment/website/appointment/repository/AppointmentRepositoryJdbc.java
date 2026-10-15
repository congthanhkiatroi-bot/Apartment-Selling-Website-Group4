package com.apartment.website.appointment.repository;

import com.apartment.website.appointment.entity.Appointment;
import com.apartment.website.common.exception.SlotTakenException;
import com.apartment.website.config.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/** Lưu lịch hẹn trong PostgreSQL (bảng viewing_appointments, xem database/04_...sql). */
public class AppointmentRepositoryJdbc implements AppointmentRepository {
    /** Mã lỗi PostgreSQL khi vi phạm UNIQUE (ở đây là unique index uq_appointment_slot). */
    private static final String UNIQUE_VIOLATION = "23505";

    @Override
    public Set<String> bookedSlots(long propertyId, LocalDate date) {
        String sql = "SELECT time_slot "
                + "FROM viewing_appointments "
                + "WHERE property_id = ? AND viewing_date = ? AND status <> 'CANCELLED'";

        Set<String> slots = new HashSet<String>();
        try (Connection connection = Database.getConnection()) {
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setLong(1, propertyId);
                statement.setObject(2, date);
                try (ResultSet rs = statement.executeQuery()) {
                    while (rs.next()) {
                        slots.add(rs.getString("time_slot"));
                    }
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return slots;
    }

    @Override
    public Map<LocalDate, Integer> bookedCountByDay(long propertyId, LocalDate from, LocalDate to) {
        String sql = "SELECT viewing_date, COUNT(*) AS booked "
                + "FROM viewing_appointments "
                + "WHERE property_id = ? AND viewing_date BETWEEN ? AND ? AND status <> 'CANCELLED' "
                + "GROUP BY viewing_date";

        Map<LocalDate, Integer> countByDay = new HashMap<LocalDate, Integer>();
        try (Connection connection = Database.getConnection()) {
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setLong(1, propertyId);
                statement.setObject(2, from);
                statement.setObject(3, to);
                try (ResultSet rs = statement.executeQuery()) {
                    while (rs.next()) {
                        LocalDate day = rs.getObject("viewing_date", LocalDate.class);
                        int booked = rs.getInt("booked");
                        countByDay.put(day, booked);
                    }
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return countByDay;
    }

    @Override
    public long create(Appointment appointment) {
        String sql = "INSERT INTO viewing_appointments (property_id, full_name, phone, email, attendees, note, "
                + "viewing_date, time_slot, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) "
                + "RETURNING appointment_id";

        long newId = 0;
        try (Connection connection = Database.getConnection()) {
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setLong(1, appointment.getPropertyId());
                statement.setString(2, appointment.getFullName());
                statement.setString(3, appointment.getPhone());
                statement.setString(4, appointment.getEmail());
                statement.setInt(5, appointment.getAttendees());
                statement.setString(6, appointment.getNote());
                statement.setObject(7, appointment.getDate());
                statement.setString(8, appointment.getTimeSlot());
                statement.setString(9, appointment.getStatus());
                try (ResultSet rs = statement.executeQuery()) {
                    if (rs.next()) {
                        newId = rs.getLong("appointment_id");
                    }
                }
            }
        } catch (SQLException e) {
            // 2 người đặt cùng 1 khung giờ -> DB chặn bằng unique index
            if (UNIQUE_VIOLATION.equals(e.getSQLState())) {
                throw new SlotTakenException();
            }
            throw new RuntimeException(e);
        }
        return newId;
    }

    @Override
    public Appointment findById(long id) {
        String sql = "SELECT appointment_id, property_id, full_name, phone, email, attendees, note, "
                + "viewing_date, time_slot, status "
                + "FROM viewing_appointments "
                + "WHERE appointment_id = ?";

        Appointment appointment = null;
        try (Connection connection = Database.getConnection()) {
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setLong(1, id);
                try (ResultSet rs = statement.executeQuery()) {
                    if (rs.next()) {
                        long appointmentId = rs.getLong("appointment_id");
                        long propertyId = rs.getLong("property_id");
                        String fullName = rs.getString("full_name");
                        String phone = rs.getString("phone");
                        String email = rs.getString("email");
                        int attendees = rs.getInt("attendees");
                        String note = rs.getString("note");
                        LocalDate viewingDate = rs.getObject("viewing_date", LocalDate.class);
                        String timeSlot = rs.getString("time_slot");
                        String status = rs.getString("status");

                        appointment = new Appointment(appointmentId, propertyId, fullName, phone, email,
                                attendees, note, viewingDate, timeSlot, status);
                    }
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return appointment;
    }
}
