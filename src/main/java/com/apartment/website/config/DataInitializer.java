package com.apartment.website.config;

import com.apartment.website.auth.entity.Owner;
import com.apartment.website.listing.entity.Posting;
import com.apartment.website.property.entity.Amenity;
import com.apartment.website.property.entity.Property;
import com.apartment.website.property.entity.PropertyImage;

import com.apartment.website.property.repository.AmenityRepository;
import com.apartment.website.auth.repository.OwnerRepository;
import com.apartment.website.listing.repository.PostingRepository;
import com.apartment.website.property.repository.PropertyRepository;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Component
public class DataInitializer implements CommandLineRunner {

    private final PropertyRepository propertyRepository;
    private final AmenityRepository amenityRepository;
    private final OwnerRepository ownerRepository;
    private final PostingRepository postingRepository;

    public DataInitializer(
            PropertyRepository propertyRepository,
            AmenityRepository amenityRepository,
            OwnerRepository ownerRepository,
            PostingRepository postingRepository
    ) {
        this.propertyRepository = propertyRepository;
        this.amenityRepository = amenityRepository;
        this.ownerRepository = ownerRepository;
        this.postingRepository = postingRepository;
    }

    @Override
    @Transactional
    public void run(String... args) {

        // Không tạo lại sample data nếu database đã có Property.
        if (propertyRepository.count() > 0) {
            System.out.println(
                    "Sample data already exists. Skip initialization."
            );
            return;
        }

        System.out.println("Creating sample data...");

        // =====================================================
        // 1. OWNER
        // =====================================================

        Owner owner = new Owner();

        owner.setUsername("sample_owner");
        owner.setEmail("owner@apartment.com");
        owner.setPasswordHash("sample_password");
        owner.setPhone("0900000000");
        owner.setActive(true);

        owner = ownerRepository.save(owner);


        // =====================================================
        // 2. AMENITIES
        // =====================================================

        Amenity swimmingPool = new Amenity(
                "Swimming Pool",
                "Hồ bơi dành cho cư dân."
        );

        Amenity gym = new Amenity(
                "Gym",
                "Phòng tập thể thao dành cho cư dân."
        );

        Amenity parking = new Amenity(
                "Parking",
                "Khu vực đỗ xe cho cư dân."
        );

        Amenity security = new Amenity(
                "24/7 Security",
                "Hệ thống an ninh và bảo vệ 24/7."
        );

        Amenity playground = new Amenity(
                "Playground",
                "Khu vui chơi dành cho trẻ em."
        );

        Amenity shoppingMall = new Amenity(
                "Shopping Mall",
                "Trung tâm thương mại và tiện ích mua sắm."
        );

        amenityRepository.saveAll(
                List.of(
                        swimmingPool,
                        gym,
                        parking,
                        security,
                        playground,
                        shoppingMall
                )
        );


        // =====================================================
        // 3. PROPERTY 1
        // =====================================================

        Property property1 = new Property(
                new BigDecimal("5800000000"),
                85.0,
                2,
                2,
                18,
                "208 Nguyễn Hữu Cảnh",
                "TP. Hồ Chí Minh",
                "Bình Thạnh",
                "Phường 22",
                Property.PropertyType.APARTMENT
        );

        property1.addAmenity(swimmingPool);
        property1.addAmenity(gym);
        property1.addAmenity(parking);
        property1.addAmenity(security);

        property1.addImage(
                new PropertyImage(
                        "/images/properties/vinhomes-1.jpg",
                        true,
                        1,
                        property1
                )
        );

        property1.addImage(
                new PropertyImage(
                        "/images/properties/vinhomes-2.jpg",
                        false,
                        2,
                        property1
                )
        );


        // =====================================================
        // 4. PROPERTY 2
        // =====================================================

        Property property2 = new Property(
                new BigDecimal("6500000000"),
                92.0,
                3,
                2,
                25,
                "159 Xa Lộ Hà Nội",
                "TP. Hồ Chí Minh",
                "TP. Thủ Đức",
                "Thảo Điền",
                Property.PropertyType.APARTMENT
        );

        property2.addAmenity(swimmingPool);
        property2.addAmenity(gym);
        property2.addAmenity(parking);
        property2.addAmenity(shoppingMall);

        property2.addImage(
                new PropertyImage(
                        "/images/properties/masteri-1.jpg",
                        true,
                        1,
                        property2
                )
        );


        // =====================================================
        // 5. PROPERTY 3
        // =====================================================

        Property property3 = new Property(
                new BigDecimal("4200000000"),
                76.0,
                2,
                2,
                12,
                "28 Mai Chí Thọ",
                "TP. Hồ Chí Minh",
                "TP. Thủ Đức",
                "An Phú",
                Property.PropertyType.APARTMENT
        );

        property3.addAmenity(swimmingPool);
        property3.addAmenity(parking);
        property3.addAmenity(security);

        property3.addImage(
                new PropertyImage(
                        "/images/properties/sun-avenue-1.jpg",
                        true,
                        1,
                        property3
                )
        );


        // =====================================================
        // 6. PROPERTY 4
        // =====================================================

        Property property4 = new Property(
                new BigDecimal("3100000000"),
                68.0,
                2,
                2,
                15,
                "Nguyễn Xiển",
                "TP. Hồ Chí Minh",
                "TP. Thủ Đức",
                "Long Thạnh Mỹ",
                Property.PropertyType.APARTMENT
        );

        property4.addAmenity(swimmingPool);
        property4.addAmenity(playground);
        property4.addAmenity(parking);
        property4.addAmenity(security);

        property4.addImage(
                new PropertyImage(
                        "/images/properties/grand-park-1.jpg",
                        true,
                        1,
                        property4
                )
        );


        // =====================================================
        // 7. PROPERTY 5
        // =====================================================

        Property property5 = new Property(
                new BigDecimal("5200000000"),
                100.0,
                3,
                2,
                20,
                "25 Nguyễn Hữu Thọ",
                "TP. Hồ Chí Minh",
                "Quận 7",
                "Tân Hưng",
                Property.PropertyType.APARTMENT
        );

        property5.addAmenity(swimmingPool);
        property5.addAmenity(gym);
        property5.addAmenity(parking);

        property5.addImage(
                new PropertyImage(
                        "/images/properties/sunrise-city-1.jpg",
                        true,
                        1,
                        property5
                )
        );


        // =====================================================
        // 8. PROPERTY 6
        // =====================================================

        Property property6 = new Property(
                new BigDecimal("2900000000"),
                45.0,
                1,
                1,
                8,
                "02 Lê Thước",
                "TP. Hồ Chí Minh",
                "TP. Thủ Đức",
                "Thảo Điền",
                Property.PropertyType.STUDIO
        );

        property6.addAmenity(gym);
        property6.addAmenity(parking);
        property6.addAmenity(security);

        property6.addImage(
                new PropertyImage(
                        "/images/properties/gateway-studio-1.jpg",
                        true,
                        1,
                        property6
                )
        );


        // =====================================================
        // 9. SAVE PROPERTIES
        // =====================================================

        propertyRepository.saveAll(
                List.of(
                        property1,
                        property2,
                        property3,
                        property4,
                        property5,
                        property6
                )
        );


        // =====================================================
        // 10. POSTINGS
        // =====================================================

        Posting posting1 = createPublishedPosting(
                "Căn hộ Vinhomes Central Park 2 phòng ngủ",
                "Căn hộ 85m², 2 phòng ngủ, đầy đủ tiện ích, "
                        + "vị trí thuận tiện tại Bình Thạnh.",
                owner,
                property1
        );

        Posting posting2 = createPublishedPosting(
                "Căn hộ Masteri Thảo Điền 3 phòng ngủ",
                "Căn hộ 92m² tại Thảo Điền, không gian rộng rãi "
                        + "và nhiều tiện ích nội khu.",
                owner,
                property2
        );

        Posting posting3 = createPublishedPosting(
                "Căn hộ The Sun Avenue 2 phòng ngủ",
                "Căn hộ 76m² tại An Phú, phù hợp gia đình trẻ "
                        + "và thuận tiện di chuyển.",
                owner,
                property3
        );

        Posting posting4 = createPublishedPosting(
                "Căn hộ Vinhomes Grand Park giá tốt",
                "Căn hộ 68m², 2 phòng ngủ, khu đô thị nhiều "
                        + "tiện ích và không gian xanh.",
                owner,
                property4
        );

        Posting posting5 = createPublishedPosting(
                "Căn hộ Sunrise City 100m²",
                "Căn hộ rộng 100m², 3 phòng ngủ tại Quận 7, "
                        + "phù hợp gia đình.",
                owner,
                property5
        );

        Posting posting6 = createPublishedPosting(
                "Studio Thảo Điền hiện đại",
                "Studio 45m² tại Thảo Điền, thiết kế hiện đại, "
                        + "phù hợp người trẻ.",
                owner,
                property6
        );

        postingRepository.saveAll(
                List.of(
                        posting1,
                        posting2,
                        posting3,
                        posting4,
                        posting5,
                        posting6
                )
        );

        System.out.println("======================================");
        System.out.println("Sample data created successfully.");
        System.out.println("Properties: 6");
        System.out.println("Postings: 6");
        System.out.println("Amenities: 6");
        System.out.println("======================================");
    }


    // =========================================================
    // HELPER
    // =========================================================

    private Posting createPublishedPosting(
            String title,
            String description,
            Owner owner,
            Property property
    ) {

        Posting posting = new Posting(
                title,
                description,
                owner,
                property
        );

        /*
         * DRAFT
         *   ↓
         * PENDING_APPROVAL
         *   ↓
         * PUBLISHED
         */
        posting.submitForApproval();
        posting.approve();

        return posting;
    }
}