package com.apartment.website.interaction.entity;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.property.entity.Property;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "COMMENTS")
public class Comment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "COMMENT_ID")
    private Long commentId;

    @Column(name = "RATING", nullable = false)
    private Integer rating;

    @Column(name = "CONTENT", nullable = false, length = 1000)
    private String content;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "UPDATED_AT")
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CUSTOMER_ID", nullable = false)
    private Customer customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "PROPERTY_ID", nullable = false)
    private Property property;


    // =========================================================
    // Constructors
    // =========================================================

    public Comment() {
        this.createdAt = LocalDateTime.now();
    }

    public Comment(
            Integer rating,
            String content,
            Customer customer,
            Property property
    ) {
        validateRating(rating);
        validateContent(content);

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

        this.rating = rating;
        this.content = content.trim();
        this.customer = customer;
        this.property = property;
        this.createdAt = LocalDateTime.now();
    }


    // =========================================================
    // Business methods
    // =========================================================

    public void updateComment(
            String content,
            Integer rating
    ) {
        validateContent(content);
        validateRating(rating);

        this.content = content.trim();
        this.rating = rating;
        this.updatedAt = LocalDateTime.now();
    }


    // =========================================================
    // Validation
    // =========================================================

    private void validateRating(Integer rating) {
        if (rating == null || rating < 1 || rating > 5) {
            throw new IllegalArgumentException(
                    "Rating must be between 1 and 5."
            );
        }
    }

    private void validateContent(String content) {
        if (content == null || content.isBlank()) {
            throw new IllegalArgumentException(
                    "Comment content cannot be empty."
            );
        }

        if (content.length() > 1000) {
            throw new IllegalArgumentException(
                    "Comment content cannot exceed 1000 characters."
            );
        }
    }


    // =========================================================
    // Getters and Setters
    // =========================================================

    public Long getCommentId() {
        return commentId;
    }

    public void setCommentId(Long commentId) {
        this.commentId = commentId;
    }

    public Integer getRating() {
        return rating;
    }

    public void setRating(Integer rating) {
        validateRating(rating);
        this.rating = rating;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        validateContent(content);
        this.content = content.trim();
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
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