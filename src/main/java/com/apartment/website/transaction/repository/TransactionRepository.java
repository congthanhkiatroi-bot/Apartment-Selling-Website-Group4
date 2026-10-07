package com.apartment.website.transaction.repository;

import com.apartment.website.transaction.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TransactionRepository
        extends JpaRepository<Transaction, Long> {

    List<Transaction> findByCustomerUserIdOrderByCreatedAtDesc(
            Long customerId
    );

    List<Transaction> findByPostingPostingId(
            Long postingId
    );

    List<Transaction> findByStatus(
            Transaction.TransactionStatus status
    );
}