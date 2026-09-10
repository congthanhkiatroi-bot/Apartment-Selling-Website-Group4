-- =====================================================
-- APARTMENT WEB - ORACLE DATABASE (REVISED)
-- 01_create_tables.sql
-- =====================================================

-- =========================
-- USERS
-- =========================
CREATE TABLE USERS (
                       USER_ID NUMBER GENERATED ALWAYS AS IDENTITY,
                       USERNAME VARCHAR2(50) NOT NULL,
                       EMAIL VARCHAR2(100) NOT NULL,
                       PASSWORD_HASH VARCHAR2(255) NOT NULL,
                       ROLE VARCHAR2(20) DEFAULT 'CUSTOMER' NOT NULL,
                       CREATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
                       IS_ACTIVE NUMBER(1) DEFAULT 1 NOT NULL,

                       CONSTRAINT PK_USERS PRIMARY KEY (USER_ID),
                       CONSTRAINT UQ_USERS_USERNAME UNIQUE (USERNAME),
                       CONSTRAINT UQ_USERS_EMAIL UNIQUE (EMAIL),
                       CONSTRAINT CK_USERS_ROLE
                           CHECK (ROLE IN ('ADMIN', 'CUSTOMER', 'OWNER')),
                       CONSTRAINT CK_USERS_ACTIVE
                           CHECK (IS_ACTIVE IN (0, 1))
);


-- =========================
-- CUSTOMERS
-- (Da bo cot PREFERRED_LOCATIONS dang chuoi text -> tach ra bang
--  CUSTOMER_LOCATIONS ben duoi de dung chuan 1NF, de query/loc)
-- =========================
CREATE TABLE CUSTOMERS (
                           CUSTOMER_ID NUMBER NOT NULL,

                           CONSTRAINT PK_CUSTOMERS PRIMARY KEY (CUSTOMER_ID),

                           CONSTRAINT FK_CUSTOMERS_USERS
                               FOREIGN KEY (CUSTOMER_ID)
                                   REFERENCES USERS(USER_ID)
                                   ON DELETE CASCADE
);


-- =========================
-- CUSTOMER_LOCATIONS (moi)
-- Danh sach khu vuc khach hang quan tam, moi khach co the co nhieu khu vuc
-- =========================
CREATE TABLE CUSTOMER_LOCATIONS (
                                    CUSTOMER_ID NUMBER NOT NULL,
                                    LOCATION_NAME VARCHAR2(100) NOT NULL,

                                    CONSTRAINT PK_CUSTOMER_LOCATIONS
                                        PRIMARY KEY (CUSTOMER_ID, LOCATION_NAME),

                                    CONSTRAINT FK_CUSTLOC_CUSTOMER
                                        FOREIGN KEY (CUSTOMER_ID)
                                            REFERENCES CUSTOMERS(CUSTOMER_ID)
                                            ON DELETE CASCADE
);


-- =========================
-- OWNERS
-- =========================
CREATE TABLE OWNERS (
                        OWNER_ID NUMBER NOT NULL,
                        TAX_CODE VARCHAR2(50),

                        CONSTRAINT PK_OWNERS PRIMARY KEY (OWNER_ID),

                        CONSTRAINT FK_OWNERS_USERS
                            FOREIGN KEY (OWNER_ID)
                                REFERENCES USERS(USER_ID)
                                ON DELETE CASCADE,

                        CONSTRAINT UQ_OWNERS_TAX UNIQUE (TAX_CODE)
);


