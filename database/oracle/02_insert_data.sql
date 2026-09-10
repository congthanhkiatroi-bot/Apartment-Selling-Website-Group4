-- ============================================================
-- 02_INSERT_DATA.SQL
-- SAMPLE DATA - APARTMENT SELLING WEBSITE
-- ============================================================

-- ============================================================
-- 1. USERS
-- ============================================================

INSERT INTO USERS
(USERNAME, EMAIL, PASSWORD_HASH, ROLE)
VALUES
    ('admin', 'admin@gmail.com', 'admin_hash', 'ADMIN');

INSERT INTO USERS
(USERNAME, EMAIL, PASSWORD_HASH, ROLE)
VALUES
    ('customer01', 'customer01@gmail.com', 'customer_hash_01', 'CUSTOMER');

INSERT INTO USERS
(USERNAME, EMAIL, PASSWORD_HASH, ROLE)
VALUES
    ('customer02', 'customer02@gmail.com', 'customer_hash_02', 'CUSTOMER');

INSERT INTO USERS
(USERNAME, EMAIL, PASSWORD_HASH, ROLE)
VALUES
    ('customer03', 'customer03@gmail.com', 'customer_hash_03', 'CUSTOMER');

INSERT INTO USERS
(USERNAME, EMAIL, PASSWORD_HASH, ROLE)
VALUES
    ('owner01', 'owner01@gmail.com', 'owner_hash_01', 'OWNER');

INSERT INTO USERS
(USERNAME, EMAIL, PASSWORD_HASH, ROLE)
VALUES
    ('owner02', 'owner02@gmail.com', 'owner_hash_02', 'OWNER');


-- ============================================================
-- 2. CUSTOMERS
-- ============================================================

INSERT INTO CUSTOMERS
(CUSTOMER_ID)
SELECT USER_ID
FROM USERS
WHERE USERNAME = 'customer01';

INSERT INTO CUSTOMERS
(CUSTOMER_ID)
SELECT USER_ID
FROM USERS
WHERE USERNAME = 'customer02';

INSERT INTO CUSTOMERS
(CUSTOMER_ID)
SELECT USER_ID
FROM USERS
WHERE USERNAME = 'customer03';


-- ============================================================
-- 3. OWNERS
-- ============================================================

INSERT INTO OWNERS
(OWNER_ID, TAX_CODE)
SELECT USER_ID, '0312345678'
FROM USERS
WHERE USERNAME = 'owner01';

INSERT INTO OWNERS
(OWNER_ID, TAX_CODE)
SELECT USER_ID, '0312345679'
FROM USERS
WHERE USERNAME = 'owner02';


-- ============================================================
-- 4. CUSTOMER LOCATIONS
-- ============================================================

INSERT INTO CUSTOMER_LOCATIONS
(CUSTOMER_ID, LOCATION_NAME)
SELECT USER_ID, 'Thu Duc'
FROM USERS
WHERE USERNAME = 'customer01';

INSERT INTO CUSTOMER_LOCATIONS
(CUSTOMER_ID, LOCATION_NAME)
SELECT USER_ID, 'District 1'
FROM USERS
WHERE USERNAME = 'customer02';

INSERT INTO CUSTOMER_LOCATIONS
(CUSTOMER_ID, LOCATION_NAME)
SELECT USER_ID, 'Binh Thanh'
FROM USERS
WHERE USERNAME = 'customer03';


-- ============================================================
-- 5. BUILDINGS
-- ============================================================

INSERT INTO BUILDINGS
(
    BUILDING_CODE,
    BUILDING_NAME,
    ADDRESS,
    WARD,
    DISTRICT,
    CITY,
    TOTAL_FLOORS,
    TOTAL_APARTMENTS,
    YEAR_BUILT,
    DESCRIPTION,
    STATUS
)
VALUES
    (
        'B001',
        'Vinhomes Grand Park - S9.01',
        'Nguyen Xien',
        'Long Binh',
        'Thu Duc',
        'Ho Chi Minh City',
        36,
        500,
        2024,
        'Chung cu cao cap gan cong vien Grand Park.',
        'ACTIVE'
    );

