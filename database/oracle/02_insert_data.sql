-- =====================================================
-- APARTMENT WEB - SAMPLE DATA (REVISED)
-- 02_insert_data.sql
-- =====================================================


-- =====================================================
-- USERS
-- Luu y: PASSWORD_HASH duoi day la BCrypt hash cua chuoi '123456'
-- (tao bang BCryptPasswordEncoder ben Java). KHONG luu plaintext.
-- =====================================================

INSERT INTO USERS
(USERNAME, EMAIL, PASSWORD_HASH, ROLE)
VALUES
    ('admin', 'admin@gmail.com', '$2a$10$Nq0m6c9rX3F1jY0m9y6QpeYV6Z0h6pQKq0m8B0m5C0m5C0m5C0m5C', 'ADMIN');


INSERT INTO USERS
(USERNAME, EMAIL, PASSWORD_HASH, ROLE)
VALUES
    ('customer01', 'customer01@gmail.com', '$2a$10$Nq0m6c9rX3F1jY0m9y6QpeYV6Z0h6pQKq0m8B0m5C0m5C0m5C0m5C', 'CUSTOMER');


INSERT INTO USERS
(USERNAME, EMAIL, PASSWORD_HASH, ROLE)
VALUES
    ('customer02', 'customer02@gmail.com', '$2a$10$Nq0m6c9rX3F1jY0m9y6QpeYV6Z0h6pQKq0m8B0m5C0m5C0m5C0m5C', 'CUSTOMER');


INSERT INTO USERS
(USERNAME, EMAIL, PASSWORD_HASH, ROLE)
VALUES
    ('owner01', 'owner01@gmail.com', '$2a$10$Nq0m6c9rX3F1jY0m9y6QpeYV6Z0h6pQKq0m8B0m5C0m5C0m5C0m5C', 'OWNER');


INSERT INTO USERS
(USERNAME, EMAIL, PASSWORD_HASH, ROLE)
VALUES
    ('owner02', 'owner02@gmail.com', '$2a$10$Nq0m6c9rX3F1jY0m9y6QpeYV6Z0h6pQKq0m8B0m5C0m5C0m5C0m5C', 'OWNER');


COMMIT;


-- =====================================================
-- CUSTOMERS
-- =====================================================

INSERT INTO CUSTOMERS (CUSTOMER_ID)
SELECT USER_ID FROM USERS WHERE USERNAME = 'customer01';

INSERT INTO CUSTOMERS (CUSTOMER_ID)
SELECT USER_ID FROM USERS WHERE USERNAME = 'customer02';


-- =====================================================
-- CUSTOMER_LOCATIONS (thay cho cot PREFERRED_LOCATIONS cu)
-- =====================================================

INSERT INTO CUSTOMER_LOCATIONS (CUSTOMER_ID, LOCATION_NAME)
SELECT USER_ID, 'Quan 1' FROM USERS WHERE USERNAME = 'customer01';

INSERT INTO CUSTOMER_LOCATIONS (CUSTOMER_ID, LOCATION_NAME)
SELECT USER_ID, 'Quan 3' FROM USERS WHERE USERNAME = 'customer01';

INSERT INTO CUSTOMER_LOCATIONS (CUSTOMER_ID, LOCATION_NAME)
SELECT USER_ID, 'Binh Thanh' FROM USERS WHERE USERNAME = 'customer01';

INSERT INTO CUSTOMER_LOCATIONS (CUSTOMER_ID, LOCATION_NAME)
SELECT USER_ID, 'Quan 7' FROM USERS WHERE USERNAME = 'customer02';

INSERT INTO CUSTOMER_LOCATIONS (CUSTOMER_ID, LOCATION_NAME)
SELECT USER_ID, 'Thu Duc' FROM USERS WHERE USERNAME = 'customer02';


-- =====================================================
-- OWNERS
-- =====================================================

INSERT INTO OWNERS (OWNER_ID, TAX_CODE)
SELECT USER_ID, '0312345678' FROM USERS WHERE USERNAME = 'owner01';

INSERT INTO OWNERS (OWNER_ID, TAX_CODE)
SELECT USER_ID, '0312345679' FROM USERS WHERE USERNAME = 'owner02';


COMMIT;


-- =====================================================
-- PROPERTIES
-- =====================================================

INSERT INTO PROPERTIES (TITLE, PRICE, AREA, STATUS, DESCRIPTION, ADDRESS)
VALUES
    ('Can ho cao cap Landmark 81', 3500000000, 75.5, 'AVAILABLE',
     'Can ho 2 phong ngu, day du noi that',
     '720A Dien Bien Phu, Binh Thanh, TP.HCM');

INSERT INTO PROPERTIES (TITLE, PRICE, AREA, STATUS, DESCRIPTION, ADDRESS)
VALUES
    ('Can ho 3 phong ngu Vinhomes', 5200000000, 105.2, 'AVAILABLE',
     'Can ho cao cap view thanh pho',
     'Nguyen Huu Canh, Binh Thanh, TP.HCM');

