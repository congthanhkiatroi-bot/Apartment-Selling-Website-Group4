-- =====================================================
-- APARTMENT WEB - BACKEND QUERIES (REVISED)
-- 03_queries.sql
-- =====================================================


-- =====================================================
-- 1. LOGIN
-- Chi lay USER theo USERNAME, KHONG so sanh password trong SQL.
-- Tang ung dung (Java) se dung BCryptPasswordEncoder.matches(
--   rawPassword, user.getPasswordHash()) de xac thuc.
-- =====================================================

SELECT
    USER_ID,
    USERNAME,
    EMAIL,
    PASSWORD_HASH,
    ROLE,
    CREATED_AT,
    IS_ACTIVE
FROM USERS
WHERE USERNAME = :username
  AND IS_ACTIVE = 1;


-- =====================================================
-- 2. GET USER BY ID
-- =====================================================

SELECT
    USER_ID, USERNAME, EMAIL, ROLE, CREATED_AT, IS_ACTIVE
FROM USERS
WHERE USER_ID = :user_id;


-- =====================================================
-- 3. SEARCH PROPERTY
-- =====================================================

SELECT
    PROPERTY_ID, TITLE, PRICE, AREA, STATUS, DESCRIPTION, ADDRESS, CREATED_AT
FROM PROPERTIES
WHERE LOWER(TITLE) LIKE LOWER(:keyword)
  AND PRICE BETWEEN :min_price AND :max_price
  AND AREA BETWEEN :min_area AND :max_area
  AND STATUS = 'AVAILABLE'
ORDER BY PROPERTY_ID DESC;


-- =====================================================
-- 4. GET ALL AVAILABLE PROPERTIES (kem thumbnail)
-- =====================================================

SELECT
    p.PROPERTY_ID, p.TITLE, p.PRICE, p.AREA, p.STATUS, p.DESCRIPTION, p.ADDRESS,
    img.IMAGE_URL AS THUMBNAIL_URL
FROM PROPERTIES p
         LEFT JOIN PROPERTY_IMAGES img
                   ON img.PROPERTY_ID = p.PROPERTY_ID AND img.IS_THUMBNAIL = 1
WHERE p.STATUS = 'AVAILABLE'
ORDER BY p.PROPERTY_ID DESC;


-- =====================================================
-- 5. GET PROPERTY BY ID
-- =====================================================

SELECT
    PROPERTY_ID, TITLE, PRICE, AREA, STATUS, DESCRIPTION, ADDRESS, CREATED_AT
FROM PROPERTIES
WHERE PROPERTY_ID = :property_id;


-- =====================================================
-- 5b. GET IMAGES OF PROPERTY (moi)
-- =====================================================

SELECT
    IMAGE_ID, IMAGE_URL, IS_THUMBNAIL, UPLOADED_AT
FROM PROPERTY_IMAGES
WHERE PROPERTY_ID = :property_id
ORDER BY IS_THUMBNAIL DESC, IMAGE_ID ASC;


-- =====================================================
-- 6. GET APARTMENT DETAIL
-- =====================================================

SELECT
    p.PROPERTY_ID, p.TITLE, p.PRICE, p.AREA, p.STATUS, p.DESCRIPTION, p.ADDRESS,
    a.FLOOR_NUMBER, a.ROOM_NUMBER, a.BEDROOMS, a.BATHROOMS
FROM PROPERTIES p
         LEFT JOIN APARTMENTS a ON a.PROPERTY_ID = p.PROPERTY_ID
WHERE p.PROPERTY_ID = :property_id;


-- =====================================================
-- 7. GET BUILDING DETAIL
-- =====================================================

SELECT
    p.PROPERTY_ID, p.TITLE, p.PRICE, p.AREA, p.STATUS, p.DESCRIPTION, p.ADDRESS,
    b.TOTAL_FLOORS
FROM PROPERTIES p
         LEFT JOIN BUILDINGS b ON b.PROPERTY_ID = p.PROPERTY_ID
WHERE p.PROPERTY_ID = :property_id;


-- =====================================================
-- 8. INSERT PROPERTY
-- =====================================================

INSERT INTO PROPERTIES (TITLE, PRICE, AREA, STATUS, DESCRIPTION, ADDRESS)
VALUES (:title, :price, :area, :status, :description, :address);


-- =====================================================
-- 9. UPDATE PROPERTY
-- =====================================================

UPDATE PROPERTIES
SET TITLE = :title, PRICE = :price, AREA = :area, STATUS = :status,
    DESCRIPTION = :description, ADDRESS = :address
WHERE PROPERTY_ID = :property_id;


-- =====================================================
-- 10. DELETE PROPERTY
-- Doi tu xoa cung (physical DELETE) sang "soft delete":
-- vi PROPERTIES lien quan LISTINGS/REVIEWS/TRANSACTIONS (khong cascade,
-- co chu dich, xem comment trong 01_create_tables.sql), xoa cung se
-- bao loi FK neu da co du lieu lien quan, va cung lam mat lich su giao dich.
-- => An tin dang bang cach chuyen STATUS = 'HIDDEN'.
-- =====================================================

UPDATE PROPERTIES
SET STATUS = 'HIDDEN'
WHERE PROPERTY_ID = :property_id;

-- Chi dung ban xoa that (hard delete) cho ADMIN, va chi khi property
-- CHUA CO listing/review/transaction nao (kiem tra truoc o tang ung dung):
-- DELETE FROM PROPERTIES WHERE PROPERTY_ID = :property_id;


-- =====================================================
-- 11. GET ACTIVE LISTINGS
-- =====================================================

