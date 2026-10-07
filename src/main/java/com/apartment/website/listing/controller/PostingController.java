package com.apartment.website.listing.controller;

import com.apartment.website.listing.entity.Posting;
import com.apartment.website.listing.service.PostingService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/postings")
public class PostingController {

    private final PostingService postingService;

    public PostingController(
            PostingService postingService
    ) {
        this.postingService = postingService;
    }


    // =========================================================
    // PUBLIC POSTINGS
    // =========================================================

    @GetMapping
    public String list(
            Model model
    ) {

        List<Posting> postings =
                postingService.getPublishedPostings();

        model.addAttribute(
                "postings",
                postings
        );

        return "listing/list";
    }


    // =========================================================
    // PUBLIC POSTING DETAIL
    // =========================================================

    @GetMapping("/{postingId}")
    public String detail(
            @PathVariable Long postingId,
            Model model
    ) {

        Posting posting =
                postingService
                        .getPublishedPostingById(
                                postingId
                        );

        model.addAttribute(
                "posting",
                posting
        );

        return "listing/detail";
    }
}