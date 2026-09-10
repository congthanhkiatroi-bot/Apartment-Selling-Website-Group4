-- ============================================================

-- ============================================================


-- ============================================================
-- 1. USERS
-- ============================================================

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
                           CHECK (IS_ACTIVE IN (0,1))
);


-- ============================================================
-- 2. CUSTOMERS
-- ============================================================

CREATE TABLE CUSTOMERS (
                           CUSTOMER_ID NUMBER NOT NULL,

                           CONSTRAINT PK_CUSTOMERS
                               PRIMARY KEY (CUSTOMER_ID),

                           CONSTRAINT FK_CUSTOMERS_USERS
                               FOREIGN KEY (CUSTOMER_ID)
                                   REFERENCES USERS(USER_ID)
                                   ON DELETE CASCADE
);


-- ============================================================
-- 3. CUSTOMER LOCATIONS
-- ============================================================

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


-- ============================================================
-- 4. OWNERS
-- ============================================================

CREATE TABLE OWNERS (
                        OWNER_ID NUMBER NOT NULL,
                        TAX_CODE VARCHAR2(50),

                        CONSTRAINT PK_OWNERS
                            PRIMARY KEY (OWNER_ID),

                        CONSTRAINT FK_OWNERS_USERS
                            FOREIGN KEY (OWNER_ID)
                                REFERENCES USERS(USER_ID)
                                ON DELETE CASCADE,

                        CONSTRAINT UQ_OWNERS_TAX
                            UNIQUE (TAX_CODE)
);


-- ============================================================
-- 5. BUILDINGS
--
-- Một BUILDING có nhiều APARTMENTS
-- ============================================================

CREATE TABLE BUILDINGS (
                           BUILDING_ID NUMBER GENERATED ALWAYS AS IDENTITY,

                           BUILDING_CODE VARCHAR2(30) NOT NULL,
                           BUILDING_NAME VARCHAR2(200) NOT NULL,

                           ADDRESS VARCHAR2(500) NOT NULL,
                           WARD VARCHAR2(100),
                           DISTRICT VARCHAR2(100),
                           CITY VARCHAR2(100),

                           TOTAL_FLOORS NUMBER NOT NULL,
                           TOTAL_APARTMENTS NUMBER DEFAULT 0 NOT NULL,

                           YEAR_BUILT NUMBER(4),

                           DESCRIPTION CLOB,

                           STATUS VARCHAR2(30) DEFAULT 'ACTIVE' NOT NULL,

                           CREATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,

                           CONSTRAINT PK_BUILDINGS
                               PRIMARY KEY (BUILDING_ID),

                           CONSTRAINT UQ_BUILDINGS_CODE
                               UNIQUE (BUILDING_CODE),

                           CONSTRAINT CK_BUILDINGS_FLOORS
                               CHECK (TOTAL_FLOORS > 0),

                           CONSTRAINT CK_BUILDINGS_APARTMENTS
                               CHECK (TOTAL_APARTMENTS >= 0),

                           CONSTRAINT CK_BUILDINGS_YEAR
                               CHECK (YEAR_BUILT IS NULL OR YEAR_BUILT >= 1900),

                           CONSTRAINT CK_BUILDINGS_STATUS
                               CHECK (
                                   STATUS IN (
                                              'ACTIVE',
                                              'INACTIVE',
                                              'MAINTENANCE'
                                       )
                                   )
);


-- ============================================================
-- 6. APARTMENTS
--
-- BUILDINGS 1 ---- N APARTMENTS
-- ============================================================

