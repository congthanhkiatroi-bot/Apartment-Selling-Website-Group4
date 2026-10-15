package com.apartment.website.listing.controller;

import com.apartment.website.common.exception.ListingException;
import com.apartment.website.common.filter.AuthFilter;
import com.apartment.website.common.util.View;
import com.apartment.website.config.AppContextListener;
import com.apartment.website.listing.entity.Listing;
import com.apartment.website.listing.service.ListingService;
import com.apartment.website.user.entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Trang "Quản lý tin" (cần đăng nhập, AuthFilter đã kiểm tra):
 *  Chủ căn hộ (OWNER):
 *   GET  /postings                    -> các tin mình đã đăng           -> views/listing/manage.jsp
 *   GET  /postings?action=create      -> form đăng tin                  -> views/listing/post.jsp
 *   POST /postings  (action=create)   -> nhận dữ liệu form (chưa lưu DB)
 *  Quản trị viên (ADMIN):
 *   GET  /postings?q=...              -> tất cả tin đã đăng để rà soát   -> views/listing/admin.jsp
 *   POST /postings  (action=delete, id, reason, q) -> xóa căn đăng sai mô tả
 *  Khách hàng: 403.
 */
@WebServlet("/postings")
public class ListingServlet extends HttpServlet {
    /** Câu thông báo xanh hiện 1 lần sau khi xóa (lưu tạm trong session). */
    private static final String FLASH = "listingFlash";

    private ListingService listingService;

    @Override
    public void init() {
        listingService = (ListingService) getServletContext().getAttribute(AppContextListener.LISTING_SERVICE);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = AuthFilter.getLoginUser(request);
        if (user == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if (user.isAdmin()) {
            showAdmin(request, response);
            return;
        }
        if (!user.isOwner()) {
            // khách hàng không có quyền đăng tin -> web.xml hiện 403.jsp
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        if ("create".equals(action)) {
            request.setAttribute("active", "post");
            View.forward(request, response, "listing/post");
        } else {
            List<Listing> listings = listingService.myListings(user.getUserId());
            request.setAttribute("active", "manage");
            request.setAttribute("listings", listings);
            View.forward(request, response, "listing/manage");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = AuthFilter.getLoginUser(request);
        String action = request.getParameter("action");

        if ("delete".equals(action)) {
            deleteByAdmin(request, response, user);
            return;
        }
        if ("create".equals(action)) {
            createListing(request, response, user);
            return;
        }
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    // ===================== ADMIN =====================

    private void showAdmin(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String keyword = request.getParameter("q");
        if (keyword == null) {
            keyword = "";
        }
        List<Listing> listings = listingService.allListings(keyword);

        // thông báo xanh sau khi xóa: đọc xong thì xóa khỏi session
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute(FLASH) != null) {
            request.setAttribute("message", session.getAttribute(FLASH));
            session.removeAttribute(FLASH);
        }

        request.setAttribute("active", "manage");
        request.setAttribute("listings", listings);
        request.setAttribute("q", keyword);
        View.forward(request, response, "listing/admin");
    }

    private void deleteByAdmin(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        if (user == null || !user.isAdmin()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        Long id = toLong(request.getParameter("id"));
        if (id == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        try {
            String message = listingService.deleteByAdmin(id, user, request.getParameter("reason"));
            HttpSession session = request.getSession(true);
            session.setAttribute(FLASH, message);
            // redirect (PRG), giữ nguyên ô tìm kiếm đang dùng
            String keyword = request.getParameter("q");
            if (keyword == null) {
                keyword = "";
            }
            response.sendRedirect(request.getContextPath() + "/postings?q=" + URLEncoder.encode(keyword, StandardCharsets.UTF_8));
            return;
        } catch (ListingException e) {
            request.setAttribute("error", e.getMessage());
        }
        showAdmin(request, response);
    }

    // ===================== CHỦ CĂN HỘ =====================

    private void createListing(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        if (user == null || !user.isOwner()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // TODO (backend): gom request.getParameter("title"), ("price")... -> ListingService.create(...) -> lưu DB
        // (tin đăng xong hiện luôn, không cần duyệt), rồi response.sendRedirect(... "/postings").
        List<Map<String, Object>> fields = new ArrayList<Map<String, Object>>();
        Map<String, String[]> parameters = request.getParameterMap();
        for (Map.Entry<String, String[]> entry : parameters.entrySet()) {
            Map<String, Object> field = new HashMap<String, Object>();
            field.put("name", entry.getKey());
            field.put("value", String.join(", ", entry.getValue()));
            fields.add(field);
        }

        request.setAttribute("active", "post");
        request.setAttribute("fields", fields);
        View.forward(request, response, "listing/post-result");
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
}