INSERT INTO BUILDINGS
(
    BUILDING_CODE,
    BUILDING_NAME,
    ADDRESS,
    WARD,
    DISTRICT,
    CITY,
    TOTAL_FLOORS,
    TOTAL_APARTMENTS,
    YEAR_BUILT,
    DESCRIPTION,
    STATUS
)
VALUES
    (
        'B002',
        'Masteri Thao Dien',
        '159 Xa Lo Ha Noi',
        'Thao Dien',
        'Thu Duc',
        'Ho Chi Minh City',
        41,
        600,
        2023,
        'Can ho cao cap khu Thao Dien.',
        'ACTIVE'
    );

INSERT INTO BUILDINGS
(
    BUILDING_CODE,
    BUILDING_NAME,
    ADDRESS,
    WARD,
    DISTRICT,
    CITY,
    TOTAL_FLOORS,
    TOTAL_APARTMENTS,
    YEAR_BUILT,
    DESCRIPTION,
    STATUS
)
VALUES
    (
        'B003',
        'Sunrise City',
        '23 Nguyen Huu Tho',
        'Tan Hung',
        'District 7',
        'Ho Chi Minh City',
        35,
        450,
        2022,
        'Khu can ho hien dai gan trung tam District 7.',
        'ACTIVE'
    );


-- ============================================================
-- 6. APARTMENTS
-- ============================================================

-- B001
INSERT INTO APARTMENTS
(
    BUILDING_ID,
    APARTMENT_CODE,
    FLOOR_NUMBER,
    ROOM_NUMBER,
    AREA,
    BEDROOMS,
    BATHROOMS,
    BALCONY_AREA,
    DIRECTION,
    VIEW_TYPE,
    LEGAL_STATUS,
    STATUS
)
SELECT
    BUILDING_ID,
    'S9.01-1205',
    12,
    '05',
    68.5,
    2,
    2,
    5.2,
    'Dong Nam',
    'View cong vien',
    'CERTIFIED',
    'AVAILABLE'
FROM BUILDINGS
WHERE BUILDING_CODE = 'B001';


INSERT INTO APARTMENTS
(
    BUILDING_ID,
    APARTMENT_CODE,
    FLOOR_NUMBER,
    ROOM_NUMBER,
    AREA,
    BEDROOMS,
    BATHROOMS,
    BALCONY_AREA,
    DIRECTION,
    VIEW_TYPE,
    LEGAL_STATUS,
    STATUS
)
SELECT
    BUILDING_ID,
    'S9.01-1808',
    18,
    '08',
    75.2,
    3,
    2,
    6.0,
    'Nam',
    'View thanh pho',
    'CERTIFIED',
    'AVAILABLE'
FROM BUILDINGS
WHERE BUILDING_CODE = 'B001';


-- B002
INSERT INTO APARTMENTS
(
    BUILDING_ID,
    APARTMENT_CODE,
    FLOOR_NUMBER,
    ROOM_NUMBER,
    AREA,
    BEDROOMS,
    BATHROOMS,
    BALCONY_AREA,
    DIRECTION,
    VIEW_TYPE,
    LEGAL_STATUS,
    STATUS
)
SELECT
    BUILDING_ID,
    'MT-2506',
    25,
    '06',
    82.3,
    3,
    2,
    7.0,
    'Dong',
    'View song',
    'CERTIFIED',
    'AVAILABLE'
FROM BUILDINGS
WHERE BUILDING_CODE = 'B002';


INSERT INTO APARTMENTS
(
    BUILDING_ID,
    APARTMENT_CODE,
    FLOOR_NUMBER,
    ROOM_NUMBER,
    AREA,
    BEDROOMS,
    BATHROOMS,
    BALCONY_AREA,
    DIRECTION,
    VIEW_TYPE,
    LEGAL_STATUS,
    STATUS
)
SELECT
    BUILDING_ID,
    'MT-1503',
    15,
    '03',
    65.7,
    2,
    2,
    5.0,
    'Tay Nam',
    'View noi khu',
    'CERTIFIED',
    'AVAILABLE'
FROM BUILDINGS
WHERE BUILDING_CODE = 'B002';


-- B003
INSERT INTO APARTMENTS
(
    BUILDING_ID,
    APARTMENT_CODE,
    FLOOR_NUMBER,
    ROOM_NUMBER,
    AREA,
    BEDROOMS,
    BATHROOMS,
    BALCONY_AREA,
    DIRECTION,
    VIEW_TYPE,
    LEGAL_STATUS,
    STATUS
)
SELECT
    BUILDING_ID,
    'SC-2001',
    20,
    '01',
    90.5,
    3,
    2,
    8.0,
    'Dong Nam',
    'View thanh pho',
    'CERTIFIED',
    'AVAILABLE'
