package com.apartment.website.property.controller;

import com.apartment.website.common.util.View;
import com.apartment.website.config.AppContextListener;
import com.apartment.website.property.dto.PageResult;
import com.apartment.website.property.dto.PropertyFilter;
import com.apartment.website.property.entity.Property;
import com.apartment.website.property.service.PropertyService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * /properties      -> danh sách (lọc + phân trang)   -> views/property/list.jsp
 * /properties/{id} -> chi tiết                        -> views/property/detail.jsp
 * (thay cho PropertyWebController: @GetMapping("/properties") và @GetMapping("/properties/{id}"))
 */
@WebServlet("/properties/*")
public class PropertyServlet extends HttpServlet {
    private PropertyService service;

    @Override
    public void init() {
        service = (PropertyService) getServletContext().getAttribute(AppContextListener.PROPERTY_SERVICE);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
            String path = req.getPathInfo();                       // null hoặc "/" = danh sách, "/3" = chi tiết căn id 3
        if (path == null || path.equals("/")) showList(req, resp);
        else showDetail(req, resp, path.substring(1));
    }

    private void showList(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = text(req, "keyword"), district = text(req, "district"), price = text(req, "price");
        String type = "RENT".equalsIgnoreCase(text(req, "type")) ? "RENT" : "SALE";
        Integer bedrooms = toInt(req.getParameter("bedrooms"));
        int page = Math.max(1, Optional.ofNullable(toInt(req.getParameter("page"))).orElse(1));
        PropertyFilter filter = new PropertyFilter(keyword, district, bedrooms, price, type);
        PageResult<Property> result = service.search(filter, page);
        if (page > result.getTotalPages()) {                   // gõ page quá lớn -> lùi về trang cuối
            page = result.getTotalPages();
            result = service.search(filter, page);
        }

        List<Map<String, Object>> districts = new ArrayList<>();
        for (String d : service.districts()) districts.add(Map.of("value", d, "selected", d.equals(district) ? "selected" : ""));

        String base = req.getContextPath() + "/properties?keyword=" + enc(keyword) + "&district=" + enc(district)
                + "&price=" + enc(price) + "&type=" + type + "&bedrooms=" + (bedrooms == null ? "" : bedrooms) + "&page=";
        long from = result.getTotal() == 0 ? 0 : (long) (page - 1) * result.getSize() + 1;   // "hiển thị from–to"
        long to = Math.min((long) page * result.getSize(), result.getTotal());

        req.setAttribute("active", "list");
        req.setAttribute("type", type);
        req.setAttribute("properties", result.getItems());
        req.setAttribute("total", result.getTotal());
        req.setAttribute("noResult", result.getItems().isEmpty());
        req.setAttribute("districts", districts);
        req.setAttribute("from", from);
        req.setAttribute("to", to);
        req.setAttribute("totalPages", result.getTotalPages());
        req.setAttribute("pages", pageLinks(base, page, result.getTotalPages()));
        View.forward(req, resp, "property/list");
    }

    /** « 1 2 3 … 10 »: luôn có trang đầu, trang cuối và 2 trang quanh trang hiện tại. href = null nghĩa là không bấm được. */
    private static List<Map<String, Object>> pageLinks(String base, int current, int total) {
        List<Map<String, Object>> out = new ArrayList<>();
        out.add(link("«", current > 1 ? base + (current - 1) : null, false));
        int last = 0;
        for (int i = 1; i <= total; i++) {
            if (i != 1 && i != total && Math.abs(i - current) > 2) continue;
            if (i - last > 1) out.add(link("…", null, false));
            out.add(link(String.valueOf(i), base + i, i == current));
            last = i;
        }
        out.add(link("»", current < total ? base + (current + 1) : null, false));
        return out;
    }

    private static Map<String, Object> link(String label, String href, boolean active) {
        Map<String, Object> m = new HashMap<>();      // HashMap vì href có thể là null (Map.of không cho null)
        m.put("label", label);
        m.put("href", href);
        m.put("active", active);
        return m;
    }

    private void showDetail(HttpServletRequest req, HttpServletResponse resp, String idText) throws ServletException, IOException {
        Optional<Property> found = Optional.empty();
        try { found = service.findById(Long.parseLong(idText)); } catch (NumberFormatException ignored) {}
        if (found.isEmpty()) { resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }   // web.xml sẽ hiện 404.jsp
        Property p = found.get();

        List<String> urls = p.getImageUrls().isEmpty() ? List.of(Property.NO_IMAGE) : p.getImageUrls();
        int sel = Math.min(Math.max(Optional.ofNullable(toInt(req.getParameter("img"))).orElse(0), 0), urls.size() - 1);
        List<Map<String, Object>> thumbs = new ArrayList<>();
        for (int i = 0; i < urls.size(); i++)
            thumbs.add(Map.of("url", urls.get(i), "href", req.getContextPath() + "/properties/" + p.getPropertyId() + "?img=" + i,
                    "active", i == sel ? "is-active" : ""));

        req.setAttribute("active", "list");
        req.setAttribute("property", p);
        req.setAttribute("mainImage", urls.get(sel));
        req.setAttribute("images", thumbs);
        List<Property> same = service.sameDistrict(p);
        req.setAttribute("sameDistrict", same);
        req.setAttribute("otherDistrict", service.otherDistrict(p, same.size()));
        View.forward(req, resp, "property/detail");
    }

    private static String text(HttpServletRequest req, String name) { String v = req.getParameter(name); return v == null ? "" : v; }
    private static Integer toInt(String s) { try { return Integer.parseInt(s.trim()); } catch (Exception e) { return null; } }
    private static String enc(String s) { return URLEncoder.encode(s, StandardCharsets.UTF_8); }
}