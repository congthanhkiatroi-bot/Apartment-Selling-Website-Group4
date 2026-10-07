package com.apartment.website.interaction.entity;

import com.apartment.website.property.entity.Property;
import jakarta.persistence.*;

@Entity
@Table(
        name = "COMPARISON_ITEMS",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "UK_COMPARISON_PROPERTY",
                        columnNames = {
                                "COMPARISON_ID",
                                "PROPERTY_ID"
                        }
                )
        }
)
public class ComparisonItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "COMPARISON_ITEM_ID")
    private Long comparisonItemId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "COMPARISON_ID", nullable = false)
    private Comparison comparison;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "PROPERTY_ID", nullable = false)
    private Property property;


    // =========================================================
    // Constructors
    // =========================================================

    public ComparisonItem() {
    }

    public ComparisonItem(
            Comparison comparison,
            Property property
    ) {
        if (comparison == null) {
            throw new IllegalArgumentException(
                    "Comparison cannot be null."
            );
        }

        if (property == null) {
            throw new IllegalArgumentException(
                    "Property cannot be null."
            );
        }

        this.comparison = comparison;
        this.property = property;
    }


    // =========================================================
    // Getters and Setters
    // =========================================================

    public Long getComparisonItemId() {
        return comparisonItemId;
    }

    public void setComparisonItemId(Long comparisonItemId) {
        this.comparisonItemId = comparisonItemId;
    }

    public Comparison getComparison() {
        return comparison;
    }

    public void setComparison(Comparison comparison) {
        this.comparison = comparison;
    }

    public Property getProperty() {
        return property;
    }

    public void setProperty(Property property) {
        this.property = property;
    }
}