package com.apartment.website.interaction.entity;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.property.entity.Property;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "FAVORITES",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "UK_FAVORITE_CUSTOMER_PROPERTY",
                        columnNames = {"CUSTOMER_ID", "PROPERTY_ID"}
                )
        }
)
public class Favorite {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "FAVORITE_ID")
    private Long favoriteId;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CUSTOMER_ID", nullable = false)
    private Customer customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "PROPERTY_ID", nullable = false)
    private Property property;


    // =========================================================
    // Constructors
    // =========================================================

    public Favorite() {
        this.createdAt = LocalDateTime.now();
    }

    public Favorite(
            Customer customer,
            Property property
    ) {
        if (customer == null) {
            throw new IllegalArgumentException(
                    "Customer cannot be null."
            );
        }

        if (property == null) {
            throw new IllegalArgumentException(
                    "Property cannot be null."
            );
        }

        this.customer = customer;
        this.property = property;
        this.createdAt = LocalDateTime.now();
    }


    // =========================================================
    // Getters and Setters
    // =========================================================

    public Long getFavoriteId() {
        return favoriteId;
    }

    public void setFavoriteId(Long favoriteId) {
        this.favoriteId = favoriteId;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    public Property getProperty() {
        return property;
    }

    public void setProperty(Property property) {
        this.property = property;
    }
}