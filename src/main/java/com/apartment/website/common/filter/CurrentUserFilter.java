package com.apartment.website.common.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/** Đưa người đang đăng nhập vào request (${currentUser}) để mọi JSP (kể cả header.jsp có session="false") dùng được. */
@WebFilter(urlPatterns = "/*", dispatcherTypes = {DispatcherType.REQUEST, DispatcherType.ERROR})
public class CurrentUserFilter implements Filter {
    public static final String SESSION_KEY = "user";

    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws IOException, ServletException {
        HttpSession s = ((HttpServletRequest) req).getSession(false);   // false: không tự tạo session cho khách vãng lai
        if (s != null) req.setAttribute("currentUser", s.getAttribute(SESSION_KEY));
        chain.doFilter(req, resp);
    }
}
