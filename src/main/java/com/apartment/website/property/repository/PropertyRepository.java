package com.apartment.website.property.repository;

import com.apartment.website.property.dto.PageResult;
import com.apartment.website.property.dto.PropertyFilter;
import com.apartment.website.property.entity.Property;
import com.apartment.website.user.entity.Owner;

import java.util.List;
import java.util.Optional;

public interface PropertyRepository {
    PageResult<Property> search(PropertyFilter filter, int page, int size);
    Optional<Property> findById(long id);
    List<String> districts();
    /** Căn tương tự căn p (cùng loại Bán/Thuê, giá & diện tích gần). sameDistrict = true: cùng quận, false: quận khác. */
    List<Property> similar(Property p, boolean sameDistrict, int limit);
    /** Chủ sở hữu của căn (qua bảng listings -> owners -> users). Ưu tiên tin đang ACTIVE, mới nhất. */
    Optional<Owner> ownerOf(long propertyId);
    /** Số tin đang ACTIVE của 1 chủ sở hữu. */
    int activeListingCount(long ownerId);
}