FROM BUILDINGS
WHERE BUILDING_CODE = 'B003';


-- ============================================================
-- 7. PROPERTIES
-- ============================================================

INSERT INTO PROPERTIES
(
    APARTMENT_ID,
    TITLE,
    PRICE,
    PRICE_PER_M2,
    DESCRIPTION,
    ADDRESS,
    STATUS
)
SELECT
    APARTMENT_ID,
    'Can ho 2PN Vinhomes Grand Park',
    3200000000,
    46715328,
    'Can ho 2 phong ngu, view cong vien, noi that dep.',
    'Nguyen Xien, Long Binh, Thu Duc, Ho Chi Minh City',
    'AVAILABLE'
FROM APARTMENTS
WHERE APARTMENT_CODE = 'S9.01-1205';


INSERT INTO PROPERTIES
(
    APARTMENT_ID,
    TITLE,
    PRICE,
    PRICE_PER_M2,
    DESCRIPTION,
    ADDRESS,
    STATUS
)
SELECT
    APARTMENT_ID,
    'Can ho 3PN Vinhomes Grand Park',
    3900000000,
    51861702,
    'Can ho 3 phong ngu tang cao, view thanh pho.',
    'Nguyen Xien, Long Binh, Thu Duc, Ho Chi Minh City',
    'AVAILABLE'
FROM APARTMENTS
WHERE APARTMENT_CODE = 'S9.01-1808';


INSERT INTO PROPERTIES
(
    APARTMENT_ID,
    TITLE,
    PRICE,
    PRICE_PER_M2,
    DESCRIPTION,
    ADDRESS,
    STATUS
)
SELECT
    APARTMENT_ID,
    'Can ho 3PN Masteri Thao Dien',
    5200000000,
    63183475,
    'Can ho cao cap 3PN view song.',
    'Xa Lo Ha Noi, Thao Dien, Thu Duc, Ho Chi Minh City',
    'AVAILABLE'
FROM APARTMENTS
WHERE APARTMENT_CODE = 'MT-2506';


INSERT INTO PROPERTIES
(
    APARTMENT_ID,
    TITLE,
    PRICE,
    PRICE_PER_M2,
    DESCRIPTION,
    ADDRESS,
    STATUS
)
SELECT
    APARTMENT_ID,
    'Can ho 2PN Masteri Thao Dien',
    4200000000,
    63926941,
    'Can ho 2PN view noi khu.',
    'Xa Lo Ha Noi, Thao Dien, Thu Duc, Ho Chi Minh City',
    'AVAILABLE'
FROM APARTMENTS
WHERE APARTMENT_CODE = 'MT-1503';


INSERT INTO PROPERTIES
(
    APARTMENT_ID,
    TITLE,
    PRICE,
    PRICE_PER_M2,
    DESCRIPTION,
    ADDRESS,
    STATUS
)
SELECT
    APARTMENT_ID,
    'Can ho 3PN Sunrise City',
    5800000000,
    64088398,
    'Can ho 3PN dien tich lon, noi that cao cap.',
    'Nguyen Huu Tho, Tan Hung, District 7, Ho Chi Minh City',
    'AVAILABLE'
FROM APARTMENTS
WHERE APARTMENT_CODE = 'SC-2001';


-- ============================================================
-- 8. PROPERTY IMAGES
-- ============================================================

INSERT INTO PROPERTY_IMAGES
(PROPERTY_ID, IMAGE_URL, IS_THUMBNAIL)
SELECT
    PROPERTY_ID,
    'images/vinhomes-1.jpg',
    1
FROM PROPERTIES
WHERE TITLE = 'Can ho 2PN Vinhomes Grand Park';

INSERT INTO PROPERTY_IMAGES
(PROPERTY_ID, IMAGE_URL, IS_THUMBNAIL)
SELECT
    PROPERTY_ID,
    'images/vinhomes-1-detail.jpg',
    0
FROM PROPERTIES
WHERE TITLE = 'Can ho 2PN Vinhomes Grand Park';


INSERT INTO PROPERTY_IMAGES
(PROPERTY_ID, IMAGE_URL, IS_THUMBNAIL)
SELECT
    PROPERTY_ID,
    'images/vinhomes-2.jpg',
    1
FROM PROPERTIES
WHERE TITLE = 'Can ho 3PN Vinhomes Grand Park';


