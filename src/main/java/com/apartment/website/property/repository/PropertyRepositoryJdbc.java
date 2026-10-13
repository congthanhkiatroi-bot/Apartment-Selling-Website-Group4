package com.apartment.website.property.repository;

import com.apartment.website.config.Database;
import com.apartment.website.property.dto.PageResult;
import com.apartment.website.property.dto.PropertyFilter;
import com.apartment.website.property.entity.Property;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

/** Lấy dữ liệu thật từ PostgreSQL bằng JDBC. */
public final class PropertyRepositoryJdbc implements PropertyRepository {

    private static final String COLS = """
            p.property_id, p.title, p.price, p.price_per_m2, p.description, p.address,
            b.building_name, b.district, b.city, a.floor_number, a.area, a.bedrooms, a.bathrooms,
            a.direction, a.legal_status, p.status, p.listing_type,
            (SELECT i.image_url FROM property_images i WHERE i.property_id = p.property_id
              ORDER BY i.is_thumbnail DESC, i.image_id LIMIT 1) AS thumb
            """;
    private static final String FROM = """
            FROM properties p
            JOIN apartments a ON a.apartment_id = p.apartment_id
            JOIN buildings b ON b.building_id = a.building_id
            """;

    @Override
    public PageResult<Property> search(PropertyFilter f, int page, int size) {
        StringBuilder where = new StringBuilder("WHERE p.status = 'AVAILABLE' AND p.listing_type = ?");
        List<Object> args = new ArrayList<>();
        args.add(f.listingType());   // 'SALE' hoặc 'RENT' (DB mới trộn cả căn thuê vào bảng properties)
        if (f.hasKeyword()) {
            where.append(" AND (p.title ILIKE ? OR b.building_name ILIKE ? OR b.address ILIKE ?)");
            String k = "%" + f.keyword().trim() + "%";
            args.add(k); args.add(k); args.add(k);
        }
        if (f.hasDistrict()) { where.append(" AND b.district = ?"); args.add(f.district()); }
        if (f.bedrooms() != null) { where.append(f.bedrooms() >= 3 ? " AND a.bedrooms >= ?" : " AND a.bedrooms = ?"); args.add(f.bedrooms()); }
        if (f.min() != null) { where.append(" AND p.price >= ?"); args.add(f.min()); }
        if (f.max() != null) { where.append(" AND p.price <= ?"); args.add(f.max()); }

        try (Connection c = Database.getConnection()) {
            long total;
            try (PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) " + FROM + where)) {
                bind(ps, args);
                try (ResultSet rs = ps.executeQuery()) { rs.next(); total = rs.getLong(1); }
            }
            List<Object> pageArgs = new ArrayList<>(args);
            pageArgs.add(size); pageArgs.add((page - 1) * size);
            List<Property> items = new ArrayList<>();
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT " + COLS + FROM + where + " ORDER BY p.created_at DESC LIMIT ? OFFSET ?")) {
                bind(ps, pageArgs);
                try (ResultSet rs = ps.executeQuery()) { while (rs.next()) items.add(map(rs, List.of())); }
            }
            return new PageResult<>(items, total, page, size);
        } catch (SQLException e) { throw new RuntimeException(e); }
    }

    @Override
    public Optional<Property> findById(long id) {
        try (Connection c = Database.getConnection()) {
            List<String> images = new ArrayList<>();
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT image_url FROM property_images WHERE property_id = ? ORDER BY is_thumbnail DESC, image_id")) {
                ps.setLong(1, id);
                try (ResultSet rs = ps.executeQuery()) { while (rs.next()) images.add(Property.imageUrl(rs.getString(1))); }
            }
            try (PreparedStatement ps = c.prepareStatement("SELECT " + COLS + FROM + "WHERE p.property_id = ?")) {
                ps.setLong(1, id);
                try (ResultSet rs = ps.executeQuery()) { return rs.next() ? Optional.of(map(rs, images)) : Optional.empty(); }
            }
        } catch (SQLException e) { throw new RuntimeException(e); }
    }

    @Override
    public List<String> districts() {
        List<String> list = new ArrayList<>();
        try (Connection c = Database.getConnection(); Statement st = c.createStatement();
             ResultSet rs = st.executeQuery("SELECT DISTINCT district FROM buildings WHERE district IS NOT NULL ORDER BY district")) {
            while (rs.next()) list.add(rs.getString(1));
        } catch (SQLException e) { throw new RuntimeException(e); }
        return list;
    }

    private static void bind(PreparedStatement ps, List<Object> args) throws SQLException {
        for (int i = 0; i < args.size(); i++) ps.setObject(i + 1, args.get(i));
    }

    private static Property map(ResultSet rs, List<String> images) throws SQLException {
        BigDecimal price = rs.getBigDecimal("price");
        BigDecimal perM2 = rs.getBigDecimal("price_per_m2");
        String thumb = rs.getString("thumb");
        return new Property(rs.getLong("property_id"), rs.getString("title"), price, Property.priceText(price),
                perM2 == null ? "" : Property.priceText(perM2), nz(rs.getString("description")), nz(rs.getString("address")),
                nz(rs.getString("building_name")), nz(rs.getString("district")), nz(rs.getString("city")),
                rs.getInt("floor_number"), rs.getBigDecimal("area").stripTrailingZeros().toPlainString(),
                rs.getInt("bedrooms"), rs.getInt("bathrooms"), nz(rs.getString("direction")), nz(rs.getString("legal_status")),
                rs.getString("status"), Property.imageUrl(thumb), images, rs.getString("listing_type"));
    }
    private static String nz(String s) { return s == null ? "" : s; }
}
