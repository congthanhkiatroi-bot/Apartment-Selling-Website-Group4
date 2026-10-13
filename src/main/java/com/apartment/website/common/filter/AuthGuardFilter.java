package com.apartment.website.common.filter;

import com.apartment.website.auth.entity.SessionUser;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Các chức năng bắt buộc đăng nhập:
 *   /appointments  (đặt lịch xem nhà)  -> vai trò CUSTOMER
 *   /postings/*    (đăng tin)          -> vai trò OWNER
 * ADMIN được vào tất cả. Chưa đăng nhập -> chuyển tới /login?next=<trang đang muốn vào>.
 * Muốn bảo vệ thêm trang khác: thêm đường dẫn vào urlPatterns và vào hàm requiredRole().
 */
@WebFilter(urlPatterns = {"/appointments", "/appointments/*", "/postings/*"})
public class AuthGuardFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String ctx = req.getContextPath();
        String path = req.getRequestURI().substring(ctx.length());

        HttpSession session = req.getSession(false);
        SessionUser user = session == null ? null : (SessionUser) session.getAttribute(CurrentUserFilter.SESSION_KEY);

        if (user == null) {                                   // chưa đăng nhập
            String next = path + (req.getQueryString() == null ? "" : "?" + req.getQueryString());
            resp.sendRedirect(ctx + "/login?next=" + URLEncoder.encode(next, StandardCharsets.UTF_8));
            return;
        }

        String need = requiredRole(path);
        if (!user.isAdmin() && !need.equals(user.getRole())) {   // đăng nhập rồi nhưng sai vai trò
            req.setAttribute("currentUser", user);
            req.setAttribute("requiredRole", need);
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        chain.doFilter(request, response);
    }

    private static String requiredRole(String path) {
        return path.startsWith("/postings") ? "OWNER" : "CUSTOMER";
    }
}
