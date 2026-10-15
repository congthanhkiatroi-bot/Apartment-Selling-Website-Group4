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
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** Quy tắc đặt lịch: khung giờ, trạng thái ngày, kiểm tra dữ liệu. */
public class AppointmentService {
    public static final ZoneId ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    // còn <= 2 khung giờ thì hiện "Ít chỗ"
    public static final int FEW_LEFT = 2;
    // cho đặt tối đa tới hết tháng thứ (hiện tại + 3)
    public static final int MAX_MONTHS_AHEAD = 3;
    private static final int MAX_NAME = 100;
    private static final int MAX_EMAIL = 100;
    private static final int MAX_NOTE = 500;
    private static final int MAX_ATTENDEES = 10;

    /** Các khung giờ xem nhà trong 1 ngày. */
    public static final List<String> SLOTS = new ArrayList<String>();

    static {
        SLOTS.add("08:30");
        SLOTS.add("09:30");
        SLOTS.add("10:30");
        SLOTS.add("13:30");
        SLOTS.add("14:30");
        SLOTS.add("15:30");
        SLOTS.add("16:30");
        SLOTS.add("17:30");
    }

    private final AppointmentRepository repository;

    public AppointmentService(AppointmentRepository repository) {
        this.repository = repository;
    }

    public LocalDate today() {
        return LocalDate.now(ZONE);
    }

    /** Ngày xa nhất được đặt: cuối tháng (hiện tại + 3). */
    public LocalDate maxDate() {
        YearMonth lastMonth = YearMonth.from(today()).plusMonths(MAX_MONTHS_AHEAD);
        return lastMonth.atEndOfMonth();
    }

    /** "2026-11" -> YearMonth, nằm trong khoảng cho phép; sai định dạng thì trả về tháng hiện tại. */
    public YearMonth parseMonth(String text) {
        YearMonth current = YearMonth.from(today());
        YearMonth month = current;
        if (text != null) {
            try {
                month = YearMonth.parse(text);
            } catch (DateTimeParseException e) {
                month = current;
            }
        }
        if (month.isBefore(current)) {
            return current;
        }
        YearMonth last = current.plusMonths(MAX_MONTHS_AHEAD);
        if (month.isAfter(last)) {
            return last;
        }
        return month;
    }

    /** Trạng thái từng ngày của một tháng (để vẽ lịch). */
    public List<DaySlot> month(long propertyId, YearMonth month) {
        LocalDate today = today();
        LocalDate firstDay = month.atDay(1);
        LocalDate lastDay = month.atEndOfMonth();
        Map<LocalDate, Integer> bookedByDay = repository.bookedCountByDay(propertyId, firstDay, lastDay);

        List<DaySlot> days = new ArrayList<DaySlot>();
        LocalDate day = firstDay;
        while (!day.isAfter(lastDay)) {
            if (day.isBefore(today)) {
                days.add(new DaySlot(day, DaySlot.PAST, 0));
            } else {
                int free;
                if (day.equals(today)) {
                    // hôm nay: đếm lại từng khung giờ vì có giờ đã trôi qua
                    free = countAvailable(slots(propertyId, day));
                } else {
                    Integer booked = bookedByDay.get(day);
                    if (booked == null) {
                        booked = 0;
                    }
                    free = SLOTS.size() - booked;
                }

                String state;
                if (free <= 0) {
                    state = DaySlot.FULL;
                    free = 0;
                } else if (free <= FEW_LEFT) {
                    state = DaySlot.FEW;
                } else {
                    state = DaySlot.OPEN;
                }
                days.add(new DaySlot(day, state, free));
            }
            day = day.plusDays(1);
        }
        return days;
    }

    private static int countAvailable(List<SlotInfo> slots) {
        int count = 0;
        for (int i = 0; i < slots.size(); i++) {
            if (slots.get(i).isAvailable()) {
                count++;
            }
        }
        return count;
    }

