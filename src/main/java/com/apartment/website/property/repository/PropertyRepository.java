package com.apartment.website.property.repository;

import com.apartment.website.property.dto.PageResult;
import com.apartment.website.property.dto.PropertyFilter;
import com.apartment.website.property.entity.Property;

import java.util.List;
import java.util.Optional;

public interface PropertyRepository {
    PageResult<Property> search(PropertyFilter filter, int page, int size);
    Optional<Property> findById(long id);
    List<String> districts();
    /** Căn tương tự căn p (cùng loại Bán/Thuê, giá & diện tích gần). sameDistrict = true: cùng quận, false: quận khác. */
    List<Property> similar(Property p, boolean sameDistrict, int limit);
}
