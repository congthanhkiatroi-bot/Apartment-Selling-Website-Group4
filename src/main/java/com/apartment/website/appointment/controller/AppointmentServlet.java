package com.apartment.website.appointment.controller;

import com.apartment.website.appointment.dto.BookingRequest;
import com.apartment.website.appointment.dto.DaySlot;
import com.apartment.website.appointment.dto.SlotInfo;
import com.apartment.website.appointment.entity.Appointment;
import com.apartment.website.appointment.service.AppointmentService;
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
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * /appointments?propertyId=1&month=2026-11&date=2026-11-05&time=09:30
 *  GET  : vẽ lịch, khung giờ, form. Chọn ngày / giờ = bấm vào liên kết (đổi tham số trên URL), không cần JavaScript.
 *  POST : nhận form đặt lịch -> kiểm tra -> lưu -> chuyển hướng về GET kèm &booked=<mã lịch hẹn>.
 */
@WebServlet("/appointments")
public class AppointmentServlet extends HttpServlet {
    private static final String[] DAY_OF_WEEK = {"Thứ hai", "Thứ ba", "Thứ tư", "Thứ năm", "Thứ sáu", "Thứ bảy", "Chủ nhật"};
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final String[] FORM_FIELDS = {"fullName", "phone", "email", "attendees", "note"};

    private AppointmentService appointmentService;
    private PropertyService propertyService;

