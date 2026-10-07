package com.apartment.website.interaction.entity;

import com.apartment.website.auth.entity.Customer;
import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "COMPARISONS")
public class Comparison {

    private static final int MAX_ITEMS = 5;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "COMPARISON_ID")
    private Long comparisonId;

    @Column(name = "NAME", length = 100)
    private String name;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CUSTOMER_ID", nullable = false)
    private Customer customer;

    @OneToMany(
            mappedBy = "comparison",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<ComparisonItem> items = new ArrayList<>();


    // =========================================================
    // Constructors
    // =========================================================

    public Comparison() {
        this.createdAt = LocalDateTime.now();
    }

    public Comparison(
            String name,
            Customer customer
    ) {
        if (customer == null) {
            throw new IllegalArgumentException(
                    "Customer cannot be null."
            );
        }

        this.name = name;
        this.customer = customer;
        this.createdAt = LocalDateTime.now();
    }


    // =========================================================
    // Business methods
    // =========================================================

    public void addItem(ComparisonItem item) {

        if (item == null) {
            throw new IllegalArgumentException(
                    "Comparison item cannot be null."
            );
        }

        if (!canAddMoreItems()) {
            throw new IllegalStateException(
                    "A comparison can contain at most 5 properties."
            );
        }

        boolean propertyAlreadyExists = items.stream()
                .anyMatch(existingItem ->
                        existingItem.getProperty() != null
                                && item.getProperty() != null
                                && existingItem.getProperty()
                                .equals(item.getProperty())
                );

        if (propertyAlreadyExists) {
            throw new IllegalArgumentException(
                    "Property already exists in this comparison."
            );
        }

        items.add(item);
        item.setComparison(this);
    }

    public void removeItem(ComparisonItem item) {

        if (item != null && items.remove(item)) {
            item.setComparison(null);
        }
    }

    public int getItemCount() {
        return items.size();
    }

    public boolean canAddMoreItems() {
        return items.size() < MAX_ITEMS;
    }


    // =========================================================
    // Getters and Setters
    // =========================================================

    public Long getComparisonId() {
        return comparisonId;
    }

    public void setComparisonId(Long comparisonId) {
        this.comparisonId = comparisonId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {

        if (name != null && name.length() > 100) {
            throw new IllegalArgumentException(
                    "Comparison name cannot exceed 100 characters."
            );
        }

        this.name = name;
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

    public List<ComparisonItem> getItems() {
        return items;
    }

    public void setItems(List<ComparisonItem> items) {
        this.items = items;
    }
}