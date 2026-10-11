package com.apartment.website.common.util;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/** forward("property/list") = mở /WEB-INF/views/property/list.jsp (tương đương return "property/list" trong Spring). */
public final class View {
    private View() {}

    public static void forward(HttpServletRequest req, HttpServletResponse resp, String view)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/" + view + ".jsp").forward(req, resp);
    }
}
