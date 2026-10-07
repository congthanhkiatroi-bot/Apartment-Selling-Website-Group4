package com.apartment.website.auth.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "OWNERS")
public class Owner extends User {

    public Owner() {
        super();
    }

    public Owner(
            String username,
            String email,
            String passwordHash,
            String phone
    ) {
        super(
                username,
                email,
                passwordHash,
                phone
        );
    }
}