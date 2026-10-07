package com.apartment.website.listing.repository;

import com.apartment.website.auth.entity.Owner;
import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.entity.Posting.PostingStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional; // Cần import Optional

public interface PostingRepository extends JpaRepository<Posting, Long> {

    // Lấy bài đăng theo trạng thái
    List<Posting> findByStatus(PostingStatus status);

    // Lấy bài đăng của một Owner
    List<Posting> findByOwner(Owner owner);

    // Lấy bài đăng của Owner theo trạng thái
    List<Posting> findByOwnerAndStatus(
            Owner owner,
            PostingStatus status
    );

    // Sắp xếp bài mới nhất trước
    List<Posting> findByStatusOrderByCreatedAtDesc(
            PostingStatus status
    );

    // Bổ sung method tìm bài đăng theo Property ID:
    Optional<Posting> findByPropertyPropertyId(Long propertyId);

    // Lưu ý: Nếu entity Property dùng tên trường là propertyId hoặc id,
    // cú pháp JPA khuyên dùng có thể dùng dấu gạch dưới để chỉ rõ quan hệ lồng:
    // Optional<Posting> findByProperty_PropertyId(Long propertyId);
}