CREATE TABLE APARTMENTS (
                            APARTMENT_ID NUMBER GENERATED ALWAYS AS IDENTITY,

                            BUILDING_ID NUMBER NOT NULL,

                            APARTMENT_CODE VARCHAR2(50) NOT NULL,

                            FLOOR_NUMBER NUMBER NOT NULL,
                            ROOM_NUMBER VARCHAR2(50),

                            AREA NUMBER(10,2) NOT NULL,

                            BEDROOMS NUMBER DEFAULT 0 NOT NULL,
                            BATHROOMS NUMBER DEFAULT 0 NOT NULL,

                            BALCONY_AREA NUMBER(10,2),

                            DIRECTION VARCHAR2(50),
                            VIEW_TYPE VARCHAR2(100),

                            LEGAL_STATUS VARCHAR2(50)
        DEFAULT 'PENDING' NOT NULL,

                            STATUS VARCHAR2(30)
        DEFAULT 'AVAILABLE' NOT NULL,

                            CREATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,

                            CONSTRAINT PK_APARTMENTS
                                PRIMARY KEY (APARTMENT_ID),

                            CONSTRAINT FK_APARTMENTS_BUILDING
                                FOREIGN KEY (BUILDING_ID)
                                    REFERENCES BUILDINGS(BUILDING_ID),

                            CONSTRAINT UQ_APARTMENTS_CODE
                                UNIQUE (BUILDING_ID, APARTMENT_CODE),

                            CONSTRAINT CK_APARTMENTS_FLOOR
                                CHECK (FLOOR_NUMBER >= 0),

                            CONSTRAINT CK_APARTMENTS_AREA
                                CHECK (AREA > 0),

                            CONSTRAINT CK_APARTMENTS_BEDROOMS
                                CHECK (BEDROOMS >= 0),

                            CONSTRAINT CK_APARTMENTS_BATHROOMS
                                CHECK (BATHROOMS >= 0),

                            CONSTRAINT CK_APARTMENTS_BALCONY
                                CHECK (
                                    BALCONY_AREA IS NULL
                                        OR BALCONY_AREA >= 0
                                    ),

                            CONSTRAINT CK_APARTMENTS_LEGAL
                                CHECK (
                                    LEGAL_STATUS IN (
                                                     'PENDING',
                                                     'CERTIFIED',
                                                     'MORTGAGED',
                                                     'DISPUTED'
                                        )
                                    ),

                            CONSTRAINT CK_APARTMENTS_STATUS
                                CHECK (
                                    STATUS IN (
                                               'AVAILABLE',
                                               'RESERVED',
                                               'SOLD',
                                               'HIDDEN'
                                        )
                                    )
);


-- ============================================================
-- 7. PROPERTIES
--
-- Một APARTMENT có một PROPERTY
-- PROPERTY chứa thông tin dùng để bán
--
-- BUILDING
--    |
--    +---- APARTMENT
--              |
--              +---- PROPERTY
-- ============================================================

CREATE TABLE PROPERTIES (
                            PROPERTY_ID NUMBER GENERATED ALWAYS AS IDENTITY,

                            APARTMENT_ID NUMBER NOT NULL,

                            TITLE VARCHAR2(200) NOT NULL,

                            PRICE NUMBER(18,2) NOT NULL,

                            PRICE_PER_M2 NUMBER(18,2),

                            DESCRIPTION CLOB,

                            ADDRESS VARCHAR2(500),

                            STATUS VARCHAR2(30)
        DEFAULT 'AVAILABLE' NOT NULL,

                            CREATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,

                            UPDATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,

                            CONSTRAINT PK_PROPERTIES
                                PRIMARY KEY (PROPERTY_ID),

                            CONSTRAINT FK_PROPERTIES_APARTMENT
                                FOREIGN KEY (APARTMENT_ID)
                                    REFERENCES APARTMENTS(APARTMENT_ID),

                            CONSTRAINT UQ_PROPERTIES_APARTMENT
                                UNIQUE (APARTMENT_ID),

                            CONSTRAINT CK_PROPERTIES_PRICE
                                CHECK (PRICE >= 0),

                            CONSTRAINT CK_PROPERTIES_PRICE_M2
                                CHECK (
                                    PRICE_PER_M2 IS NULL
                                        OR PRICE_PER_M2 >= 0
                                    ),

                            CONSTRAINT CK_PROPERTIES_STATUS
                                CHECK (
                                    STATUS IN (
                                               'AVAILABLE',
                                               'RESERVED',
                                               'SOLD',
                                               'HIDDEN'
                                        )
                                    )
);


-- ============================================================
-- 8. PROPERTY IMAGES
-- ============================================================

CREATE TABLE PROPERTY_IMAGES (
                                 IMAGE_ID NUMBER GENERATED ALWAYS AS IDENTITY,

                                 PROPERTY_ID NUMBER NOT NULL,

                                 IMAGE_URL VARCHAR2(500) NOT NULL,

                                 IS_THUMBNAIL NUMBER(1)
        DEFAULT 0 NOT NULL,

                                 UPLOADED_AT TIMESTAMP
                                     DEFAULT SYSTIMESTAMP NOT NULL,

                                 CONSTRAINT PK_PROPERTY_IMAGES
                                     PRIMARY KEY (IMAGE_ID),

                                 CONSTRAINT FK_IMAGES_PROPERTY
                                     FOREIGN KEY (PROPERTY_ID)
                                         REFERENCES PROPERTIES(PROPERTY_ID)
                                         ON DELETE CASCADE,

                                 CONSTRAINT CK_IMAGES_THUMBNAIL
                                     CHECK (IS_THUMBNAIL IN (0,1))
);


