package com.apartment.website.auth.controller;

import com.apartment.website.auth.service.AuthService;
import com.apartment.website.common.util.View;
import com.apartment.website.config.AppContextListener;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/** GET /register -> form đăng ký (chọn Khách hàng / Chủ căn hộ); POST /register -> tạo tài khoản. */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final String[] FIELDS = {"role", "fullName", "phone", "idNumber", "taxCode", "email", "password", "confirm"};
    private AuthService auth;

    @Override
    public void init() { auth = (AuthService) getServletContext().getAttribute(AppContextListener.AUTH_SERVICE); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Map<String, String> form = new HashMap<>();
        form.put("role", "OWNER".equals(req.getParameter("role")) ? "OWNER" : "CUSTOMER");   // /register?role=OWNER
        req.setAttribute("form", form);
        View.forward(req, resp, "auth/register");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Map<String, String> form = new HashMap<>();
        for (String f : FIELDS) {
            String v = req.getParameter(f);
            form.put(f, v == null ? "" : ("password".equals(f) || "confirm".equals(f) ? v : v.trim()));
        }
        Map<String, String> errors = auth.register(form);
        if (errors.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/login?registered=1");
            return;
        }
        form.remove("password");    // không gửi mật khẩu ngược lại trang
        form.remove("confirm");
        req.setAttribute("form", form);
        req.setAttribute("errors", errors);
        View.forward(req, resp, "auth/register");
    }
}
