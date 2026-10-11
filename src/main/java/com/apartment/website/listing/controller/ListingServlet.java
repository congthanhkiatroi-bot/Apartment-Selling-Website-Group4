package com.apartment.website.listing.controller;

import com.apartment.website.common.util.View;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.*;

/** /postings/create: GET hiện form đăng tin, POST nhận dữ liệu form (thay cho ListingWebController). */
@WebServlet("/postings/create")
public class ListingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("active", "post");
        View.forward(req, resp, "listing/post");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // TODO (backend): gom req.getParameter("title"), ("price")... -> ListingService.create(...) -> lưu DB,
        // rồi resp.sendRedirect(req.getContextPath() + "/properties") để tránh gửi lại form khi F5.
        List<Map<String, Object>> fields = new ArrayList<>();
        req.getParameterMap().forEach((name, values) -> fields.add(Map.of("name", name, "value", String.join(", ", values))));
        req.setAttribute("active", "post");
        req.setAttribute("fields", fields);
        View.forward(req, resp, "listing/post-result");
    }
}