-- ============================================================
-- 9. FAVORITES
-- ============================================================

CREATE TABLE FAVORITES (
                           CUSTOMER_ID NUMBER NOT NULL,
                           PROPERTY_ID NUMBER NOT NULL,

                           CREATED_AT TIMESTAMP
                               DEFAULT SYSTIMESTAMP NOT NULL,

                           CONSTRAINT PK_FAVORITES
                               PRIMARY KEY (CUSTOMER_ID, PROPERTY_ID),

                           CONSTRAINT FK_FAVORITES_CUSTOMER
                               FOREIGN KEY (CUSTOMER_ID)
                                   REFERENCES CUSTOMERS(CUSTOMER_ID)
                                   ON DELETE CASCADE,

                           CONSTRAINT FK_FAVORITES_PROPERTY
                               FOREIGN KEY (PROPERTY_ID)
                                   REFERENCES PROPERTIES(PROPERTY_ID)
                                   ON DELETE CASCADE
);


-- ============================================================
-- 10. LISTINGS
--
-- OWNER đăng tin bán PROPERTY
--
-- PROPERTY
--    |
--    +---- LISTING
--              |
--              +---- TRANSACTION
-- ============================================================

CREATE TABLE LISTINGS (
                          LISTING_ID NUMBER GENERATED ALWAYS AS IDENTITY,

                          LISTING_CODE VARCHAR2(50) NOT NULL,

                          OWNER_ID NUMBER NOT NULL,

                          PROPERTY_ID NUMBER NOT NULL,

                          LISTING_TITLE VARCHAR2(200),

                          ASKING_PRICE NUMBER(18,2) NOT NULL,

                          DESCRIPTION CLOB,

                          POST_DATE TIMESTAMP
                              DEFAULT SYSTIMESTAMP NOT NULL,

                          EXPIRY_DATE TIMESTAMP,

                          STATUS VARCHAR2(30)
        DEFAULT 'ACTIVE' NOT NULL,

                          CREATED_AT TIMESTAMP
                              DEFAULT SYSTIMESTAMP NOT NULL,

                          UPDATED_AT TIMESTAMP
                              DEFAULT SYSTIMESTAMP NOT NULL,

                          CONSTRAINT PK_LISTINGS
                              PRIMARY KEY (LISTING_ID),

                          CONSTRAINT UQ_LISTINGS_CODE
                              UNIQUE (LISTING_CODE),

                          CONSTRAINT FK_LISTINGS_OWNER
                              FOREIGN KEY (OWNER_ID)
                                  REFERENCES OWNERS(OWNER_ID),

                          CONSTRAINT FK_LISTINGS_PROPERTY
                              FOREIGN KEY (PROPERTY_ID)
                                  REFERENCES PROPERTIES(PROPERTY_ID),

                          CONSTRAINT CK_LISTINGS_PRICE
                              CHECK (ASKING_PRICE >= 0),

                          CONSTRAINT CK_LISTINGS_DATE
                              CHECK (
                                  EXPIRY_DATE IS NULL
                                      OR EXPIRY_DATE >= POST_DATE
                                  ),

                          CONSTRAINT CK_LISTINGS_STATUS
                              CHECK (
                                  STATUS IN (
                                             'ACTIVE',
                                             'EXPIRED',
                                             'SOLD',
                                             'HIDDEN',
                                             'CANCELLED'
                                      )
                                  )
);


-- ============================================================
-- 11. TRANSACTIONS
--
-- Thông tin giao dịch thực tế
-- ============================================================

