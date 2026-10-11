package com.apartment.website.interaction.controller;

import com.apartment.website.common.util.View;
import com.apartment.website.config.AppContextListener;
import com.apartment.website.property.entity.Property;
import com.apartment.website.property.service.PropertyService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * /comparisons
 *  GET                      -> hiện bảng so sánh các căn đã chọn (lưu trong session) -> views/comparison/compare.jsp
 *  POST action=add&id=5     -> thêm căn 5 vào danh sách so sánh (tối đa 3 căn), rồi redirect về GET
 *  POST action=remove&id=5  -> bỏ căn 5
 *  POST action=clear        -> xóa hết
 */
@WebServlet("/comparisons")
public class ComparisonServlet extends HttpServlet {
    public static final int MAX_ITEMS = 3;
    private static final String SESSION_KEY = "compareIds";
    private PropertyService service;

    @Override
    public void init() {
        service = (PropertyService) getServletContext().getAttribute(AppContextListener.PROPERTY_SERVICE);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        List<Property> items = new ArrayList<>();
        synchronized (session) {
            List<Long> ids = ids(session);
            List<Long> valid = new ArrayList<>();
            for (Long id : ids) {
                Optional<Property> p = service.findById(id);
                if (p.isPresent()) { items.add(p.get()); valid.add(id); }   // căn đã bị xóa khỏi DB thì tự bỏ
            }
            ids.clear();
            ids.addAll(valid);
        }
        List<Integer> emptySlots = new ArrayList<>();
        for (int i = items.size(); i < MAX_ITEMS; i++) emptySlots.add(i + 1);

        req.setAttribute("active", "compare");
        req.setAttribute("items", items);
        req.setAttribute("emptySlots", emptySlots);
        req.setAttribute("canAdd", items.size() < MAX_ITEMS);
        req.setAttribute("full", "1".equals(req.getParameter("full")));
        req.setAttribute("maxItems", MAX_ITEMS);
        View.forward(req, resp, "comparison/compare");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String action = req.getParameter("action");
        Long id = toLong(req.getParameter("id"));
        boolean full = false;
        HttpSession session = req.getSession(true);
        synchronized (session) {
            List<Long> ids = ids(session);
            if ("add".equals(action) && id != null) {
                if (!ids.contains(id)) {
                    if (ids.size() >= MAX_ITEMS) full = true;
                    else if (service.findById(id).isPresent()) ids.add(id);
                }
            } else if ("remove".equals(action) && id != null) {
                ids.remove(id);          // id là Long (object) -> remove theo giá trị, không phải theo vị trí
            } else if ("clear".equals(action)) {
                ids.clear();
            }
        }
        resp.sendRedirect(req.getContextPath() + "/comparisons" + (full ? "?full=1" : ""));
    }

    @SuppressWarnings("unchecked")
    private static List<Long> ids(HttpSession session) {
        List<Long> ids = (List<Long>) session.getAttribute(SESSION_KEY);
        if (ids == null) { ids = new ArrayList<>(); session.setAttribute(SESSION_KEY, ids); }
        return ids;
    }

    private static Long toLong(String s) { try { return Long.valueOf(s.trim()); } catch (Exception e) { return null; } }
}