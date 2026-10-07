package com.apartment.website.auth.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "ADMINS")
public class Admin extends User {

    public Admin() {
        super();
    }
}