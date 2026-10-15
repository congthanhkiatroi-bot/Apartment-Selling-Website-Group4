package com.apartment.website.listing.controller;

import com.apartment.website.common.util.View;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** /postings/create: GET hiện form đăng tin, POST nhận dữ liệu form. */
@WebServlet("/postings/create")
public class ListingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("active", "post");
        View.forward(request, response, "listing/post");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO (backend): gom request.getParameter("title"), ("price")... -> ListingService.create(...) -> lưu DB,
        // rồi response.sendRedirect(request.getContextPath() + "/properties") để tránh gửi lại form khi F5.
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
}