CREATE TABLE TRANSACTIONS (
                              TRANSACTION_ID NUMBER GENERATED ALWAYS AS IDENTITY,

                              TRANSACTION_CODE VARCHAR2(50) NOT NULL,

                              CUSTOMER_ID NUMBER NOT NULL,

                              LISTING_ID NUMBER NOT NULL,

                              TRANSACTION_TYPE VARCHAR2(30)
        DEFAULT 'PURCHASE' NOT NULL,

                              LISTING_PRICE NUMBER(18,2),

                              AGREED_PRICE NUMBER(18,2) NOT NULL,

                              DEPOSIT_AMOUNT NUMBER(18,2)
        DEFAULT 0 NOT NULL,

                              REMAINING_AMOUNT NUMBER(18,2)
        DEFAULT 0 NOT NULL,

                              TRANSACTION_DATE TIMESTAMP
                                  DEFAULT SYSTIMESTAMP NOT NULL,

                              CONTRACT_DATE TIMESTAMP,

                              COMPLETION_DATE TIMESTAMP,

                              PAYMENT_METHOD VARCHAR2(30),

                              PAYMENT_STATUS VARCHAR2(30)
        DEFAULT 'PENDING' NOT NULL,

                              STATUS VARCHAR2(30)
        DEFAULT 'PENDING' NOT NULL,

                              NOTE VARCHAR2(1000),

                              CREATED_AT TIMESTAMP
                                  DEFAULT SYSTIMESTAMP NOT NULL,

                              UPDATED_AT TIMESTAMP
                                  DEFAULT SYSTIMESTAMP NOT NULL,

                              CONSTRAINT PK_TRANSACTIONS
                                  PRIMARY KEY (TRANSACTION_ID),

                              CONSTRAINT UQ_TRANSACTIONS_CODE
                                  UNIQUE (TRANSACTION_CODE),

                              CONSTRAINT FK_TRANSACTIONS_CUSTOMER
                                  FOREIGN KEY (CUSTOMER_ID)
                                      REFERENCES CUSTOMERS(CUSTOMER_ID),

                              CONSTRAINT FK_TRANSACTIONS_LISTING
                                  FOREIGN KEY (LISTING_ID)
                                      REFERENCES LISTINGS(LISTING_ID),

                              CONSTRAINT CK_TRANSACTION_TYPE
                                  CHECK (
                                      TRANSACTION_TYPE IN (
                                          'PURCHASE'
                                          )
                                      ),

                              CONSTRAINT CK_TRANSACTION_LISTING_PRICE
                                  CHECK (
                                      LISTING_PRICE IS NULL
                                          OR LISTING_PRICE >= 0
                                      ),

                              CONSTRAINT CK_TRANSACTION_AGREED_PRICE
                                  CHECK (AGREED_PRICE >= 0),

                              CONSTRAINT CK_TRANSACTION_DEPOSIT
                                  CHECK (DEPOSIT_AMOUNT >= 0),

                              CONSTRAINT CK_TRANSACTION_REMAINING
                                  CHECK (REMAINING_AMOUNT >= 0),

                              CONSTRAINT CK_TRANSACTION_PAYMENT_METHOD
                                  CHECK (
                                      PAYMENT_METHOD IS NULL
                                          OR PAYMENT_METHOD IN (
                                                                'CASH',
                                                                'BANK_TRANSFER',
                                                                'MIXED'
                                          )
                                      ),

                              CONSTRAINT CK_TRANSACTION_PAYMENT_STATUS
                                  CHECK (
                                      PAYMENT_STATUS IN (
                                                         'PENDING',
                                                         'PARTIAL',
                                                         'PAID',
                                                         'REFUNDED'
                                          )
                                      ),

                              CONSTRAINT CK_TRANSACTION_STATUS
                                  CHECK (
                                      STATUS IN (
                                                 'PENDING',
                                                 'DEPOSITED',
                                                 'PROCESSING',
                                                 'COMPLETED',
                                                 'CANCELLED'
                                          )
                                      )
);


-- ============================================================
-- 12. PAYMENTS
--
-- Một TRANSACTION có thể có nhiều lần thanh toán
-- ============================================================