INSERT INTO PROPERTY_IMAGES
(PROPERTY_ID, IMAGE_URL, IS_THUMBNAIL)
SELECT
    PROPERTY_ID,
    'images/masteri-1.jpg',
    1
FROM PROPERTIES
WHERE TITLE = 'Can ho 3PN Masteri Thao Dien';


INSERT INTO PROPERTY_IMAGES
(PROPERTY_ID, IMAGE_URL, IS_THUMBNAIL)
SELECT
    PROPERTY_ID,
    'images/masteri-2.jpg',
    1
FROM PROPERTIES
WHERE TITLE = 'Can ho 2PN Masteri Thao Dien';


INSERT INTO PROPERTY_IMAGES
(PROPERTY_ID, IMAGE_URL, IS_THUMBNAIL)
SELECT
    PROPERTY_ID,
    'images/sunrise-1.jpg',
    1
FROM PROPERTIES
WHERE TITLE = 'Can ho 3PN Sunrise City';


-- ============================================================
-- 9. LISTINGS
-- ============================================================

INSERT INTO LISTINGS
(
    LISTING_CODE,
    OWNER_ID,
    PROPERTY_ID,
    LISTING_TITLE,
    ASKING_PRICE,
    DESCRIPTION,
    POST_DATE,
    EXPIRY_DATE,
    STATUS
)
SELECT
    'LIST-0001',
    o.OWNER_ID,
    p.PROPERTY_ID,
    p.TITLE,
    p.PRICE,
    p.DESCRIPTION,
    SYSTIMESTAMP,
    SYSTIMESTAMP + INTERVAL '90' DAY,
    'ACTIVE'
FROM OWNERS o
         CROSS JOIN PROPERTIES p
WHERE o.OWNER_ID = (
    SELECT USER_ID
    FROM USERS
    WHERE USERNAME = 'owner01'
)
  AND p.TITLE = 'Can ho 2PN Vinhomes Grand Park';


INSERT INTO LISTINGS
(
    LISTING_CODE,
    OWNER_ID,
    PROPERTY_ID,
    LISTING_TITLE,
    ASKING_PRICE,
    DESCRIPTION,
    POST_DATE,
    EXPIRY_DATE,
    STATUS
)
SELECT
    'LIST-0002',
    o.OWNER_ID,
    p.PROPERTY_ID,
    p.TITLE,
    p.PRICE,
    p.DESCRIPTION,
    SYSTIMESTAMP,
    SYSTIMESTAMP + INTERVAL '90' DAY,
    'ACTIVE'
FROM OWNERS o
         CROSS JOIN PROPERTIES p
WHERE o.OWNER_ID = (
    SELECT USER_ID
    FROM USERS
    WHERE USERNAME = 'owner01'
)
  AND p.TITLE = 'Can ho 3PN Vinhomes Grand Park';


INSERT INTO LISTINGS
(
    LISTING_CODE,
    OWNER_ID,
    PROPERTY_ID,
    LISTING_TITLE,
    ASKING_PRICE,
    DESCRIPTION,
    POST_DATE,
    EXPIRY_DATE,
    STATUS
)
SELECT
    'LIST-0003',
    o.OWNER_ID,
    p.PROPERTY_ID,
    p.TITLE,
    p.PRICE,
    p.DESCRIPTION,
    SYSTIMESTAMP,
    SYSTIMESTAMP + INTERVAL '90' DAY,
    'ACTIVE'
FROM OWNERS o
         CROSS JOIN PROPERTIES p
WHERE o.OWNER_ID = (
    SELECT USER_ID
    FROM USERS
    WHERE USERNAME = 'owner02'
)
  AND p.TITLE = 'Can ho 3PN Masteri Thao Dien';


INSERT INTO LISTINGS
(
    LISTING_CODE,
    OWNER_ID,
    PROPERTY_ID,
    LISTING_TITLE,
    ASKING_PRICE,
    DESCRIPTION,
    POST_DATE,
    EXPIRY_DATE,
    STATUS
)
SELECT
    'LIST-0004',
    o.OWNER_ID,
    p.PROPERTY_ID,
    p.TITLE,
    p.PRICE,
    p.DESCRIPTION,
    SYSTIMESTAMP,
    SYSTIMESTAMP + INTERVAL '90' DAY,
    'ACTIVE'
FROM OWNERS o
         CROSS JOIN PROPERTIES p
