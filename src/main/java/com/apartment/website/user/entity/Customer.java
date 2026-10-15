package com.apartment.website.user.entity;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Khách hàng (bảng customers, customer_id = users.user_id) -> kế thừa User.
 * locations = các khu vực khách quan tâm (bảng customer_locations).
 * searchProperties(), addFavorite(), compareProperties(), bookViewing(), writeReview() của diagram
 * được hiện thực ở Service tương ứng: PropertyService, AppointmentService, ReviewService...
 */
public class Customer extends User {
    private final List<String> locations;

    public Customer(long userId, String username, String email, String passwordHash, LocalDateTime createdAt,
                    boolean active, List<String> locations) {
        super(userId, username, email, passwordHash, ROLE_CUSTOMER, createdAt, active);
        this.locations = locations;
    }

    public long getCustomerId() {
        return getUserId();
    }

    public List<String> getLocations() {
        return locations;
    }
}
