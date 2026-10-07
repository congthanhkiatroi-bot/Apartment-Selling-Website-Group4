package com.apartment.website.auth.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "USER_VERIFICATIONS")
public class UserVerification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "VERIFICATION_ID")
    private Long verificationId;

    @Enumerated(EnumType.STRING)
    @Column(name = "VERIFICATION_TYPE", nullable = false, length = 30)
    private VerificationType verificationType;

    @Column(name = "VERIFICATION_CODE", length = 100)
    private String verificationCode;

    @Column(name = "IDENTITY_NUMBER", length = 20)
    private String identityNumber;

    @Column(name = "FULL_NAME", length = 100)
    private String fullName;

    @Column(name = "EXPIRES_AT")
    private LocalDateTime expiresAt;

    @Column(name = "VERIFIED_AT")
    private LocalDateTime verifiedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "STATUS", nullable = false, length = 20)
    private VerificationStatus status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "USER_ID", nullable = false)
    private User user;

    public UserVerification() {
        this.status = VerificationStatus.PENDING;
    }

    public boolean verifyCode(String code) {

        if (isExpired()) {
            return false;
        }

        if (status != VerificationStatus.PENDING) {
            return false;
        }

        if (verificationCode != null && verificationCode.equals(code)) {
            this.status = VerificationStatus.VERIFIED;
            this.verifiedAt = LocalDateTime.now();
            return true;
        }

        return false;
    }

    public void approveIdentity() {
        this.status = VerificationStatus.VERIFIED;
        this.verifiedAt = LocalDateTime.now();
    }

    public void reject() {
        this.status = VerificationStatus.REJECTED;
    }

    public boolean isExpired() {

        if (expiresAt == null) {
            return false;
        }

        if (LocalDateTime.now().isAfter(expiresAt)) {
            this.status = VerificationStatus.EXPIRED;
            return true;
        }

        return false;
    }

    public Long getVerificationId() {
        return verificationId;
    }

    public void setVerificationId(Long verificationId) {
        this.verificationId = verificationId;
    }

    public VerificationType getVerificationType() {
        return verificationType;
    }

    public void setVerificationType(VerificationType verificationType) {
        this.verificationType = verificationType;
    }

    public String getVerificationCode() {
        return verificationCode;
    }

    public void setVerificationCode(String verificationCode) {
        this.verificationCode = verificationCode;
    }

    public String getIdentityNumber() {
        return identityNumber;
    }

    public void setIdentityNumber(String identityNumber) {
        this.identityNumber = identityNumber;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }

    public LocalDateTime getVerifiedAt() {
        return verifiedAt;
    }

    public void setVerifiedAt(LocalDateTime verifiedAt) {
        this.verifiedAt = verifiedAt;
    }

    public VerificationStatus getStatus() {
        return status;
    }

    public void setStatus(VerificationStatus status) {
        this.status = status;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public enum VerificationType {
        EMAIL,
        PHONE,
        IDENTITY
    }

    public enum VerificationStatus {
        PENDING,
        VERIFIED,
        REJECTED,
        EXPIRED
    }
}