INSERT INTO PROPERTIES (TITLE, PRICE, AREA, STATUS, DESCRIPTION, ADDRESS)
VALUES
    ('Can ho 2 phong ngu Quan 7', 3000000000, 68.5, 'AVAILABLE',
     'Can ho gan trung tam Quan 7',
     'Nguyen Thi Thap, Quan 7, TP.HCM');

INSERT INTO PROPERTIES (TITLE, PRICE, AREA, STATUS, DESCRIPTION, ADDRESS)
VALUES
    ('Toa nha van phong Quan 1', 15000000000, 350, 'AVAILABLE',
     'Toa nha van phong 10 tang',
     'Nguyen Hue, Quan 1, TP.HCM');


COMMIT;


-- =====================================================
-- PROPERTY_IMAGES
-- =====================================================

INSERT INTO PROPERTY_IMAGES (PROPERTY_ID, IMAGE_URL, IS_THUMBNAIL)
SELECT PROPERTY_ID, '/images/landmark81_1.jpg', 1
FROM PROPERTIES WHERE TITLE = 'Can ho cao cap Landmark 81';

INSERT INTO PROPERTY_IMAGES (PROPERTY_ID, IMAGE_URL, IS_THUMBNAIL)
SELECT PROPERTY_ID, '/images/landmark81_2.jpg', 0
FROM PROPERTIES WHERE TITLE = 'Can ho cao cap Landmark 81';

INSERT INTO PROPERTY_IMAGES (PROPERTY_ID, IMAGE_URL, IS_THUMBNAIL)
SELECT PROPERTY_ID, '/images/vinhomes_1.jpg', 1
FROM PROPERTIES WHERE TITLE = 'Can ho 3 phong ngu Vinhomes';

INSERT INTO PROPERTY_IMAGES (PROPERTY_ID, IMAGE_URL, IS_THUMBNAIL)
SELECT PROPERTY_ID, '/images/quan7_1.jpg', 1
FROM PROPERTIES WHERE TITLE = 'Can ho 2 phong ngu Quan 7';

INSERT INTO PROPERTY_IMAGES (PROPERTY_ID, IMAGE_URL, IS_THUMBNAIL)
SELECT PROPERTY_ID, '/images/office_q1_1.jpg', 1
FROM PROPERTIES WHERE TITLE = 'Toa nha van phong Quan 1';


-- =====================================================
-- APARTMENTS
-- =====================================================

INSERT INTO APARTMENTS (PROPERTY_ID, FLOOR_NUMBER, ROOM_NUMBER, BEDROOMS, BATHROOMS)
SELECT PROPERTY_ID, 25, 'A25-01', 2, 2
FROM PROPERTIES WHERE TITLE = 'Can ho cao cap Landmark 81';

INSERT INTO APARTMENTS (PROPERTY_ID, FLOOR_NUMBER, ROOM_NUMBER, BEDROOMS, BATHROOMS)
SELECT PROPERTY_ID, 30, 'B30-05', 3, 2
FROM PROPERTIES WHERE TITLE = 'Can ho 3 phong ngu Vinhomes';

INSERT INTO APARTMENTS (PROPERTY_ID, FLOOR_NUMBER, ROOM_NUMBER, BEDROOMS, BATHROOMS)
SELECT PROPERTY_ID, 15, 'C15-02', 2, 1
FROM PROPERTIES WHERE TITLE = 'Can ho 2 phong ngu Quan 7';


-- =====================================================
-- BUILDINGS
-- =====================================================

INSERT INTO BUILDINGS (PROPERTY_ID, TOTAL_FLOORS)
SELECT PROPERTY_ID, 10
FROM PROPERTIES WHERE TITLE = 'Toa nha van phong Quan 1';


COMMIT;


-- =====================================================
-- FAVORITES
-- =====================================================

INSERT INTO FAVORITES (CUSTOMER_ID, PROPERTY_ID)
SELECT c.CUSTOMER_ID, p.PROPERTY_ID
FROM CUSTOMERS c
         JOIN USERS u ON u.USER_ID = c.CUSTOMER_ID
         CROSS JOIN PROPERTIES p
WHERE u.USERNAME = 'customer01'
  AND p.TITLE = 'Can ho 3 phong ngu Vinhomes';

INSERT INTO FAVORITES (CUSTOMER_ID, PROPERTY_ID)
SELECT c.CUSTOMER_ID, p.PROPERTY_ID
FROM CUSTOMERS c
         JOIN USERS u ON u.USER_ID = c.CUSTOMER_ID
         CROSS JOIN PROPERTIES p
WHERE u.USERNAME = 'customer02'
  AND p.TITLE = 'Can ho cao cap Landmark 81';


COMMIT;


-- =====================================================
-- LISTINGS
-- =====================================================

INSERT INTO LISTINGS (OWNER_ID, PROPERTY_ID, POST_DATE, EXPIRY_DATE, STATUS)
SELECT o.OWNER_ID, p.PROPERTY_ID, SYSTIMESTAMP, SYSTIMESTAMP + INTERVAL '3' MONTH, 'ACTIVE'
FROM OWNERS o CROSS JOIN PROPERTIES p
WHERE o.TAX_CODE = '0312345678' AND p.TITLE = 'Can ho cao cap Landmark 81';

