-- ============================================================
-- 03_QUERIES.SQL
-- QUERIES FOR APARTMENT SELLING WEBSITE
-- ============================================================


-- ============================================================
-- 1. XEM TẤT CẢ TÒA NHÀ
-- ============================================================

SELECT
    BUILDING_ID,
    BUILDING_CODE,
    BUILDING_NAME,
    ADDRESS,
    WARD,
    DISTRICT,
    CITY,
    TOTAL_FLOORS,
    TOTAL_APARTMENTS,
    YEAR_BUILT,
    STATUS
FROM BUILDINGS
ORDER BY BUILDING_NAME;


-- ============================================================
-- 2. XEM TÒA NHÀ + SỐ LƯỢNG CĂN HỘ
-- ============================================================

SELECT
    b.BUILDING_ID,
    b.BUILDING_CODE,
    b.BUILDING_NAME,
    b.DISTRICT,
    b.CITY,
    COUNT(a.APARTMENT_ID) AS APARTMENT_COUNT
FROM BUILDINGS b
         LEFT JOIN APARTMENTS a
                   ON b.BUILDING_ID = a.BUILDING_ID
GROUP BY
    b.BUILDING_ID,
    b.BUILDING_CODE,
    b.BUILDING_NAME,
    b.DISTRICT,
    b.CITY
ORDER BY b.BUILDING_NAME;


-- ============================================================
-- 3. XEM DANH SÁCH CĂN HỘ
-- ============================================================

SELECT
    a.APARTMENT_ID,
    b.BUILDING_NAME,
    a.APARTMENT_CODE,
    a.FLOOR_NUMBER,
    a.ROOM_NUMBER,
    a.AREA,
    a.BEDROOMS,
    a.BATHROOMS,
    a.BALCONY_AREA,
    a.DIRECTION,
    a.VIEW_TYPE,
    a.LEGAL_STATUS,
    a.STATUS
FROM APARTMENTS a
         JOIN BUILDINGS b
              ON a.BUILDING_ID = b.BUILDING_ID
ORDER BY
    b.BUILDING_NAME,
    a.FLOOR_NUMBER,
    a.APARTMENT_CODE;


-- ============================================================
-- 4. DANH SÁCH CĂN HỘ ĐANG BÁN
-- ============================================================

SELECT
    p.PROPERTY_ID,
    b.BUILDING_NAME,
    a.APARTMENT_CODE,
    a.FLOOR_NUMBER,
    a.AREA,
    a.BEDROOMS,
    a.BATHROOMS,
    p.TITLE,
    p.PRICE,
    p.PRICE_PER_M2,
    p.STATUS
FROM PROPERTIES p
         JOIN APARTMENTS a
              ON p.APARTMENT_ID = a.APARTMENT_ID
         JOIN BUILDINGS b
              ON a.BUILDING_ID = b.BUILDING_ID
WHERE p.STATUS = 'AVAILABLE'
ORDER BY p.PRICE;


-- ============================================================
-- 5. DANH SÁCH TIN ĐĂNG
-- ============================================================

SELECT
    l.LISTING_ID,
    l.LISTING_CODE,
    l.LISTING_TITLE,
    o.OWNER_ID,
    u.USERNAME AS OWNER_USERNAME,
    p.PROPERTY_ID,
    p.TITLE,
    l.ASKING_PRICE,
    l.POST_DATE,
    l.EXPIRY_DATE,
    l.STATUS
FROM LISTINGS l
         JOIN OWNERS o
              ON l.OWNER_ID = o.OWNER_ID
         JOIN USERS u
              ON o.OWNER_ID = u.USER_ID
         JOIN PROPERTIES p
              ON l.PROPERTY_ID = p.PROPERTY_ID
ORDER BY l.POST_DATE DESC;


-- ============================================================
-- 6. CHI TIẾT CĂN HỘ
-- ============================================================

SELECT
    p.PROPERTY_ID,
    p.TITLE,

    b.BUILDING_NAME,
    b.ADDRESS,
    b.WARD,
    b.DISTRICT,
    b.CITY,

    a.APARTMENT_CODE,
    a.FLOOR_NUMBER,
    a.ROOM_NUMBER,
    a.AREA,
    a.BEDROOMS,
    a.BATHROOMS,
    a.BALCONY_AREA,
    a.DIRECTION,
    a.VIEW_TYPE,
    a.LEGAL_STATUS,

    p.PRICE,
    p.PRICE_PER_M2,
    p.DESCRIPTION,
    p.STATUS

FROM PROPERTIES p
         JOIN APARTMENTS a
              ON p.APARTMENT_ID = a.APARTMENT_ID
         JOIN BUILDINGS b
              ON a.BUILDING_ID = b.BUILDING_ID;


