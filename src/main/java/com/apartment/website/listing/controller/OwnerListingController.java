package com.apartment.website.listing.controller;

import com.apartment.website.auth.entity.Owner;
import com.apartment.website.auth.service.CurrentUserService;

import com.apartment.website.listing.dto.OwnerListingRequest;
import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.service.OwnerListingService;
import com.apartment.website.listing.service.PostingService;

import com.apartment.website.property.entity.Property;

import jakarta.validation.Valid;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/owner/listings")
public class OwnerListingController {

    private final OwnerListingService ownerListingService;
    private final PostingService postingService;
    private final CurrentUserService currentUserService;

    public OwnerListingController(
            OwnerListingService ownerListingService,
            PostingService postingService,
            CurrentUserService currentUserService
    ) {
        this.ownerListingService =
                ownerListingService;

        this.postingService =
                postingService;

        this.currentUserService =
                currentUserService;
    }


    // =========================================================
    // LIST
    // =========================================================

    @GetMapping
    public String list(
            Model model
    ) {

        Owner owner =
                currentUserService
                        .getCurrentOwner();

        model.addAttribute(
                "postings",
                postingService
                        .getPostingsByOwner(owner)
        );

        return "owner/listings";
    }


    // =========================================================
    // CREATE FORM
    // =========================================================

    @GetMapping("/create")
    public String createForm(
            Model model
    ) {

        model.addAttribute(
                "listingRequest",
                new OwnerListingRequest()
        );

        model.addAttribute(
                "propertyTypes",
                Property.PropertyType.values()
        );

        return "owner/listing-form";
    }


    // =========================================================
    // CREATE
    // =========================================================

    @PostMapping("/create")
    public String create(
            @Valid
            @ModelAttribute("listingRequest")
            OwnerListingRequest request,

            BindingResult bindingResult,

            Model model
    ) {

        if (bindingResult.hasErrors()) {

            model.addAttribute(
                    "propertyTypes",
                    Property.PropertyType.values()
            );

            return "owner/listing-form";
        }

        Posting posting =
                ownerListingService
                        .createListing(request);

        return "redirect:/owner/listings/"
                + posting.getPostingId();
    }


    // =========================================================
    // DETAIL
    // =========================================================

    @GetMapping("/{postingId}")
    public String detail(
            @PathVariable Long postingId,
            Model model
    ) {

        Posting posting =
                ownerListingService
                        .getOwnerListing(
                                postingId
                        );

        model.addAttribute(
                "posting",
                posting
        );

        return "owner/listing-detail";
    }


    // =========================================================
    // EDIT FORM
    // =========================================================

    @GetMapping("/{postingId}/edit")
    public String editForm(
            @PathVariable Long postingId,
            Model model
    ) {

        Posting posting =
                ownerListingService
                        .getOwnerListing(
                                postingId
                        );

        if (!posting.isEditable()) {
            throw new IllegalStateException(
                    "This posting cannot be edited."
            );
        }

        Property property =
                posting.getProperty();

        OwnerListingRequest request =
                new OwnerListingRequest();

        request.setTitle(
                posting.getTitle()
        );

        request.setDescription(
                posting.getDescription()
        );

        request.setPrice(
                property.getPrice()
        );

        request.setArea(
                property.getArea()
        );

        request.setBedrooms(
                property.getBedrooms()
        );

        request.setBathrooms(
                property.getBathrooms()
        );

        request.setFloor(
                property.getFloor()
        );

        request.setAddress(
                property.getAddress()
        );

        request.setCity(
                property.getCity()
        );

        request.setDistrict(
                property.getDistrict()
        );

        request.setWard(
                property.getWard()
        );

        request.setPropertyType(
                property.getPropertyType()
        );

        model.addAttribute(
                "listingRequest",
                request
        );

        model.addAttribute(
                "posting",
                posting
        );

        model.addAttribute(
                "propertyTypes",
                Property.PropertyType.values()
        );

        return "owner/listing-form";
    }


    // =========================================================
    // UPDATE
    // =========================================================

    @PostMapping("/{postingId}/edit")
    public String update(
            @PathVariable Long postingId,

            @Valid
            @ModelAttribute("listingRequest")
            OwnerListingRequest request,

            BindingResult bindingResult,

            Model model
    ) {

        if (bindingResult.hasErrors()) {

            Posting posting =
                    ownerListingService
                            .getOwnerListing(
                                    postingId
                            );

            model.addAttribute(
                    "posting",
                    posting
            );

            model.addAttribute(
                    "propertyTypes",
                    Property.PropertyType.values()
            );

            return "owner/listing-form";
        }

        ownerListingService.updateListing(
                postingId,
                request
        );

        return "redirect:/owner/listings/"
                + postingId;
    }


    // =========================================================
    // SUBMIT
    // =========================================================

    @PostMapping("/{postingId}/submit")
    public String submit(
            @PathVariable Long postingId
    ) {

        ownerListingService.submit(
                postingId
        );

        return "redirect:/owner/listings/"
                + postingId;
    }


    // =========================================================
    // HIDE
    // =========================================================

    @PostMapping("/{postingId}/hide")
    public String hide(
            @PathVariable Long postingId
    ) {

        ownerListingService.hide(
                postingId
        );

        return "redirect:/owner/listings/"
                + postingId;
    }


    // =========================================================
    // REPUBLISH
    // =========================================================

    @PostMapping("/{postingId}/republish")
    public String republish(
            @PathVariable Long postingId
    ) {

        ownerListingService.republish(
                postingId
        );

        return "redirect:/owner/listings/"
                + postingId;
    }


    // =========================================================
    // REMOVE
    // =========================================================

    @PostMapping("/{postingId}/remove")
    public String remove(
            @PathVariable Long postingId
    ) {

        ownerListingService.remove(
                postingId
        );

        return "redirect:/owner/listings";
    }
}