-- =========================
-- PROPERTIES
-- =========================
CREATE TABLE PROPERTIES (
                            PROPERTY_ID NUMBER GENERATED ALWAYS AS IDENTITY,
                            TITLE VARCHAR2(200) NOT NULL,
                            PRICE NUMBER(18,2) NOT NULL,
                            AREA NUMBER(10,2) NOT NULL,
                            STATUS VARCHAR2(30) DEFAULT 'AVAILABLE' NOT NULL,
                            DESCRIPTION CLOB,
                            ADDRESS VARCHAR2(500),
                            CREATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,

                            CONSTRAINT PK_PROPERTIES PRIMARY KEY (PROPERTY_ID),

                            CONSTRAINT CK_PROPERTIES_PRICE
                                CHECK (PRICE >= 0),

                            CONSTRAINT CK_PROPERTIES_AREA
                                CHECK (AREA > 0),

                            CONSTRAINT CK_PROPERTIES_STATUS
                                CHECK (
                                    STATUS IN (
                                               'AVAILABLE',
                                               'SOLD',
                                               'RENTED',
                                               'HIDDEN'
                                        )
                                    )
);


-- =========================
-- PROPERTY_IMAGES (moi)
-- Anh cua tin dang, 1 property co nhieu anh, 1 anh danh dau la thumbnail
-- =========================
CREATE TABLE PROPERTY_IMAGES (
                                 IMAGE_ID NUMBER GENERATED ALWAYS AS IDENTITY,
                                 PROPERTY_ID NUMBER NOT NULL,
                                 IMAGE_URL VARCHAR2(500) NOT NULL,
                                 IS_THUMBNAIL NUMBER(1) DEFAULT 0 NOT NULL,
                                 UPLOADED_AT TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,

                                 CONSTRAINT PK_PROPERTY_IMAGES PRIMARY KEY (IMAGE_ID),

                                 CONSTRAINT FK_IMAGES_PROPERTY
                                     FOREIGN KEY (PROPERTY_ID)
                                         REFERENCES PROPERTIES(PROPERTY_ID)
                                         ON DELETE CASCADE,

                                 CONSTRAINT CK_IMAGES_THUMBNAIL
                                     CHECK (IS_THUMBNAIL IN (0, 1))
);


-- =========================
-- APARTMENTS
-- (Them BEDROOMS, BATHROOMS de phuc vu tim kiem/loc)
-- =========================
CREATE TABLE APARTMENTS (
                            PROPERTY_ID NUMBER NOT NULL,
                            FLOOR_NUMBER NUMBER NOT NULL,
                            ROOM_NUMBER VARCHAR2(50),
                            BEDROOMS NUMBER DEFAULT 0 NOT NULL,
                            BATHROOMS NUMBER DEFAULT 0 NOT NULL,

                            CONSTRAINT PK_APARTMENTS PRIMARY KEY (PROPERTY_ID),

                            CONSTRAINT FK_APARTMENTS_PROPERTIES
                                FOREIGN KEY (PROPERTY_ID)
                                    REFERENCES PROPERTIES(PROPERTY_ID)
                                    ON DELETE CASCADE,

                            CONSTRAINT CK_APARTMENTS_FLOOR
                                CHECK (FLOOR_NUMBER >= 0),

                            CONSTRAINT CK_APARTMENTS_BEDROOMS
                                CHECK (BEDROOMS >= 0),

                            CONSTRAINT CK_APARTMENTS_BATHROOMS
                                CHECK (BATHROOMS >= 0)
);


-- =========================
-- BUILDINGS
-- =========================
CREATE TABLE BUILDINGS (
                           PROPERTY_ID NUMBER NOT NULL,
                           TOTAL_FLOORS NUMBER NOT NULL,

                           CONSTRAINT PK_BUILDINGS PRIMARY KEY (PROPERTY_ID),

                           CONSTRAINT FK_BUILDINGS_PROPERTIES
                               FOREIGN KEY (PROPERTY_ID)
                                   REFERENCES PROPERTIES(PROPERTY_ID)
                                   ON DELETE CASCADE,

                           CONSTRAINT CK_BUILDINGS_FLOORS
                               CHECK (TOTAL_FLOORS > 0)
);


