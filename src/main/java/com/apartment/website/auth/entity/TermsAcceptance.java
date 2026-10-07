package com.apartment.website.auth.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "TERMS_ACCEPTANCES")
public class TermsAcceptance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ACCEPTANCE_ID")
    private Long acceptanceId;

    @Enumerated(EnumType.STRING)
    @Column(name = "TERMS_TYPE", nullable = false, length = 30)
    private TermsType termsType;

    @Column(name = "TERMS_VERSION", nullable = false, length = 50)
    private String termsVersion;

    @Column(name = "ACCEPTED_AT", nullable = false)
    private LocalDateTime acceptedAt;

    @Column(name = "ACCEPTED", nullable = false)
    private boolean accepted;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "USER_ID", nullable = false)
    private User user;

    public TermsAcceptance() {
    }

    public TermsAcceptance(
            TermsType termsType,
            String termsVersion,
            User user
    ) {
        this.termsType = termsType;
        this.termsVersion = termsVersion;
        this.user = user;
        this.accepted = true;
        this.acceptedAt = LocalDateTime.now();
    }

    public void accept() {
        this.accepted = true;
        this.acceptedAt = LocalDateTime.now();
    }

    public Long getAcceptanceId() {
        return acceptanceId;
    }

    public void setAcceptanceId(Long acceptanceId) {
        this.acceptanceId = acceptanceId;
    }

    public TermsType getTermsType() {
        return termsType;
    }

    public void setTermsType(TermsType termsType) {
        this.termsType = termsType;
    }

    public String getTermsVersion() {
        return termsVersion;
    }

    public void setTermsVersion(String termsVersion) {
        this.termsVersion = termsVersion;
    }

    public LocalDateTime getAcceptedAt() {
        return acceptedAt;
    }

    public void setAcceptedAt(LocalDateTime acceptedAt) {
        this.acceptedAt = acceptedAt;
    }

    public boolean isAccepted() {
        return accepted;
    }

    public void setAccepted(boolean accepted) {
        this.accepted = accepted;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public enum TermsType {
        REGISTRATION,
        SELLER_POSTING
    }
}