WHERE o.OWNER_ID = (
    SELECT USER_ID
    FROM USERS
    WHERE USERNAME = 'owner02'
)
  AND p.TITLE = 'Can ho 2PN Masteri Thao Dien';


INSERT INTO LISTINGS
(
    LISTING_CODE,
    OWNER_ID,
    PROPERTY_ID,
    LISTING_TITLE,
    ASKING_PRICE,
    DESCRIPTION,
    POST_DATE,
    EXPIRY_DATE,
    STATUS
)
SELECT
    'LIST-0005',
    o.OWNER_ID,
    p.PROPERTY_ID,
    p.TITLE,
    p.PRICE,
    p.DESCRIPTION,
    SYSTIMESTAMP,
    SYSTIMESTAMP + INTERVAL '90' DAY,
    'ACTIVE'
FROM OWNERS o
         CROSS JOIN PROPERTIES p
WHERE o.OWNER_ID = (
    SELECT USER_ID
    FROM USERS
    WHERE USERNAME = 'owner01'
)
  AND p.TITLE = 'Can ho 3PN Sunrise City';


-- ============================================================
-- 10. FAVORITES
-- ============================================================

INSERT INTO FAVORITES
(CUSTOMER_ID, PROPERTY_ID)
SELECT
    c.CUSTOMER_ID,
    p.PROPERTY_ID
FROM CUSTOMERS c
         CROSS JOIN PROPERTIES p
WHERE c.CUSTOMER_ID = (
    SELECT USER_ID
    FROM USERS
    WHERE USERNAME = 'customer01'
)
  AND p.TITLE = 'Can ho 3PN Masteri Thao Dien';


INSERT INTO FAVORITES
(CUSTOMER_ID, PROPERTY_ID)
SELECT
    c.CUSTOMER_ID,
    p.PROPERTY_ID
FROM CUSTOMERS c
         CROSS JOIN PROPERTIES p
WHERE c.CUSTOMER_ID = (
    SELECT USER_ID
    FROM USERS
    WHERE USERNAME = 'customer02'
)
  AND p.TITLE = 'Can ho 2PN Vinhomes Grand Park';


-- ============================================================
-- 11. TRANSACTION 1 - HOÀN TẤT
-- ============================================================

INSERT INTO TRANSACTIONS
(
    TRANSACTION_CODE,
    CUSTOMER_ID,
    LISTING_ID,
    TRANSACTION_TYPE,
    LISTING_PRICE,
    AGREED_PRICE,
    DEPOSIT_AMOUNT,
    REMAINING_AMOUNT,
    PAYMENT_METHOD,
    PAYMENT_STATUS,
    STATUS,
    CONTRACT_DATE,
    COMPLETION_DATE,
    NOTE
)
SELECT
    'TXN-0001',
    c.CUSTOMER_ID,
    l.LISTING_ID,
    'PURCHASE',
    l.ASKING_PRICE,
    3100000000,
    300000000,
    0,
    'BANK_TRANSFER',
    'PENDING',
    'PENDING',
    SYSTIMESTAMP - INTERVAL '20' DAY,
    NULL,
    'Giao dich mua can ho Vinhomes'
FROM CUSTOMERS c
         CROSS JOIN LISTINGS l
WHERE c.CUSTOMER_ID = (
    SELECT USER_ID
    FROM USERS
    WHERE USERNAME = 'customer01'
)
  AND l.LISTING_CODE = 'LIST-0001';


-- ============================================================
-- 12. PAYMENTS FOR TRANSACTION 1
-- ============================================================

INSERT INTO PAYMENTS
(
    TRANSACTION_ID,
    PAYMENT_CODE,
    AMOUNT,
    PAYMENT_TYPE,
    PAYMENT_METHOD,
    PAYMENT_DATE,
    REFERENCE_NUMBER,
    STATUS,
    NOTE
)
SELECT
    TRANSACTION_ID,
    'PAY-0001',
    300000000,
    'DEPOSIT',
    'BANK_TRANSFER',
    SYSTIMESTAMP - INTERVAL '20' DAY,
    'VCB202609010001',
    'SUCCESS',
    'Thanh toan dat coc'
FROM TRANSACTIONS
WHERE TRANSACTION_CODE = 'TXN-0001';


