package com.apartment.website.listing.service;

import com.apartment.website.auth.entity.Owner;
import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.entity.Posting.PostingStatus;
import com.apartment.website.listing.repository.PostingRepository;
import com.apartment.website.property.entity.Property;

import jakarta.persistence.EntityNotFoundException;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class PostingService {

    private final PostingRepository postingRepository;

    public PostingService(
            PostingRepository postingRepository
    ) {
        this.postingRepository = postingRepository;
    }


    // =========================================================
    // QUERY
    // =========================================================
    @Transactional(readOnly = true)
    public List<Posting> getPublishedPostings() {
        return postingRepository.findByStatus(
                PostingStatus.PUBLISHED
        );
    }

    @Transactional(readOnly = true)
    public Posting getPostingById(
            Long postingId
    ) {

        if (postingId == null) {
            throw new IllegalArgumentException(
                    "Posting ID cannot be null."
            );
        }

        return postingRepository
                .findById(postingId)
                .orElseThrow(() ->
                        new EntityNotFoundException(
                                "Posting not found with ID: "
                                        + postingId
                        )
                );
    }


    @Transactional(readOnly = true)
    public Posting getPublishedPostingById(
            Long postingId
    ) {

        Posting posting =
                getPostingById(postingId);

        if (posting.getStatus()
                != PostingStatus.PUBLISHED) {

            throw new IllegalArgumentException(
                    "Published posting not found."
            );
        }

        return posting;
    }


    @Transactional(readOnly = true)
    public List<Posting> getPostingsByOwner(
            Owner owner
    ) {

        if (owner == null
                || owner.getUserId() == null) {

            throw new IllegalArgumentException(
                    "Owner cannot be null."
            );
        }

        return postingRepository.findByOwner(
                owner
        );
    }


    // =========================================================
    // CREATE
    // =========================================================

    public Posting createPosting(
            String title,
            String description,
            Owner owner,
            Property property
    ) {

        if (owner == null
                || owner.getUserId() == null) {

            throw new IllegalArgumentException(
                    "Owner cannot be null."
            );
        }

        if (property == null) {
            throw new IllegalArgumentException(
                    "Property cannot be null."
            );
        }

        Posting posting =
                new Posting(
                        title,
                        description,
                        owner,
                        property
                );

        return postingRepository.save(
                posting
        );
    }


    // =========================================================
    // OWNERSHIP
    // =========================================================

    @Transactional(readOnly = true)
    public Posting getPostingOwnedBy(
            Long postingId,
            Owner owner
    ) {

        if (owner == null
                || owner.getUserId() == null) {

            throw new IllegalArgumentException(
                    "Owner cannot be null."
            );
        }

        Posting posting =
                getPostingById(postingId);

        if (posting.getOwner() == null
                || posting.getOwner()
                .getUserId() == null
                || !posting.getOwner()
                .getUserId()
                .equals(owner.getUserId())) {

            throw new AccessDeniedException(
                    "You do not own this posting."
            );
        }

        return posting;
    }


    // =========================================================
    // OWNER ACTIONS
    // =========================================================

    public Posting updatePostingByOwner(
            Long postingId,
            String title,
            String description,
            Owner owner
    ) {

        Posting posting =
                getPostingOwnedBy(
                        postingId,
                        owner
                );

        posting.updatePosting(
                title,
                description
        );

        return posting;
    }


    public Posting submitForApprovalByOwner(
            Long postingId,
            Owner owner
    ) {

        Posting posting =
                getPostingOwnedBy(
                        postingId,
                        owner
                );

        posting.submitForApproval();

        return posting;
    }


    public Posting hidePostingByOwner(
            Long postingId,
            Owner owner
    ) {

        Posting posting =
                getPostingOwnedBy(
                        postingId,
                        owner
                );

        posting.hide();

        return posting;
    }


    public Posting republishPostingByOwner(
            Long postingId,
            Owner owner
    ) {

        Posting posting =
                getPostingOwnedBy(
                        postingId,
                        owner
                );

        posting.republish();

        return posting;
    }


    public Posting removePostingByOwner(
            Long postingId,
            Owner owner
    ) {

        Posting posting =
                getPostingOwnedBy(
                        postingId,
                        owner
                );

        posting.remove();

        return posting;
    }


    // =========================================================
    // ADMIN QUERY
    // =========================================================

    @Transactional(readOnly = true)
    public List<Posting> getAllPostings() {

        return postingRepository.findAll();
    }


    @Transactional(readOnly = true)
    public List<Posting> getPendingApprovalPostings() {

        return postingRepository.findByStatus(
                PostingStatus.PENDING_APPROVAL
        );
    }


    // =========================================================
    // ADMIN MODERATION
    // =========================================================

    public Posting approvePosting(
            Long postingId
    ) {

        Posting posting =
                getPostingById(postingId);

        posting.approve();

        return posting;
    }


    public Posting rejectPosting(
            Long postingId,
            String reason
    ) {

        if (reason == null
                || reason.isBlank()) {

            throw new IllegalArgumentException(
                    "Rejection reason is required."
            );
        }

        Posting posting =
                getPostingById(postingId);

        posting.reject(
                reason.trim()
        );

        return posting;
    }


    // =========================================================
    // TRANSACTION WORKFLOW
    // =========================================================

    public Posting markPostingAsSold(
            Long postingId
    ) {

        Posting posting =
                getPostingById(postingId);

        posting.markAsSold();

        return posting;
    }
    @Transactional(readOnly = true)
    public Posting getPublishedPostingByPropertyId(
            Long propertyId
    ) {

        if (propertyId == null) {
            throw new IllegalArgumentException(
                    "Property ID cannot be null."
            );
        }

        Posting posting =
                postingRepository
                        .findByPropertyPropertyId(propertyId)
                        .orElseThrow(() ->
                                new EntityNotFoundException(
                                        "Published posting not found for property ID: "
                                                + propertyId
                                )
                        );

        if (posting.getStatus()
                != PostingStatus.PUBLISHED) {

            throw new IllegalArgumentException(
                    "Published posting not found."
            );
        }

        return posting;
    }
}