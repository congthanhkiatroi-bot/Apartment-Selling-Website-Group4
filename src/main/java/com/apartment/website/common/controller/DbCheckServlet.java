package com.apartment.website.common.controller;

import com.apartment.website.config.Database;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/** TẠM THỜI - mở /db-check để kiểm tra kết nối PostgreSQL. Kiểm tra xong thì XÓA file này. */
@WebServlet("/db-check")
public class DbCheckServlet extends HttpServlet {
    private static final String[] TABLES = {"users", "customers", "owners", "buildings", "apartments", "properties",
            "customer_locations", "property_images", "listings", "favorites", "transactions", "payments", "reviews",
            "property_viewings", "rental_apartments", "rental_apartment_images"};

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.println("data.mode = " + Database.get("data.mode", "mock"));
        out.println("db.url    = " + Database.get("db.url", "(chua cau hinh)"));
        out.println("db.user   = " + Database.get("db.user", ""));
        out.println();
        try (Connection c = Database.getConnection()) {
            out.println("KET NOI THANH CONG: " + c.getMetaData().getDatabaseProductName()
                    + " " + c.getMetaData().getDatabaseProductVersion());
            out.println();
            for (String t : TABLES) {
                try (Statement st = c.createStatement(); ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM " + t)) {
                    rs.next();
                    out.printf("%-18s %d dong%n", t, rs.getLong(1));
                } catch (SQLException e) {
                    out.printf("%-18s LOI: %s%n", t, e.getMessage());
                }
            }
            try (Statement st = c.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FILTER (WHERE listing_type = 'SALE'), COUNT(*) FILTER (WHERE listing_type = 'RENT') "
                         + "FROM properties WHERE status = 'AVAILABLE'")) {
                rs.next();
                out.println();
                out.println("Can ho BAN AVAILABLE (tab mac dinh): " + rs.getLong(1));
                out.println("Can ho THUE AVAILABLE (?type=RENT): " + rs.getLong(2));
            } catch (SQLException ignored) { }
        } catch (SQLException e) {
            out.println("KET NOI THAT BAI: " + e.getMessage());
            Throwable cause = e.getCause();
            if (cause != null) out.println("Nguyen nhan: " + cause);
        }
    }
}