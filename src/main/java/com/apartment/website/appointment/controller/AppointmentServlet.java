package com.apartment.website.appointment.controller;

import com.apartment.website.appointment.dto.BookingRequest;
import com.apartment.website.appointment.dto.DaySlot;
import com.apartment.website.appointment.dto.SlotInfo;
import com.apartment.website.appointment.service.AppointmentService;
import com.apartment.website.auth.entity.SessionUser;
import com.apartment.website.common.filter.CurrentUserFilter;
import com.apartment.website.common.exception.BookingException;
import com.apartment.website.common.exception.SlotTakenException;
import com.apartment.website.common.util.View;
import com.apartment.website.config.AppContextListener;
import com.apartment.website.property.entity.Property;
import com.apartment.website.property.service.PropertyService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * /appointments?propertyId=1&month=2026-11&date=2026-11-05&time=09:30
 *  GET  : vẽ lịch, khung giờ, form. Chọn ngày / giờ = bấm vào liên kết (đổi tham số trên URL), không cần JavaScript.
 *  POST : nhận form đặt lịch -> kiểm tra -> lưu -> chuyển hướng về GET kèm &booked=<mã lịch hẹn>.
 */
@WebServlet("/appointments")
public class AppointmentServlet extends HttpServlet {
    private static final String[] DOW = {"Thứ hai", "Thứ ba", "Thứ tư", "Thứ năm", "Thứ sáu", "Thứ bảy", "Chủ nhật"};
    private static final DateTimeFormatter DMY = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final String[] FORM_FIELDS = {"fullName", "phone", "email", "attendees", "note"};

    private AppointmentService appointments;
    private PropertyService properties;

