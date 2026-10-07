package com.apartment.website.auth.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "CUSTOMERS")
public class Customer extends User {

    public Customer() {
        super();
    }

    public Customer(
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