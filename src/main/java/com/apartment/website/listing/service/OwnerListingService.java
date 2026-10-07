package com.apartment.website.listing.service;

import com.apartment.website.auth.entity.Owner;
import com.apartment.website.auth.service.CurrentUserService;

import com.apartment.website.listing.dto.OwnerListingRequest;
import com.apartment.website.listing.entity.Posting;

import com.apartment.website.property.entity.Property;
import com.apartment.website.property.service.PropertyService;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class OwnerListingService {

    private final CurrentUserService currentUserService;
    private final PropertyService propertyService;
    private final PostingService postingService;

    public OwnerListingService(
            CurrentUserService currentUserService,
            PropertyService propertyService,
            PostingService postingService
    ) {
        this.currentUserService =
                currentUserService;

        this.propertyService =
                propertyService;

        this.postingService =
                postingService;
    }


    // =========================================================
    // CREATE PROPERTY + POSTING
    // =========================================================

    public Posting createListing(
            OwnerListingRequest request
    ) {

        if (request == null) {
            throw new IllegalArgumentException(
                    "Listing data cannot be null."
            );
        }

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        Property property =
                request.toProperty();

        Property savedProperty =
                propertyService.createProperty(
                        property
                );

        return postingService.createPosting(
                request.getTitle(),
                request.getDescription(),
                owner,
                savedProperty
        );
    }


    // =========================================================
    // UPDATE PROPERTY + POSTING
    // =========================================================

    public Posting updateListing(
            Long postingId,
            OwnerListingRequest request
    ) {

        if (request == null) {
            throw new IllegalArgumentException(
                    "Listing data cannot be null."
            );
        }

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        Posting posting =
                postingService.getPostingOwnedBy(
                        postingId,
                        owner
                );

        if (!posting.isEditable()) {
            throw new IllegalStateException(
                    "Only draft or rejected postings can be edited."
            );
        }

        Property updatedProperty =
                request.toProperty();

        propertyService.updateProperty(
                posting.getProperty()
                        .getPropertyId(),
                updatedProperty
        );

        return postingService
                .updatePostingByOwner(
                        postingId,
                        request.getTitle(),
                        request.getDescription(),
                        owner
                );
    }


    // =========================================================
    // GET OWNER LISTING
    // =========================================================

    @Transactional(readOnly = true)
    public Posting getOwnerListing(
            Long postingId
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        return postingService
                .getPostingOwnedBy(
                        postingId,
                        owner
                );
    }


    // =========================================================
    // SUBMIT
    // =========================================================

    public Posting submit(
            Long postingId
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        return postingService
                .submitForApprovalByOwner(
                        postingId,
                        owner
                );
    }


    // =========================================================
    // HIDE
    // =========================================================

    public Posting hide(
            Long postingId
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        return postingService
                .hidePostingByOwner(
                        postingId,
                        owner
                );
    }


    // =========================================================
    // REPUBLISH
    // =========================================================

    public Posting republish(
            Long postingId
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        return postingService
                .republishPostingByOwner(
                        postingId,
                        owner
                );
    }


    // =========================================================
    // REMOVE
    // =========================================================

    public Posting remove(
            Long postingId
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        return postingService
                .removePostingByOwner(
                        postingId,
                        owner
                );
    }
}