-- ============================================================
-- 7. TÌM CĂN HỘ THEO KHOẢNG GIÁ
-- ============================================================

SELECT
    p.PROPERTY_ID,
    p.TITLE,
    a.AREA,
    a.BEDROOMS,
    p.PRICE,
    b.BUILDING_NAME
FROM PROPERTIES p
         JOIN APARTMENTS a
              ON p.APARTMENT_ID = a.APARTMENT_ID
         JOIN BUILDINGS b
              ON a.BUILDING_ID = b.BUILDING_ID
WHERE p.PRICE BETWEEN 3000000000 AND 5000000000
  AND p.STATUS = 'AVAILABLE'
ORDER BY p.PRICE;


-- ============================================================
-- 8. TÌM CĂN HỘ THEO DIỆN TÍCH
-- ============================================================

SELECT
    p.PROPERTY_ID,
    p.TITLE,
    a.AREA,
    a.BEDROOMS,
    a.BATHROOMS,
    p.PRICE
FROM PROPERTIES p
         JOIN APARTMENTS a
              ON p.APARTMENT_ID = a.APARTMENT_ID
WHERE a.AREA >= 70
ORDER BY a.AREA DESC;


-- ============================================================
-- 9. TÌM CĂN HỘ THEO SỐ PHÒNG NGỦ
-- ============================================================

SELECT
    p.PROPERTY_ID,
    p.TITLE,
    a.BEDROOMS,
    a.BATHROOMS,
    a.AREA,
    p.PRICE
FROM PROPERTIES p
         JOIN APARTMENTS a
              ON p.APARTMENT_ID = a.APARTMENT_ID
WHERE a.BEDROOMS = 3
  AND p.STATUS = 'AVAILABLE'
ORDER BY p.PRICE;


-- ============================================================
-- 10. DANH SÁCH FAVORITES CỦA KHÁCH HÀNG
-- ============================================================

SELECT
    u.USERNAME,
    p.PROPERTY_ID,
    p.TITLE,
    p.PRICE,
    f.CREATED_AT
FROM FAVORITES f
         JOIN CUSTOMERS c
              ON f.CUSTOMER_ID = c.CUSTOMER_ID
         JOIN USERS u
              ON c.CUSTOMER_ID = u.USER_ID
         JOIN PROPERTIES p
              ON f.PROPERTY_ID = p.PROPERTY_ID
ORDER BY f.CREATED_AT DESC;


-- ============================================================
-- 11. DANH SÁCH GIAO DỊCH
-- ============================================================

SELECT
    t.TRANSACTION_ID,
    t.TRANSACTION_CODE,

    customer.USERNAME AS CUSTOMER,

    l.LISTING_CODE,
    p.TITLE,

    t.LISTING_PRICE,
    t.AGREED_PRICE,
    t.DEPOSIT_AMOUNT,
    t.REMAINING_AMOUNT,

    t.PAYMENT_METHOD,
    t.PAYMENT_STATUS,
    t.STATUS,

    t.TRANSACTION_DATE,
    t.CONTRACT_DATE,
    t.COMPLETION_DATE

FROM TRANSACTIONS t

         JOIN CUSTOMERS c
              ON t.CUSTOMER_ID = c.CUSTOMER_ID

         JOIN USERS customer
              ON c.CUSTOMER_ID = customer.USER_ID

         JOIN LISTINGS l
              ON t.LISTING_ID = l.LISTING_ID

         JOIN PROPERTIES p
              ON l.PROPERTY_ID = p.PROPERTY_ID

ORDER BY t.TRANSACTION_DATE DESC;


-- ============================================================
-- 12. CHI TIẾT CÁC LẦN THANH TOÁN
-- ============================================================

SELECT
    t.TRANSACTION_CODE,

    p.PAYMENT_CODE,
    p.AMOUNT,
    p.PAYMENT_TYPE,
    p.PAYMENT_METHOD,
    p.PAYMENT_DATE,
    p.REFERENCE_NUMBER,
    p.STATUS,
    p.NOTE

FROM PAYMENTS p

         JOIN TRANSACTIONS t
              ON p.TRANSACTION_ID = t.TRANSACTION_ID

ORDER BY
    t.TRANSACTION_CODE,
    p.PAYMENT_DATE;


-- ============================================================
-- 13. TỔNG TIỀN ĐÃ THANH TOÁN CHO TỪNG GIAO DỊCH
-- ============================================================

SELECT
    t.TRANSACTION_CODE,
    t.AGREED_PRICE,

    NVL(
            SUM(
                    CASE
                        WHEN p.STATUS = 'SUCCESS'
                            AND p.PAYMENT_TYPE <> 'REFUND'
                            THEN p.AMOUNT
                        ELSE 0
                        END
            ),
            0
    ) AS TOTAL_PAID,

    t.REMAINING_AMOUNT

