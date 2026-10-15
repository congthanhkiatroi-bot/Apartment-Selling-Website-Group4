package com.apartment.website.property.service;

import com.apartment.website.property.dto.PageResult;
import com.apartment.website.property.dto.PropertyFilter;
import com.apartment.website.property.entity.Property;
import com.apartment.website.property.repository.PropertyRepository;
import com.apartment.website.user.entity.Owner;

import java.util.List;

/** Logic nghiệp vụ về căn hộ. */
public class PropertyService {
    // căn BÁN: 12 căn / trang (3 cột x 4 hàng)
    public static final int PAGE_SIZE = 12;
    // căn THUÊ: 12 căn / trang
    public static final int RENT_PAGE_SIZE = 12;
    // số căn tối đa ở mục "Căn hộ tương tự"
    public static final int SIMILAR_LIMIT = 6;
    // mục "Gợi ý ở khu vực khác" luôn có ít nhất 3 căn
    public static final int OTHER_DISTRICT_MIN = 3;

    private final PropertyRepository repository;

    public PropertyService(PropertyRepository repository) {
        this.repository = repository;
    }

    public PageResult<Property> search(PropertyFilter filter, int page) {
        int size;
        if (filter.isRent()) {
            size = RENT_PAGE_SIZE;
        } else {
            size = PAGE_SIZE;
        }
        if (page < 1) {
            page = 1;
        }
        return repository.search(filter, page, size);
    }

    /** Các căn mới nhất cho trang chủ. */
    public List<Property> featured(int count) {
        PropertyFilter noFilter = new PropertyFilter("", "", null, "");
        PageResult<Property> firstPage = repository.search(noFilter, 1, count);
        return firstPage.getItems();
    }

    /** Trả về null nếu không tìm thấy. */
    public Property findById(long id) {
        return repository.findById(id);
    }

    public List<String> districts() {
        return repository.districts();
    }

    /** Trả về null nếu căn chưa có chủ sở hữu. */
    public Owner ownerOf(long propertyId) {
        return repository.ownerOf(propertyId);
    }

    public int activeListingCount(long ownerId) {
        return repository.activeListingCount(ownerId);
    }

    /** "Căn hộ tương tự" ở cuối trang chi tiết: tối đa 6 căn cùng quận. */
    public List<Property> sameDistrict(Property p) {
        return repository.similar(p, true, SIMILAR_LIMIT);
    }

    /** Gợi ý khu vực khác: lấp cho đủ 6 ô nếu cùng quận còn thiếu, và luôn có ít nhất 3 căn. */
    public List<Property> otherDistrict(Property p, int sameCount) {
        int limit = SIMILAR_LIMIT - sameCount;
        if (limit < OTHER_DISTRICT_MIN) {
            limit = OTHER_DISTRICT_MIN;
        }
        return repository.similar(p, false, limit);
    }
}
