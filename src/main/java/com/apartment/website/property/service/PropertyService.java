package com.apartment.website.property.service;

import com.apartment.website.property.dto.PageResult;
import com.apartment.website.property.dto.PropertyFilter;
import com.apartment.website.property.entity.Property;
import com.apartment.website.property.repository.PropertyRepository;

import java.util.List;
import java.util.Optional;

/** Logic nghiệp vụ về căn hộ. Class Java thường: không cần @Service. */
public class PropertyService {
    public static final int PAGE_SIZE = 12;        // căn BÁN: 12 căn / trang (3 cột x 4 hàng)
    public static final int RENT_PAGE_SIZE = 12;   // căn THUÊ: 12 căn / trang
    private final PropertyRepository repository;

    public PropertyService(PropertyRepository repository) {   // thay @Autowired: truyền qua constructor
        this.repository = repository;
    }

    public PageResult<Property> search(PropertyFilter filter, int page) {
        int size = filter.isRent() ? RENT_PAGE_SIZE : PAGE_SIZE;
        return repository.search(filter, Math.max(1, page), size);
    }

    public List<Property> featured(int count) { // Phương thức featured
        return repository.search(new PropertyFilter("", "", null, ""),
                1,
                count
        ).getItems(); // trả về PageResult<Property>
    }

    public Optional<Property> findById(long id) {
        return repository.findById(id);
    }
    public List<String> districts() {
        return repository.districts();
    }
    /** "Căn hộ tương tự" ở cuối trang chi tiết: tối đa 6 căn cùng quận. */
    public List<Property> sameDistrict(Property p) {
        return repository.similar(p, true, 6);
    }
    /** Gợi ý khu vực khác: lấp cho đủ 6 ô nếu cùng quận còn thiếu, và luôn có ít nhất 3 căn. */
    public List<Property> otherDistrict(Property p, int sameCount) {
        return repository.similar(p, false, Math.max(3, 6 - sameCount));
    }
}