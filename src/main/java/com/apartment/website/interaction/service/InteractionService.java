package com.apartment.website.interaction.service;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.interaction.entity.Comment;
import com.apartment.website.interaction.entity.Comparison;
import com.apartment.website.interaction.entity.ComparisonItem;
import com.apartment.website.interaction.entity.Favorite;
import com.apartment.website.interaction.entity.SearchHistory;
import com.apartment.website.interaction.repository.CommentRepository;
import com.apartment.website.interaction.repository.ComparisonItemRepository;
import com.apartment.website.interaction.repository.ComparisonRepository;
import com.apartment.website.interaction.repository.FavoriteRepository;
import com.apartment.website.interaction.repository.SearchHistoryRepository;
import com.apartment.website.property.entity.Property;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@Transactional
public class InteractionService {

    private final FavoriteRepository favoriteRepository;
    private final CommentRepository commentRepository;
    private final ComparisonRepository comparisonRepository;
    private final ComparisonItemRepository comparisonItemRepository;
    private final SearchHistoryRepository searchHistoryRepository;

    public InteractionService(
            FavoriteRepository favoriteRepository,
            CommentRepository commentRepository,
            ComparisonRepository comparisonRepository,
            ComparisonItemRepository comparisonItemRepository,
            SearchHistoryRepository searchHistoryRepository
    ) {
        this.favoriteRepository = favoriteRepository;
        this.commentRepository = commentRepository;
        this.comparisonRepository = comparisonRepository;
        this.comparisonItemRepository = comparisonItemRepository;
        this.searchHistoryRepository = searchHistoryRepository;
    }


    // =========================================================
    // FAVORITE
    // =========================================================

    public Favorite addFavorite(
            Customer customer,
            Property property
    ) {

        validateCustomerAndProperty(customer, property);

        boolean alreadyExists =
                favoriteRepository
                        .existsByCustomerUserIdAndPropertyPropertyId(
                                customer.getUserId(),
                                property.getPropertyId()
                        );

        if (alreadyExists) {
            throw new IllegalStateException(
                    "Property is already in favorites."
            );
        }

        Favorite favorite =
                new Favorite(customer, property);

        return favoriteRepository.save(favorite);
    }


