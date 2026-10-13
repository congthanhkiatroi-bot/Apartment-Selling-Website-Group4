package com.apartment.website.auth.controller;

import com.apartment.website.auth.entity.SessionUser;
import com.apartment.website.auth.service.AuthService;
import com.apartment.website.common.filter.CurrentUserFilter;
import com.apartment.website.common.util.View;
import com.apartment.website.config.AppContextListener;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Optional;

/** GET /login -> form đăng nhập; POST /login -> kiểm tra rồi chuyển về trang trước đó (next) hoặc trang chủ. */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private AuthService auth;

    @Override
    public void init() { auth = (AuthService) getServletContext().getAttribute(AppContextListener.AUTH_SERVICE); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession s = req.getSession(false);
        if (s != null && s.getAttribute(CurrentUserFilter.SESSION_KEY) != null) {   // đã đăng nhập rồi
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }
        req.setAttribute("next", req.getParameter("next"));
        View.forward(req, resp, "auth/login");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String identity = req.getParameter("identity");
        Optional<SessionUser> user = auth.login(identity, req.getParameter("password"));
        String next = req.getParameter("next");
        if (user.isEmpty()) {
            req.setAttribute("error", "SĐT/email hoặc mật khẩu không đúng.");
            req.setAttribute("identity", identity);
            req.setAttribute("next", next);
            View.forward(req, resp, "auth/login");
            return;
        }
        HttpSession old = req.getSession(false);
        if (old != null) old.invalidate();                          // chống session fixation
        req.getSession(true).setAttribute(CurrentUserFilter.SESSION_KEY, user.get());
        resp.sendRedirect(req.getContextPath() + safeNext(next));
    }

    /** Chỉ cho chuyển hướng trong nội bộ website (tránh open redirect). */
    private static String safeNext(String next) {
        if (next != null && next.startsWith("/") && !next.startsWith("//") && !next.contains("\\")) return next;
        return "/";
    }
}
