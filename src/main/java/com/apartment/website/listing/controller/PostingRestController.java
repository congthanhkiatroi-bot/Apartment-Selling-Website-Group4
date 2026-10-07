package com.apartment.website.listing.controller;

import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.service.PostingService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/postings")
public class PostingRestController {

    private final PostingService postingService;

    public PostingRestController(
            PostingService postingService
    ) {
        this.postingService = postingService;
    }


    // =========================================================
    // PUBLIC - GET ALL PUBLISHED POSTINGS
    // =========================================================

    @GetMapping
    public ResponseEntity<List<Posting>>
    getPublishedPostings() {

        return ResponseEntity.ok(
                postingService.getPublishedPostings()
        );
    }


    // =========================================================
    // PUBLIC - GET PUBLISHED POSTING BY ID
    // =========================================================

    @GetMapping("/{postingId}")
    public ResponseEntity<Posting> getById(
            @PathVariable Long postingId
    ) {

        return ResponseEntity.ok(
                postingService
                        .getPublishedPostingById(
                                postingId
                        )
        );
    }
}