    public void removeFavorite(
            Long customerId,
            Long propertyId
    ) {

        validateIds(customerId, propertyId);

        Favorite favorite =
                favoriteRepository
                        .findByCustomerUserIdAndPropertyPropertyId(
                                customerId,
                                propertyId
                        )
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Favorite not found."
                                )
                        );

        favoriteRepository.delete(favorite);
    }


    @Transactional(readOnly = true)
    public boolean isFavorite(
            Long customerId,
            Long propertyId
    ) {

        validateIds(customerId, propertyId);

        return favoriteRepository
                .existsByCustomerUserIdAndPropertyPropertyId(
                        customerId,
                        propertyId
                );
    }


    @Transactional(readOnly = true)
    public List<Favorite> getFavoritesByCustomer(
            Long customerId
    ) {

        validateCustomerId(customerId);

        return favoriteRepository
                .findByCustomerUserIdOrderByCreatedAtDesc(
                        customerId
                );
    }


    // =========================================================
    // COMMENT
    // =========================================================

    public Comment addComment(
            Integer rating,
            String content,
            Customer customer,
            Property property
    ) {

        validateCustomerAndProperty(customer, property);

        if (commentRepository
                .existsByCustomerUserIdAndPropertyPropertyId(
                        customer.getUserId(),
                        property.getPropertyId()
                )) {

            throw new IllegalStateException(
                    "Customer has already commented on this property."
            );
        }

        Comment comment = new Comment(
                rating,
                content,
                customer,
                property
        );

        return commentRepository.save(comment);
    }


    public Comment updateComment(
            Long commentId,
            String content,
            Integer rating
    ) {

        Comment comment = getCommentById(commentId);

        comment.updateComment(
                content,
                rating
        );

        return commentRepository.save(comment);
    }


    public void deleteComment(Long commentId) {

        Comment comment = getCommentById(commentId);

        commentRepository.delete(comment);
    }


    @Transactional(readOnly = true)
    public Comment getCommentById(Long commentId) {

        if (commentId == null) {
            throw new IllegalArgumentException(
                    "Comment ID cannot be null."
            );
        }

        return commentRepository
                .findById(commentId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Comment not found with ID: "
                                        + commentId
                        )
                );
    }


    @Transactional(readOnly = true)
    public List<Comment> getCommentsByProperty(
            Long propertyId
    ) {

        if (propertyId == null) {
            throw new IllegalArgumentException(
                    "Property ID cannot be null."
            );
        }

        return commentRepository
                .findByPropertyPropertyIdOrderByCreatedAtDesc(
                        propertyId
                );
    }


    @Transactional(readOnly = true)
    public List<Comment> getCommentsByCustomer(
            Long customerId
    ) {

        validateCustomerId(customerId);

        return commentRepository
                .findByCustomerUserIdOrderByCreatedAtDesc(
                        customerId
                );
    }


    // =========================================================
    // COMPARISON
    // =========================================================

    public Comparison createComparison(
            String name,
            Customer customer
    ) {

        if (customer == null
                || customer.getUserId() == null) {

            throw new IllegalArgumentException(
                    "Customer cannot be null."
            );
        }

        Comparison comparison =
                new Comparison(name, customer);

        return comparisonRepository.save(comparison);
    }


    @Transactional(readOnly = true)
    public Comparison getComparisonById(
            Long comparisonId
    ) {

        if (comparisonId == null) {
            throw new IllegalArgumentException(
                    "Comparison ID cannot be null."
            );
        }

        return comparisonRepository
                .findById(comparisonId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Comparison not found with ID: "
                                        + comparisonId
                        )
                );
    }


    @Transactional(readOnly = true)
    public List<Comparison> getComparisonsByCustomer(
            Long customerId
    ) {

        validateCustomerId(customerId);

        return comparisonRepository
                .findByCustomerUserIdOrderByCreatedAtDesc(
                        customerId
                );
    }


    public ComparisonItem addPropertyToComparison(
            Long comparisonId,
            Property property
    ) {

        if (property == null
                || property.getPropertyId() == null) {

            throw new IllegalArgumentException(
                    "Property cannot be null."
            );
        }

        Comparison comparison =
                getComparisonById(comparisonId);

        boolean alreadyExists =
                comparisonItemRepository
                        .existsByComparisonComparisonIdAndPropertyPropertyId(
                                comparisonId,
                                property.getPropertyId()
                        );

        if (alreadyExists) {
            throw new IllegalStateException(
                    "Property already exists in comparison."
            );
        }

        ComparisonItem item =
                new ComparisonItem(
                        comparison,
                        property
                );

        return comparisonItemRepository.save(item);
    }


    public void removePropertyFromComparison(
            Long comparisonId,
            Long propertyId
    ) {

        if (comparisonId == null
                || propertyId == null) {

            throw new IllegalArgumentException(
                    "Comparison ID and Property ID cannot be null."
            );
        }

        boolean exists =
                comparisonItemRepository
                        .existsByComparisonComparisonIdAndPropertyPropertyId(
                                comparisonId,
                                propertyId
                        );

        if (!exists) {
            throw new IllegalArgumentException(
                    "Property not found in comparison."
            );
        }

        comparisonItemRepository
                .deleteByComparisonComparisonIdAndPropertyPropertyId(
                        comparisonId,
                        propertyId
                );
    }


    public void deleteComparison(Long comparisonId) {

        Comparison comparison =
                getComparisonById(comparisonId);

        comparisonRepository.delete(comparison);
    }


    // =========================================================
    // SEARCH HISTORY
    // =========================================================

    public SearchHistory saveSearchHistory(
            String keyword,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Double minArea,
            Double maxArea,
            Integer bedrooms,
            String location,
            Customer customer
    ) {

        if (customer == null
                || customer.getUserId() == null) {

            throw new IllegalArgumentException(
                    "Customer cannot be null."
            );
        }

        validateSearchRange(
                minPrice,
                maxPrice,
                minArea,
                maxArea,
                bedrooms
        );

        SearchHistory searchHistory =
                new SearchHistory(
                        keyword,
                        minPrice,
                        maxPrice,
                        minArea,
                        maxArea,
                        bedrooms,
                        location,
                        customer
                );

        return searchHistoryRepository.save(
                searchHistory
        );
    }


    @Transactional(readOnly = true)
    public List<SearchHistory> getSearchHistory(
            Long customerId
    ) {

        validateCustomerId(customerId);

        return searchHistoryRepository
                .findByCustomerUserIdOrderByCreatedAtDesc(
                        customerId
                );
    }


    @Transactional(readOnly = true)
    public List<SearchHistory> getRecentSearchHistory(
            Long customerId
    ) {

        validateCustomerId(customerId);

        return searchHistoryRepository
                .findTop10ByCustomerUserIdOrderByCreatedAtDesc(
                        customerId
                );
    }


    public void clearSearchHistory(
            Long customerId
    ) {

        validateCustomerId(customerId);

        searchHistoryRepository
                .deleteByCustomerUserId(customerId);
    }


    // =========================================================
    // VALIDATION
    // =========================================================

    private void validateCustomerAndProperty(
            Customer customer,
            Property property
    ) {

        if (customer == null
                || customer.getUserId() == null) {

            throw new IllegalArgumentException(
                    "Customer cannot be null."
            );
        }

        if (property == null
                || property.getPropertyId() == null) {

            throw new IllegalArgumentException(
                    "Property cannot be null."
            );
        }
    }


    private void validateIds(
            Long customerId,
            Long propertyId
    ) {

        validateCustomerId(customerId);

        if (propertyId == null) {
            throw new IllegalArgumentException(
                    "Property ID cannot be null."
            );
        }
    }


    private void validateCustomerId(
            Long customerId
    ) {

        if (customerId == null) {
            throw new IllegalArgumentException(
                    "Customer ID cannot be null."
            );
        }
    }


    private void validateSearchRange(
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Double minArea,
            Double maxArea,
            Integer bedrooms
    ) {

        if (minPrice != null
                && maxPrice != null
                && minPrice.compareTo(maxPrice) > 0) {

            throw new IllegalArgumentException(
                    "Minimum price cannot be greater than maximum price."
            );
        }

        if (minArea != null
                && maxArea != null
                && minArea > maxArea) {

            throw new IllegalArgumentException(
                    "Minimum area cannot be greater than maximum area."
            );
        }

        if (minPrice != null
                && minPrice.compareTo(BigDecimal.ZERO) < 0) {

            throw new IllegalArgumentException(
                    "Minimum price cannot be negative."
            );
        }

        if (maxPrice != null
                && maxPrice.compareTo(BigDecimal.ZERO) < 0) {

            throw new IllegalArgumentException(
                    "Maximum price cannot be negative."
            );
        }

        if (minArea != null && minArea < 0) {
            throw new IllegalArgumentException(
                    "Minimum area cannot be negative."
            );
        }

        if (maxArea != null && maxArea < 0) {
            throw new IllegalArgumentException(
                    "Maximum area cannot be negative."
            );
        }

        if (bedrooms != null && bedrooms < 0) {
            throw new IllegalArgumentException(
                    "Bedrooms cannot be negative."
            );
        }
    }
    // =========================================================
