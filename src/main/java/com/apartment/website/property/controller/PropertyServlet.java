package com.apartment.website.property.controller;

import com.apartment.website.common.exception.ReviewException;
import com.apartment.website.common.util.View;
import com.apartment.website.config.AppContextListener;
import com.apartment.website.interaction.dto.ReviewSummary;
import com.apartment.website.interaction.entity.Review;
import com.apartment.website.interaction.service.ReviewService;
import com.apartment.website.property.dto.PageResult;
import com.apartment.website.property.dto.PropertyFilter;
import com.apartment.website.property.entity.Property;
import com.apartment.website.property.service.PropertyService;
import com.apartment.website.user.entity.Owner;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Điều hướng bằng tham số action:
 *  GET  /properties                          -> danh sách (lọc + phân trang)  -> views/property/list.jsp
 *  GET  /properties?action=detail&id=3       -> chi tiết căn id 3              -> views/property/detail.jsp
 *  POST /properties  (action=review, id=3)   -> gửi đánh giá, xong redirect về trang chi tiết
 */
@WebServlet("/properties")
public class PropertyServlet extends HttpServlet {
    private static final String[] REVIEW_FIELDS = {"name", "email", "rating", "comment"};

    private PropertyService propertyService;
    private ReviewService reviewService;

    @Override
    public void init() {
        propertyService = (PropertyService) getServletContext().getAttribute(AppContextListener.PROPERTY_SERVICE);
        reviewService = (ReviewService) getServletContext().getAttribute(AppContextListener.REVIEW_SERVICE);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null || action.isEmpty() || action.equals("list")) {
            showList(request, response);
        } else if (action.equals("detail")) {
            showDetail(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("review".equals(action)) {
            submitReview(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // ===================== action=list =====================

    private void showList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Đọc các ô lọc trên URL
        String keyword = getText(request, "keyword");
        String district = getText(request, "district");
        String price = getText(request, "price");
        String type = "SALE";
        if ("RENT".equalsIgnoreCase(getText(request, "type"))) {
            type = "RENT";
        }
        Integer bedrooms = toInt(request.getParameter("bedrooms"));
        Integer pageParam = toInt(request.getParameter("page"));
        int page = 1;
        if (pageParam != null && pageParam > 1) {
            page = pageParam;
        }

        // 2. Gọi Service lấy 1 trang kết quả
        PropertyFilter filter = new PropertyFilter(keyword, district, bedrooms, price, type);
        PageResult<Property> result = propertyService.search(filter, page);
        // gõ page quá lớn -> lùi về trang cuối
        if (page > result.getTotalPages()) {
            page = result.getTotalPages();
            result = propertyService.search(filter, page);
        }

        // 3. Danh sách quận cho ô chọn, đánh dấu quận đang chọn
        List<Map<String, Object>> districts = new ArrayList<Map<String, Object>>();
        List<String> districtNames = propertyService.districts();
        for (int i = 0; i < districtNames.size(); i++) {
            String name = districtNames.get(i);
            Map<String, Object> option = new HashMap<String, Object>();
            option.put("value", name);
            if (name.equals(district)) {
                option.put("selected", "selected");
            } else {
                option.put("selected", "");
            }
            districts.add(option);
        }

        // 4. Link phân trang giữ nguyên bộ lọc, chỉ đổi số trang ở cuối
        String bedroomsText = "";
        if (bedrooms != null) {
            bedroomsText = String.valueOf(bedrooms);
        }
        String baseUrl = request.getContextPath() + "/properties?action=list"
                + "&keyword=" + encode(keyword)
                + "&district=" + encode(district)
                + "&price=" + encode(price)
                + "&type=" + type
                + "&bedrooms=" + bedroomsText
                + "&page=";

        // "Hiển thị from–to trong tổng số total căn"
        long from = 0;
        if (result.getTotal() > 0) {
            from = (long) (page - 1) * result.getSize() + 1;
        }
        long to = (long) page * result.getSize();
        if (to > result.getTotal()) {
            to = result.getTotal();
        }

        // 5. Gửi dữ liệu sang JSP
        request.setAttribute("active", "list");
        request.setAttribute("type", type);
        request.setAttribute("properties", result.getItems());
        request.setAttribute("total", result.getTotal());
        request.setAttribute("noResult", result.getItems().isEmpty());
        request.setAttribute("districts", districts);
        request.setAttribute("from", from);
        request.setAttribute("to", to);
        request.setAttribute("totalPages", result.getTotalPages());
        request.setAttribute("pages", buildPageLinks(baseUrl, page, result.getTotalPages()));
        View.forward(request, response, "property/list");
    }

    /** « 1 2 3 … 10 »: luôn có trang đầu, trang cuối và 2 trang quanh trang hiện tại. href = null nghĩa là không bấm được. */
    private static List<Map<String, Object>> buildPageLinks(String baseUrl, int current, int total) {
        List<Map<String, Object>> links = new ArrayList<Map<String, Object>>();

        String previousHref = null;
        if (current > 1) {
            previousHref = baseUrl + (current - 1);
        }
        links.add(createLink("«", previousHref, false));

        int lastShown = 0;
        for (int i = 1; i <= total; i++) {
            boolean isFirstOrLast = (i == 1 || i == total);
            boolean nearCurrent = Math.abs(i - current) <= 2;
            if (!isFirstOrLast && !nearCurrent) {
                continue;
            }
            // có khoảng trống giữa 2 số trang -> chèn dấu …
            if (i - lastShown > 1) {
                links.add(createLink("…", null, false));
            }
            links.add(createLink(String.valueOf(i), baseUrl + i, i == current));
            lastShown = i;
        }

        String nextHref = null;
        if (current < total) {
            nextHref = baseUrl + (current + 1);
        }
        links.add(createLink("»", nextHref, false));
        return links;
    }

    private static Map<String, Object> createLink(String label, String href, boolean active) {
        Map<String, Object> link = new HashMap<String, Object>();
        link.put("label", label);
        link.put("href", href);
        link.put("active", active);
        return link;
    }

    // ===================== action=detail =====================

    private void showDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Lấy id trên URL rồi tìm căn
        Long id = toLong(request.getParameter("id"));
        if (id == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        Property property = propertyService.findById(id);
        if (property == null) {
            // web.xml sẽ hiện 404.jsp
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // 2. Ảnh: ảnh lớn là ảnh thứ ?img=..., các ảnh nhỏ là link đổi ?img
        List<String> imageUrls = property.getImageUrls();
        if (imageUrls.isEmpty()) {
            imageUrls = new ArrayList<String>();
            imageUrls.add(Property.NO_IMAGE);
        }
        int selected = 0;
        Integer imgParam = toInt(request.getParameter("img"));
        if (imgParam != null && imgParam > 0 && imgParam < imageUrls.size()) {
            selected = imgParam;
        }
        List<Map<String, Object>> thumbs = new ArrayList<Map<String, Object>>();
        for (int i = 0; i < imageUrls.size(); i++) {
            Map<String, Object> thumb = new HashMap<String, Object>();
            thumb.put("url", imageUrls.get(i));
            thumb.put("href", request.getContextPath() + "/properties?action=detail&id=" + property.getPropertyId() + "&img=" + i);
            if (i == selected) {
                thumb.put("active", "is-active");
            } else {
                thumb.put("active", "");
            }
            thumbs.add(thumb);
        }

        // 3. Căn tương tự: cùng quận và khu vực khác
        List<Property> sameDistrict = propertyService.sameDistrict(property);
        List<Property> otherDistrict = propertyService.otherDistrict(property, sameDistrict.size());

        // 4. Chủ sở hữu (có thể chưa có)
        Owner owner = propertyService.ownerOf(property.getPropertyId());
        int ownerListings = 0;
        if (owner != null) {
            ownerListings = propertyService.activeListingCount(owner.getOwnerId());
        }

        // 5. Đánh giá
        List<Review> reviews = reviewService.reviews(property.getPropertyId());
        ReviewSummary reviewSummary = reviewService.summary(reviews);
        // form đánh giá: lần đầu mở trang thì mặc định chọn 5 sao
        if (request.getAttribute("reviewForm") == null) {
            Map<String, String> defaultForm = new HashMap<String, String>();
            defaultForm.put("rating", "5");
            request.setAttribute("reviewForm", defaultForm);
        }

        // 6. Gửi dữ liệu sang JSP
        request.setAttribute("active", "list");
        request.setAttribute("property", property);
        request.setAttribute("mainImage", imageUrls.get(selected));
        request.setAttribute("images", thumbs);
        request.setAttribute("sameDistrict", sameDistrict);
        request.setAttribute("otherDistrict", otherDistrict);
        request.setAttribute("owner", owner);
        request.setAttribute("ownerListings", ownerListings);
        request.setAttribute("reviews", reviews);
        request.setAttribute("reviewSummary", reviewSummary);
        // "created" | "updated" sau khi gửi đánh giá thành công
        request.setAttribute("reviewStatus", getText(request, "review"));
        View.forward(request, response, "property/detail");
    }

    // ===================== action=review (POST) =====================

    private void submitReview(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Long id = toLong(request.getParameter("id"));
        if (id == null || propertyService.findById(id) == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String rating = request.getParameter("rating");
        String comment = request.getParameter("comment");

        try {
            boolean created = reviewService.submit(id, name, email, rating, comment);
            String status;
            if (created) {
                status = "created";
            } else {
                status = "updated";
            }
            // redirect (Post/Redirect/Get) để F5 không gửi lại form; #reviews cuộn thẳng xuống phần đánh giá
            response.sendRedirect(request.getContextPath() + "/properties?action=detail&id=" + id
                    + "&review=" + status + "#reviews");
            return;
        } catch (ReviewException e) {
            request.setAttribute("reviewError", e.getMessage());
        }

        // Dữ liệu sai -> hiện lại trang chi tiết, giữ lại những gì người dùng đã nhập
        Map<String, String> form = new HashMap<String, String>();
        for (int i = 0; i < REVIEW_FIELDS.length; i++) {
            String field = REVIEW_FIELDS[i];
            form.put(field, getText(request, field));
        }
        request.setAttribute("reviewForm", form);
        showDetail(request, response);
    }

    // ===================== hàm phụ =====================

    /** Tham số không có thì trả về chuỗi rỗng thay vì null. */
    private static String getText(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value == null) {
            return "";
        }
        return value;
    }

    private static Integer toInt(String text) {
        if (text == null) {
            return null;
        }
        try {
            return Integer.parseInt(text.trim());
        } catch (NumberFormatException e) {
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

    private static String encode(String text) {
        return URLEncoder.encode(text, StandardCharsets.UTF_8);
    }
}