CREATE TABLE PAYMENTS (
                          PAYMENT_ID NUMBER GENERATED ALWAYS AS IDENTITY,

                          TRANSACTION_ID NUMBER NOT NULL,

                          PAYMENT_CODE VARCHAR2(50) NOT NULL,

                          AMOUNT NUMBER(18,2) NOT NULL,

                          PAYMENT_TYPE VARCHAR2(30) NOT NULL,

                          PAYMENT_METHOD VARCHAR2(30) NOT NULL,

                          PAYMENT_DATE TIMESTAMP
                              DEFAULT SYSTIMESTAMP NOT NULL,

                          REFERENCE_NUMBER VARCHAR2(100),

                          STATUS VARCHAR2(30)
        DEFAULT 'SUCCESS' NOT NULL,

                          NOTE VARCHAR2(1000),

                          CREATED_AT TIMESTAMP
                              DEFAULT SYSTIMESTAMP NOT NULL,

                          CONSTRAINT PK_PAYMENTS
                              PRIMARY KEY (PAYMENT_ID),

                          CONSTRAINT UQ_PAYMENTS_CODE
                              UNIQUE (PAYMENT_CODE),

                          CONSTRAINT FK_PAYMENTS_TRANSACTION
                              FOREIGN KEY (TRANSACTION_ID)
                                  REFERENCES TRANSACTIONS(TRANSACTION_ID)
                                  ON DELETE CASCADE,

                          CONSTRAINT CK_PAYMENTS_AMOUNT
                              CHECK (AMOUNT > 0),

                          CONSTRAINT CK_PAYMENTS_TYPE
                              CHECK (
                                  PAYMENT_TYPE IN (
                                                   'DEPOSIT',
                                                   'INSTALLMENT',
                                                   'FINAL',
                                                   'REFUND'
                                      )
                                  ),

                          CONSTRAINT CK_PAYMENTS_METHOD
                              CHECK (
                                  PAYMENT_METHOD IN (
                                                     'CASH',
                                                     'BANK_TRANSFER',
                                                     'MIXED'
                                      )
                                  ),

                          CONSTRAINT CK_PAYMENTS_STATUS
                              CHECK (
                                  STATUS IN (
                                             'PENDING',
                                             'SUCCESS',
                                             'FAILED',
                                             'REFUNDED'
                                      )
                                  )
);


-- ============================================================
-- 13. REVIEWS
-- ============================================================

CREATE TABLE REVIEWS (
                         REVIEW_ID NUMBER GENERATED ALWAYS AS IDENTITY,

                         CUSTOMER_ID NUMBER NOT NULL,

                         PROPERTY_ID NUMBER NOT NULL,

                         RATING NUMBER(1) NOT NULL,

                         COMMENT_TEXT VARCHAR2(1000),

                         REVIEW_DATE TIMESTAMP
                             DEFAULT SYSTIMESTAMP NOT NULL,

                         CONSTRAINT PK_REVIEWS
                             PRIMARY KEY (REVIEW_ID),

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


-- ============================================================
-- 14. INDEXES
-- ============================================================

CREATE INDEX IDX_BUILDINGS_NAME
    ON BUILDINGS(BUILDING_NAME);

CREATE INDEX IDX_BUILDINGS_CITY
    ON BUILDINGS(CITY);

CREATE INDEX IDX_APARTMENTS_BUILDING
    ON APARTMENTS(BUILDING_ID);

CREATE INDEX IDX_APARTMENTS_FLOOR
    ON APARTMENTS(FLOOR_NUMBER);

CREATE INDEX IDX_APARTMENTS_STATUS
    ON APARTMENTS(STATUS);

CREATE INDEX IDX_PROPERTIES_APARTMENT
    ON PROPERTIES(APARTMENT_ID);

CREATE INDEX IDX_PROPERTIES_PRICE
    ON PROPERTIES(PRICE);

CREATE INDEX IDX_PROPERTIES_AREA
    ON APARTMENTS(AREA);

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

CREATE INDEX IDX_TRANSACTIONS_LISTING
    ON TRANSACTIONS(LISTING_ID);

CREATE INDEX IDX_TRANSACTIONS_STATUS
    ON TRANSACTIONS(STATUS);

CREATE INDEX IDX_TRANSACTIONS_PAYMENT_STATUS
    ON TRANSACTIONS(PAYMENT_STATUS);

CREATE INDEX IDX_PAYMENTS_TRANSACTION
    ON PAYMENTS(TRANSACTION_ID);

CREATE INDEX IDX_PAYMENTS_STATUS
    ON PAYMENTS(STATUS);

CREATE INDEX IDX_REVIEWS_PROPERTY
    ON REVIEWS(PROPERTY_ID);

CREATE INDEX IDX_IMAGES_PROPERTY
    ON PROPERTY_IMAGES(PROPERTY_ID);


-- ============================================================
-- 15. CHỈ CHO PHÉP 1 THUMBNAIL / PROPERTY
-- ============================================================

CREATE UNIQUE INDEX UQ_PROPERTY_ONE_THUMBNAIL
    ON PROPERTY_IMAGES (
                        CASE
                            WHEN IS_THUMBNAIL = 1
        THEN PROPERTY_ID
    END
        );


-- ============================================================
-- 16. TRIGGER UPDATE PROPERTY UPDATED_AT
-- ============================================================

CREATE OR REPLACE TRIGGER TRG_PROPERTIES_UPDATED
BEFORE UPDATE ON PROPERTIES
                  FOR EACH ROW
BEGIN
    :NEW.UPDATED_AT := SYSTIMESTAMP;
END;
/


-- ============================================================
-- 17. TRIGGER UPDATE LISTING UPDATED_AT
-- ============================================================

CREATE OR REPLACE TRIGGER TRG_LISTINGS_UPDATED
BEFORE UPDATE ON LISTINGS
                  FOR EACH ROW
BEGIN
    :NEW.UPDATED_AT := SYSTIMESTAMP;
END;
/


-- ============================================================
-- 18. TRANSACTION COMPLETED
--
-- Khi giao dịch hoàn tất:
--
-- LISTING       -> SOLD
-- PROPERTY      -> SOLD
-- APARTMENT     -> SOLD
--
-- ============================================================

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
    SELECT PROPERTY_ID
    FROM LISTINGS
    WHERE LISTING_ID = :NEW.LISTING_ID
);

