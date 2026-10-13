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
}
