package com.apartment.website.common.controller;

import com.apartment.website.common.util.View;
import com.apartment.website.config.AppContextListener;
import com.apartment.website.property.service.PropertyService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/** GET /  ->  views/home.jsp */
@WebServlet(urlPatterns = {"", "/home"})
public class HomeServlet extends HttpServlet {
    private PropertyService propertyService;

    @Override
    public void init() {   // lấy service đã lắp sẵn trong AppContextListener (thay cho @Autowired)
        propertyService = (PropertyService) getServletContext().getAttribute(AppContextListener.PROPERTY_SERVICE);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("active", "home");                          // đánh dấu mục menu (header.jsp đọc ${active})
        req.setAttribute("featured", propertyService.featured(3));   // = model.addAttribute(...) Phương thức featured
        View.forward(req, resp, "home");
    }
}
