-- ============================================================

-- ============================================================


-- ============================================================
-- 1. USERS
-- ============================================================

CREATE TABLE USERS (
                       USER_ID BIGINT GENERATED ALWAYS AS IDENTITY,
                       USERNAME VARCHAR(50) NOT NULL,
                       EMAIL VARCHAR(100) NOT NULL,
                       PASSWORD_HASH VARCHAR(255) NOT NULL,
                       ROLE VARCHAR(20) DEFAULT 'CUSTOMER' NOT NULL,
                       CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                       IS_ACTIVE SMALLINT DEFAULT 1 NOT NULL,

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
                           CUSTOMER_ID BIGINT NOT NULL,

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
                                    CUSTOMER_ID BIGINT NOT NULL,
                                    LOCATION_NAME VARCHAR(100) NOT NULL,

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
                        OWNER_ID BIGINT NOT NULL,
                        TAX_CODE VARCHAR(50),

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
                           BUILDING_ID BIGINT GENERATED ALWAYS AS IDENTITY,

                           BUILDING_CODE VARCHAR(30) NOT NULL,
                           BUILDING_NAME VARCHAR(200) NOT NULL,

                           ADDRESS VARCHAR(500) NOT NULL,
                           WARD VARCHAR(100),
                           DISTRICT VARCHAR(100),
                           CITY VARCHAR(100),

                           TOTAL_FLOORS BIGINT NOT NULL,
                           TOTAL_APARTMENTS BIGINT DEFAULT 0 NOT NULL,

                           YEAR_BUILT NUMERIC(4),

                           DESCRIPTION TEXT,

                           STATUS VARCHAR(30) DEFAULT 'ACTIVE' NOT NULL,

                           CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

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
                            APARTMENT_ID BIGINT GENERATED ALWAYS AS IDENTITY,

                            BUILDING_ID BIGINT NOT NULL,

                            APARTMENT_CODE VARCHAR(50) NOT NULL,

                            FLOOR_NUMBER BIGINT NOT NULL,
                            ROOM_NUMBER VARCHAR(50),

                            AREA NUMERIC(10,2) NOT NULL,

                            BEDROOMS BIGINT DEFAULT 0 NOT NULL,
                            BATHROOMS BIGINT DEFAULT 0 NOT NULL,

                            BALCONY_AREA NUMERIC(10,2),

                            DIRECTION VARCHAR(50),
                            VIEW_TYPE VARCHAR(100),

                            LEGAL_STATUS VARCHAR(50)
        DEFAULT 'PENDING' NOT NULL,

                            STATUS VARCHAR(30)
        DEFAULT 'AVAILABLE' NOT NULL,

                            CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

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
                            PROPERTY_ID BIGINT GENERATED ALWAYS AS IDENTITY,

                            APARTMENT_ID BIGINT NOT NULL,

                            TITLE VARCHAR(200) NOT NULL,

                            PRICE NUMERIC(18,2) NOT NULL,

                            PRICE_PER_M2 NUMERIC(18,2),

                            DESCRIPTION TEXT,

                            ADDRESS VARCHAR(500),

                            STATUS VARCHAR(30)
        DEFAULT 'AVAILABLE' NOT NULL,

                            CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

                            UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

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
                                 IMAGE_ID BIGINT GENERATED ALWAYS AS IDENTITY,

                                 PROPERTY_ID BIGINT NOT NULL,

                                 IMAGE_URL VARCHAR(500) NOT NULL,

                                 IS_THUMBNAIL SMALLINT
        DEFAULT 0 NOT NULL,

                                 UPLOADED_AT TIMESTAMP
                                     DEFAULT CURRENT_TIMESTAMP NOT NULL,

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
                           CUSTOMER_ID BIGINT NOT NULL,
                           PROPERTY_ID BIGINT NOT NULL,

                           CREATED_AT TIMESTAMP
                               DEFAULT CURRENT_TIMESTAMP NOT NULL,

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
                          LISTING_ID BIGINT GENERATED ALWAYS AS IDENTITY,

                          LISTING_CODE VARCHAR(50) NOT NULL,

                          OWNER_ID BIGINT NOT NULL,

                          PROPERTY_ID BIGINT NOT NULL,

                          LISTING_TITLE VARCHAR(200),

                          ASKING_PRICE NUMERIC(18,2) NOT NULL,

                          DESCRIPTION TEXT,

                          POST_DATE TIMESTAMP
                              DEFAULT CURRENT_TIMESTAMP NOT NULL,

                          EXPIRY_DATE TIMESTAMP,

                          STATUS VARCHAR(30)
        DEFAULT 'ACTIVE' NOT NULL,

                          CREATED_AT TIMESTAMP
                              DEFAULT CURRENT_TIMESTAMP NOT NULL,

                          UPDATED_AT TIMESTAMP
                              DEFAULT CURRENT_TIMESTAMP NOT NULL,

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
                              TRANSACTION_ID BIGINT GENERATED ALWAYS AS IDENTITY,

                              TRANSACTION_CODE VARCHAR(50) NOT NULL,

                              CUSTOMER_ID BIGINT NOT NULL,

                              LISTING_ID BIGINT NOT NULL,

                              TRANSACTION_TYPE VARCHAR(30)
        DEFAULT 'PURCHASE' NOT NULL,

                              LISTING_PRICE NUMERIC(18,2),

                              AGREED_PRICE NUMERIC(18,2) NOT NULL,

                              DEPOSIT_AMOUNT NUMERIC(18,2)
        DEFAULT 0 NOT NULL,

                              REMAINING_AMOUNT NUMERIC(18,2)
        DEFAULT 0 NOT NULL,

                              TRANSACTION_DATE TIMESTAMP
                                  DEFAULT CURRENT_TIMESTAMP NOT NULL,

                              CONTRACT_DATE TIMESTAMP,

                              COMPLETION_DATE TIMESTAMP,

                              PAYMENT_METHOD VARCHAR(30),

                              PAYMENT_STATUS VARCHAR(30)
        DEFAULT 'PENDING' NOT NULL,

                              STATUS VARCHAR(30)
        DEFAULT 'PENDING' NOT NULL,

                              NOTE VARCHAR(1000),

                              CREATED_AT TIMESTAMP
                                  DEFAULT CURRENT_TIMESTAMP NOT NULL,

                              UPDATED_AT TIMESTAMP
                                  DEFAULT CURRENT_TIMESTAMP NOT NULL,

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
                          PAYMENT_ID BIGINT GENERATED ALWAYS AS IDENTITY,

                          TRANSACTION_ID BIGINT NOT NULL,

                          PAYMENT_CODE VARCHAR(50) NOT NULL,

                          AMOUNT NUMERIC(18,2) NOT NULL,

                          PAYMENT_TYPE VARCHAR(30) NOT NULL,

                          PAYMENT_METHOD VARCHAR(30) NOT NULL,

                          PAYMENT_DATE TIMESTAMP
                              DEFAULT CURRENT_TIMESTAMP NOT NULL,

                          REFERENCE_NUMBER VARCHAR(100),

                          STATUS VARCHAR(30)
        DEFAULT 'SUCCESS' NOT NULL,

                          NOTE VARCHAR(1000),

                          CREATED_AT TIMESTAMP
                              DEFAULT CURRENT_TIMESTAMP NOT NULL,

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
                         REVIEW_ID BIGINT GENERATED ALWAYS AS IDENTITY,

                         CUSTOMER_ID BIGINT NOT NULL,

                         PROPERTY_ID BIGINT NOT NULL,

                         RATING SMALLINT NOT NULL,

                         COMMENT_TEXT VARCHAR(1000),

                         REVIEW_DATE TIMESTAMP
                             DEFAULT CURRENT_TIMESTAMP NOT NULL,

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
    ON PROPERTY_IMAGES (PROPERTY_ID)
    WHERE IS_THUMBNAIL = 1;



-- ============================================================
-- TRIGGER (viết lại bằng PL/pgSQL)
-- ============================================================
CREATE OR REPLACE FUNCTION fn_set_updated_at() RETURNS trigger AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_properties_updated BEFORE UPDATE ON properties
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();
CREATE TRIGGER trg_listings_updated BEFORE UPDATE ON listings
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- Giao dịch COMPLETED -> listing / property / apartment thành SOLD
CREATE OR REPLACE FUNCTION fn_transaction_completed() RETURNS trigger AS $$
BEGIN
    UPDATE listings SET status = 'SOLD' WHERE listing_id = NEW.listing_id;
    UPDATE properties SET status = 'SOLD'
     WHERE property_id = (SELECT property_id FROM listings WHERE listing_id = NEW.listing_id);
    UPDATE apartments SET status = 'SOLD'
     WHERE apartment_id = (SELECT apartment_id FROM properties
                            WHERE property_id = (SELECT property_id FROM listings WHERE listing_id = NEW.listing_id));
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_transaction_completed AFTER INSERT OR UPDATE OF status ON transactions
    FOR EACH ROW WHEN (NEW.status = 'COMPLETED') EXECUTE FUNCTION fn_transaction_completed();

-- Thanh toán SUCCESS -> tính lại tiền cọc, tiền còn lại, trạng thái thanh toán
CREATE OR REPLACE FUNCTION fn_payment_success() RETURNS trigger AS $$
DECLARE
    v_agreed NUMERIC(18,2);
    v_paid   NUMERIC(18,2);
BEGIN
    SELECT agreed_price INTO v_agreed FROM transactions WHERE transaction_id = NEW.transaction_id;
    SELECT COALESCE(SUM(amount), 0) INTO v_paid FROM payments
     WHERE transaction_id = NEW.transaction_id AND status = 'SUCCESS' AND payment_type <> 'REFUND';
    UPDATE transactions
       SET deposit_amount = COALESCE((SELECT SUM(amount) FROM payments
                                       WHERE transaction_id = NEW.transaction_id
                                         AND payment_type = 'DEPOSIT' AND status = 'SUCCESS'), 0),
           remaining_amount = GREATEST(v_agreed - v_paid, 0),
           payment_status = CASE WHEN v_paid = 0 THEN 'PENDING'
                                 WHEN v_paid < v_agreed THEN 'PARTIAL' ELSE 'PAID' END
     WHERE transaction_id = NEW.transaction_id;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_payment_success AFTER INSERT OR UPDATE OF status, amount ON payments
    FOR EACH ROW WHEN (NEW.status = 'SUCCESS') EXECUTE FUNCTION fn_payment_success();

-- payment_status = PAID -> status = PROCESSING (nếu chưa hủy / hoàn tất)
CREATE OR REPLACE FUNCTION fn_transaction_payment_status() RETURNS trigger AS $$
BEGIN
    IF NEW.status NOT IN ('CANCELLED', 'COMPLETED') THEN NEW.status := 'PROCESSING'; END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_transaction_payment_status BEFORE UPDATE OF payment_status ON transactions
    FOR EACH ROW WHEN (NEW.payment_status = 'PAID') EXECUTE FUNCTION fn_transaction_payment_status();


-- ============================================================
-- 16. PROPERTY VIEWINGS - LICH HEN XEM BAT DONG SAN
-- PostgreSQL: EXCLUDE USING GIST ngan hai lich trung gio tren cung property
-- ============================================================
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE property_viewings (
    viewing_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customers(customer_id),
    property_id BIGINT NOT NULL REFERENCES properties(property_id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    note VARCHAR(1000),
    cancellation_reason VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_viewing_time CHECK (end_time > start_time),
    CONSTRAINT ck_viewing_status CHECK (
        status IN ('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED', 'REJECTED')
    ),
    CONSTRAINT ex_viewing_no_overlap EXCLUDE USING GIST (
        property_id WITH =,
        tsrange(start_time, end_time, '[)') WITH &&
    ) WHERE (status IN ('PENDING', 'CONFIRMED'))
);

CREATE INDEX idx_viewings_customer ON property_viewings(customer_id);
CREATE INDEX idx_viewings_property_start ON property_viewings(property_id, start_time);
CREATE INDEX idx_viewings_status ON property_viewings(status);

CREATE TRIGGER trg_viewings_updated
BEFORE UPDATE ON property_viewings
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- Khóa dòng property để đồng bộ việc đặt lịch với thao tác đặt cọc.
-- Chỉ kiểm tra trạng thái AVAILABLE khi tạo/kích hoạt lịch.
CREATE OR REPLACE FUNCTION fn_viewing_validate() RETURNS trigger AS $$
DECLARE
    v_property_status VARCHAR(30);
BEGIN
    IF NEW.status IN ('PENDING', 'CONFIRMED')
       AND (TG_OP = 'INSERT'
            OR OLD.status NOT IN ('PENDING', 'CONFIRMED')
            OR NEW.property_id IS DISTINCT FROM OLD.property_id
            OR NEW.start_time IS DISTINCT FROM OLD.start_time
            OR NEW.end_time IS DISTINCT FROM OLD.end_time) THEN
        SELECT status INTO v_property_status
          FROM properties WHERE property_id = NEW.property_id FOR UPDATE;
        IF v_property_status IS DISTINCT FROM 'AVAILABLE' THEN
            RAISE EXCEPTION 'Property % khong AVAILABLE, khong the dat lich', NEW.property_id;
        END IF;
        IF NOT EXISTS (
            SELECT 1 FROM listings
             WHERE property_id = NEW.property_id AND status = 'ACTIVE'
        ) THEN
            RAISE EXCEPTION 'Property % khong co listing ACTIVE', NEW.property_id;
        END IF;
        IF NEW.start_time <= CURRENT_TIMESTAMP THEN
            RAISE EXCEPTION 'Lich xem phai bat dau trong tuong lai';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_viewings_validate
BEFORE INSERT OR UPDATE ON property_viewings
FOR EACH ROW EXECUTE FUNCTION fn_viewing_validate();

-- Khóa property khi xác nhận khoản cọc, chống hai giao dịch cùng giữ một căn.
CREATE OR REPLACE FUNCTION fn_deposit_validate() RETURNS trigger AS $$
DECLARE
    v_property_id BIGINT;
    v_status VARCHAR(30);
BEGIN
    IF NEW.payment_type = 'DEPOSIT' AND NEW.status = 'SUCCESS' THEN
        SELECT l.property_id INTO v_property_id
          FROM transactions t JOIN listings l ON l.listing_id = t.listing_id
         WHERE t.transaction_id = NEW.transaction_id;
        SELECT status INTO v_status FROM properties
         WHERE property_id = v_property_id FOR UPDATE;
        IF v_status NOT IN ('AVAILABLE', 'RESERVED') THEN
            RAISE EXCEPTION 'Property % da ban/an, khong the dat coc', v_property_id;
        END IF;
        IF EXISTS (
            SELECT 1
              FROM transactions t JOIN listings l ON l.listing_id = t.listing_id
              JOIN payments pay ON pay.transaction_id = t.transaction_id
             WHERE l.property_id = v_property_id
               AND t.transaction_id <> NEW.transaction_id
               AND t.status <> 'CANCELLED'
               AND pay.payment_type = 'DEPOSIT' AND pay.status = 'SUCCESS'
        ) THEN
            RAISE EXCEPTION 'Property % da co giao dich dat coc khac', v_property_id;
        END IF;
        IF v_status = 'RESERVED' AND NOT EXISTS (
            SELECT 1 FROM payments pay
             WHERE pay.transaction_id = NEW.transaction_id
               AND pay.payment_type = 'DEPOSIT' AND pay.status = 'SUCCESS'
        ) THEN
            RAISE EXCEPTION 'Property % da duoc giu cho', v_property_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_deposit_validate
BEFORE INSERT OR UPDATE OF status, amount, transaction_id, payment_type ON payments
FOR EACH ROW EXECUTE FUNCTION fn_deposit_validate();

-- Sau khi thanh toán cọc SUCCESS: giữ căn, hủy lịch tương lai của khách khác.
-- Không hủy lịch đã COMPLETED; không xóa lịch sử.
CREATE OR REPLACE FUNCTION fn_deposit_reserve_property() RETURNS trigger AS $$
DECLARE
    v_property_id BIGINT;
    v_customer_id BIGINT;
BEGIN
    IF NEW.payment_type <> 'DEPOSIT' OR NEW.status <> 'SUCCESS' THEN
        RETURN NEW;
    END IF;

    SELECT l.property_id, t.customer_id
      INTO v_property_id, v_customer_id
      FROM transactions t JOIN listings l ON l.listing_id = t.listing_id
     WHERE t.transaction_id = NEW.transaction_id;

    UPDATE properties SET status = 'RESERVED'
     WHERE property_id = v_property_id AND status = 'AVAILABLE';

    UPDATE apartments SET status = 'RESERVED'
     WHERE apartment_id = (SELECT apartment_id FROM properties
                            WHERE property_id = v_property_id)
       AND status = 'AVAILABLE';

    UPDATE transactions SET status = 'DEPOSITED'
     WHERE transaction_id = NEW.transaction_id AND status = 'PENDING';

    UPDATE property_viewings
       SET status = 'CANCELLED',
           cancellation_reason = 'Bat dong san da duoc khach khac dat coc'
     WHERE property_id = v_property_id
       AND customer_id <> v_customer_id
       AND status IN ('PENDING', 'CONFIRMED')
       AND end_time > CURRENT_TIMESTAMP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_deposit_reserve_property
AFTER INSERT OR UPDATE OF status ON payments
FOR EACH ROW
WHEN (NEW.payment_type = 'DEPOSIT' AND NEW.status = 'SUCCESS')
EXECUTE FUNCTION fn_deposit_reserve_property();

-- Ghi chu: viec hoan coc / huy giao dich / mo ban lai can quy trinh
-- nghiep vu rieng, khong tu dong mo RESERVED chi bang UPDATE status.