FROM TRANSACTIONS t

         LEFT JOIN PAYMENTS p
                   ON t.TRANSACTION_ID = p.TRANSACTION_ID

GROUP BY
    t.TRANSACTION_CODE,
    t.AGREED_PRICE,
    t.REMAINING_AMOUNT

ORDER BY t.TRANSACTION_CODE;


-- ============================================================
-- 14. GIAO DỊCH ĐÃ HOÀN TẤT
-- ============================================================

SELECT
    t.TRANSACTION_CODE,
    u.USERNAME AS CUSTOMER,
    p.TITLE,
    t.AGREED_PRICE,
    t.COMPLETION_DATE,
    t.PAYMENT_STATUS,
    t.STATUS
FROM TRANSACTIONS t
         JOIN CUSTOMERS c
              ON t.CUSTOMER_ID = c.CUSTOMER_ID
         JOIN USERS u
              ON c.CUSTOMER_ID = u.USER_ID
         JOIN LISTINGS l
              ON t.LISTING_ID = l.LISTING_ID
         JOIN PROPERTIES p
              ON l.PROPERTY_ID = p.PROPERTY_ID
WHERE t.STATUS = 'COMPLETED'
ORDER BY t.COMPLETION_DATE DESC;


-- ============================================================
-- 15. GIAO DỊCH ĐANG CHỜ XỬ LÝ
-- ============================================================

SELECT
    t.TRANSACTION_CODE,
    u.USERNAME AS CUSTOMER,
    p.TITLE,
    t.AGREED_PRICE,
    t.DEPOSIT_AMOUNT,
    t.REMAINING_AMOUNT,
    t.PAYMENT_STATUS,
    t.STATUS
FROM TRANSACTIONS t
         JOIN CUSTOMERS c
              ON t.CUSTOMER_ID = c.CUSTOMER_ID
         JOIN USERS u
              ON c.CUSTOMER_ID = u.USER_ID
         JOIN LISTINGS l
              ON t.LISTING_ID = l.LISTING_ID
         JOIN PROPERTIES p
              ON l.PROPERTY_ID = p.PROPERTY_ID
WHERE t.STATUS IN ('PENDING', 'DEPOSITED', 'PROCESSING')
ORDER BY t.TRANSACTION_DATE DESC;


-- ============================================================
-- 16. DOANH THU ĐÃ HOÀN TẤT
-- ============================================================

SELECT
    COUNT(*) AS COMPLETED_TRANSACTIONS,
    NVL(SUM(AGREED_PRICE), 0) AS TOTAL_REVENUE
FROM TRANSACTIONS
WHERE STATUS = 'COMPLETED';


-- ============================================================
-- 17. DOANH THU THEO TỪNG THÁNG
-- ============================================================

SELECT
    TO_CHAR(COMPLETION_DATE, 'YYYY-MM') AS MONTH,
    COUNT(*) AS TRANSACTION_COUNT,
    SUM(AGREED_PRICE) AS TOTAL_REVENUE
FROM TRANSACTIONS
WHERE STATUS = 'COMPLETED'
GROUP BY TO_CHAR(COMPLETION_DATE, 'YYYY-MM')
ORDER BY MONTH;


-- ============================================================
-- 18. SỐ LƯỢNG CĂN HỘ THEO TRẠNG THÁI
-- ============================================================

SELECT
    STATUS,
    COUNT(*) AS TOTAL_APARTMENTS
FROM APARTMENTS
GROUP BY STATUS
ORDER BY STATUS;


-- ============================================================
-- 19. SỐ LƯỢNG TIN ĐĂNG THEO OWNER
-- ============================================================

SELECT
    u.USERNAME AS OWNER,
    COUNT(l.LISTING_ID) AS TOTAL_LISTINGS
FROM OWNERS o
         JOIN USERS u
              ON o.OWNER_ID = u.USER_ID
         LEFT JOIN LISTINGS l
                   ON o.OWNER_ID = l.OWNER_ID
GROUP BY u.USERNAME
ORDER BY TOTAL_LISTINGS DESC;


-- ============================================================
-- 20. TOP CĂN HỘ ĐƯỢC YÊU THÍCH
-- ============================================================

SELECT
    p.PROPERTY_ID,
    p.TITLE,
    COUNT(f.CUSTOMER_ID) AS FAVORITE_COUNT
FROM PROPERTIES p
         LEFT JOIN FAVORITES f
                   ON p.PROPERTY_ID = f.PROPERTY_ID
GROUP BY
    p.PROPERTY_ID,
    p.TITLE
ORDER BY FAVORITE_COUNT DESC;


-- ============================================================
-- 21. ĐÁNH GIÁ CĂN HỘ
-- ============================================================

SELECT
    p.PROPERTY_ID,
    p.TITLE,
    ROUND(AVG(r.RATING), 2) AS AVERAGE_RATING,
    COUNT(r.REVIEW_ID) AS REVIEW_COUNT
