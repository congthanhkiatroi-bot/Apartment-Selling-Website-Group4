package com.apartment.website.appointment.service;

import com.apartment.website.appointment.dto.BookingRequest;
import com.apartment.website.appointment.dto.DaySlot;
import com.apartment.website.appointment.dto.SlotInfo;
import com.apartment.website.appointment.entity.Appointment;
import com.apartment.website.appointment.repository.AppointmentRepository;
import com.apartment.website.common.exception.BookingException;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.YearMonth;
import java.time.ZoneId;
import java.util.*;

/** Quy tắc đặt lịch: khung giờ, trạng thái ngày, kiểm tra dữ liệu. */
public class AppointmentService {
    public static final ZoneId ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    public static final List<String> SLOTS = List.of("08:30", "09:30", "10:30", "13:30", "14:30", "15:30", "16:30", "17:30");
    public static final int FEW_LEFT = 2;          // còn <= 2 khung giờ thì hiện "Ít chỗ"
    public static final int MAX_MONTHS_AHEAD = 3;  // cho đặt tối đa tới hết tháng thứ hiện tại + 3

    private final AppointmentRepository repository;

    public AppointmentService(AppointmentRepository repository) { this.repository = repository; }

    public LocalDate today() { return LocalDate.now(ZONE); }
    public LocalDate maxDate() { return YearMonth.from(today()).plusMonths(MAX_MONTHS_AHEAD).atEndOfMonth(); }

    /** "2026-11" -> YearMonth, nằm trong khoảng cho phép; sai định dạng thì trả về tháng hiện tại. */
    public YearMonth parseMonth(String text) {
        YearMonth current = YearMonth.from(today()), ym = current;
        try { if (text != null) ym = YearMonth.parse(text); } catch (Exception ignored) { }
        if (ym.isBefore(current)) return current;
        YearMonth last = current.plusMonths(MAX_MONTHS_AHEAD);
        return ym.isAfter(last) ? last : ym;
    }

    /** Trạng thái từng ngày của một tháng (để vẽ lịch). */
    public List<DaySlot> month(long propertyId, YearMonth ym) {
        LocalDate today = today();
        Map<LocalDate, Integer> booked = repository.bookedCountByDay(propertyId, ym.atDay(1), ym.atEndOfMonth());
        List<DaySlot> days = new ArrayList<>();
        for (LocalDate d = ym.atDay(1); !d.isAfter(ym.atEndOfMonth()); d = d.plusDays(1)) {
            if (d.isBefore(today)) { days.add(new DaySlot(d, "PAST", 0)); continue; }
            int free = SLOTS.size() - booked.getOrDefault(d, 0);
            if (d.equals(today)) free = (int) slots(propertyId, d).stream().filter(SlotInfo::available).count();
            days.add(new DaySlot(d, free <= 0 ? "FULL" : free <= FEW_LEFT ? "FEW" : "OPEN", Math.max(free, 0)));
        }
        return days;
    }

    /** Các khung giờ của 1 ngày, đánh dấu cái nào còn trống (đã đặt hoặc đã qua giờ thì không trống). */
    public List<SlotInfo> slots(long propertyId, LocalDate date) {
        Set<String> booked = repository.bookedSlots(propertyId, date);
        LocalTime now = LocalTime.now(ZONE);
        List<SlotInfo> out = new ArrayList<>();
        for (String s : SLOTS) {
            boolean past = date.equals(today()) && LocalTime.parse(s).isBefore(now);
            out.add(new SlotInfo(s, !booked.contains(s) && !past));
        }
        return out;
    }

    /** Kiểm tra dữ liệu rồi lưu. Ném BookingException (dữ liệu sai) hoặc SlotTakenException (giờ đã bị đặt). */
    public long book(BookingRequest r) {
        LocalDate date;
        try { date = LocalDate.parse(r.date()); }
        catch (Exception e) { throw new BookingException("Vui lòng chọn ngày xem nhà."); }
        if (!SLOTS.contains(r.time())) throw new BookingException("Vui lòng chọn một khung giờ xem nhà.");
        LocalDate today = today();
        if (date.isBefore(today) || date.isAfter(maxDate())) throw new BookingException("Ngày đã chọn không hợp lệ.");
        if (date.equals(today) && LocalTime.parse(r.time()).isBefore(LocalTime.now(ZONE)))
            throw new BookingException("Khung giờ này đã qua, vui lòng chọn giờ khác.");

        String name = trim(r.fullName()), phone = trim(r.phone()).replaceAll("[\\s.\\-]", ""), email = trim(r.email()), note = trim(r.note());
        if (name.isEmpty() || name.length() > 100) throw new BookingException("Vui lòng nhập họ và tên.");
        if (!phone.matches("^(0|\\+84)\\d{9,10}$")) throw new BookingException("Số điện thoại không hợp lệ (ví dụ 0901234567).");
        if (!email.isEmpty() && (email.length() > 100 || !email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")))
            throw new BookingException("Email không hợp lệ.");
        if (note.length() > 500) throw new BookingException("Ghi chú tối đa 500 ký tự.");
        int attendees;
        try { attendees = Integer.parseInt(trim(r.attendees())); } catch (NumberFormatException e) { attendees = 1; }
        attendees = Math.min(Math.max(attendees, 1), 10);

        return repository.create(new Appointment(0, r.propertyId(), name, phone, email.isEmpty() ? null : email,
                attendees, note.isEmpty() ? null : note, date, r.time(), "PENDING"));
    }

    public Optional<Appointment> findById(long id) { return repository.findById(id); }

    private static String trim(String s) { return s == null ? "" : s.trim(); }
}