    @Override
    public void init() {
        appointmentService = (AppointmentService) getServletContext().getAttribute(AppContextListener.APPOINTMENT_SERVICE);
        propertyService = (PropertyService) getServletContext().getAttribute(AppContextListener.PROPERTY_SERVICE);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        show(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Long propertyId = toLong(request.getParameter("propertyId"));
        if (propertyId == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        BookingRequest booking = new BookingRequest(
                propertyId,
                getText(request, "date"),
                getText(request, "time"),
                getText(request, "fullName"),
                getText(request, "phone"),
                getText(request, "email"),
                getText(request, "attendees"),
                getText(request, "note"));

        try {
            long appointmentId = appointmentService.book(booking);
            // redirect để F5 không gửi lại form
            response.sendRedirect(request.getContextPath() + "/appointments?propertyId=" + propertyId
                    + "&booked=" + appointmentId);
            return;
        } catch (SlotTakenException e) {
            request.setAttribute("error", "Khung giờ này vừa có người đặt. Vui lòng chọn khung giờ khác.");
        } catch (BookingException e) {
            request.setAttribute("error", e.getMessage());
        }

        // giữ lại những gì người dùng đã nhập
        Map<String, String> form = new HashMap<String, String>();
        for (int i = 0; i < FORM_FIELDS.length; i++) {
            String field = FORM_FIELDS[i];
            form.put(field, getText(request, field));
        }
        request.setAttribute("form", form);
        show(request, response);
    }

    private void show(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Property property = findProperty(request);
        if (property == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        long propertyId = property.getPropertyId();

        // ---- tháng và ngày đang xem ----
        LocalDate today = appointmentService.today();
        LocalDate maxDate = appointmentService.maxDate();
        YearMonth currentMonth = YearMonth.from(today);
        LocalDate selectedDate = parseDate(request.getParameter("date"));
        YearMonth month;
        if (selectedDate != null && !selectedDate.isBefore(today) && !selectedDate.isAfter(maxDate)) {
            month = YearMonth.from(selectedDate);
        } else {
            selectedDate = null;
            month = appointmentService.parseMonth(request.getParameter("month"));
        }
        // chưa chọn ngày: tháng này thì chọn hôm nay, tháng sau thì chọn ngày 1
        if (selectedDate == null) {
            if (month.equals(currentMonth)) {
                selectedDate = today;
            } else {
                selectedDate = month.atDay(1);
            }
        }

        String baseUrl = request.getContextPath() + "/appointments?propertyId=" + propertyId;

        // ---- lưới lịch (bắt đầu từ thứ 2) ----
        List<Map<String, Object>> cells = new ArrayList<Map<String, Object>>();
        int blankCells = month.atDay(1).getDayOfWeek().getValue() - 1;
        for (int i = 0; i < blankCells; i++) {
            Map<String, Object> blank = new HashMap<String, Object>();
            blank.put("blank", true);
            cells.add(blank);
        }
        List<DaySlot> days = appointmentService.month(propertyId, month);
        for (int i = 0; i < days.size(); i++) {
            DaySlot day = days.get(i);
            String cssClass;
            String label;
            String href = null;
            if (DaySlot.PAST.equals(day.getState())) {
                cssClass = "is-past";
                label = "Đã qua";
            } else if (DaySlot.FULL.equals(day.getState())) {
                cssClass = "is-full";
                label = "Hết lịch";
            } else if (DaySlot.FEW.equals(day.getState())) {
                cssClass = "is-few";
                label = "Ít chỗ";
                href = baseUrl + "&date=" + day.getDate();
            } else {
                cssClass = "";
                label = "Còn lịch";
                href = baseUrl + "&date=" + day.getDate();
            }
            if (day.getDate().equals(selectedDate)) {
                cssClass = cssClass + " is-selected";
            }

            Map<String, Object> cell = new HashMap<String, Object>();
            cell.put("day", day.getDate().getDayOfMonth());
            cell.put("cls", cssClass.trim());
            cell.put("label", label);
            cell.put("href", href);
            cells.add(cell);
        }

        // ---- khung giờ của ngày đang chọn ----
        String timeParam = request.getParameter("time");
        String selectedTime = null;
        List<Map<String, Object>> slots = new ArrayList<Map<String, Object>>();
        List<SlotInfo> slotInfos = appointmentService.slots(propertyId, selectedDate);
        for (int i = 0; i < slotInfos.size(); i++) {
            SlotInfo slotInfo = slotInfos.get(i);
            boolean selected = slotInfo.isAvailable() && slotInfo.getTime().equals(timeParam);
            if (selected) {
                selectedTime = slotInfo.getTime();
            }

            Map<String, Object> slot = new HashMap<String, Object>();
            slot.put("time", slotInfo.getTime());
            if (!slotInfo.isAvailable()) {
                slot.put("cls", "is-disabled");
                slot.put("href", null);
            } else {
                if (selected) {
                    slot.put("cls", "is-selected");
                } else {
                    slot.put("cls", "");
                }
                slot.put("href", baseUrl + "&date=" + selectedDate + "&time=" + encode(slotInfo.getTime()));
            }
            slots.add(slot);
        }

        // ---- lịch vừa đặt xong (hiện thông báo thành công) ----
        Long bookedId = toLong(request.getParameter("booked"));
        if (bookedId != null) {
            Appointment appointment = appointmentService.findById(bookedId);
            if (appointment != null) {
                Map<String, Object> booked = new HashMap<String, Object>();
                booked.put("id", appointment.getId());
                booked.put("dateText", formatDate(appointment.getDate()));
                booked.put("time", appointment.getTimeSlot());
                request.setAttribute("booked", booked);
            }
        }

        // ---- nút tháng trước / tháng sau (null = không bấm được) ----
        String previousHref = null;
        if (month.isAfter(currentMonth)) {
            previousHref = baseUrl + "&month=" + month.minusMonths(1);
        }
        String nextHref = null;
        if (month.isBefore(currentMonth.plusMonths(AppointmentService.MAX_MONTHS_AHEAD))) {
            nextHref = baseUrl + "&month=" + month.plusMonths(1);
        }
        String timeText = "Chưa chọn";
        if (selectedTime != null) {
            timeText = selectedTime;
        }

        request.setAttribute("active", "schedule");
        request.setAttribute("property", property);
        request.setAttribute("monthTitle", "Tháng " + month.getMonthValue() + ", " + month.getYear());
        request.setAttribute("prevHref", previousHref);
        request.setAttribute("nextHref", nextHref);
        request.setAttribute("cells", cells);
        request.setAttribute("slots", slots);
        request.setAttribute("selectedDate", selectedDate.toString());
        request.setAttribute("selectedTime", selectedTime);
        request.setAttribute("dateText", formatDate(selectedDate));
        request.setAttribute("timeText", timeText);
        View.forward(request, response, "appointment/schedule");
    }

    /** Có propertyId thì lấy căn đó, không thì lấy căn mới nhất để trang vẫn hiển thị được. Không có căn nào thì null. */
    private Property findProperty(HttpServletRequest request) {
        Long id = toLong(request.getParameter("propertyId"));
        if (id != null) {
            return propertyService.findById(id);
        }
        List<Property> featured = propertyService.featured(1);
        if (featured.isEmpty()) {
            return null;
        }
        return featured.get(0);
    }

    /** 2026-11-05 -> "Thứ năm, 05/11/2026" */
    private static String formatDate(LocalDate date) {
        int dayIndex = date.getDayOfWeek().getValue() - 1;
        return DAY_OF_WEEK[dayIndex] + ", " + date.format(DATE_FORMAT);
    }

    private static LocalDate parseDate(String text) {
        if (text == null) {
            return null;
        }
        try {
            return LocalDate.parse(text);
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    private static Long toLong(String text) {
        if (text == null) {
            return null;
        }
        try {
            return Long.parseLong(text.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /** Tham số không có thì trả về chuỗi rỗng thay vì null. */
    private static String getText(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value == null) {
            return "";
        }
        return value;
    }

    private static String encode(String text) {
        return URLEncoder.encode(text, StandardCharsets.UTF_8);
    }
}