FROM PROPERTIES p
         LEFT JOIN REVIEWS r
                   ON p.PROPERTY_ID = r.PROPERTY_ID
GROUP BY
    p.PROPERTY_ID,
    p.TITLE
ORDER BY AVERAGE_RATING DESC NULLS LAST;


-- ============================================================
-- 22. DASHBOARD TỔNG QUAN
-- ============================================================

SELECT
    (SELECT COUNT(*)
     FROM BUILDINGS
     WHERE STATUS = 'ACTIVE') AS TOTAL_BUILDINGS,

    (SELECT COUNT(*)
     FROM APARTMENTS) AS TOTAL_APARTMENTS,

    (SELECT COUNT(*)
     FROM PROPERTIES
     WHERE STATUS = 'AVAILABLE') AS AVAILABLE_PROPERTIES,

    (SELECT COUNT(*)
     FROM LISTINGS
     WHERE STATUS = 'ACTIVE') AS ACTIVE_LISTINGS,

    (SELECT COUNT(*)
     FROM TRANSACTIONS
     WHERE STATUS = 'COMPLETED') AS COMPLETED_TRANSACTIONS,

    (SELECT NVL(SUM(AGREED_PRICE), 0)
     FROM TRANSACTIONS
     WHERE STATUS = 'COMPLETED') AS TOTAL_REVENUE,

    (SELECT NVL(SUM(AMOUNT), 0)
     FROM PAYMENTS
     WHERE STATUS = 'SUCCESS'
       AND PAYMENT_TYPE <> 'REFUND') AS TOTAL_PAID;


-- ============================================================
-- 23. THÔNG TIN ĐẦY ĐỦ: BUILDING -> APARTMENT -> LISTING
-- ============================================================

SELECT
    b.BUILDING_NAME,
    b.DISTRICT,

    a.APARTMENT_CODE,
    a.FLOOR_NUMBER,
    a.AREA,
    a.BEDROOMS,
    a.BATHROOMS,

    p.TITLE,
    p.PRICE,

    l.LISTING_CODE,
    l.ASKING_PRICE,
    l.STATUS AS LISTING_STATUS

FROM BUILDINGS b

         JOIN APARTMENTS a
              ON b.BUILDING_ID = a.BUILDING_ID

         JOIN PROPERTIES p
              ON a.APARTMENT_ID = p.APARTMENT_ID

         LEFT JOIN LISTINGS l
                   ON p.PROPERTY_ID = l.PROPERTY_ID

ORDER BY
    b.BUILDING_NAME,
    a.FLOOR_NUMBER;


-- ============================================================
-- 24. KHÁCH HÀNG + GIAO DỊCH + CĂN HỘ
-- ============================================================

SELECT
    u.USERNAME AS CUSTOMER,
    u.EMAIL,

    t.TRANSACTION_CODE,

    b.BUILDING_NAME,
    a.APARTMENT_CODE,

    p.TITLE,

    t.AGREED_PRICE,
    t.DEPOSIT_AMOUNT,
    t.REMAINING_AMOUNT,

    t.PAYMENT_STATUS,
    t.STATUS

FROM TRANSACTIONS t

         JOIN CUSTOMERS c
              ON t.CUSTOMER_ID = c.CUSTOMER_ID

         JOIN USERS u
              ON c.CUSTOMER_ID = u.USER_ID

         JOIN LISTINGS l
              ON t.LISTING_ID = l.LISTING_ID

         JOIN PROPERTIES p
              ON l.PROPERTY_ID = p.PROPERTY_ID

         JOIN APARTMENTS a
              ON p.APARTMENT_ID = a.APARTMENT_ID

         JOIN BUILDINGS b
              ON a.BUILDING_ID = b.BUILDING_ID

ORDER BY t.TRANSACTION_DATE DESC;


-- ============================================================
-- 25. OWNER + TIN ĐĂNG + CĂN HỘ
-- ============================================================

SELECT
    u.USERNAME AS OWNER,
    l.LISTING_CODE,

    b.BUILDING_NAME,
    a.APARTMENT_CODE,

    p.TITLE,
    l.ASKING_PRICE,
    l.STATUS

FROM LISTINGS l

         JOIN OWNERS o
              ON l.OWNER_ID = o.OWNER_ID

         JOIN USERS u
              ON o.OWNER_ID = u.USER_ID

         JOIN PROPERTIES p
              ON l.PROPERTY_ID = p.PROPERTY_ID

         JOIN APARTMENTS a
              ON p.APARTMENT_ID = a.APARTMENT_ID

         JOIN BUILDINGS b
              ON a.BUILDING_ID = b.BUILDING_ID

ORDER BY l.POST_DATE DESC;