-- =========================
-- FAVORITES (moi)
-- Khach hang luu tin yeu thich
-- =========================
CREATE TABLE FAVORITES (
                           CUSTOMER_ID NUMBER NOT NULL,
                           PROPERTY_ID NUMBER NOT NULL,
                           CREATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,

                           CONSTRAINT PK_FAVORITES PRIMARY KEY (CUSTOMER_ID, PROPERTY_ID),

                           CONSTRAINT FK_FAVORITES_CUSTOMER
                               FOREIGN KEY (CUSTOMER_ID)
                                   REFERENCES CUSTOMERS(CUSTOMER_ID)
                                   ON DELETE CASCADE,

                           CONSTRAINT FK_FAVORITES_PROPERTY
                               FOREIGN KEY (PROPERTY_ID)
                                   REFERENCES PROPERTIES(PROPERTY_ID)
                                   ON DELETE CASCADE
);


-- =========================
-- LISTINGS
-- =========================
CREATE TABLE LISTINGS (
                          LISTING_ID NUMBER GENERATED ALWAYS AS IDENTITY,
                          OWNER_ID NUMBER NOT NULL,
                          PROPERTY_ID NUMBER NOT NULL,
                          POST_DATE TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
                          EXPIRY_DATE TIMESTAMP,
                          STATUS VARCHAR2(30) DEFAULT 'ACTIVE' NOT NULL,

                          CONSTRAINT PK_LISTINGS PRIMARY KEY (LISTING_ID),

                          CONSTRAINT FK_LISTINGS_OWNER
                              FOREIGN KEY (OWNER_ID)
                                  REFERENCES OWNERS(OWNER_ID),

    -- Khong dung ON DELETE CASCADE o day (co chu dich):
    -- neu xoa PROPERTIES ma con LISTINGS thi phai bao loi,
    -- buoc ung dung dung "soft delete" (STATUS = 'HIDDEN')
    -- thay vi xoa vinh vien, tranh mat lich su tin dang/giao dich.
                          CONSTRAINT FK_LISTINGS_PROPERTY
                              FOREIGN KEY (PROPERTY_ID)
                                  REFERENCES PROPERTIES(PROPERTY_ID),

                          CONSTRAINT CK_LISTINGS_STATUS
                              CHECK (
                                  STATUS IN (
                                             'ACTIVE',
                                             'EXPIRED',
                                             'SOLD',
                                             'HIDDEN'
                                      )
                                  )
);


-- =========================
-- TRANSACTIONS
-- (Giu nguyen: 1 LISTING co the co nhieu TRANSACTIONS, vi 1 can ho
--  co the duoc mua ban lai nhieu lan qua cac tin dang/giao dich khac nhau)
-- =========================
CREATE TABLE TRANSACTIONS (
                              TRANSACTION_ID NUMBER GENERATED ALWAYS AS IDENTITY,
                              CUSTOMER_ID NUMBER NOT NULL,
                              LISTING_ID NUMBER NOT NULL,
                              AMOUNT NUMBER(18,2) NOT NULL,
                              TRANSACTION_DATE TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
                              STATUS VARCHAR2(30) DEFAULT 'PENDING' NOT NULL,

                              CONSTRAINT PK_TRANSACTIONS PRIMARY KEY (TRANSACTION_ID),

                              CONSTRAINT FK_TRANSACTIONS_CUSTOMER
                                  FOREIGN KEY (CUSTOMER_ID)
                                      REFERENCES CUSTOMERS(CUSTOMER_ID),

                              CONSTRAINT FK_TRANSACTIONS_LISTING
                                  FOREIGN KEY (LISTING_ID)
                                      REFERENCES LISTINGS(LISTING_ID),

                              CONSTRAINT CK_TRANSACTIONS_AMOUNT
                                  CHECK (AMOUNT >= 0),

                              CONSTRAINT CK_TRANSACTIONS_STATUS
                                  CHECK (
                                      STATUS IN (
                                                 'PENDING',
                                                 'COMPLETED',
                                                 'CANCELLED'
                                          )
                                      )
);