SELECT
    l.LISTING_ID, l.OWNER_ID, l.PROPERTY_ID, l.POST_DATE, l.EXPIRY_DATE, l.STATUS,
    p.TITLE, p.PRICE, p.AREA, p.ADDRESS
FROM LISTINGS l
         JOIN PROPERTIES p ON p.PROPERTY_ID = l.PROPERTY_ID
WHERE l.STATUS = 'ACTIVE'
  AND p.STATUS = 'AVAILABLE'
ORDER BY l.POST_DATE DESC;


-- =====================================================
-- 12. GET LISTINGS BY OWNER
-- =====================================================

SELECT
    l.LISTING_ID, l.PROPERTY_ID, p.TITLE, p.PRICE, p.AREA,
    p.STATUS AS PROPERTY_STATUS, l.POST_DATE, l.EXPIRY_DATE, l.STATUS AS LISTING_STATUS
FROM LISTINGS l
         JOIN PROPERTIES p ON p.PROPERTY_ID = l.PROPERTY_ID
WHERE l.OWNER_ID = :owner_id
ORDER BY l.POST_DATE DESC;


-- =====================================================
-- 13. CREATE TRANSACTION
-- (Trigger TRG_TRANSACTION_COMPLETED se tu dong cap nhat LISTINGS/PROPERTIES
--  neu STATUS = 'COMPLETED')
-- =====================================================

INSERT INTO TRANSACTIONS (CUSTOMER_ID, LISTING_ID, AMOUNT, TRANSACTION_DATE, STATUS)
VALUES (:customer_id, :listing_id, :amount, SYSTIMESTAMP, 'PENDING');


-- =====================================================
-- 14. GET TRANSACTIONS BY CUSTOMER
-- =====================================================

SELECT
    t.TRANSACTION_ID, t.CUSTOMER_ID, t.LISTING_ID, t.AMOUNT, t.TRANSACTION_DATE, t.STATUS,
    l.PROPERTY_ID, p.TITLE, p.PRICE
FROM TRANSACTIONS t
         JOIN LISTINGS l ON l.LISTING_ID = t.LISTING_ID
         JOIN PROPERTIES p ON p.PROPERTY_ID = l.PROPERTY_ID
WHERE t.CUSTOMER_ID = :customer_id
ORDER BY t.TRANSACTION_DATE DESC;


-- =====================================================
-- 15. UPDATE TRANSACTION STATUS
-- =====================================================

UPDATE TRANSACTIONS
SET STATUS = :status
WHERE TRANSACTION_ID = :transaction_id;


-- =====================================================
-- 16. GET REVIEWS OF PROPERTY
-- =====================================================

SELECT
    r.REVIEW_ID, r.CUSTOMER_ID, u.USERNAME, r.PROPERTY_ID, r.RATING, r.COMMENT_TEXT, r.REVIEW_DATE
FROM REVIEWS r
         JOIN USERS u ON u.USER_ID = r.CUSTOMER_ID
WHERE r.PROPERTY_ID = :property_id
ORDER BY r.REVIEW_DATE DESC;


-- =====================================================
-- 17. ADD REVIEW
-- =====================================================

INSERT INTO REVIEWS (CUSTOMER_ID, PROPERTY_ID, RATING, COMMENT_TEXT)
VALUES (:customer_id, :property_id, :rating, :comment_text);


-- =====================================================
-- 18. AVERAGE RATING
-- =====================================================

SELECT
    PROPERTY_ID, ROUND(AVG(RATING), 2) AS AVERAGE_RATING, COUNT(*) AS REVIEW_COUNT
FROM REVIEWS
WHERE PROPERTY_ID = :property_id
GROUP BY PROPERTY_ID;


-- =====================================================
-- 19a. ADD FAVORITE (moi)
-- =====================================================

INSERT INTO FAVORITES (CUSTOMER_ID, PROPERTY_ID)
VALUES (:customer_id, :property_id);


-- =====================================================
-- 19b. REMOVE FAVORITE (moi)
-- =====================================================

DELETE FROM FAVORITES
WHERE CUSTOMER_ID = :customer_id AND PROPERTY_ID = :property_id;


-- =====================================================
-- 19c. GET FAVORITES BY CUSTOMER (moi)
-- =====================================================

SELECT
    f.PROPERTY_ID, p.TITLE, p.PRICE, p.AREA, p.STATUS, f.CREATED_AT
FROM FAVORITES f
         JOIN PROPERTIES p ON p.PROPERTY_ID = f.PROPERTY_ID
WHERE f.CUSTOMER_ID = :customer_id
ORDER BY f.CREATED_AT DESC;


-- =====================================================
-- 20. CHECK DATABASE
-- =====================================================

SELECT COUNT(*) AS USER_COUNT FROM USERS;
SELECT COUNT(*) AS CUSTOMER_COUNT FROM CUSTOMERS;
SELECT COUNT(*) AS CUSTOMER_LOCATION_COUNT FROM CUSTOMER_LOCATIONS;
SELECT COUNT(*) AS OWNER_COUNT FROM OWNERS;
SELECT COUNT(*) AS PROPERTY_COUNT FROM PROPERTIES;
SELECT COUNT(*) AS PROPERTY_IMAGE_COUNT FROM PROPERTY_IMAGES;
SELECT COUNT(*) AS APARTMENT_COUNT FROM APARTMENTS;
SELECT COUNT(*) AS BUILDING_COUNT FROM BUILDINGS;
SELECT COUNT(*) AS FAVORITE_COUNT FROM FAVORITES;
SELECT COUNT(*) AS LISTING_COUNT FROM LISTINGS;
SELECT COUNT(*) AS TRANSACTION_COUNT FROM TRANSACTIONS;
SELECT COUNT(*) AS REVIEW_COUNT FROM REVIEWS;