UPDATE APARTMENTS
SET STATUS = 'SOLD'
WHERE APARTMENT_ID = (
    SELECT APARTMENT_ID
    FROM PROPERTIES
    WHERE PROPERTY_ID = (
        SELECT PROPERTY_ID
        FROM LISTINGS
        WHERE LISTING_ID = :NEW.LISTING_ID
    )
);

END;
/


-- ============================================================
-- 19. PAYMENT SUCCESS
--
-- Tự động tính tổng tiền đã thanh toán
-- và số tiền còn lại
-- ============================================================

CREATE OR REPLACE TRIGGER TRG_PAYMENT_SUCCESS
AFTER INSERT OR UPDATE OF STATUS, AMOUNT ON PAYMENTS
    FOR EACH ROW
    WHEN (NEW.STATUS = 'SUCCESS')
DECLARE

V_AGREED_PRICE NUMBER(18,2);
    V_PAID_AMOUNT NUMBER(18,2);

BEGIN

SELECT AGREED_PRICE
INTO V_AGREED_PRICE
FROM TRANSACTIONS
WHERE TRANSACTION_ID = :NEW.TRANSACTION_ID;


SELECT NVL(SUM(AMOUNT), 0)
INTO V_PAID_AMOUNT
FROM PAYMENTS
WHERE TRANSACTION_ID = :NEW.TRANSACTION_ID
  AND STATUS = 'SUCCESS'
  AND PAYMENT_TYPE <> 'REFUND';


UPDATE TRANSACTIONS

SET DEPOSIT_AMOUNT =
        NVL(
                (
                    SELECT SUM(AMOUNT)
                    FROM PAYMENTS
                    WHERE TRANSACTION_ID = :NEW.TRANSACTION_ID
                      AND PAYMENT_TYPE = 'DEPOSIT'
                      AND STATUS = 'SUCCESS'
                ),
                0
        ),

    REMAINING_AMOUNT =
        GREATEST(
                V_AGREED_PRICE - V_PAID_AMOUNT,
                0
        ),

    PAYMENT_STATUS =
        CASE
            WHEN V_PAID_AMOUNT = 0
                THEN 'PENDING'

            WHEN V_PAID_AMOUNT < V_AGREED_PRICE
                THEN 'PARTIAL'

            ELSE 'PAID'
            END

WHERE TRANSACTION_ID = :NEW.TRANSACTION_ID;

END;
/


-- ============================================================
-- 20. TRANSACTION PAYMENT STATUS
-- ============================================================

CREATE OR REPLACE TRIGGER TRG_TRANSACTION_PAYMENT_STATUS
AFTER UPDATE OF PAYMENT_STATUS ON TRANSACTIONS
    FOR EACH ROW
    WHEN (NEW.PAYMENT_STATUS = 'PAID')
BEGIN

UPDATE TRANSACTIONS
SET STATUS =
        CASE
            WHEN STATUS NOT IN ('CANCELLED', 'COMPLETED')
                THEN 'PROCESSING'
            ELSE STATUS
            END
WHERE TRANSACTION_ID = :NEW.TRANSACTION_ID;

END;
/


COMMIT;