INSERT INTO LISTINGS (OWNER_ID, PROPERTY_ID, POST_DATE, EXPIRY_DATE, STATUS)
SELECT o.OWNER_ID, p.PROPERTY_ID, SYSTIMESTAMP, SYSTIMESTAMP + INTERVAL '3' MONTH, 'ACTIVE'
FROM OWNERS o CROSS JOIN PROPERTIES p
WHERE o.TAX_CODE = '0312345678' AND p.TITLE = 'Can ho 3 phong ngu Vinhomes';

INSERT INTO LISTINGS (OWNER_ID, PROPERTY_ID, POST_DATE, EXPIRY_DATE, STATUS)
SELECT o.OWNER_ID, p.PROPERTY_ID, SYSTIMESTAMP, SYSTIMESTAMP + INTERVAL '2' MONTH, 'ACTIVE'
FROM OWNERS o CROSS JOIN PROPERTIES p
WHERE o.TAX_CODE = '0312345679' AND p.TITLE = 'Can ho 2 phong ngu Quan 7';

INSERT INTO LISTINGS (OWNER_ID, PROPERTY_ID, POST_DATE, EXPIRY_DATE, STATUS)
SELECT o.OWNER_ID, p.PROPERTY_ID, SYSTIMESTAMP, SYSTIMESTAMP + INTERVAL '6' MONTH, 'ACTIVE'
FROM OWNERS o CROSS JOIN PROPERTIES p
WHERE o.TAX_CODE = '0312345679' AND p.TITLE = 'Toa nha van phong Quan 1';


COMMIT;


-- =====================================================
-- TRANSACTIONS
-- Luu y: nho co TRG_TRANSACTION_COMPLETED, khi INSERT/UPDATE STATUS =
-- 'COMPLETED' thi LISTINGS va PROPERTIES tuong ung se tu dong chuyen sang 'SOLD'.
-- =====================================================

INSERT INTO TRANSACTIONS (CUSTOMER_ID, LISTING_ID, AMOUNT, STATUS)
SELECT c.CUSTOMER_ID, l.LISTING_ID, 3500000000, 'PENDING'
FROM CUSTOMERS c
         CROSS JOIN LISTINGS l
         JOIN PROPERTIES p ON p.PROPERTY_ID = l.PROPERTY_ID
WHERE c.CUSTOMER_ID = (SELECT USER_ID FROM USERS WHERE USERNAME = 'customer01')
  AND p.TITLE = 'Can ho cao cap Landmark 81';

INSERT INTO TRANSACTIONS (CUSTOMER_ID, LISTING_ID, AMOUNT, STATUS)
SELECT c.CUSTOMER_ID, l.LISTING_ID, 3000000000, 'COMPLETED'
FROM CUSTOMERS c
         CROSS JOIN LISTINGS l
         JOIN PROPERTIES p ON p.PROPERTY_ID = l.PROPERTY_ID
WHERE c.CUSTOMER_ID = (SELECT USER_ID FROM USERS WHERE USERNAME = 'customer02')
  AND p.TITLE = 'Can ho 2 phong ngu Quan 7';


COMMIT;


-- =====================================================
-- REVIEWS
-- =====================================================

INSERT INTO REVIEWS (CUSTOMER_ID, PROPERTY_ID, RATING, COMMENT_TEXT)
SELECT c.CUSTOMER_ID, p.PROPERTY_ID, 5, 'Can ho dep, vi tri thuan tien.'
FROM CUSTOMERS c CROSS JOIN PROPERTIES p
WHERE c.CUSTOMER_ID = (SELECT USER_ID FROM USERS WHERE USERNAME = 'customer01')
  AND p.TITLE = 'Can ho cao cap Landmark 81';

INSERT INTO REVIEWS (CUSTOMER_ID, PROPERTY_ID, RATING, COMMENT_TEXT)
SELECT c.CUSTOMER_ID, p.PROPERTY_ID, 4, 'Khong gian rong va sach.'
FROM CUSTOMERS c CROSS JOIN PROPERTIES p
WHERE c.CUSTOMER_ID = (SELECT USER_ID FROM USERS WHERE USERNAME = 'customer02')
  AND p.TITLE = 'Can ho cao cap Landmark 81';

INSERT INTO REVIEWS (CUSTOMER_ID, PROPERTY_ID, RATING, COMMENT_TEXT)
SELECT c.CUSTOMER_ID, p.PROPERTY_ID, 5, 'Gia hop ly, vi tri tot.'
FROM CUSTOMERS c CROSS JOIN PROPERTIES p
WHERE c.CUSTOMER_ID = (SELECT USER_ID FROM USERS WHERE USERNAME = 'customer02')
  AND p.TITLE = 'Can ho 2 phong ngu Quan 7';


COMMIT;