-- =========================
-- REVIEWS
-- =========================
CREATE TABLE REVIEWS (
                         REVIEW_ID NUMBER GENERATED ALWAYS AS IDENTITY,
                         CUSTOMER_ID NUMBER NOT NULL,
                         PROPERTY_ID NUMBER NOT NULL,
                         RATING NUMBER(1) NOT NULL,
                         COMMENT_TEXT VARCHAR2(1000),
                         REVIEW_DATE TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,

                         CONSTRAINT PK_REVIEWS PRIMARY KEY (REVIEW_ID),

                         CONSTRAINT FK_REVIEWS_CUSTOMER
                             FOREIGN KEY (CUSTOMER_ID)
                                 REFERENCES CUSTOMERS(CUSTOMER_ID),

                         CONSTRAINT FK_REVIEWS_PROPERTY
                             FOREIGN KEY (PROPERTY_ID)
                                 REFERENCES PROPERTIES(PROPERTY_ID),

                         CONSTRAINT CK_REVIEWS_RATING
                             CHECK (RATING BETWEEN 1 AND 5),

                         CONSTRAINT UQ_REVIEWS_CUSTOMER_PROPERTY
                             UNIQUE (CUSTOMER_ID, PROPERTY_ID)
);


-- =========================
-- INDEXES
-- =========================

CREATE INDEX IDX_PROPERTIES_PRICE
    ON PROPERTIES(PRICE);

CREATE INDEX IDX_PROPERTIES_AREA
    ON PROPERTIES(AREA);

CREATE INDEX IDX_PROPERTIES_STATUS
    ON PROPERTIES(STATUS);

CREATE INDEX IDX_LISTINGS_OWNER
    ON LISTINGS(OWNER_ID);

CREATE INDEX IDX_LISTINGS_PROPERTY
    ON LISTINGS(PROPERTY_ID);

CREATE INDEX IDX_LISTINGS_STATUS
    ON LISTINGS(STATUS);

CREATE INDEX IDX_TRANSACTIONS_CUSTOMER
    ON TRANSACTIONS(CUSTOMER_ID);

CREATE INDEX IDX_TRANSACTIONS_STATUS
    ON TRANSACTIONS(STATUS);

CREATE INDEX IDX_REVIEWS_PROPERTY
    ON REVIEWS(PROPERTY_ID);

CREATE INDEX IDX_IMAGES_PROPERTY
    ON PROPERTY_IMAGES(PROPERTY_ID);


COMMIT;


-- =====================================================
-- TRIGGERS: dong bo STATUS giua LISTINGS <-> PROPERTIES
-- (van de #6 - tranh du lieu lech nhau)
-- Business rule:
--   - Giao dich COMPLETED  -> listing SOLD, property SOLD
--   - Tao/mo lai listing ACTIVE cho property (ban lai/resale)
--     -> property tro lai AVAILABLE
-- =====================================================

CREATE OR REPLACE TRIGGER TRG_TRANSACTION_COMPLETED
    AFTER INSERT OR UPDATE OF STATUS ON TRANSACTIONS
    FOR EACH ROW
    WHEN (NEW.STATUS = 'COMPLETED')
BEGIN
UPDATE LISTINGS
SET STATUS = 'SOLD'
WHERE LISTING_ID = :NEW.LISTING_ID;

UPDATE PROPERTIES
SET STATUS = 'SOLD'
WHERE PROPERTY_ID = (
    SELECT PROPERTY_ID FROM LISTINGS WHERE LISTING_ID = :NEW.LISTING_ID
);
END;
/

CREATE OR REPLACE TRIGGER TRG_LISTING_REACTIVATED
    AFTER INSERT OR UPDATE OF STATUS ON LISTINGS
    FOR EACH ROW
    WHEN (NEW.STATUS = 'ACTIVE')
BEGIN
UPDATE PROPERTIES
SET STATUS = 'AVAILABLE'
WHERE PROPERTY_ID = :NEW.PROPERTY_ID;
END;
/

COMMIT;