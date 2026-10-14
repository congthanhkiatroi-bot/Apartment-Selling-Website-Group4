package com.apartment.website.transaction.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Giao dịch mua căn hộ (bảng transactions). Diagram: Customer 1 --- 0..* Transaction --- 1 Listing.
 * App không làm thanh toán nên bỏ qua các cột payment_method, payment_status.
 * create() / cancel() của diagram sẽ nằm ở TransactionService.
 */
public class Transaction {
    private final long transactionId, customerId, listingId; private final String transactionCode;
    private final BigDecimal listingPrice, agreedPrice, depositAmount, remainingAmount;
    private final LocalDateTime transactionDate, contractDate, completionDate;
    private final String status, note;

    public Transaction(long transactionId, String transactionCode, long customerId, long listingId,
                       BigDecimal listingPrice, BigDecimal agreedPrice, BigDecimal depositAmount, BigDecimal remainingAmount,
                       LocalDateTime transactionDate, LocalDateTime contractDate, LocalDateTime completionDate,
                       String status, String note) {
        this.transactionId = transactionId; this.transactionCode = transactionCode; this.customerId = customerId;
        this.listingId = listingId; this.listingPrice = listingPrice; this.agreedPrice = agreedPrice;
        this.depositAmount = depositAmount; this.remainingAmount = remainingAmount; this.transactionDate = transactionDate;
        this.contractDate = contractDate; this.completionDate = completionDate; this.status = status; this.note = note;
    }

    public long getTransactionId() { return transactionId; }   public String getTransactionCode() { return transactionCode; }
    public long getCustomerId() { return customerId; }         public long getListingId() { return listingId; }
    public BigDecimal getListingPrice() { return listingPrice; }  public BigDecimal getAgreedPrice() { return agreedPrice; }
    public BigDecimal getDepositAmount() { return depositAmount; }  public BigDecimal getRemainingAmount() { return remainingAmount; }
    public LocalDateTime getTransactionDate() { return transactionDate; }  public LocalDateTime getContractDate() { return contractDate; }
    public LocalDateTime getCompletionDate() { return completionDate; }   public String getStatus() { return status; }
    public String getNote() { return note; }

    /** getDetails() trong diagram. */
    public String getDetails() {
        return transactionCode + " | giá chốt " + agreedPrice.toPlainString() + " | còn lại " + remainingAmount.toPlainString()
                + " | " + status;
    }
}
