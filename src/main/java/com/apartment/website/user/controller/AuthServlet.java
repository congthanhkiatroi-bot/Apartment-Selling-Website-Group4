package com.apartment.website.user.controller;

import com.apartment.website.common.exception.AuthException;
import com.apartment.website.common.filter.AuthFilter;
import com.apartment.website.common.util.View;
import com.apartment.website.config.AppContextListener;
import com.apartment.website.user.dto.RegisterRequest;
import com.apartment.website.user.entity.User;
import com.apartment.website.user.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Điều hướng bằng tham số action:
 *  GET  /auth?action=login               -> form đăng nhập        -> views/auth/login.jsp
 *  GET  /auth?action=register&role=OWNER -> form đăng ký          -> views/auth/register.jsp
 *  GET  /auth?action=logout              -> đăng xuất, về trang chủ
 *  POST /auth  (action=login | register) -> kiểm tra, lưu User vào session, chuyển về trang trước đó (?next=)
 */
@WebServlet("/auth")
public class AuthServlet extends HttpServlet {
    private static final String[] REGISTER_FIELDS = {"role", "fullName", "phone", "cccd", "email"};

    private AuthService authService;

    @Override
    public void init() {
        authService = (AuthService) getServletContext().getAttribute(AppContextListener.AUTH_SERVICE);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("logout".equals(action)) {
            logout(request, response);
            return;
        }
        // đã đăng nhập rồi thì không cần vào trang đăng nhập / đăng ký nữa
        if (AuthFilter.getLoginUser(request) != null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        if ("register".equals(action)) {
            Map<String, String> form = new HashMap<String, String>();
            if (User.ROLE_OWNER.equals(request.getParameter("role"))) {
                form.put("role", User.ROLE_OWNER);
            } else {
                form.put("role", User.ROLE_CUSTOMER);
            }
            request.setAttribute("form", form);
            showRegister(request, response);
        } else {
            showLogin(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("login".equals(action)) {
            login(request, response);
        } else if ("register".equals(action)) {
            register(request, response);
        } else if ("logout".equals(action)) {
            logout(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // ===================== action=login =====================

    private void login(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String phoneOrEmail = request.getParameter("phoneOrEmail");
        String password = request.getParameter("password");
        try {
            User user = authService.login(phoneOrEmail, password);
            saveToSession(request, user);
            response.sendRedirect(nextUrl(request));
            return;
        } catch (AuthException e) {
            request.setAttribute("error", e.getMessage());
        }
        // sai -> hiện lại form, giữ ô SĐT/email (không giữ mật khẩu)
        Map<String, String> form = new HashMap<String, String>();
        form.put("phoneOrEmail", getText(request, "phoneOrEmail"));
        request.setAttribute("form", form);
        showLogin(request, response);
    }

    // ===================== action=register =====================

    private void register(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        RegisterRequest registerRequest = new RegisterRequest(
                request.getParameter("role"),
                request.getParameter("fullName"),
                request.getParameter("phone"),
                request.getParameter("cccd"),
                request.getParameter("email"),
                request.getParameter("password"),
                request.getParameter("confirmPassword"));
        try {
            User user = authService.register(registerRequest);
            // đăng ký xong thì đăng nhập luôn
            saveToSession(request, user);
            response.sendRedirect(nextUrl(request));
            return;
        } catch (AuthException e) {
            request.setAttribute("error", e.getMessage());
        }
        // sai -> hiện lại form, giữ những gì đã nhập (trừ mật khẩu)
        Map<String, String> form = new HashMap<String, String>();
        for (int i = 0; i < REGISTER_FIELDS.length; i++) {
            String field = REGISTER_FIELDS[i];
            form.put(field, getText(request, field));
        }
        request.setAttribute("form", form);
        showRegister(request, response);
    }

    // ===================== action=logout =====================

    private void logout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/");
    }

    // ===================== hàm phụ =====================

    private void showLogin(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("next", getSafeNext(request));
        View.forward(request, response, "auth/login");
    }

    private void showRegister(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("next", getSafeNext(request));
        View.forward(request, response, "auth/register");
    }

    /** Lưu User vào session. Đổi session id sau khi đăng nhập để chống chiếm phiên (session fixation). */
    private static void saveToSession(HttpServletRequest request, User user) {
        HttpSession session = request.getSession(true);
        request.changeSessionId();
        session.setAttribute(AuthFilter.SESSION_USER, user);
    }

    /** Trang cần quay lại sau khi đăng nhập; không có thì về trang chủ. */
    private static String nextUrl(HttpServletRequest request) {
        String next = getSafeNext(request);
        if (next.isEmpty()) {
            return request.getContextPath() + "/";
        }
        return request.getContextPath() + next;
    }

    /**
     * Chỉ nhận đường dẫn nội bộ dạng "/viewings?..." để kẻ xấu không gửi link ?next=https://trang-gia-mao.com.
     * Không hợp lệ thì trả về chuỗi rỗng.
     */
    private static String getSafeNext(HttpServletRequest request) {
        String next = request.getParameter("next");
        if (next == null) {
            return "";
        }
        if (!next.startsWith("/") || next.startsWith("//") || next.contains("\\")) {
            return "";
        }
        if (next.contains("\r") || next.contains("\n")) {
            return "";
        }
        return next;
    }

    private static String getText(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value == null) {
            return "";
        }
        return value;
    }
}
