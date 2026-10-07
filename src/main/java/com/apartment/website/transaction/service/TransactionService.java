package com.apartment.website.transaction.service;

import com.apartment.website.auth.entity.Customer;
import com.apartment.website.listing.entity.Posting;
import com.apartment.website.transaction.entity.Transaction;
import com.apartment.website.transaction.entity.Transaction.TransactionStatus;
import com.apartment.website.transaction.repository.TransactionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.apartment.website.auth.entity.Customer;
import com.apartment.website.auth.entity.Owner;

import java.math.BigDecimal;
import java.util.List;

@Service
@Transactional
public class TransactionService {

    private final TransactionRepository transactionRepository;

    public TransactionService(
            TransactionRepository transactionRepository
    ) {
        this.transactionRepository = transactionRepository;
    }


    // =========================================================
    // CREATE TRANSACTION
    // =========================================================

    public Transaction createTransaction(
            BigDecimal agreedPrice,
            Customer customer,
            Posting posting
    ) {

        if (agreedPrice == null
                || agreedPrice.compareTo(BigDecimal.ZERO) <= 0) {

            throw new IllegalArgumentException(
                    "Agreed price must be greater than zero."
            );
        }

        if (customer == null || customer.getUserId() == null) {
            throw new IllegalArgumentException(
                    "Customer cannot be null."
            );
        }

        if (posting == null || posting.getPostingId() == null) {
            throw new IllegalArgumentException(
                    "Posting cannot be null."
            );
        }

        Transaction transaction = new Transaction(
                agreedPrice,
                customer,
                posting
        );

        return transactionRepository.save(transaction);
    }


    // =========================================================
    // READ
    // =========================================================

    @Transactional(readOnly = true)
    public Transaction getTransactionById(Long transactionId) {

        validateId(transactionId);

        return transactionRepository.findById(transactionId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Transaction not found with ID: "
                                        + transactionId
                        )
                );
    }


    @Transactional(readOnly = true)
    public List<Transaction> getAllTransactions() {
        return transactionRepository.findAll();
    }


    @Transactional(readOnly = true)
    public List<Transaction> getTransactionsByCustomer(
            Long customerId
    ) {

        if (customerId == null) {
            throw new IllegalArgumentException(
                    "Customer ID cannot be null."
            );
        }

        return transactionRepository
                .findByCustomerUserIdOrderByCreatedAtDesc(
                        customerId
                );
    }


    @Transactional(readOnly = true)
    public List<Transaction> getTransactionsByPosting(
            Long postingId
    ) {

        if (postingId == null) {
            throw new IllegalArgumentException(
                    "Posting ID cannot be null."
            );
        }

        return transactionRepository
                .findByPostingPostingId(postingId);
    }


    @Transactional(readOnly = true)
    public List<Transaction> getTransactionsByStatus(
            TransactionStatus status
    ) {

        if (status == null) {
            throw new IllegalArgumentException(
                    "Transaction status cannot be null."
            );
        }

        return transactionRepository.findByStatus(status);
    }


    // =========================================================
    // CONFIRM
    // PENDING -> CONFIRMED
    // =========================================================

    public Transaction confirmTransaction(Long transactionId) {

        Transaction transaction =
                getTransactionById(transactionId);

        transaction.confirm();

        return transactionRepository.save(transaction);
    }


    // =========================================================
    // MARK AS PAID
    // CONFIRMED -> PAID
    // =========================================================

    public Transaction markTransactionAsPaid(
            Long transactionId
    ) {

        Transaction transaction =
                getTransactionById(transactionId);

        transaction.markAsPaid();

        return transactionRepository.save(transaction);
    }


    // =========================================================
    // COMPLETE
    // PAID -> COMPLETED
    // =========================================================

    public Transaction completeTransaction(
            Long transactionId
    ) {

        Transaction transaction =
                getTransactionById(transactionId);

        transaction.complete();

        return transactionRepository.save(transaction);
    }


    // =========================================================
    // CANCEL
    // =========================================================

    public Transaction cancelTransaction(
            Long transactionId
    ) {

        Transaction transaction =
                getTransactionById(transactionId);

        transaction.cancel();

        return transactionRepository.save(transaction);
    }


    // =========================================================
    // DELETE
    // =========================================================

    public void deleteTransaction(Long transactionId) {

        Transaction transaction =
                getTransactionById(transactionId);

        transactionRepository.delete(transaction);
    }


    // =========================================================
    // VALIDATION
    // =========================================================

    private void validateId(Long transactionId) {

        if (transactionId == null) {
            throw new IllegalArgumentException(
                    "Transaction ID cannot be null."
            );
        }
    }
    // =========================================================
// CUSTOMER OWNERSHIP
// =========================================================

    @Transactional(readOnly = true)
    public Transaction getTransactionOwnedByCustomer(
            Long transactionId,
            Customer customer
    ) {

        if (customer == null || customer.getUserId() == null) {
            throw new IllegalArgumentException(
                    "Customer cannot be null."
            );
        }

        Transaction transaction =
                getTransactionById(transactionId);

        if (transaction.getCustomer() == null
                || transaction.getCustomer().getUserId() == null
                || !transaction.getCustomer()
                .getUserId()
                .equals(customer.getUserId())) {

            throw new IllegalStateException(
                    "You do not own this transaction."
            );
        }

        return transaction;
    }


    public Transaction cancelTransactionByCustomer(
            Long transactionId,
            Customer customer
    ) {

        getTransactionOwnedByCustomer(
                transactionId,
                customer
        );

        return cancelTransaction(transactionId);
    }


// =========================================================
// OWNER OWNERSHIP
// =========================================================

    @Transactional(readOnly = true)
    public Transaction getTransactionOwnedByOwner(
            Long transactionId,
            Owner owner
    ) {

        if (owner == null || owner.getUserId() == null) {
            throw new IllegalArgumentException(
                    "Owner cannot be null."
            );
        }

        Transaction transaction =
                getTransactionById(transactionId);

        if (transaction.getPosting() == null
                || transaction.getPosting().getOwner() == null
                || transaction.getPosting()
                .getOwner()
                .getUserId() == null
                || !transaction.getPosting()
                .getOwner()
                .getUserId()
                .equals(owner.getUserId())) {

            throw new IllegalStateException(
                    "You do not own the posting of this transaction."
            );
        }

        return transaction;
    }


    public Transaction confirmTransactionByOwner(
            Long transactionId,
            Owner owner
    ) {

        getTransactionOwnedByOwner(
                transactionId,
                owner
        );

        return confirmTransaction(transactionId);
    }


    public Transaction cancelTransactionByOwner(
            Long transactionId,
            Owner owner
    ) {

        getTransactionOwnedByOwner(
                transactionId,
                owner
        );

        return cancelTransaction(transactionId);
    }
}