INSERT INTO PAYMENTS
(
    TRANSACTION_ID,
    PAYMENT_CODE,
    AMOUNT,
    PAYMENT_TYPE,
    PAYMENT_METHOD,
    PAYMENT_DATE,
    REFERENCE_NUMBER,
    STATUS,
    NOTE
)
SELECT
    TRANSACTION_ID,
    'PAY-0002',
    1000000000,
    'INSTALLMENT',
    'BANK_TRANSFER',
    SYSTIMESTAMP - INTERVAL '10' DAY,
    'VCB202609100002',
    'SUCCESS',
    'Thanh toan dot 2'
FROM TRANSACTIONS
WHERE TRANSACTION_CODE = 'TXN-0001';


INSERT INTO PAYMENTS
(
    TRANSACTION_ID,
    PAYMENT_CODE,
    AMOUNT,
    PAYMENT_TYPE,
    PAYMENT_METHOD,
    PAYMENT_DATE,
    REFERENCE_NUMBER,
    STATUS,
    NOTE
)
SELECT
    TRANSACTION_ID,
    'PAY-0003',
    1800000000,
    'FINAL',
    'BANK_TRANSFER',
    SYSTIMESTAMP - INTERVAL '2' DAY,
    'VCB202609080003',
    'SUCCESS',
    'Thanh toan day du'
FROM TRANSACTIONS
WHERE TRANSACTION_CODE = 'TXN-0001';


-- ============================================================
-- 13. UPDATE TRANSACTION 1
-- ============================================================

UPDATE TRANSACTIONS
SET STATUS = 'COMPLETED',
    CONTRACT_DATE = SYSTIMESTAMP - INTERVAL '20' DAY,
    COMPLETION_DATE = SYSTIMESTAMP - INTERVAL '2' DAY
WHERE TRANSACTION_CODE = 'TXN-0001';


-- ============================================================
-- 14. TRANSACTION 2 - ĐANG ĐẶT CỌC
-- ============================================================

INSERT INTO TRANSACTIONS
(
    TRANSACTION_CODE,
    CUSTOMER_ID,
    LISTING_ID,
    TRANSACTION_TYPE,
    LISTING_PRICE,
    AGREED_PRICE,
    DEPOSIT_AMOUNT,
    REMAINING_AMOUNT,
    PAYMENT_METHOD,
    PAYMENT_STATUS,
    STATUS,
    NOTE
)
SELECT
    'TXN-0002',
    c.CUSTOMER_ID,
    l.LISTING_ID,
    'PURCHASE',
    l.ASKING_PRICE,
    5000000000,
    500000000,
    4500000000,
    'BANK_TRANSFER',
    'PENDING',
    'PENDING',
    'Khach dang cho xu ly hop dong'
FROM CUSTOMERS c
         CROSS JOIN LISTINGS l
WHERE c.CUSTOMER_ID = (
    SELECT USER_ID
    FROM USERS
    WHERE USERNAME = 'customer02'
)
  AND l.LISTING_CODE = 'LIST-0003';


INSERT INTO PAYMENTS
(
    TRANSACTION_ID,
    PAYMENT_CODE,
    AMOUNT,
    PAYMENT_TYPE,
    PAYMENT_METHOD,
    PAYMENT_DATE,
    REFERENCE_NUMBER,
    STATUS,
    NOTE
)
SELECT
    TRANSACTION_ID,
    'PAY-0004',
    500000000,
    'DEPOSIT',
    'BANK_TRANSFER',
    SYSTIMESTAMP - INTERVAL '3' DAY,
    'MB202609070004',
    'SUCCESS',
    'Dat coc can ho Masteri'
FROM TRANSACTIONS
WHERE TRANSACTION_CODE = 'TXN-0002';


-- ============================================================
-- 15. REVIEWS
-- ============================================================

INSERT INTO REVIEWS
(
    CUSTOMER_ID,
    PROPERTY_ID,
    RATING,
    COMMENT_TEXT
)
SELECT
    c.CUSTOMER_ID,
    p.PROPERTY_ID,
    5,
    'Can ho dep, vi tri tot, quy trinh mua ban nhanh.'
FROM CUSTOMERS c
         CROSS JOIN PROPERTIES p
WHERE c.CUSTOMER_ID = (
    SELECT USER_ID
    FROM USERS
    WHERE USERNAME = 'customer01'
)
  AND p.TITLE = 'Can ho 2PN Vinhomes Grand Park';


-- ============================================================
-- 16. COMMIT
-- ============================================================

COMMIT;