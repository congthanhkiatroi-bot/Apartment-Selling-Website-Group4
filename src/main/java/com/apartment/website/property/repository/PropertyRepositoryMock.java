package com.apartment.website.property.repository;

import com.apartment.website.property.dto.PageResult;
import com.apartment.website.property.dto.PropertyFilter;
import com.apartment.website.property.entity.Property;
import java.math.BigDecimal;
import java.util.*;

/** Dữ liệu mẫu trong bộ nhớ: frontend làm việc được khi chưa có database. */
public final class PropertyRepositoryMock implements PropertyRepository {
    private final List<Property> data = new ArrayList<>();

    public PropertyRepositoryMock() {
        String[][] rows = {
            // tiêu đề, giá, quận, diện tích, PN, WC, tòa nhà
            {"Căn hộ 2PN Vinhomes view sông", "2800000000", "Quận 9", "75", "2", "2", "Vinhomes Grand Park S1.02"},
            {"Căn hộ 2PN Masteri Thảo Điền", "4500000000", "Thủ Đức", "75", "2", "1", "Masteri Thảo Điền T5"},
            {"Căn hộ 3PN Sun Avenue", "6800000000", "Thủ Đức", "110", "3", "2", "Sun Avenue SAV6"},
            {"Căn hộ 1PN Vinhomes Grand Park", "1900000000", "Quận 9", "48", "1", "1", "Vinhomes Grand Park S2.05"},
            {"Căn hộ 2PN Landmark 81", "5200000000", "Bình Thạnh", "88", "2", "2", "Vinhomes Landmark 81"},
            {"Căn hộ 3PN Vinhomes Central Park", "9800000000", "Bình Thạnh", "120", "3", "3", "Vinhomes Central Park P3"},
            {"Căn hộ 2PN The Sun Avenue", "3300000000", "Thủ Đức", "70", "2", "2", "Sun Avenue SAV2"},
            {"Căn hộ 1PN Masteri An Phú", "2300000000", "Thủ Đức", "52", "1", "1", "Masteri An Phú"},
        };
        for (int i = 0; i < rows.length; i++) {
            String[] r = rows[i];
            BigDecimal price = new BigDecimal(r[1]);
            data.add(new Property(i + 1, r[0], price, Property.priceText(price), "35 Triệu",
                    "Căn hộ thiết kế hiện đại, thông thoáng, ban công rộng, pháp lý rõ ràng. Tiện ích: hồ bơi, gym, công viên.",
                    "Đường số " + (i + 1), r[6], r[2], "TP.HCM", 5 + i, r[3], Integer.parseInt(r[4]), Integer.parseInt(r[5]),
                    "Đông Nam", "Sổ hồng lâu dài", "AVAILABLE", Property.NO_IMAGE,
                    List.of(Property.NO_IMAGE, Property.NO_IMAGE, Property.NO_IMAGE, Property.NO_IMAGE), "SALE"));        }
    }

    @Override
    public PageResult<Property> search(PropertyFilter f, int page, int size) {
        List<Property> all = data.stream()
                .filter(p -> !f.hasKeyword() || (p.getTitle() + " " + p.getBuildingName()).toLowerCase().contains(f.keyword().trim().toLowerCase()))
                .filter(p -> !f.hasDistrict() || p.getDistrict().equals(f.district()))
                .filter(p -> f.bedrooms() == null || (f.bedrooms() >= 3 ? p.getBedrooms() >= 3 : p.getBedrooms() == f.bedrooms()))
                .filter(p -> f.min() == null || p.getPrice().compareTo(f.min()) >= 0)
                .filter(p -> f.max() == null || p.getPrice().compareTo(f.max()) <= 0)
                .toList();
        int from = Math.min((page - 1) * size, all.size());
        return new PageResult<>(all.subList(from, Math.min(from + size, all.size())), all.size(), page, size);
    }

    @Override public Optional<Property> findById(long id) { return data.stream().filter(p -> p.getPropertyId() == id).findFirst(); }
    @Override public List<String> districts() { return data.stream().map(Property::getDistrict).distinct().sorted().toList(); }
}