    @Override
    public void init() {
        appointments = (AppointmentService) getServletContext().getAttribute(AppContextListener.APPOINTMENT_SERVICE);
        properties = (PropertyService) getServletContext().getAttribute(AppContextListener.PROPERTY_SERVICE);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        show(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long propertyId = toLong(req.getParameter("propertyId"));
        if (propertyId == null) { resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }
        BookingRequest booking = new BookingRequest(propertyId, p(req, "date"), p(req, "time"), p(req, "fullName"),
                p(req, "phone"), p(req, "email"), p(req, "attendees"), p(req, "note"));
        try {
            long id = appointments.book(booking);
            resp.sendRedirect(req.getContextPath() + "/appointments?propertyId=" + propertyId + "&booked=" + id);   // tránh gửi lại form khi F5
            return;
        } catch (SlotTakenException e) {
            req.setAttribute("error", "Khung giờ này vừa có người đặt. Vui lòng chọn khung giờ khác.");
        } catch (BookingException e) {
            req.setAttribute("error", e.getMessage());
        }
        Map<String, String> form = new HashMap<>();            // giữ lại những gì người dùng đã nhập
        for (String f : FORM_FIELDS) form.put(f, p(req, f));
        req.setAttribute("form", form);
        show(req, resp);
    }

    private void show(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Optional<Property> found = resolveProperty(req);
        if (found.isEmpty()) { resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }
        Property property = found.get();
        long pid = property.getPropertyId();

        LocalDate today = appointments.today(), max = appointments.maxDate();
        YearMonth current = YearMonth.from(today);
        LocalDate date = parseDate(req.getParameter("date"));
        YearMonth ym;
        if (date != null && !date.isBefore(today) && !date.isAfter(max)) ym = YearMonth.from(date);
        else { date = null; ym = appointments.parseMonth(req.getParameter("month")); }
        if (date == null) date = ym.equals(current) ? today : ym.atDay(1);

        String base = req.getContextPath() + "/appointments?propertyId=" + pid;

        // ---- lưới lịch (bắt đầu từ thứ 2) ----
        List<Map<String, Object>> cells = new ArrayList<>();
        for (int i = 0; i < ym.atDay(1).getDayOfWeek().getValue() - 1; i++) cells.add(Map.of("blank", true));
        for (DaySlot d : appointments.month(pid, ym)) {
            String cls, label, href = null;
            switch (d.state()) {
                case "PAST" -> { cls = "is-past"; label = "Đã qua"; }
                case "FULL" -> { cls = "is-full"; label = "Hết lịch"; }
                case "FEW" -> { cls = "is-few"; label = "Ít chỗ"; href = base + "&date=" + d.date(); }
                default -> { cls = ""; label = "Còn lịch"; href = base + "&date=" + d.date(); }
            }
            if (d.date().equals(date)) cls += " is-selected";
            Map<String, Object> cell = new HashMap<>();
            cell.put("day", d.date().getDayOfMonth());
            cell.put("cls", cls.trim());
            cell.put("label", label);
            cell.put("href", href);
            cells.add(cell);
        }

        // ---- khung giờ của ngày đang chọn ----
        String timeParam = req.getParameter("time"), selectedTime = null;
        List<Map<String, Object>> slots = new ArrayList<>();
        for (SlotInfo s : appointments.slots(pid, date)) {
            boolean selected = s.available() && s.time().equals(timeParam);
            if (selected) selectedTime = s.time();
            Map<String, Object> slot = new HashMap<>();
            slot.put("time", s.time());
            slot.put("cls", !s.available() ? "is-disabled" : selected ? "is-selected" : "");
            slot.put("href", s.available() ? base + "&date=" + date + "&time=" + enc(s.time()) : null);
            slots.add(slot);
        }

        // ---- lịch vừa đặt xong (hiện thông báo thành công) ----
        Long bookedId = toLong(req.getParameter("booked"));
        if (bookedId != null)
            appointments.findById(bookedId).ifPresent(a -> req.setAttribute("booked",
                    Map.of("id", a.getId(), "dateText", dateText(a.getDate()), "time", a.getTimeSlot())));

        if (req.getAttribute("form") == null && req.getSession(false) != null
                && req.getSession(false).getAttribute(CurrentUserFilter.SESSION_KEY) instanceof SessionUser u) {
            Map<String, String> prefill = new HashMap<>();          // điền sẵn thông tin người đăng nhập
            prefill.put("fullName", u.getDisplayName());
            prefill.put("phone", u.getUsername());
            req.setAttribute("form", prefill);
        }

        req.setAttribute("active", "schedule");
        req.setAttribute("property", property);
        req.setAttribute("monthTitle", "Tháng " + ym.getMonthValue() + ", " + ym.getYear());
        req.setAttribute("prevHref", ym.isAfter(current) ? base + "&month=" + ym.minusMonths(1) : null);
        req.setAttribute("nextHref", ym.isBefore(current.plusMonths(AppointmentService.MAX_MONTHS_AHEAD)) ? base + "&month=" + ym.plusMonths(1) : null);
        req.setAttribute("cells", cells);
        req.setAttribute("slots", slots);
        req.setAttribute("selectedDate", date.toString());
        req.setAttribute("selectedTime", selectedTime);
        req.setAttribute("dateText", dateText(date));
        req.setAttribute("timeText", selectedTime == null ? "Chưa chọn" : selectedTime);
        View.forward(req, resp, "appointment/schedule");
    }

    /** Có propertyId thì lấy căn đó, không thì lấy căn mới nhất để trang vẫn hiển thị được. */
    private Optional<Property> resolveProperty(HttpServletRequest req) {
        Long id = toLong(req.getParameter("propertyId"));
        if (id != null) return properties.findById(id);
        List<Property> featured = properties.featured(1);
        return featured.isEmpty() ? Optional.empty() : Optional.of(featured.get(0));
    }

    private static String dateText(LocalDate d) { return DOW[d.getDayOfWeek().getValue() - 1] + ", " + d.format(DMY); }
    private static LocalDate parseDate(String s) { try { return s == null ? null : LocalDate.parse(s); } catch (Exception e) { return null; } }
    private static Long toLong(String s) { try { return s == null ? null : Long.parseLong(s.trim()); } catch (Exception e) { return null; } }
    private static String p(HttpServletRequest req, String name) { String v = req.getParameter(name); return v == null ? "" : v; }
    private static String enc(String s) { return URLEncoder.encode(s, StandardCharsets.UTF_8); }
}