    /** Các khung giờ của 1 ngày, đánh dấu cái nào còn trống (đã đặt hoặc đã qua giờ thì không trống). */
    public List<SlotInfo> slots(long propertyId, LocalDate date) {
        Set<String> booked = repository.bookedSlots(propertyId, date);
        LocalTime now = LocalTime.now(ZONE);
        boolean isToday = date.equals(today());

        List<SlotInfo> result = new ArrayList<SlotInfo>();
        for (int i = 0; i < SLOTS.size(); i++) {
            String time = SLOTS.get(i);
            boolean past = isToday && LocalTime.parse(time).isBefore(now);
            boolean available = !booked.contains(time) && !past;
            result.add(new SlotInfo(time, available));
        }
        return result;
    }

    /** Kiểm tra dữ liệu rồi lưu. Ném BookingException (dữ liệu sai) hoặc SlotTakenException (giờ đã bị đặt). */
    public long book(BookingRequest request) {
        // 1. Ngày và giờ
        LocalDate date;
        try {
            date = LocalDate.parse(request.getDate());
        } catch (DateTimeParseException e) {
            throw new BookingException("Vui lòng chọn ngày xem nhà.");
        }
        if (!SLOTS.contains(request.getTime())) {
            throw new BookingException("Vui lòng chọn một khung giờ xem nhà.");
        }
        LocalDate today = today();
        if (date.isBefore(today) || date.isAfter(maxDate())) {
            throw new BookingException("Ngày đã chọn không hợp lệ.");
        }
        if (date.equals(today) && LocalTime.parse(request.getTime()).isBefore(LocalTime.now(ZONE))) {
            throw new BookingException("Khung giờ này đã qua, vui lòng chọn giờ khác.");
        }

        // 2. Thông tin người đặt
        String name = trimText(request.getFullName());
        // bỏ khoảng trắng, dấu chấm, gạch ngang: "0901 234.567" -> "0901234567"
        String phone = trimText(request.getPhone()).replaceAll("[\\s.\\-]", "");
        String email = trimText(request.getEmail());
        String note = trimText(request.getNote());

        if (name.isEmpty() || name.length() > MAX_NAME) {
            throw new BookingException("Vui lòng nhập họ và tên.");
        }
        if (!phone.matches("^(0|\\+84)\\d{9,10}$")) {
            throw new BookingException("Số điện thoại không hợp lệ (ví dụ 0901234567).");
        }
        if (!email.isEmpty()) {
            if (email.length() > MAX_EMAIL || !email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
                throw new BookingException("Email không hợp lệ.");
            }
        }
        if (note.length() > MAX_NOTE) {
            throw new BookingException("Ghi chú tối đa " + MAX_NOTE + " ký tự.");
        }

        // 3. Số người đi xem: sai thì coi là 1, giới hạn trong 1..10
        int attendees;
        try {
            attendees = Integer.parseInt(trimText(request.getAttendees()));
        } catch (NumberFormatException e) {
            attendees = 1;
        }
        if (attendees < 1) {
            attendees = 1;
        }
        if (attendees > MAX_ATTENDEES) {
            attendees = MAX_ATTENDEES;
        }

        // 4. Ô không bắt buộc để trống thì lưu NULL
        String emailToSave = null;
        if (!email.isEmpty()) {
            emailToSave = email;
        }
        String noteToSave = null;
        if (!note.isEmpty()) {
            noteToSave = note;
        }

        Appointment appointment = new Appointment(0, request.getPropertyId(), name, phone, emailToSave,
                attendees, noteToSave, date, request.getTime(), "PENDING");
        return repository.create(appointment);
    }

    /** Trả về null nếu không tìm thấy. */
    public Appointment findById(long id) {
        return repository.findById(id);
    }

    private static String trimText(String text) {
        if (text == null) {
            return "";
        }
        return text.trim();
    }
}