// COMMENT OWNERSHIP
// =========================================================

    @Transactional(readOnly = true)
    public Comment getCommentOwnedBy(
            Long commentId,
            Customer customer
    ) {

        if (customer == null
                || customer.getUserId() == null) {

            throw new IllegalArgumentException(
                    "Customer cannot be null."
            );
        }

        Comment comment =
                getCommentById(commentId);

        if (comment.getCustomer() == null
                || comment.getCustomer().getUserId() == null
                || !comment.getCustomer()
                .getUserId()
                .equals(customer.getUserId())) {

            throw new IllegalStateException(
                    "You do not own this comment."
            );
        }

        return comment;
    }


    public Comment updateCommentByCustomer(
            Long commentId,
            String content,
            Integer rating,
            Customer customer
    ) {

        getCommentOwnedBy(
                commentId,
                customer
        );

        return updateComment(
                commentId,
                content,
                rating
        );
    }


    public void deleteCommentByCustomer(
            Long commentId,
            Customer customer
    ) {

        getCommentOwnedBy(
                commentId,
                customer
        );

        deleteComment(commentId);
    }


// =========================================================
// COMPARISON OWNERSHIP
// =========================================================

    @Transactional(readOnly = true)
    public Comparison getComparisonOwnedBy(
            Long comparisonId,
            Customer customer
    ) {

        if (customer == null
                || customer.getUserId() == null) {

            throw new IllegalArgumentException(
                    "Customer cannot be null."
            );
        }

        Comparison comparison =
                getComparisonById(comparisonId);

        if (comparison.getCustomer() == null
                || comparison.getCustomer().getUserId() == null
                || !comparison.getCustomer()
                .getUserId()
                .equals(customer.getUserId())) {

            throw new IllegalStateException(
                    "You do not own this comparison."
            );
        }

        return comparison;
    }


    public ComparisonItem addPropertyToComparisonByCustomer(
            Long comparisonId,
            Property property,
            Customer customer
    ) {

        Comparison comparison =
                getComparisonOwnedBy(
                        comparisonId,
                        customer
                );

        if (!comparison.canAddMoreItems()) {
            throw new IllegalStateException(
                    "A comparison can contain at most 5 properties."
            );
        }

        return addPropertyToComparison(
                comparisonId,
                property
        );
    }


    public void removePropertyFromComparisonByCustomer(
            Long comparisonId,
            Long propertyId,
            Customer customer
    ) {

        getComparisonOwnedBy(
                comparisonId,
                customer
        );

        removePropertyFromComparison(
                comparisonId,
                propertyId
        );
    }


    public void deleteComparisonByCustomer(
            Long comparisonId,
            Customer customer
    ) {

        getComparisonOwnedBy(
                comparisonId,
                customer
        );

        deleteComparison(comparisonId);
    }
}