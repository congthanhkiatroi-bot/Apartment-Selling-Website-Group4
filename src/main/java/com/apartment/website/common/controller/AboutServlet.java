package com.apartment.website.common.controller;

import com.apartment.website.common.util.View;
import com.apartment.website.config.AppContextListener;
import com.apartment.website.property.dto.SiteStats;
import com.apartment.website.property.service.PropertyService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/** GET /about  ->  views/about.jsp (giới thiệu website, số liệu đếm thật từ database) */
public class AboutServlet extends HttpServlet {
    private PropertyService propertyService;

    @Override
    public void init() {
        // lấy service đã lắp sẵn trong AppContextListener
        propertyService = (PropertyService) getServletContext().getAttribute(AppContextListener.PROPERTY_SERVICE);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        SiteStats stats = propertyService.siteStats();
        List<String> districts = propertyService.districts();

        // đánh dấu mục menu "Về chúng tôi" (header.jsp đọc ${active})
        request.setAttribute("active", "about");
        request.setAttribute("stats", stats);
        request.setAttribute("districts", districts);
        View.forward(request, response, "about");
    }
}
