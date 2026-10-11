--
-- PostgreSQL database dump
--

\restrict EGX7jGcZiUiKZQ1t53A1oQhYwpOtz4D2EIXmZgF7E0c7FTOoCKn0VdCp4SFBCNH

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

-- Started on 2026-10-11 17:15:08

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 17521)
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- TOC entry 5602 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- TOC entry 341 (class 1255 OID 18288)
-- Name: fn_deposit_reserve_property(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_deposit_reserve_property() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- TOC entry 324 (class 1255 OID 18286)
-- Name: fn_deposit_validate(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_deposit_validate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- TOC entry 289 (class 1255 OID 17517)
-- Name: fn_payment_success(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_payment_success() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
END; $$;


--
-- TOC entry 396 (class 1255 OID 17512)
-- Name: fn_set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END; $$;


--
-- TOC entry 285 (class 1255 OID 17515)
-- Name: fn_transaction_completed(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_transaction_completed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE listings SET status = 'SOLD' WHERE listing_id = NEW.listing_id;
    UPDATE properties SET status = 'SOLD'
     WHERE property_id = (SELECT property_id FROM listings WHERE listing_id = NEW.listing_id);
    UPDATE apartments SET status = 'SOLD'
     WHERE apartment_id = (SELECT apartment_id FROM properties
                            WHERE property_id = (SELECT property_id FROM listings WHERE listing_id = NEW.listing_id));
    RETURN NEW;
END; $$;


--
-- TOC entry 427 (class 1255 OID 17519)
-- Name: fn_transaction_payment_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_transaction_payment_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.status NOT IN ('CANCELLED', 'COMPLETED') THEN NEW.status := 'PROCESSING'; END IF;
    RETURN NEW;
END; $$;


--
-- TOC entry 292 (class 1255 OID 18284)
-- Name: fn_viewing_validate(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_viewing_validate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


SET default_table_access_method = heap;

--
-- TOC entry 228 (class 1259 OID 17246)
-- Name: apartments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apartments (
    apartment_id bigint NOT NULL,
    building_id bigint NOT NULL,
    apartment_code character varying(50) NOT NULL,
    floor_number bigint NOT NULL,
    room_number character varying(50),
    area numeric(10,2) NOT NULL,
    bedrooms bigint DEFAULT 0 NOT NULL,
    bathrooms bigint DEFAULT 0 NOT NULL,
    balcony_area numeric(10,2),
    direction character varying(50),
    view_type character varying(100),
    legal_status character varying(50) DEFAULT 'PENDING'::character varying NOT NULL,
    status character varying(30) DEFAULT 'AVAILABLE'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_apartments_area CHECK ((area > (0)::numeric)),
    CONSTRAINT ck_apartments_balcony CHECK (((balcony_area IS NULL) OR (balcony_area >= (0)::numeric))),
    CONSTRAINT ck_apartments_bathrooms CHECK ((bathrooms >= 0)),
    CONSTRAINT ck_apartments_bedrooms CHECK ((bedrooms >= 0)),
    CONSTRAINT ck_apartments_floor CHECK ((floor_number >= 0)),
    CONSTRAINT ck_apartments_legal CHECK (((legal_status)::text = ANY ((ARRAY['PENDING'::character varying, 'CERTIFIED'::character varying, 'MORTGAGED'::character varying, 'DISPUTED'::character varying])::text[]))),
    CONSTRAINT ck_apartments_status CHECK (((status)::text = ANY ((ARRAY['AVAILABLE'::character varying, 'RESERVED'::character varying, 'SOLD'::character varying, 'HIDDEN'::character varying])::text[])))
);


--
-- TOC entry 227 (class 1259 OID 17245)
-- Name: apartments_apartment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.apartments ALTER COLUMN apartment_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.apartments_apartment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 226 (class 1259 OID 17221)
-- Name: buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.buildings (
    building_id bigint NOT NULL,
    building_code character varying(30) NOT NULL,
    building_name character varying(200) NOT NULL,
    address character varying(500) NOT NULL,
    ward character varying(100),
    district character varying(100),
    city character varying(100),
    total_floors bigint NOT NULL,
    total_apartments bigint DEFAULT 0 NOT NULL,
    year_built numeric(4,0),
    description text,
    status character varying(30) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_buildings_apartments CHECK ((total_apartments >= 0)),
    CONSTRAINT ck_buildings_floors CHECK ((total_floors > 0)),
    CONSTRAINT ck_buildings_status CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying, 'MAINTENANCE'::character varying])::text[]))),
    CONSTRAINT ck_buildings_year CHECK (((year_built IS NULL) OR (year_built >= (1900)::numeric)))
);


--
-- TOC entry 225 (class 1259 OID 17220)
-- Name: buildings_building_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.buildings ALTER COLUMN building_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.buildings_building_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 223 (class 1259 OID 17195)
-- Name: customer_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_locations (
    customer_id bigint NOT NULL,
    location_name character varying(100) NOT NULL
);


--
-- TOC entry 222 (class 1259 OID 17184)
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    customer_id bigint NOT NULL
);


--
-- TOC entry 233 (class 1259 OID 17329)
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    customer_id bigint NOT NULL,
    property_id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- TOC entry 235 (class 1259 OID 17349)
-- Name: listings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.listings (
    listing_id bigint NOT NULL,
    listing_code character varying(50) NOT NULL,
    owner_id bigint NOT NULL,
    property_id bigint NOT NULL,
    listing_title character varying(200),
    asking_price numeric(18,2) NOT NULL,
    description text,
    post_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expiry_date timestamp without time zone,
    status character varying(30) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    listing_type character varying(10) DEFAULT 'SALE'::character varying NOT NULL,
    CONSTRAINT ck_listings_date CHECK (((expiry_date IS NULL) OR (expiry_date >= post_date))),
    CONSTRAINT ck_listings_listing_type CHECK (((listing_type)::text = ANY ((ARRAY['SALE'::character varying, 'RENT'::character varying])::text[]))),
    CONSTRAINT ck_listings_price CHECK ((asking_price >= (0)::numeric)),
    CONSTRAINT ck_listings_status CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'EXPIRED'::character varying, 'SOLD'::character varying, 'HIDDEN'::character varying, 'CANCELLED'::character varying])::text[])))
);


--
-- TOC entry 234 (class 1259 OID 17348)
-- Name: listings_listing_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.listings ALTER COLUMN listing_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.listings_listing_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 224 (class 1259 OID 17207)
-- Name: owners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.owners (
    owner_id bigint NOT NULL,
    tax_code character varying(50)
);


--
-- TOC entry 239 (class 1259 OID 17434)
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    payment_id bigint NOT NULL,
    transaction_id bigint NOT NULL,
    payment_code character varying(50) NOT NULL,
    amount numeric(18,2) NOT NULL,
    payment_type character varying(30) NOT NULL,
    payment_method character varying(30) NOT NULL,
    payment_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    reference_number character varying(100),
    status character varying(30) DEFAULT 'SUCCESS'::character varying NOT NULL,
    note character varying(1000),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_payments_amount CHECK ((amount > (0)::numeric)),
    CONSTRAINT ck_payments_method CHECK (((payment_method)::text = ANY ((ARRAY['CASH'::character varying, 'BANK_TRANSFER'::character varying, 'MIXED'::character varying])::text[]))),
    CONSTRAINT ck_payments_status CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'SUCCESS'::character varying, 'FAILED'::character varying, 'REFUNDED'::character varying])::text[]))),
    CONSTRAINT ck_payments_type CHECK (((payment_type)::text = ANY ((ARRAY['DEPOSIT'::character varying, 'INSTALLMENT'::character varying, 'FINAL'::character varying, 'REFUND'::character varying])::text[])))
);


--
-- TOC entry 238 (class 1259 OID 17433)
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.payments ALTER COLUMN payment_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.payments_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 230 (class 1259 OID 17281)
-- Name: properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.properties (
    property_id bigint NOT NULL,
    apartment_id bigint NOT NULL,
    title character varying(200) NOT NULL,
    price numeric(18,2) NOT NULL,
    price_per_m2 numeric(18,2),
    description text,
    address character varying(500),
    status character varying(30) DEFAULT 'AVAILABLE'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    listing_type character varying(10) DEFAULT 'SALE'::character varying NOT NULL,
    is_illustrative boolean DEFAULT false NOT NULL,
    CONSTRAINT ck_properties_listing_type CHECK (((listing_type)::text = ANY ((ARRAY['SALE'::character varying, 'RENT'::character varying])::text[]))),
    CONSTRAINT ck_properties_price CHECK ((price >= (0)::numeric)),
    CONSTRAINT ck_properties_price_m2 CHECK (((price_per_m2 IS NULL) OR (price_per_m2 >= (0)::numeric))),
    CONSTRAINT ck_properties_status CHECK (((status)::text = ANY ((ARRAY['AVAILABLE'::character varying, 'RESERVED'::character varying, 'SOLD'::character varying, 'HIDDEN'::character varying])::text[])))
);


--
-- TOC entry 229 (class 1259 OID 17280)
-- Name: properties_property_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.properties ALTER COLUMN property_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.properties_property_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 232 (class 1259 OID 17309)
-- Name: property_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.property_images (
    image_id bigint NOT NULL,
    property_id bigint NOT NULL,
    image_url character varying(500) NOT NULL,
    is_thumbnail smallint DEFAULT 0 NOT NULL,
    uploaded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_images_thumbnail CHECK ((is_thumbnail = ANY (ARRAY[0, 1])))
);


--
-- TOC entry 231 (class 1259 OID 17308)
-- Name: property_images_image_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.property_images ALTER COLUMN image_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.property_images_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 243 (class 1259 OID 18248)
-- Name: property_viewings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.property_viewings (
    viewing_id bigint NOT NULL,
    customer_id bigint NOT NULL,
    property_id bigint NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    note character varying(1000),
    cancellation_reason character varying(500),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_viewing_status CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'CONFIRMED'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying, 'REJECTED'::character varying])::text[]))),
    CONSTRAINT ck_viewing_time CHECK ((end_time > start_time))
);


--
-- TOC entry 242 (class 1259 OID 18247)
-- Name: property_viewings_viewing_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.property_viewings ALTER COLUMN viewing_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.property_viewings_viewing_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 247 (class 1259 OID 18326)
-- Name: rental_apartment_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rental_apartment_images (
    image_id bigint NOT NULL,
    rental_id bigint NOT NULL,
    image_url character varying(500) NOT NULL,
    sort_order smallint NOT NULL,
    is_thumbnail smallint DEFAULT 0 NOT NULL,
    is_illustrative boolean DEFAULT true NOT NULL,
    CONSTRAINT rental_apartment_images_is_thumbnail_check CHECK ((is_thumbnail = ANY (ARRAY[0, 1])))
);


--
-- TOC entry 246 (class 1259 OID 18325)
-- Name: rental_apartment_images_image_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.rental_apartment_images ALTER COLUMN image_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rental_apartment_images_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 245 (class 1259 OID 18296)
-- Name: rental_apartments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rental_apartments (
    rental_id bigint NOT NULL,
    source_listing_code character varying(50) NOT NULL,
    building_name character varying(200) NOT NULL,
    title character varying(250) NOT NULL,
    monthly_rent numeric(18,2) NOT NULL,
    area numeric(10,2) NOT NULL,
    bedrooms integer NOT NULL,
    bathrooms integer NOT NULL,
    street_address character varying(500),
    ward character varying(150),
    city character varying(150),
    description text,
    listing_type character varying(10) DEFAULT 'RENT'::character varying NOT NULL,
    status character varying(30) DEFAULT 'AVAILABLE'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT rental_apartments_area_check CHECK ((area > (0)::numeric)),
    CONSTRAINT rental_apartments_bathrooms_check CHECK ((bathrooms >= 0)),
    CONSTRAINT rental_apartments_bedrooms_check CHECK ((bedrooms >= 0)),
    CONSTRAINT rental_apartments_listing_type_check CHECK (((listing_type)::text = 'RENT'::text)),
    CONSTRAINT rental_apartments_monthly_rent_check CHECK ((monthly_rent >= (0)::numeric)),
    CONSTRAINT rental_apartments_status_check CHECK (((status)::text = ANY ((ARRAY['AVAILABLE'::character varying, 'HIDDEN'::character varying, 'RENTED'::character varying])::text[])))
);


--
-- TOC entry 244 (class 1259 OID 18295)
-- Name: rental_apartments_rental_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.rental_apartments ALTER COLUMN rental_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rental_apartments_rental_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 241 (class 1259 OID 17465)
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    review_id bigint NOT NULL,
    customer_id bigint NOT NULL,
    property_id bigint NOT NULL,
    rating smallint NOT NULL,
    comment_text character varying(1000),
    review_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_reviews_rating CHECK (((rating >= 1) AND (rating <= 5)))
);


--
-- TOC entry 240 (class 1259 OID 17464)
-- Name: reviews_review_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.reviews ALTER COLUMN review_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.reviews_review_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 237 (class 1259 OID 17385)
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    transaction_id bigint NOT NULL,
    transaction_code character varying(50) NOT NULL,
    customer_id bigint NOT NULL,
    listing_id bigint NOT NULL,
    transaction_type character varying(30) DEFAULT 'PURCHASE'::character varying NOT NULL,
    listing_price numeric(18,2),
    agreed_price numeric(18,2) NOT NULL,
    deposit_amount numeric(18,2) DEFAULT 0 NOT NULL,
    remaining_amount numeric(18,2) DEFAULT 0 NOT NULL,
    transaction_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    contract_date timestamp without time zone,
    completion_date timestamp without time zone,
    payment_method character varying(30),
    payment_status character varying(30) DEFAULT 'PENDING'::character varying NOT NULL,
    status character varying(30) DEFAULT 'PENDING'::character varying NOT NULL,
    note character varying(1000),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_transaction_agreed_price CHECK ((agreed_price >= (0)::numeric)),
    CONSTRAINT ck_transaction_deposit CHECK ((deposit_amount >= (0)::numeric)),
    CONSTRAINT ck_transaction_listing_price CHECK (((listing_price IS NULL) OR (listing_price >= (0)::numeric))),
    CONSTRAINT ck_transaction_payment_method CHECK (((payment_method IS NULL) OR ((payment_method)::text = ANY ((ARRAY['CASH'::character varying, 'BANK_TRANSFER'::character varying, 'MIXED'::character varying])::text[])))),
    CONSTRAINT ck_transaction_payment_status CHECK (((payment_status)::text = ANY ((ARRAY['PENDING'::character varying, 'PARTIAL'::character varying, 'PAID'::character varying, 'REFUNDED'::character varying])::text[]))),
    CONSTRAINT ck_transaction_remaining CHECK ((remaining_amount >= (0)::numeric)),
    CONSTRAINT ck_transaction_status CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'DEPOSITED'::character varying, 'PROCESSING'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))),
    CONSTRAINT ck_transaction_type CHECK (((transaction_type)::text = 'PURCHASE'::text))
);


--
-- TOC entry 236 (class 1259 OID 17384)
-- Name: transactions_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.transactions ALTER COLUMN transaction_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.transactions_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 221 (class 1259 OID 17163)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id bigint NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role character varying(20) DEFAULT 'CUSTOMER'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_active smallint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_users_active CHECK ((is_active = ANY (ARRAY[0, 1]))),
    CONSTRAINT ck_users_role CHECK (((role)::text = ANY ((ARRAY['ADMIN'::character varying, 'CUSTOMER'::character varying, 'OWNER'::character varying])::text[])))
);


--
-- TOC entry 220 (class 1259 OID 17162)
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.users ALTER COLUMN user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 5577 (class 0 OID 17246)
-- Dependencies: 228
-- Data for Name: apartments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.apartments (apartment_id, building_id, apartment_code, floor_number, room_number, area, bedrooms, bathrooms, balcony_area, direction, view_type, legal_status, status, created_at) FROM stdin;
2	1	S9.01-1808	18	08	75.20	3	2	6.00	Nam	View thanh pho	CERTIFIED	AVAILABLE	2026-10-11 12:56:50.41717
4	2	MT-1503	15	03	65.70	2	2	5.00	Tay Nam	View noi khu	CERTIFIED	AVAILABLE	2026-10-11 12:56:50.41717
5	3	SC-2001	20	01	90.50	3	2	8.00	Dong Nam	View thanh pho	CERTIFIED	AVAILABLE	2026-10-11 12:56:50.41717
1	1	S9.01-1205	12	05	68.50	2	2	5.20	Dong Nam	View cong vien	CERTIFIED	SOLD	2026-10-11 12:56:50.41717
3	2	MT-2506	25	06	82.30	3	2	7.00	Dong	View song	CERTIFIED	RESERVED	2026-10-11 12:56:50.41717
6	19	EGR-102	0	\N	65.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
7	24	MST-101	0	\N	48.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
8	6	TMQ-101	0	\N	52.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
9	24	MST-102	0	\N	68.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
10	25	LMN-102	0	\N	96.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
11	16	CTG-102	0	\N	105.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
12	10	PMC-101	0	\N	55.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
13	19	EGR-103	0	\N	85.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
14	9	VGR-101	0	\N	50.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
15	16	CTG-101	0	\N	70.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
16	16	CTG-103	0	\N	140.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
17	5	SSV-103	0	\N	330.00	4	4	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
18	13	SCV-102	0	\N	80.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
19	4	GTW-103	0	\N	122.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
20	8	HDC-104	0	\N	123.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
21	3	SRC-103	0	\N	120.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
22	4	GTW-104	0	\N	180.00	4	3	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
23	22	MDT-102	0	\N	89.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
24	19	EGR-101	0	\N	45.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
25	10	PMC-104	0	\N	140.00	3	3	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
26	13	SCV-104	0	\N	130.00	3	3	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
27	14	ESH-104	0	\N	250.00	4	4	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
28	8	HDC-102	0	\N	86.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
29	5	SSV-104	0	\N	500.00	5	5	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
30	23	TRV-103	0	\N	125.00	3	3	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
31	8	HDC-101	0	\N	53.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
32	13	SCV-101	0	\N	70.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
33	22	MDT-104	0	\N	160.00	4	3	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
34	25	LMN-104	0	\N	200.00	4	4	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
35	9	VGR-103	0	\N	110.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
36	3	SRC-102	0	\N	76.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
37	3	SRC-104	0	\N	210.00	4	4	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
38	15	SWP-101	0	\N	56.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
39	5	SSV-102	0	\N	210.00	3	3	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
40	15	SWP-104	0	\N	230.00	4	4	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
41	9	VGR-102	0	\N	78.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
42	17	VGP-102	0	\N	59.00	2	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
43	16	CTG-104	0	\N	220.00	4	4	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
44	23	TRV-104	0	\N	240.00	4	4	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
45	12	EMP-102	0	\N	93.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
46	17	VGP-103	0	\N	72.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
47	22	MDT-101	0	\N	62.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
48	22	MDT-103	0	\N	121.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
49	3	SRC-101	0	\N	56.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
50	11	TGC-102	0	\N	75.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
51	18	MTP-103	0	\N	120.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
52	21	INF-102	0	\N	82.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
53	21	INF-103	0	\N	120.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
54	11	TGC-101	0	\N	50.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
55	12	EMP-101	0	\N	64.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
56	6	TMQ-104	0	\N	146.00	4	3	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
57	14	ESH-102	0	\N	90.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
58	9	VGR-104	0	\N	160.00	4	3	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
59	23	TRV-102	0	\N	84.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
60	20	GMS-102	0	\N	88.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
61	10	PMC-102	0	\N	78.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
62	5	SSV-101	0	\N	136.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
63	4	GTW-101	0	\N	52.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
64	21	INF-101	0	\N	58.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
65	15	SWP-102	0	\N	102.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
66	21	INF-104	0	\N	150.00	3	3	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
67	12	EMP-103	0	\N	155.00	3	3	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
68	7	VCP-101	0	\N	54.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
69	26	DMI-101	0	\N	55.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
70	14	ESH-101	0	\N	60.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
71	15	SWP-103	0	\N	128.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
72	17	VGP-104	0	\N	100.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
73	18	MTP-102	0	\N	82.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
74	20	GMS-101	0	\N	59.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
75	11	TGC-104	0	\N	190.00	4	4	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
76	7	VCP-102	0	\N	78.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
77	7	VCP-104	0	\N	144.00	4	3	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
78	14	ESH-103	0	\N	130.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
79	6	TMQ-102	0	\N	78.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
80	24	MST-103	0	\N	90.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
81	18	MTP-101	0	\N	55.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
82	10	PMC-103	0	\N	105.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
83	13	SCV-103	0	\N	110.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
84	26	DMI-102	0	\N	88.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
85	8	HDC-103	0	\N	107.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
86	24	MST-104	0	\N	130.00	3	3	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
87	23	TRV-101	0	\N	57.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
88	12	EMP-104	0	\N	220.00	4	4	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
89	19	EGR-104	0	\N	95.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
90	18	MTP-104	0	\N	170.00	4	4	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
91	26	DMI-103	0	\N	125.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
92	26	DMI-104	0	\N	210.00	4	4	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
93	20	GMS-104	0	\N	220.00	4	4	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
94	20	GMS-103	0	\N	133.00	3	3	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
95	17	VGP-101	0	\N	33.00	1	1	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
96	11	TGC-103	0	\N	105.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
97	4	GTW-102	0	\N	85.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
98	25	LMN-103	0	\N	113.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
99	25	LMN-101	0	\N	75.00	2	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
100	7	VCP-103	0	\N	115.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
101	6	TMQ-103	0	\N	120.00	3	2	\N	\N	\N	PENDING	AVAILABLE	2026-10-11 15:43:02.119508
\.


--
-- TOC entry 5575 (class 0 OID 17221)
-- Dependencies: 226
-- Data for Name: buildings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.buildings (building_id, building_code, building_name, address, ward, district, city, total_floors, total_apartments, year_built, description, status, created_at) FROM stdin;
1	B001	Vinhomes Grand Park - S9.01	Nguyễn Xiển	Long Bình	Thủ Đức	TP. Hồ Chí Minh	36	500	2022	Chung cu cao cap gan cong vien Grand Park.	ACTIVE	2026-10-11 12:56:50.41717
2	B002	Masteri Thao Dien	159 Xa Lộ Hà Nội	Thảo Điền	Thủ Đức	TP. Hồ Chí Minh	41	600	2016	Can ho cao cap khu Thao Dien.	ACTIVE	2026-10-11 12:56:50.41717
3	B003	Sunrise City	23 Nguyễn Hữu Thọ	Tân Hưng	Quận 7	TP. Hồ Chí Minh	35	450	2015	Khu can ho hien dai gan trung tam District 7.	ACTIVE	2026-10-11 12:56:50.41717
4	B004	The Gateway Thảo Điền	2 Trần Ngọc Diện	Phường Thảo Điền	Quận 2	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
5	B005	Serenity Sky Villas	259 Điện Biên Phủ	Phường Xuân Khánh	Quận 3	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
6	B006	The Marq	29B Nguyễn Đình Chiểu	Phường Đa Kao	Quận 1	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
7	B007	Vinhomes Central Park	208 Nguyễn Hữu Cảnh	Phường Thạnh Mỹ Tây	Bình Thạnh	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
8	B008	Haado Centrosa Garden	200 3 Tháng 2	Phường Hòa Hưng	Quận 10	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
9	B009	Vinhomes Golden River (Ba Son)	2 Tôn Đức Thắng	Phường Bến Nghé	Quận 1	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
10	B010	Palm Heights / Palm City	Đường Song Hành	Phường An Phú	Quận 2	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
11	B011	The Global City	Đường Đỗ Xuân Hợp	Phường An Phú	Quận 2	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
12	B012	Empire City	Khu đô thị mới Thủ Thiêm	Phường Thủ Thiêm	Quận 2	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
13	B013	Scenic Valley	Đường Tôn Dật Tiên	Phường Tân Phú	Quận 7	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
14	B014	Estella Heights	88 Xa Lộ Hà Nội	Phường Thảo Điền	Quận 2	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
15	B015	Sunwah Pearl	90 Nguyễn Hữu Cảnh	Phường Thạnh Mỹ Tây	Bình Thạnh	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
16	B016	City Garden	59 Ngô Tất Tố	Phường Thạnh Mỹ Tây	Bình Thạnh	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
17	B017	Vinhomes Grand Park	Đường Nguyễn Xiển	Phường Long Bình	Quận 9	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
18	B018	The Metropole Thủ Thiêm	Khu đô thị mới Thủ Thiêm	Phường Thủ Thiêm	Quận 2	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
19	B019	Eco Green Sài Gòn	39/1B Nguyễn Văn Linh	Phường Tân Thuận	Quận 7	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
20	B020	Grand Marina Saigon	2 Tôn Đức Thắng	Phường Bến Nghé	Quận 1	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
21	B021	The Infiniti at Riviera Point	584 Huỳnh Tấn Phát	Phường Tân Phú	Quận 7	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
22	B022	Midtown Phú Mỹ Hưng	Đường Nguyễn Lương Bằng	Phường Tân Phú	Quận 7	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
23	B023	The River Thủ Thiêm	Đại lộ Trống Đồng	Phường Thủ Thiêm	Quận 2	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
24	B024	Masteri Thảo Điền	159 Xa Lộ Hà Nội	Phường Thảo Điền	Quận 2	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
25	B025	Leman Luxury Apartments	117 Nguyễn Đình Chiểu	Phường Xuân Khánh	Quận 3	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
26	B026	Đảo Kim Cương (Diamond Island)	Số 1 Đường số 104	Phường Bình Trưng	Thủ Đức	TP. Hồ Chí Minh	1	0	\N	Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.	ACTIVE	2026-10-11 15:43:02.119508
\.


--
-- TOC entry 5572 (class 0 OID 17195)
-- Dependencies: 223
-- Data for Name: customer_locations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_locations (customer_id, location_name) FROM stdin;
2	Thu Duc
3	District 1
4	Binh Thanh
\.


--
-- TOC entry 5571 (class 0 OID 17184)
-- Dependencies: 222
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customers (customer_id) FROM stdin;
2
3
4
\.


--
-- TOC entry 5582 (class 0 OID 17329)
-- Dependencies: 233
-- Data for Name: favorites; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.favorites (customer_id, property_id, created_at) FROM stdin;
2	3	2026-10-11 12:56:50.41717
3	1	2026-10-11 12:56:50.41717
\.


--
-- TOC entry 5584 (class 0 OID 17349)
-- Dependencies: 235
-- Data for Name: listings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.listings (listing_id, listing_code, owner_id, property_id, listing_title, asking_price, description, post_date, expiry_date, status, created_at, updated_at, listing_type) FROM stdin;
2	LIST-0002	5	2	Can ho 3PN Vinhomes Grand Park	3900000000.00	Can ho 3 phong ngu tang cao, view thanh pho.	2026-10-11 12:56:50.41717	2027-01-09 12:56:50.41717	ACTIVE	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717	SALE
3	LIST-0003	6	3	Can ho 3PN Masteri Thao Dien	5200000000.00	Can ho cao cap 3PN view song.	2026-10-11 12:56:50.41717	2027-01-09 12:56:50.41717	ACTIVE	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717	SALE
4	LIST-0004	6	4	Can ho 2PN Masteri Thao Dien	4200000000.00	Can ho 2PN view noi khu.	2026-10-11 12:56:50.41717	2027-01-09 12:56:50.41717	ACTIVE	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717	SALE
5	LIST-0005	5	5	Can ho 3PN Sunrise City	5800000000.00	Can ho 3PN dien tich lon, noi that cao cap.	2026-10-11 12:56:50.41717	2027-01-09 12:56:50.41717	ACTIVE	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717	SALE
1	LIST-0001	5	1	Can ho 2PN Vinhomes Grand Park	3200000000.00	Can ho 2 phong ngu, view cong vien, noi that dep.	2026-10-11 12:56:50.41717	2027-01-09 12:56:50.41717	SOLD	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717	SALE
6	RENT-HDC-103	5	6	Căn 2PN+1 Hà Đô Centrosa Garden góc 2 mặt thoáng cực rộng	24000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
7	RENT-CTG-101	5	7	Căn 1PN City Garden Bình Thạnh thiết kế gợn sóng độc đáo	20000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
8	RENT-CTG-102	5	8	Căn 2PN City Garden tháp Crescent tầng cao view Landmark 81	31000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
9	RENT-CTG-103	5	9	Căn 3PN City Garden nội thất Châu Âu thiết kế cực sang	46000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
10	RENT-CTG-104	5	10	Penthouse City Garden thiết kế Duplex đỉnh cao kiến trúc	90000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
11	RENT-DMI-101	5	11	Căn 1PN tháp Hawaii Đảo Kim Cương view sông Sài Gòn êm đềm	18000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
12	RENT-DMI-102	5	12	Căn 2PN tháp Bora Bora Đảo Kim Cương full nội thất hiện đại	26000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
13	RENT-DMI-103	5	13	Căn góc 3PN tháp Maldives Đảo Kim Cương view sông trực diện	45000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
14	RENT-DMI-104	5	14	Căn Pool Villa Đảo Kim Cương sân vườn hồ bơi riêng xa xỉ	100000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
15	RENT-EGR-101	5	15	Căn 1PN Eco Green Sài Gòn Nguyễn Văn Linh full đồ xinh xắn	12000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
16	RENT-EGR-102	5	16	Căn 2PN Eco Green Sài Gòn view công viên Hương Tràm 22ha	16000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
17	RENT-EGR-103	5	17	Căn góc 3PN Eco Green Sài Gòn tầng cao view sông cầu Phú Mỹ	22000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
18	RENT-EGR-104	5	18	Căn 3PN Eco Green Sài Gòn full nội thất gỗ cao cấp	24000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
19	RENT-EMP-101	5	19	Căn 1PN Linden Empire City Thủ Thiêm full nội thất xịn	23000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
20	RENT-EMP-102	5	20	Cho thuê căn 2PN Tilia Empire City tầng cao view nội khu mát mẻ	34000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
21	RENT-EMP-103	5	21	Căn 3PN Cove Empire City view trực diện sông thang máy riêng	70000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
22	RENT-EMP-104	5	22	Penthouse Empire City Thủ Thiêm tầng cao view 360 độ cực phẩm	120000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
23	RENT-ESH-101	5	23	Căn 1PN Estella Heights thiết kế nghỉ dưỡng full nội thất	22000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
24	RENT-ESH-102	5	24	Cho thuê căn 2PN Estella Heights tháp T3 view hồ bơi tràn bờ	32000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
25	RENT-ESH-103	5	25	Căn 3PN Estella Heights tầng cao view trọn thành phố lộng lẫy	48000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
26	RENT-ESH-104	5	26	Căn Penthouse Estella Heights sân vườn riêng đẳng cấp thượng lưu	95000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
27	RENT-GMS-101	5	27	Căn 1PN Tòa Lake Grand Marina Saigon quản lý chuẩn Marriott	38000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
28	RENT-GMS-102	5	28	Cho thuê căn 2PN Grand Marina Saigon view sông cực đẹp	58000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
29	RENT-GMS-103	5	29	Căn 3PN Hàng hiệu Marriott Grand Marina view trung tâm Q1	95000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
30	RENT-GMS-104	5	30	Căn Penthouse Masterise Grand Marina Bến Nghé siêu sang	180000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
31	RENT-GTW-101	5	31	Cho thuê căn 1PN Gateway Thảo Điền full nội thất hiện đại	19000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
32	RENT-GTW-102	5	32	Căn 2PN Gateway Thảo Điền tầng cao view sông Sài Gòn tuyệt đẹp	28000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
33	RENT-GTW-103	5	33	Căn 3PN Gateway Thảo Điền thiết kế sang trọng nội thất cao cấp	42000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
34	RENT-GTW-104	5	34	Căn Garden Villa Gateway Thảo Điền có sân vườn rộng thoáng	75000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
35	RENT-HDC-101	5	35	Căn 1PN1WC Hà Đô Centrosa Garden full nội thất hiện đại	15000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
36	RENT-HDC-102	5	36	Cho thuê căn 2PN2WC Hà Đô Centrosa tháp Orchid view hồ bơi	20000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
37	RENT-HDC-104	5	37	Căn 3PN Hà Đô Centrosa Garden tầng cao view trọn thành phố	29000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
38	RENT-INF-101	5	38	Căn 1PN The Infiniti Riviera Point full nội thất mới 100%	15000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
39	RENT-INF-102	5	39	Cho thuê căn 2PN Riviera Point view sông thoáng mát	21000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
40	RENT-INF-103	5	40	Căn góc 3PN Riviera Point tầng cao view toàn cảnh Quận 7	30000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
41	RENT-INF-104	5	41	Căn Duplex The Infiniti Riviera Point thiết kế thông tầng xa hoa	48000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
42	RENT-LMN-101	5	42	Căn 2PN Leman Luxury Nguyễn Đình Chiểu full nội thất Thụy Sỹ	32000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
43	RENT-LMN-102	5	43	Cho thuê căn 3PN Leman Luxury không gian sống yên tĩnh đẳng cấp	45000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
44	RENT-LMN-103	5	44	Căn góc 3PN Leman Luxury ban công thoáng mát nội thất xịn	52000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
45	RENT-LMN-104	5	45	Penthouse Leman Luxury tầng cao sân vườn riêng cực hiếm	90000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
46	RENT-MDT-101	5	46	Căn 1PN The Grande Midtown Phú Mỹ Hưng thiết kế Nhật Bản	17000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
47	RENT-MDT-102	5	47	Cho thuê căn 2PN The Symphony Midtown view Sakura Park	25000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
48	RENT-MDT-103	5	48	Căn góc 3PN The Signature Midtown tầng trung view sông biệt thự	40000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
49	RENT-MDT-104	5	49	Căn 4PN The Peak Midtown Phú Mỹ Hưng full nội thất cao cấp	62000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
50	RENT-MST-101	5	50	Cho thuê căn Studio Masteri Thảo Điền T4 full nội thất xinh xắn	13500000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
51	RENT-MST-102	5	51	Căn hộ 2PN2WC Masteri Thảo Điền T2 view sông Sài Gòn thoáng mát	18000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
52	RENT-MST-103	5	52	Căn góc 3PN Masteri Thảo Điền T1 tầng cao view Vincom sang trọng	26000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
53	RENT-MST-104	5	53	Cho thuê Duplex Masteri Thảo Điền thiết kế hiện đại, đầy đủ tiện nghi	45000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
54	RENT-MTP-101	5	54	Căn 1PN Galleria Metropole Thủ Thiêm full nội thất cao cấp	25000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
55	RENT-MTP-102	5	55	Cho thuê căn 2PN The Crest Metropole view cầu Ba Sơn tuyệt đẹp	38000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
56	RENT-MTP-103	5	56	Căn 3PN Opera Metropole Thủ Thiêm ban công rộng view sông	60000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
57	RENT-MTP-104	5	57	Căn 4PN VIP Metropole Thủ Thiêm thang máy riêng biệt xa hoa	110000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
58	RENT-PMC-101	5	58	Căn 1PN Palm Heights An Phú full nội thất xinh xắn	14000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
59	RENT-PMC-102	5	59	Căn 2PN Palm Heights view sông mát mẻ tầng cao	18500000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
60	RENT-PMC-103	5	60	Căn góc 3PN Palm Heights diện tích rộng full đồ cao cấp	25000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
61	RENT-PMC-104	5	61	Cho thuê căn Duplex Palm Garden không gian thoáng đãng	42000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
62	RENT-SCV-101	5	62	Căn 2PN Scenic Valley Phú Mỹ Hưng full nội thất xinh xắn	16000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
63	RENT-SCV-102	5	63	Căn 2PN Scenic Valley view hồ bơi nội khu xanh mát	18000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
64	RENT-SCV-103	5	64	Căn 3PN Scenic Valley Phú Mỹ Hưng căn góc view sân Golf	26000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
65	RENT-SCV-104	5	65	Cho thuê căn 3PN Scenic Valley tầng cao thoáng mát full đồ	28000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
66	RENT-SRC-101	5	66	Căn 1PN Sunrise City Central full nội thất đẹp giá tốt	13000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
67	RENT-SRC-102	5	67	Căn 2PN Sunrise City South tầng cao view trung tâm lộng lẫy	17500000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
68	RENT-SRC-103	5	68	Căn góc 3PN Sunrise City North thiết kế rộng rãi thoáng mát	23000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
69	RENT-SRC-104	5	69	Căn Penthouse Sunrise City South diện tích lớn view 360 độ	55000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
70	RENT-SSV-101	5	70	Biệt thự trên không Serenity Sky Villas 2PN hồ bơi riêng 136m2	90000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
71	RENT-SSV-102	5	71	Căn 3PN Serenity Sky Villas thông tầng trần cao 7m đẳng cấp	120000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
72	RENT-SSV-103	5	72	Căn 4PN Serenity Sky Villas không gian sống riêng tư tuyệt đối	160000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
73	RENT-SSV-104	5	73	Penthouse Serenity Sky Villas kiệt tác thượng lưu số 1 Sài Gòn	250000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
74	RENT-SWP-101	5	74	Căn 1PN Sunwah Pearl tháp White House full đồ siêu đẹp	20000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
75	RENT-SWP-102	5	75	Cho thuê căn 2PN Sunwah Pearl tháp Silver House view sông cực phẩm	30000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
76	RENT-SWP-103	5	76	Căn góc 3PN Sunwah Pearl tháp Golden House ngắm trọn Bason	48000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
77	RENT-SWP-104	5	77	Penthouse Sunwah Pearl tầm nhìn ôm trọn sông Sài Gòn	110000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
78	RENT-TGC-101	5	78	Căn 1PN Masteri Rise Mount The Global City thiết kế đẳng cấp	18000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
79	RENT-TGC-102	5	79	Căn 2PN The Global City An Phú view kênh đào nhạc nước tuyệt đẹp	27000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
80	RENT-TGC-103	5	80	Căn góc 3PN The Global City thiết kế thông minh full tiện nghi	38000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
81	RENT-TGC-104	5	81	Cho thuê Penthouse The Global City tầm nhìn biểu tượng vô tận	85000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
82	RENT-TMQ-101	5	82	Căn 1PN The Marq Nguyễn Đình Chiểu full nội thất hạng sang	28000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
83	RENT-TMQ-102	5	83	Cho thuê căn 2PN The Marq Đa Kao view trung tâm thành phố	40000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
84	RENT-TMQ-103	5	84	Căn 3PN The Marq sang trọng có sảnh thang máy riêng biệt	65000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
85	RENT-TMQ-104	5	85	Căn 4PN The Marq Đa Kao căn góc tầng cao cực đắt giá	100000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
86	RENT-TRV-101	5	86	Căn 1PN The River Thủ Thiêm full nội thất thiết kế hiện đại	24000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
87	RENT-TRV-102	5	87	Căn 2PN The River Thủ Thiêm view trực diện sông lộng gió	36000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
88	RENT-TRV-103	5	88	Căn 3PN The River Thủ Thiêm thang máy riêng nội thất siêu sang	62000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
89	RENT-TRV-104	5	89	Căn Pool Villa The River Thủ Thiêm có hồ bơi riêng xa hoa	130000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
90	RENT-VCP-101	5	90	Căn 1PN Landmark 1 Vinhomes Central Park full nội thất cao cấp	16500000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
91	RENT-VCP-102	5	91	Cho thuê căn 2PN Park 3 view trực diện công viên 14ha lộng gió	23000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
92	RENT-VCP-103	5	92	Căn góc 3PN Central 2 Vinhomes Central Park nội thất nhập khẩu	35000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
93	RENT-VCP-104	5	93	Cho thuê căn 4PN Landmark 81 tầng cao view toàn cảnh thành phố	70000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
94	RENT-VGP-101	5	94	Cho thuê căn Studio The Rainbow Vinhomes Grand Park full đồ	6500000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
95	RENT-VGP-102	5	95	Căn 2PN1WC The Origami Vinhomes Grand Park nội thất Nhật Bản	9000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
96	RENT-VGP-103	5	96	Căn 2PN2WC Masteri Centre Point Vinhomes Grand Park cực sang	14000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
97	RENT-VGP-104	5	97	Căn 3PN The Beverly Vinhomes Grand Park view trực diện công viên 36ha	20000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
98	RENT-VGR-101	5	98	Căn 1PN Aqua 1 Vinhomes Golden River full đồ sang trọng	21000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
99	RENT-VGR-102	5	99	Cho thuê căn 2PN Lux 6 Vinhomes Golden River view trực diện sông	32000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
100	RENT-VGR-103	5	100	Căn góc 3PN Aqua 2 Vinhomes Golden River nội thất xa xỉ	50000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
101	RENT-VGR-104	5	101	Căn 4PN Penthouse Vinhomes Golden River đẳng cấp đỉnh cao	95000000.00	Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.	2026-10-11 15:43:02.119508	2027-10-11 15:43:02.119508	ACTIVE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT
\.


--
-- TOC entry 5573 (class 0 OID 17207)
-- Dependencies: 224
-- Data for Name: owners; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.owners (owner_id, tax_code) FROM stdin;
5	0312345678
6	0312345679
\.


--
-- TOC entry 5588 (class 0 OID 17434)
-- Dependencies: 239
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (payment_id, transaction_id, payment_code, amount, payment_type, payment_method, payment_date, reference_number, status, note, created_at) FROM stdin;
1	1	PAY-0001	300000000.00	DEPOSIT	BANK_TRANSFER	2026-09-21 12:56:50.41717	VCB202609010001	SUCCESS	Thanh toan dat coc	2026-10-11 12:56:50.41717
2	1	PAY-0002	1000000000.00	INSTALLMENT	BANK_TRANSFER	2026-10-01 12:56:50.41717	VCB202609100002	SUCCESS	Thanh toan dot 2	2026-10-11 12:56:50.41717
3	1	PAY-0003	1800000000.00	FINAL	BANK_TRANSFER	2026-10-09 12:56:50.41717	VCB202609080003	SUCCESS	Thanh toan day du	2026-10-11 12:56:50.41717
4	2	PAY-0004	500000000.00	DEPOSIT	BANK_TRANSFER	2026-10-08 12:56:50.41717	MB202609070004	SUCCESS	Dat coc can ho Masteri	2026-10-11 12:56:50.41717
\.


--
-- TOC entry 5579 (class 0 OID 17281)
-- Dependencies: 230
-- Data for Name: properties; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.properties (property_id, apartment_id, title, price, price_per_m2, description, address, status, created_at, updated_at, listing_type, is_illustrative) FROM stdin;
2	2	Can ho 3PN Vinhomes Grand Park	3900000000.00	51861702.00	Can ho 3 phong ngu tang cao, view thanh pho.	Nguyen Xien, Long Binh, Thu Duc, Ho Chi Minh City	AVAILABLE	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717	SALE	f
4	4	Can ho 2PN Masteri Thao Dien	4200000000.00	63926941.00	Can ho 2PN view noi khu.	Xa Lo Ha Noi, Thao Dien, Thu Duc, Ho Chi Minh City	AVAILABLE	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717	SALE	f
5	5	Can ho 3PN Sunrise City	5800000000.00	64088398.00	Can ho 3PN dien tich lon, noi that cao cap.	Nguyen Huu Tho, Tan Hung, District 7, Ho Chi Minh City	AVAILABLE	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717	SALE	f
1	1	Can ho 2PN Vinhomes Grand Park	3200000000.00	46715328.00	Can ho 2 phong ngu, view cong vien, noi that dep.	Nguyen Xien, Long Binh, Thu Duc, Ho Chi Minh City	SOLD	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717	SALE	f
3	3	Can ho 3PN Masteri Thao Dien	5200000000.00	63183475.00	Can ho cao cap 3PN view song.	Xa Lo Ha Noi, Thao Dien, Thu Duc, Ho Chi Minh City	RESERVED	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717	SALE	f
6	85	Căn 2PN+1 Hà Đô Centrosa Garden góc 2 mặt thoáng cực rộng	24000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 2PN+1 HÀ ĐÔ CENTROSA GARDEN 107M2\nĐịa chỉ: 200 3 Tháng 2, Phường Hòa Hưng, TP. Hồ Chí Minh\nCăn góc diện tích lớn 107m2 thiết kế 2PN lớn + 1 phòng đọc sách/làm việc.\nBếp riêng biệt nối liền ra logia phơi đồ kín đáo.\nAn ninh bảo vệ 3 lớp thẻ từ thang máy an toàn.\nGiá thuê: 24 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	200 3 Tháng 2	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
7	15	Căn 1PN City Garden Bình Thạnh thiết kế gợn sóng độc đáo	20000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN CITY GARDEN NGÔ TẤT TỐ DIỆN TÍCH 70M2\nĐịa chỉ: 59 Ngô Tất Tố, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn 1PN diện tích lớn 70m2 với đường nét kiến trúc hình gợn sóng độc bản.\nĐầy đủ trang thiết bị nội thất xịn xò, tone màu trầm ấm cúng tinh tế.\nMật độ xanh bao phủ lên tới 70%, tạo môi trường sống trong lành như resort.\nGiá thuê: 20 Triệu/tháng.\\nLiên hệ: 092x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	59 Ngô Tất Tố	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
8	11	Căn 2PN City Garden tháp Crescent tầng cao view Landmark 81	31000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN CITY GARDEN THÁP CRESCENT 105M2\nĐịa chỉ: 59 Ngô Tất Tố, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn hộ 2 phòng ngủ rộng rãi, ban công cong độc đáo ngắm trọn Landmark 81.\nNội thất thiết kế hiện đại sang trọng, trang bị máy rửa bát và tủ lạnh lớn.\nTiện ích: Hồ bơi tràn bờ 50m, nhà hàng cao cấp, mảng xanh bãi cỏ nội khu.\nGiá thuê: 31 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	59 Ngô Tất Tố	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
9	16	Căn 3PN City Garden nội thất Châu Âu thiết kế cực sang	46000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN CITY GARDEN NGÔ TẤT TỐ DIỆN TÍCH 140M2\nĐịa chỉ: 59 Ngô Tất Tố, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn 3PN thiết kế mở, khung cửa kính từ sàn đến trần đón trọn ánh sáng tự nhiên.\nĐã chuẩn bị sẵn đầy đủ đồ dùng, chỉ việc xách vali vào ở ngay.\nVị trí đắc địa di chuyển sang trung tâm Bến Nghé chỉ mất 5 phút.\nGiá thuê: 46 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	59 Ngô Tất Tố	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
10	43	Penthouse City Garden thiết kế Duplex đỉnh cao kiến trúc	90000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE DUPLEX CITY GARDEN DIỆN TÍCH 220M2\nĐịa chỉ: 59 Ngô Tất Tố, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn Penthouse thông tầng đẳng cấp sở hữu tầm nhìn 360 độ ôm trọn trung tâm TP.HCM.\nNội thất xa hoa được đặt riêng từng chi tiết từ các hãng thiết kế danh tiếng.\nSảnh thang máy thẻ từ bảo mật tuyệt đối.\nGiá thuê: 90 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	59 Ngô Tất Tố	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
11	69	Căn 1PN tháp Hawaii Đảo Kim Cương view sông Sài Gòn êm đềm	18000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN ĐẢO KIM CƯƠNG THÁP HAWAII DIỆN TÍCH 55M2\nĐịa chỉ: Số 1 Đường số 104, Phường Bình Trưng, TP. Hồ Chí Minh\nCăn hộ 1PN trên hòn đảo tự nhiên duy nhất tại TP.HCM, không gian sống nghỉ dưỡng tuyệt đối.\nĐầy đủ nội thất nhập khẩu, ban công hướng sông mát mẻ quanh năm.\nTiện ích đặc quyền: Hồ bơi mặn 2.300m2, bến du thuyền riêng, công viên thủy cung.\nGiá thuê: 18 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Số 1 Đường số 104	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
12	84	Căn 2PN tháp Bora Bora Đảo Kim Cương full nội thất hiện đại	26000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN ĐẢO KIM CƯƠNG THÁP BORA BORA DIỆN TÍCH 88M2\nĐịa chỉ: Số 1 Đường số 104, Phường Bình Trưng, TP. Hồ Chí Minh\nCăn hộ 2 phòng ngủ tòa Bora Bora đón trọn bình minh ngập tràn sức sống.\nThiết kế tối giản tinh tế, sofa da bò, hệ thống bếp điện và lò nướng âm tủ.\nTận hưởng 86.5% mật độ mảng xanh và mặt nước bao phủ xung quanh đảo.\nGiá thuê: 26 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Số 1 Đường số 104	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
13	91	Căn góc 3PN tháp Maldives Đảo Kim Cương view sông trực diện	45000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN ĐẢO KIM CƯƠNG THÁP MALDIVES DIỆN TÍCH 125M2\nĐịa chỉ: Số 1 Đường số 104, Phường Bình Trưng, TP. Hồ Chí Minh\nCăn góc đắt giá nhất tháp Maldives, view nhìn 220 độ ôm trọn sông Sài Gòn và Bitexco.\nTrang bị nội thất siêu xa hoa nhập khẩu hoàn toàn từ Châu Âu.\nKhông gian sống yên tĩnh hoàn hảo cách biệt hoàn toàn khỏi khói bụi.\nGiá thuê: 45 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Số 1 Đường số 104	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
14	92	Căn Pool Villa Đảo Kim Cương sân vườn hồ bơi riêng xa xỉ	100000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nPOOL VILLA ĐẢO KIM CƯƠNG HỒ BƠI SÂN VƯỜN RIÊNG 210M2\nĐịa chỉ: Số 1 Đường số 104, Phường Bình Trưng, TP. Hồ Chí Minh\nCăn hộ Pool Villa tầng trệt có hồ bơi riêng và sân vườn bao quanh nhà.\nMang đến sự riêng tư tối đa chuẩn resort đẳng cấp giữa lòng thành phố.\nĐầy đủ trang thiết bị nội thất đạt chuẩn khách sạn 5 sao. \nGiá thuê: 100 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Số 1 Đường số 104	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
15	24	Căn 1PN Eco Green Sài Gòn Nguyễn Văn Linh full đồ xinh xắn	12000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN ECO GREEN SÀI GÒN DIỆN TÍCH 45M2\nĐịa chỉ: 39/1B Nguyễn Văn Linh, Phường Tân Thuận, TP. Hồ Chí Minh\nCăn hộ 1PN thiết kế xinh xắn tối ưu không gian, ban công thoáng mát.\nĐầy đủ nội thất: Sofa, tủ lạnh, tivi, máy giặt, bếp từ âm, máy lạnh Daikin.\nNằm ngay cạnh công viên Hương Tràm rộng 22ha cực kỳ xanh mát.\nGiá thuê: 12 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	39/1B Nguyễn Văn Linh	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
16	6	Căn 2PN Eco Green Sài Gòn view công viên Hương Tràm 22ha	16000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN ECO GREEN SÀI GÒN DIỆN TÍCH 65M2\nĐịa chỉ: 39/1B Nguyễn Văn Linh, Phường Tân Thuận, TP. Hồ Chí Minh\nCăn hộ 2PN 2WC thiết kế hợp lý, các phòng ngủ đều có cửa sổ đón sáng tự nhiên.\nTrang bị kính khoang âm cản nhiệt cách âm tuyệt đối.\nTiện ích: Hồ bơi tràn bờ, trường tiểu học Kim Đồng ngay trong dự án, TTTM.\nGiá thuê: 16 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	39/1B Nguyễn Văn Linh	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
17	13	Căn góc 3PN Eco Green Sài Gòn tầng cao view sông cầu Phú Mỹ	22000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN ECO GREEN SÀI GÒN 85M2\nĐịa chỉ: 39/1B Nguyễn Văn Linh, Phường Tân Thuận, TP. Hồ Chí Minh\nCăn góc 3PN sở hữu tầm nhìn panorama tuyệt đẹp ngắm cầu Phú Mỹ lung linh về đêm.\nBàn giao thiết bị bếp Teka, thiết bị vệ sinh Duravit cao cấp.\nKết nối sang trung tâm Bến Nghé qua cầu Tân Thuận chỉ 5 phút.\nGiá thuê: 22 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	39/1B Nguyễn Văn Linh	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
18	89	Căn 3PN Eco Green Sài Gòn full nội thất gỗ cao cấp	24000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN ECO GREEN SÀI GÒN DIỆN TÍCH 95M2\nĐịa chỉ: 39/1B Nguyễn Văn Linh, Phường Tân Thuận, TP. Hồ Chí Minh\nCăn 3PN diện tích lớn, thiết kế hiện đại sang trọng thích hợp cho gia đình ở dài hạn.\nTrang bị full đồ gỗ tự nhiên, tivi 65 inch, tủ lạnh side-by-side.\nDịch vụ quản lý tòa nhà chuyên nghiệp an toàn 24/7.\nGiá thuê: 24 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	39/1B Nguyễn Văn Linh	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
19	55	Căn 1PN Linden Empire City Thủ Thiêm full nội thất xịn	23000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN LINDEN RESIDENCES EMPIRE CITY DIỆN TÍCH 64M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh.\nCăn hộ 1PN diện tích cực rộng 64m2 tại phân khu Linden Residences.\nThiết kế tinh tế, không gian bếp thoáng đạt kết nối trực tiếp ra ban công.\nTiện ích: Hồ bơi nước mặn 50m, phòng sauna khô/ướt, khu BBQ ngoài trời.\nGiá thuê: 23 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Khu đô thị mới Thủ Thiêm	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
20	45	Cho thuê căn 2PN Tilia Empire City tầng cao view nội khu mát mẻ	34000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN TILIA RESIDENCES EMPIRE CITY DIỆN TÍCH 93M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh\nCăn hộ 2PN phân khu Tilia Residences, layout thiết kế vuông vức phong thủy tốt.\nĐã trang bị đầy đủ đồ dùng sinh hoạt, máy giặt sấy, lò nướng âm tủ.\nMôi trường sống chuẩn quốc tế, cư dân văn minh tri thức.\nGiá thuê: 34 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Khu đô thị mới Thủ Thiêm	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
21	67	Căn 3PN Cove Empire City view trực diện sông thang máy riêng	70000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN COVE RESIDENCES EMPIRE CITY THANG MÁY RIÊNG 155M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh\nCăn hộ đắt giá thuộc tòa Cove Residences – tòa căn hộ sát sông nhất dự án Empire City.\nTrang bị thang máy riêng mở thẳng vào căn hộ, tầm nhìn ôm trọn sông Sài Gòn.\nBàn giao nội thất cao cấp chuẩn resort 5 sao.\nGiá thuê: 70 Triệu/tháng.\\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Khu đô thị mới Thủ Thiêm	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
22	88	Penthouse Empire City Thủ Thiêm tầng cao view 360 độ cực phẩm	120000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE EMPIRE CITY THỦ THIÊM TẦNG CAO DIỆN TÍCH 220M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh\nCăn Penthouse thiết kế Duplex thông tầng đẳng cấp nhất tại dự án.\nBan công siêu rộng ôm trọn góc view 360 độ ngắm toàn cảnh sông Sài Gòn và thành phố.\nThang máy riêng biệt, hệ thống an ninh 3 lớp tuyệt đối bảo mật.\nGiá thuê: 120 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Khu đô thị mới Thủ Thiêm	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
23	70	Căn 1PN Estella Heights thiết kế nghỉ dưỡng full nội thất	22000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN ESTELLA HEIGHTS PHONG CÁCH RESORT DIỆN TÍCH 60M2\nĐịa chỉ: 88 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn hộ 1PN ban công rộng hướng hồ bơi tràn bờ phong cách nghỉ dưỡng.\nBàn giao full nội thất cao cấp sang trọng chuẩn 5 sao.\nTiện ích đẳng cấp: Hồ bơi lướt sóng, đường chạy bộ trên cao, phòng gym hiện đại.\nTTTM Estella Place ngay bên dưới cung cấp mọi nhu cầu mua sắm, ẩm thực.\nGiá thuê: 22 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx"\n  },\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	88 Xa Lộ Hà Nội	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
24	57	Cho thuê căn 2PN Estella Heights tháp T3 view hồ bơi tràn bờ	32000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN ESTELLA HEIGHTS THÁP T3 DIỆN TÍCH 90M2\nĐịa chỉ: 88 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh\nThiết kế phòng khách nối liền ban công kính tràn viền vô cùng thông thoáng.\nTrang bị đầy đủ thiết bị điện tử cao cấp, sofa da, bàn ăn gỗ sồi.\nMôi trường sống xanh, mát mẻ với mật độ cây xanh che phủ cao.\nGiá thuê: 32 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	88 Xa Lộ Hà Nội	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
25	78	Căn 3PN Estella Heights tầng cao view trọn thành phố lộng lẫy	48000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN ESTELLA HEIGHTS TẦNG CAO DIỆN TÍCH 130M2\nĐịa chỉ: 88 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Thủ Đức\nCăn 3 phòng ngủ rộng rãi, view tầng cao ngắm trọn bình minh và hoàng hôn thành phố.\nBếp đóng riêng biệt chống ám mùi, trang bị lò nướng và máy rửa bát cao cấp.\nQuản lý vận hành bởi tập đoàn uy tín Keppel Land.\nGiá thuê: 48 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	88 Xa Lộ Hà Nội	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
26	27	Căn Penthouse Estella Heights sân vườn riêng đẳng cấp thượng lưu	95000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE ESTELLA HEIGHTS SÂN VƯỜN RIÊNG DIỆN TÍCH 250M2\nĐịa chỉ: 88 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn Penthouse đỉnh cao sở hữu sân vườn riêng rộng lớn ngắm view 360 độ.\nThiết kế nội thất độc bản từ các nhà thiết kế hàng đầu, không gian xa hoa.\nThang máy thẻ từ riêng, dịch vụ chăm sóc căn hộ đặc quyền VIP.\nGiá thuê: 95 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	88 Xa Lộ Hà Nội	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
27	74	Căn 1PN Tòa Lake Grand Marina Saigon quản lý chuẩn Marriott	38000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ HÀNG HIỆU MARRIOTT GRAND MARINA SAIGON 59M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nCăn hộ dịch vụ hàng hiệu chuẩn Marriott International đầu tiên tại trung tâm Sài Gòn.\nBàn giao full nội thất nhập khẩu Ý, thiết bị bếp và vệ sinh Gaggenau & Duravit.\nDịch vụ quản gia, lễ tân và concierge tiêu chuẩn khách sạn 5 sao quốc tế 24/7.\nGiá thuê: 38 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	2 Tôn Đức Thắng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
28	60	Cho thuê căn 2PN Grand Marina Saigon view sông cực đẹp	58000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN GRAND MARINA SAIGON VIEW SÔNG 88M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nCăn hộ 2PN view trực diện sông Sài Gòn và cầu Ba Sơn, ban công kính tràn viền siêu sang.\nTận hưởng các đặc quyền tiện ích: Hồ bơi mây trên tầng cao, rạp chiếu phim riêng, phòng họp VIP.\nMôi trường sống tinh hoa tôn vinh đẳng cấp gia chủ.\nGiá thuê: 58 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	2 Tôn Đức Thắng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
29	94	Căn 3PN Hàng hiệu Marriott Grand Marina view trung tâm Q1	95000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN MARRIOTT GRAND MARINA SAIGON 133M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nCăn 3PN góc 2 mặt thoáng ngắm toàn cảnh đại lộ Tôn Đức Thắng và sông Sài Gòn.\nThiết kế tỉ mỉ đến từng chi tiết nhỏ bởi các kiến trúc sư thế giới.\nBàn giao đầy đủ trang thiết bị nội thất xa hoa nhất.\nGiá thuê: 95 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	2 Tôn Đức Thắng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
30	93	Căn Penthouse Masterise Grand Marina Bến Nghé siêu sang	180000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE GRAND MARINA SAIGON BẾN NGHÉ 220M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nSiêu căn hộ Penthouse hàng hiệu Marriott bậc nhất Việt Nam.\nSở hữu tầm nhìn kiệt tác ôm trọn dòng sông Sài Gòn và trung tâm đô thị.\nĐặc quyền phục vụ riêng biệt theo chuẩn mực toàn cầu của tập đoàn Marriott. \nGiá thuê: 180 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	2 Tôn Đức Thắng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
31	63	Cho thuê căn 1PN Gateway Thảo Điền full nội thất hiện đại	19000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN THE GATEWAY THẢO ĐIỀN DIỆN TÍCH 52M2\nĐịa chỉ: 2 Trần Ngọc Diện, Phường Thảo Điền, TP. Hồ Chí Minh.\nCăn hộ 1PN thiết kế tinh tế, tối ưu từng khoảng không gian sống.\nNội thất nhập khẩu cao cấp, trang bị hệ thống Smart Home tiện lợi.\nTọa lạc tại khu phố tây Trần Ngọc Diện sầm uất với nhiều nhà hàng, cafe cao cấp.\nGiá thuê: 19 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	2 Trần Ngọc Diện	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
32	97	Căn 2PN Gateway Thảo Điền tầng cao view sông Sài Gòn tuyệt đẹp	28000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN THE GATEWAY THẢO ĐIỀN VIEW SÔNG DIỆN TÍCH 85M2\nĐịa chỉ: 2 Trần Ngọc Diện, Phường Thảo Điền, TP. Hồ Chí Minh\nBan công kính tràn chiều cao ceiling 3.1m tạo sự thông thoáng vượt trội.\nView sông Sài Gòn thơ mộng không bị che chắn.\nTiện ích: Hồ bơi nước mặn, phòng xông hơi, khu nướng BBQ ngoài trời.\n Giá thuê: 28 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	2 Trần Ngọc Diện	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
33	19	Căn 3PN Gateway Thảo Điền thiết kế sang trọng nội thất cao cấp	42000000.00	\N	=== MÔ TẢ CHI TIẾT ==\nCĂN HỘ 3PN THE GATEWAY THẢO ĐIỀN DIỆN TÍCH 122M2\nĐịa chỉ: 2 Trần Ngọc Diện, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn 3PN diện tích lớn, thiết kế mở đón ánh sáng tự nhiên cho toàn bộ các phòng.\nBếp đảo hiện đại trang bị thiết bị SBG Bosch chất lượng cao.\nVị trí đắc địa gần các trường quốc tế BIS, ISHCMC.\nGiá thuê 42 Triệutháng.\nLiên hệ 092x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	2 Trần Ngọc Diện	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
34	22	Căn Garden Villa Gateway Thảo Điền có sân vườn rộng thoáng	75000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nGARDEN VILLA THE GATEWAY THẢO ĐIỀN DIỆN TÍCH 180M2\nĐịa chỉ: 2 Trần Ngọc Diện, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn hộ sân vườn đặc quyền tầng trệt mang đến không gian sống chuẩn biệt thự.\nSân vườn riêng xanh mát thích hợp tổ chức tiệc trà, BBQ gia đình.\nThiết kế 4 phòng ngủ riêng tư, nội thất siêu sang trọng.\nGiá thuê: 75 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	2 Trần Ngọc Diện	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
35	31	Căn 1PN1WC Hà Đô Centrosa Garden full nội thất hiện đại	15000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN HÀ ĐÔ CENTROSA GARDEN 53M2\nĐịa chỉ: 200 3 Tháng 2, Phường Hòa Hưng, TP. Hồ Chí Minh\nCăn hộ 1PN thiết kế thông minh + 1 phòng đa năng làm việc rộng rãi.\nFull nội thất đẹp, tông màu tươi sáng, trang bị tivi, tủ lạnh, máy giặt.\nVị trí trung tâm kết nối giao thông đi các khu vực vô cùng thuận tiện.\nGiá thuê: 15 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	200 3 Tháng 2	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
36	28	Cho thuê căn 2PN2WC Hà Đô Centrosa tháp Orchid view hồ bơi	20000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN HÀ ĐÔ CENTROSA GARDEN ORCHID 86M2\nĐịa chỉ: 200 3 Tháng 2, Phường Hòa Hưng, TP. Hồ Chí Minh\nCăn hộ 2PN 2WC tòa Orchid, ban công nhìn trực diện hồ bơi tràn tràn mây nội khu.\nĐã được trang bị đầy đủ trang thiết bị nội thất xịn xò.\nTiện ích: 21 khu vườn treo trên không, hồ bơi tràn bờ, phòng gym, siêu thị.\nGiá thuê: 20 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	200 3 Tháng 2	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
37	20	Căn 3PN Hà Đô Centrosa Garden tầng cao view trọn thành phố	29000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN HÀ ĐÔ CENTROSA GARDEN 123M2\nĐịa chỉ: 200 3 Tháng 2, Phường Hòa Hưng, TP. Hồ Chí Minh\nCăn hộ 3PN diện tích lớn thích hợp cho gia đình nhiều thế hệ sinh sống.\nTrang bị full nội thất cao cấp: Sofa da, bàn ăn 6 ghế, máy lạnh âm trần.\nGiá thuê: 29 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	200 3 Tháng 2	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
38	64	Căn 1PN The Infiniti Riviera Point full nội thất mới 100%	15000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN THE INFINITI RIVIERA POINT 58M2\nĐịa chỉ: 584 Huỳnh Tấn Phát, Phường Phú Thuận, TP. Hồ Chí Minh\nCăn hộ 1PN mang cảm hứng thiên nhiên Hawaii do Keppel Land phát triển.\nBan công hướng sông Cả Cấm vô cùng mát mẻ.\nTiện ích đột phá: Sân chơi nước nội khu lớn nhất TP.HCM, hồ bơi tràn bờ 50m.\nGiá thuê: 15 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	584 Huỳnh Tấn Phát	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
39	52	Cho thuê căn 2PN Riviera Point view sông thoáng mát	21000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN THE INFINITI RIVIERA POINT 82M2\nĐịa chỉ: 584 Huỳnh Tấn Phát, Phường Phú Thuận, TP. Hồ Chí Minh\nCăn 2PN thiết kế vuông vức, không gian phòng khách nối liền ban công thông thoáng.\nTrang bị đầy đủ thiết bị bếp, máy lạnh âm trần, nội thất gỗ hiện đại.\nKết nối sang trung tâm Phú Mỹ Hưng chỉ 2 phút qua cầu Phú Thuận.\nGiá thuê: 21 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	584 Huỳnh Tấn Phát	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
40	53	Căn góc 3PN Riviera Point tầng cao view toàn cảnh Quận 7	30000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN THE INFINITI RIVIERA POINT 120M2\nĐịa chỉ: 584 Huỳnh Tấn Phát, Phường Phú Thuận, TP. Hồ Chí Minh\nCăn góc 3 phòng ngủ thoáng đạt, đón nắng và gió tự nhiên tràn ngập các phòng.\nBàn giao trọn bộ nội thất xịn xò chuẩn phong cách resort nghỉ dưỡng.\nGiá thuê: 30 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	584 Huỳnh Tấn Phát	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
41	66	Căn Duplex The Infiniti Riviera Point thiết kế thông tầng xa hoa	48000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ DUPLEX THE INFINITI RIVIERA POINT 150M2\nĐịa chỉ: 584 Huỳnh Tấn Phát, Phường Phú Thuận, TP. Hồ Chí Minh\nCăn Duplex thông tầng ấn tượng với hệ kính cao kịch trần ngắm trọn view sông.\nNội thất xa hoa được đặt riêng phù hợp không gian sang trọng.\nQuản lý vận hành chuẩn mực bởi Keppel Land.\nGiá thuê: 48 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	584 Huỳnh Tấn Phát	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
42	99	Căn 2PN Leman Luxury Nguyễn Đình Chiểu full nội thất Thụy Sỹ	32000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN LEMAN LUXURY XUÂN KHÁNH DIỆN TÍCH 75M2\nĐịa chỉ: 117 Nguyễn Đình Chiểu, Phường Xuân Khánh, TP. Hồ Chí Minh\nCăn hộ mang đậm kiến trúc Thụy Sỹ giữa tâm xanh thành phố.\nTrang bị full nội thất cao cấp cổ điển pha lẫn hiện đại sang trọng.\nSiêu thị Bon Grocer và chuỗi nhà hàng cao cấp ngay tại khối đế tòa nhà.\nGiá thuê: 32 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	117 Nguyễn Đình Chiểu	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
43	10	Cho thuê căn 3PN Leman Luxury không gian sống yên tĩnh đẳng cấp	45000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN LEMAN LUXURY APARTMENTS 96M2\nĐịa chỉ: 117 Nguyễn Đình Chiểu, Phường Xuân Khánh, TP. Hồ Chí Minh\nCăn hộ 3PN thiết kế thông thoáng, ô cửa kính lớn đón nắng tự nhiên mát mẻ.\nĐầy đủ tiện ích sinh hoạt, lò nướng, máy giặt sấy, giường nệm cao cấp.\nHồ bơi chân mây trên tầng mây ngắm trọn trung tâm thành phố.\nGiá thuê: 45 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	117 Nguyễn Đình Chiểu	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
44	98	Căn góc 3PN Leman Luxury ban công thoáng mát nội thất xịn	52000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN LEMAN LUXURY DIỆN TÍCH 113M2\nĐịa chỉ: 117 Nguyễn Đình Chiểu, Phường Xuân Khánh, TP. Hồ Chí Minh\nCăn góc 2 mặt tiền đường Nguyễn Đình Chiểu - Trương Định vô cùng đắt giá.\nThiết kế nội thất sang trọng, trang thiết bị điện tử âm tường hiện đại.\nGiá thuê: 52 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	117 Nguyễn Đình Chiểu	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
45	34	Penthouse Leman Luxury tầng cao sân vườn riêng cực hiếm	90000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE LEMAN LUXURY SÂN VƯỜN RIÊNG 200M2\nĐịa chỉ: 117 Nguyễn Đình Chiểu, Phường Xuân Khánh, TP. Hồ Chí Minh\nPenthouse đẳng cấp có khu sân vườn ngợp bóng mát ngay trên tầng cao.\nKhông gian sống thượng lưu riêng biệt hoàn toàn giữa lòng trung tâm.\nNội thất thiết kế độc bản siêu sang trọng. \nGiá thuê: 90 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	117 Nguyễn Đình Chiểu	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
46	47	Căn 1PN The Grande Midtown Phú Mỹ Hưng thiết kế Nhật Bản	17000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN MIDTOWN PHÚ MỸ HƯNG 62M2\nĐịa chỉ: Đường Nguyễn Lương Bằng, Phường Tân Phú, TP. Hồ Chí Minh\nCăn 1PN thuộc phân khu The Grande, thiết kế tối giản chuẩn phong cách Nhật Bản.\nBan công đón ánh sáng tự nhiên, full nội thất gỗ cao cấp.\nCông viên hoa anh đào Sakura Park ngay sát chân tòa nhà.\nGiá thuê: 17 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Nguyễn Lương Bằng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
47	23	Cho thuê căn 2PN The Symphony Midtown view Sakura Park	25000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN THE SYMPHONY MIDTOWN PHÚ MỸ HƯNG 89M2\nĐịa chỉ: Đường Nguyễn Lương Bằng, Phường Tân Phú, TP. Hồ Chí Minh\nCăn 2PN view trực diện công viên hoa anh đào Sakura Park thơ mộng.\nĐầy đủ thiết bị điện tử hiện đại, thiết bị vệ sinh Toto thông minh.\nTiện ích: Hồ bơi massage Jacuzzi, phòng sauna khô/ướt, phòng chơi trẻ em.\nGiá thuê: 25 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Nguyễn Lương Bằng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
48	48	Căn góc 3PN The Signature Midtown tầng trung view sông biệt thự	40000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN THE SIGNATURE MIDTOWN 121M2\nĐịa chỉ: Đường Nguyễn Lương Bằng, Phường Tân Phú, TP. Hồ Chí Minh\nCăn góc đắt giá thuộc tòa The Signature có cầu đi bộ trên không biểu tượng.\nView trực diện sông Cả Cấm và khu biệt thự Phú Mỹ Hưng sang trọng.\nTrang bị full đồ gỗ tự nhiên nhập khẩu cao cấp.\\n- Giá thuê: 40 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Nguyễn Lương Bằng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
49	33	Căn 4PN The Peak Midtown Phú Mỹ Hưng full nội thất cao cấp	62000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 4PN THE PEAK MIDTOWN PHÚ MỸ HƯNG 160M2\nĐịa chỉ: Đường Nguyễn Lương Bằng, Phường Tân Phú, TP. Hồ Chí Minh\nCăn hộ 4PN thuộc phân khu đỉnh cao nhất The Peak Midtown.\nĐầy đủ tiện ích thác nước vô cực, đài ngắm cảnh waterfall, phòng gym hiện đại.\nKhông gian sống xanh thư thái chuẩn mực đẳng cấp quốc tế.\nGiá thuê: 62 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Nguyễn Lương Bằng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
50	7	Cho thuê căn Studio Masteri Thảo Điền T4 full nội thất xinh xắn	13500000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ STUDIO MASTERI THẢO ĐIỀN TÒA T4 DIỆN TÍCH 48M2\nĐịa chỉ: 159 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn hộ Studio tầng trung thiết kế tối ưu diện tích, đón ánh sáng tự nhiên tốt.\nĐầy đủ nội thất cao cấp: Giường tủ, sofa, máy giặt, tủ lạnh, bếp từ.\nTiện ích nội khu: Hồ bơi ngoài trời, phòng Gym, TTTM Vincom Mega Mall ngay dưới chân nhà.\nKết nối giao thông thuận tiện qua tuyến Metro số 1 và đại lộ Xa Lộ Hà Nội.\nGiá thuê: 13.5 Triệu/tháng.\nLiên hệ: 090x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	159 Xa Lộ Hà Nội	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
51	9	Căn hộ 2PN2WC Masteri Thảo Điền T2 view sông Sài Gòn thoáng mát	18000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN2WC MASTERI THẢO ĐIỀN VIEW SÔNG DIỆN TÍCH 68M2\nĐịa chỉ: 159 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn hộ 2 phòng ngủ tòa T2, ban công hướng Đông Bắc view trực diện sông lộng gió. \nBàn giao đầy đủ trang thiết bị nội thất xịn, chỉ cần xách vali vào ở ngay.\nCộng đồng cư dân văn minh, nhiều chuyên gia nước ngoài sinh sống. \nAn ninh 24/7, thẻ từ thang máy riêng biệt cho từng tầng.\nGiá thuê: 18 Triệu/tháng.\nLiên hệ: 090x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	159 Xa Lộ Hà Nội	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
52	80	Căn góc 3PN Masteri Thảo Điền T1 tầng cao view Vincom sang trọng	26000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN MASTERI THẢO ĐIỀN TÒA T1 DIỆN TÍCH 90M2\nĐịa chỉ: 159 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn góc 2 mặt thoáng, tầm nhìn panorama ôm trọn khu Thảo Điền năng động.\nThiết kế 3PN rộng rãi, thích hợp cho gia đình đông thành viên hoặc nhóm chuyên gia.\nNội thất nhập khẩu phong cách hiện đại, tông màu ấm cúng.\nTiện ích cao cấp: Sân tennis, công viên nội khu, khu vui chơi trẻ em.\nGiá thuê: 26 Triệu/tháng.\nLiên hệ: 090x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	159 Xa Lộ Hà Nội	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
53	86	Cho thuê Duplex Masteri Thảo Điền thiết kế hiện đại, đầy đủ tiện nghi	45000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ DUPLEX MASTERI THẢO ĐIỀN THÔNG TẦNG DIỆN TÍCH 130M2\nĐịa chỉ: 159 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn Duplex thông tầng siêu rộng, trần cao thoáng đạt tạo cảm giác như biệt thự.\nTrang bị hệ thống điều hòa âm trần, thiết bị bếp và vệ sinh chuẩn Châu Âu.\nTận hưởng không gian sống riêng tư, hiện đại ngay trung tâm Thảo Điền. \nGiá thuê: 45 Triệu/tháng.\nLiên hệ: 090x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	159 Xa Lộ Hà Nội	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
54	81	Căn 1PN Galleria Metropole Thủ Thiêm full nội thất cao cấp	25000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN THE METROPOLE THỦ THIÊM DIỆN TÍCH 55M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh \nCăn hộ 1PN tại phân khu Galleria Residence, thiết kế tinh tế chuẩn phong cách Châu Âu.\nTrang bị toàn bộ thiết bị nội thất thông minh tích hợp điều khiển giọng nói.\nNgay chân cầu Ba Sơn, kết nối sang trung tâm Bến Nghé chỉ 2 phút di chuyển.\nGiá thuê: 25 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Khu đô thị mới Thủ Thiêm	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
55	73	Cho thuê căn 2PN The Crest Metropole view cầu Ba Sơn tuyệt đẹp	38000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN THE CREST RESIDENCE METROPOLE DIỆN TÍCH 82M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh\nCăn hộ 2PN tầng trung ban công rộng view trực diện cầu Ba Sơn và tháp Bitexco.\nThiết kế sang trọng với thiết bị vệ sinh tự động, bếp từ Bosch cao cấp.\nTiện ích đỉnh cao: Hồ bơi vô cực tràn bờ, phòng tập Golf 3D giả lập.\nGiá thuê: 38 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Khu đô thị mới Thủ Thiêm	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
56	51	Căn 3PN Opera Metropole Thủ Thiêm ban công rộng view sông	60000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN THE OPERA RESIDENCE METROPOLE DIỆN TÍCH 120M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh\nCăn hộ thuộc phân khu Opera đắt giá nhất dự án, nằm sát Nhà hát Thành phố mới.\nBan công kính chạy dài view trực diện sông Sài Gòn lung linh về đêm.\nHệ thống lọc không khí và lọc nước trung tâm đạt chuẩn quốc tế.\nGiá thuê: 60 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Khu đô thị mới Thủ Thiêm	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
57	90	Căn 4PN VIP Metropole Thủ Thiêm thang máy riêng biệt xa hoa	110000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 4PN VIP METROPOLE THỦ THIÊM THANG MÁY RIÊNG 170M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh.\nCăn hộ 4PN hạng sang trang bị sảnh thang máy riêng tư đi thẳng vào phòng khách.\nNội thất siêu xa hoa nhập khẩu nguyên chiếc từ Ý và Đức.\nView sông ngắm toàn bộ skyline trung tâm thành phố.\nGiá thuê: 110 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Khu đô thị mới Thủ Thiêm	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
58	12	Căn 1PN Palm Heights An Phú full nội thất xinh xắn	14000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN PALM HEIGHTS AN PHÚ DIỆN TÍCH 55M2\nĐịa chỉ: Đường Song Hành, Phường An Phú, TP. Hồ Chí Minh\nCăn hộ 1PN thiết kế thông minh, tối ưu diện tích đón gió tự nhiên từ sông Giồng Ông Tố.\nĐầy đủ nội thất cao cấp: Sofa, tivi, tủ lạnh, bếp âm, giường tủ.\nQuản lý vận hành bởi tập đoàn Keppel Land danh tiếng.\nGiá thuê: 14 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Song Hành	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
59	61	Căn 2PN Palm Heights view sông mát mẻ tầng cao	18500000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN PALM HEIGHTS TẦNG CAO VIEW SÔNG 78M2\nĐịa chỉ: Đường Song Hành, Phường An Phú, TP. Hồ Chí Minh\nBan công hướng Nam mát mẻ view sông trọn vẹn không bị che chắn.\nĐã được trang bị full nội thất đẹp mắt, chỉ việc xách vali vào ở.\nTiện ích: Hồ bơi phong cách nghỉ dưỡng, phòng sauna, khu tiệc BBQ ngoài trời.\nGiá thuê: 18.5 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Song Hành	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
60	82	Căn góc 3PN Palm Heights diện tích rộng full đồ cao cấp	25000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN PALM HEIGHTS AN PHÚ DIỆN TÍCH 105M2\nĐịa chỉ: Đường Song Hành, Phường An Phú, TP. Hồ Chí Minh\nCăn góc 3 phòng ngủ thoáng đạt, các phòng ngủ đều có cửa sổ đón ánh sáng trực tiếp.\nNội thất thiết kế riêng hiện đại, trang bị đầy đủ máy giặt sấy, lò nướng.\nVị trí sát nút giao An Phú di chuyển thuận tiện về trung tâm.\nGiá thuê: 25 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Song Hành	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
61	25	Cho thuê căn Duplex Palm Garden không gian thoáng đãng	42000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ DUPLEX PALM GARDEN AN PHÚ DIỆN TÍCH 140M2\nĐịa chỉ: Đường Song Hành, Phường An Phú, TP. Hồ Chí Minh\nCăn Duplex thông tầng siêu rộng rãi, không gian phòng khách trần cao cực kỳ sang trọng.\nTrang bị hệ thống điện thông minh, nội thất chọn lọc cao cấp.\nTiện ích nội khu đầy đủ: Sân tennis, phòng tập gym, khu vui chơi trẻ em.\nGiá thuê: 42 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Song Hành	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
62	32	Căn 2PN Scenic Valley Phú Mỹ Hưng full nội thất xinh xắn	16000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN SCENIC VALLEY PHÚ MỸ HƯNG 70M2\nĐịa chỉ: Đường Tôn Dật Tiên, Phường Tân Phú, TP. Hồ Chí Minh\nCăn hộ 2PN 2WC không gian thiết kế vuông vức, tối ưu hóa công năng.\nNội thất hiện đại đầy đủ: Tivi, tủ lạnh, máy giặt, máy lạnh các phòng.\nVị trí kế bên sân golf và bệnh viện FV, bệnh viện Tam Đức.\nGiá thuê: 16 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Tôn Dật Tiên	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
63	18	Căn 2PN Scenic Valley view hồ bơi nội khu xanh mát	18000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN SCENIC VALLEY VIEW HỒ BƠI 80M2\nĐịa chỉ: Đường Tôn Dật Tiên, Phường Tân Phú, TP. Hồ Chí Minh\nCăn hộ tầng trung view trực diện hồ bơi ngoài trời xanh mát quanh năm.\nTrang bị đồ dùng nội thất còn mới nguyên, xách vali vào ở ngay.\nCư dân tận hưởng trọn vẹn tiện ích đô thị Phú Mỹ Hưng.\nGiá thuê: 18 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Tôn Dật Tiên	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
64	83	Căn 3PN Scenic Valley Phú Mỹ Hưng căn góc view sân Golf	26000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN SCENIC VALLEY VIEW SÂN GOLF 110M2\nĐịa chỉ: Đường Tôn Dật Tiên, Phường Tân Phú, TP. Hồ Chí Minh\nCăn góc 3PN tầm nhìn xanh ngút ngàn hướng thẳng ra sân Golf Phú Mỹ Hưng.\nThiết kế nội thất ấm cúng, phù hợp cho gia đình có trẻ nhỏ hoặc người già nghỉ dưỡng.\nAn ninh bảo vệ khép kín 24/7.\nGiá thuê: 26 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Tôn Dật Tiên	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
65	26	Cho thuê căn 3PN Scenic Valley tầng cao thoáng mát full đồ	28000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN SCENIC VALLEY TẦNG CAO 130M2\nĐịa chỉ: Đường Tôn Dật Tiên, Phường Tân Phú, TP. Hồ Chí Minh\nCăn 3PN diện tích lớn nhất dự án, ban công góc lộng gió cả ngày.\nTrang bị đầy đủ nội thất gia đình cao cấp, tủ lạnh Side-by-side.\nHồ bơi trong nhà và hồ bơi ngoài trời sử dụng hoàn toàn miễn phí.\nGiá thuê: 28 Triệu/tháng\nLiên hệ: 092x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Tôn Dật Tiên	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
66	49	Căn 1PN Sunrise City Central full nội thất đẹp giá tốt	13000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN SUNRISE CITY CENTRAL DIỆN TÍCH 56M2\nĐịa chỉ: 23 Brookside / Nguyễn Hữu Thọ, Phường Tân Hưng, TP. Hồ Chí Minh\nCăn hộ 1PN khu Central đối diện siêu thị Lotte Mart Tân Hưng.\nĐầy đủ nội thất sinh hoạt: Sofa, tivi, tủ lạnh, máy giặt, giường nệm.\nTiện ích: Hồ bơi tràn bờ, phòng gym, khu vui chơi trẻ em, nhà thuốc, ngân hàng.\nGiá thuê: 13 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	23 Brookside / Nguyễn Hữu Thọ	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
67	36	Căn 2PN Sunrise City South tầng cao view trung tâm lộng lẫy	17500000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN SUNRISE CITY SOUTH DIỆN TÍCH 76M2\nĐịa chỉ: 23 Brookside / Nguyễn Hữu Thọ, Phường Tân Hưng, TP. Hồ Chí Minh\nCăn hộ 2PN khu South Towers chất lượng xây dựng kiên cố vượt trội.\nBan công hướng Bắc đón gió mát ngắm view thành phố lung linh.\nTrang bị full đồ gỗ nội thất tự nhiên bền đẹp.\nGiá thuê: 17.5 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	23 Brookside / Nguyễn Hữu Thọ	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
68	21	Căn góc 3PN Sunrise City North thiết kế rộng rãi thoáng mát	23000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN SUNRISE CITY NORTH 120M2\nĐịa chỉ: 23 Brookside / Nguyễn Hữu Thọ, Phường Tân Hưng, TP. Hồ Chí Minh\nCăn góc 3 phòng ngủ thoáng mát, các không gian phòng đều ngập tràn ánh sáng.\nĐã được trang bị full trang thiết bị đồ dùng gia đình.\nVị trí cửa ngõ Nam TP.HCM di chuyển sang trung tâm chỉ 10 phút.\nGiá thuê: 23 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	23 Brookside / Nguyễn Hữu Thọ	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
69	37	Căn Penthouse Sunrise City South diện tích lớn view 360 độ	55000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE SUNRISE CITY SOUTH DIỆN TÍCH 210M2\nĐịa chỉ: 23 Brookside / Nguyễn Hữu Thọ, Phường Tân Hưng, TP. Hồ Chí Minh\nCăn Penthouse không gian cực kỳ rộng rãi, ban công lớn ngắm toàn cảnh khu Nam Sài Gòn.\nTrang bị nội thất sang trọng cổ điển cao cấp.\nThang máy bảo mật thẻ từ tầng riêng biệt.\nGiá thuê: 55 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	23 Brookside / Nguyễn Hữu Thọ	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
70	62	Biệt thự trên không Serenity Sky Villas 2PN hồ bơi riêng 136m2	90000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nBIỆT THỰ TRÊN KHÔNG SIÊU SANG SERENITY SKY VILLAS DIỆN TÍCH 136M2\nĐịa chỉ: 259 Điện Biên Phủ, Phường Xuân Khánh, TP. Hồ Chí Minh\nBiệt thự trên không độc bản chỉ có 45 căn duy nhất tại dự án.\nTích hợp hồ bơi riêng và sân vườn riêng ngay tại ban công từng căn hộ.\nChiều cao trần phòng khách thông tầng lên tới 7m, thiết kế siêu sang trọng.\nGiá thuê: 90 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	259 Điện Biên Phủ	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
71	39	Căn 3PN Serenity Sky Villas thông tầng trần cao 7m đẳng cấp	120000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nBIỆT THỰ TRÊN KHÔNG 3PN SERENITY SKY VILLAS 210M2\nĐịa chỉ: 259 Điện Biên Phủ, Phường Xuân Khánh, TP. Hồ Chí Minh\nCăn hộ 3PN Duplex thiết kế đỉnh cao, hồ bơi riêng nước mặn ngoài ban công.\nBàn giao đầy đủ siêu nội thất nhập khẩu từ các thương hiệu xa xỉ nhất Châu Âu.\nThang máy nâng ô tô tận hộ và thang máy riêng vào nhà.\nGiá thuê: 120 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	259 Điện Biên Phủ	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
72	17	Căn 4PN Serenity Sky Villas không gian sống riêng tư tuyệt đối	160000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nSIÊU BIỆT THỰ TRÊN KHÔNG 4PN SERENITY SKY VILLAS 330M2\nĐịa chỉ: 259 Điện Biên Phủ, Phường Xuân Khánh, TP. Hồ Chí Minh\nCăn biệt thự trên không 4PN diện tích cực đại 330m2.\nSân vườn xanh mát và hồ bơi vô cực riêng trải dài theo ban công căn hộ.\nKhớp nối hoàn hảo giữa thiên nhiên và phong cách sống thượng lưu.\nGiá thuê: 160 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	259 Điện Biên Phủ	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
73	29	Penthouse Serenity Sky Villas kiệt tác thượng lưu số 1 Sài Gòn	250000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE SERENITY SKY VILLAS DIỆN TÍCH 500M2\nĐịa chỉ: 259 Điện Biên Phủ, Phường Xuân Khánh, TP. Hồ Chí Minh\nCăn Penthouse độc bản đỉnh tháp Serenity Sky Villas, biểu tượng sống cao nhất của giới siêu giàu.\nHồ bơi riêng cực lớn, sân vườn riêng ôm trọn 4 mặt góc nhìn thành phố.\nDịch vụ quản gia concierge cá nhân hóa phục vụ 24/7.\nGiá thuê: 250 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	259 Điện Biên Phủ	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
74	38	Căn 1PN Sunwah Pearl tháp White House full đồ siêu đẹp	20000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN SUNWAH PEARL WHITE HOUSE DIỆN TÍCH 56M2\nĐịa chỉ: 90 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn hộ 1PN tháp White House thiết kế vuông vức, tông màu sáng hiện đại.\nBàn giao full trang thiết bị nội thất xịn, ban công hướng mát đón gió sông.\nVị trí đắc địa ngay chân cầu Thủ Thiêm, di chuyển sang trung tâm chỉ 3 phút.\nGiá thuê: 20 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	90 Nguyễn Hữu Cảnh	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
75	65	Cho thuê căn 2PN Sunwah Pearl tháp Silver House view sông cực phẩm	30000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN SUNWAH PEARL SILVER HOUSE 102M2\nĐịa chỉ: 90 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn 2PN diện tích cực rộng 102m2, ban công góc view sông Sài Gòn và Bitexco đỉnh cao.\nThiết kế nội thất phong cách Châu Âu hiện đại sang trọng.\nTiện ích nội khu: Hồ bơi tràn bờ 1.000m2, công viên bến thuyền, phòng tập gym.\nGiá thuê: 30 Triệu/tháng.\\nLiên hệ: 091x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	90 Nguyễn Hữu Cảnh	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
76	71	Căn góc 3PN Sunwah Pearl tháp Golden House ngắm trọn Bason	48000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN SUNWAH PEARL GOLDEN HOUSE 128M2\nĐịa chỉ: 90 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn góc đắt giá nhất tháp Golden House, các phòng ngủ đều ngắm trực diện sông.\nBếp kín hiện đại trang bị thiết bị Bosch âm tủ.\nCộng đồng cư dân cao cấp, an ninh bảo vệ khép kín 24/7.\nGiá thuê: 48 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	90 Nguyễn Hữu Cảnh	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
77	40	Penthouse Sunwah Pearl tầm nhìn ôm trọn sông Sài Gòn	110000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE SUNWAH PEARL TẦNG CAO DIỆN TÍCH 230M2\nĐịa chỉ: 90 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nSiêu căn hộ Penthouse độc bản trên tầng cao nhất của dự án Sunwah Pearl.\nThiết kế hiện đại đẳng cấp, không gian sân vườn ban công siêu rộng ngắm toàn cảnh.\nTrang bị sảnh thang máy riêng biệt bảo mật cao.\nGiá thuê: 110 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	90 Nguyễn Hữu Cảnh	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
78	54	Căn 1PN Masteri Rise Mount The Global City thiết kế đẳng cấp	18000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN THE GLOBAL CITY DIỆN TÍCH 50M2\nĐịa chỉ: Đường Đỗ Xuân Hợp, Phường An Phú, TP. Hồ Chí Minh\nCăn hộ cao cấp nằm trong siêu đô thị biểu tượng do Foster & Partners thiết kế.\nThiết kế tối tân, ban công hướng Nam lộng gió ngắm kênh đào nhạc nước.\nĐầy đủ tiện ích tiêu chuẩn quốc tế: TTTM 123.000m2, khu nhạc nước lớn nhất ĐNA.\nGiá thuê: 18 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Đỗ Xuân Hợp	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
79	50	Căn 2PN The Global City An Phú view kênh đào nhạc nước tuyệt đẹp	27000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN THE GLOBAL CITY AN PHÚ DIỆN TÍCH 75M2\nĐịa chỉ: Đường Đỗ Xuân Hợp, Phường An Phú, TP. Hồ Chí Minh\nCăn 2PN ban công cực rộng, không gian phòng khách hiện đại ngập tràn ánh sáng.\nNội thất nhập khẩu chuẩn Foster & Partners thiết kế riêng.\nCư dân tận hưởng trọn vẹn hạ tầng chuẩn Downtown mới của TP.HCM.\nGiá thuê: 27 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Đỗ Xuân Hợp	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
80	96	Căn góc 3PN The Global City thiết kế thông minh full tiện nghi	38000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN THE GLOBAL CITY DIỆN TÍCH 105M2\nĐịa chỉ: Đường Đỗ Xuân Hợp, Phường An Phú, TP. Hồ Chí Minh\nCăn góc 2 mặt thoáng view trọn khu nhà phố SOHO năng động và đường đua Go-kart.\nĐầy đủ đồ dùng cao cấp, hệ thống thiết bị lọc khí thông minh.\nThuận tiện di chuyển qua cao tốc TP.HCM - Long Thành Dầu Giây.\nGiá thuê: 38 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Đỗ Xuân Hợp	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
81	75	Cho thuê Penthouse The Global City tầm nhìn biểu tượng vô tận	85000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE THE GLOBAL CITY AN PHÚ DIỆN TÍCH 190M2\nĐịa chỉ: Đường Đỗ Xuân Hợp, Phường An Phú, TP. Hồ Chí Minh\nSiêu phẩm Penthouse không gian thượng lưu, chiều cao trần phòng khách vượt trội.\nBan công kính vô cực ngắm trọn vẹn đại lộ mua sắm sầm uất.\nThang máy riêng, dịch vụ quản gia cao cấp riêng cho cư dân.\nGiá thuê: 85 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Đỗ Xuân Hợp	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
82	8	Căn 1PN The Marq Nguyễn Đình Chiểu full nội thất hạng sang	28000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN THE MARQ NGUYỄN ĐÌNH CHIỂU 52M2\nĐịa chỉ: 29B Nguyễn Đình Chiểu, Phường Đa Kao, TP. Hồ Chí Minh\nCăn hộ 1PN phân khu hạng sang trung tâm Đa Kao, trần cao 3.2m thoáng đạt.\nBàn giao sàn đá Cẩm Thạch (Marble) tự nhiên sang trọng.\nTiện ích tầng tầng mái The Sky Club: Hồ bơi vô cực 30m, Sky Bar, phòng Gym ngắm cảnh.\nGiá thuê: 28 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	29B Nguyễn Đình Chiểu	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
83	79	Cho thuê căn 2PN The Marq Đa Kao view trung tâm thành phố	40000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN THE MARQ NGUYỄN ĐÌNH CHIỂU 78M2\nĐịa chỉ: 29B Nguyễn Đình Chiểu, Phường Đa Kao, TP. Hồ Chí Minh\nCăn hộ 2PN thiết kế tối giản tinh tế theo phong cách Hongkong Land.\nTrang bị đầy đủ nội thất nhập khẩu Châu Âu cao cấp, đồ dùng hiện đại.\nVị trí đắc địa gần các đại sứ quán và tòa nhà văn phòng hạng A.\nGiá thuê: 40 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	29B Nguyễn Đình Chiểu	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
84	101	Căn 3PN The Marq sang trọng có sảnh thang máy riêng biệt	65000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN THE MARQ THANG MÁY RIÊNG 120M2\nĐịa chỉ: 29B Nguyễn Đình Chiểu, Phường Đa Kao, TP. Hồ Chí Minh\nCăn 3PN sở hữu sảnh thang máy riêng biệt mở ra không gian sống đẳng cấp.\nBếp khô và bếp wet trang bị toàn bộ thiết bị Küppersbusch đỉnh cao.\nTầm nhìn ngắm toàn cảnh cây xanh mảng lớn trung tâm thành phố.\nGiá thuê: 65 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	29B Nguyễn Đình Chiểu	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
85	56	Căn 4PN The Marq Đa Kao căn góc tầng cao cực đắt giá	100000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 4PN THE MARQ ĐA KAO DIỆN TÍCH 146M2\nĐịa chỉ: 29B Nguyễn Đình Chiểu, Phường Đa Kao, TP. Hồ Chí Minh\nCăn góc 4PN xuất sắc nhất dự án The Marq với thiết kế trần cao và ban công kính lớn.\nTrang bị sảnh thang máy riêng, nội thất đặt làm riêng thượng thượng thừa.\n An ninh bảo vệ nghiêm ngặt 24/24.\nGiá thuê: 100 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	29B Nguyễn Đình Chiểu	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
86	87	Căn 1PN The River Thủ Thiêm full nội thất thiết kế hiện đại	24000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN THE RIVER THỦ THIÊM DIỆN TÍCH 57M2\nĐịa chỉ: Đại lộ Trống Đồng, Phường Thủ Thiêm, TP. Hồ Chí Minh.\nCăn hộ 1PN phân khu Seine Tower, thiết kế phong cách Châu Âu hiện đại.\nBan công hướng mát, nội thất nhập khẩu cao cấp đầy đủ tiện nghi.\nVị trí sát sông Sài Gòn, không khí xung quanh luôn trong lành thoáng mát.\nGiá thuê: 24 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đại lộ Trống Đồng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
87	59	Căn 2PN The River Thủ Thiêm view trực diện sông lộng gió	36000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN THE RIVER THỦ THIÊM VIEW SÔNG 84M2\nĐịa chỉ: Đại lộ Trống Đồng, Phường Thủ Thiêm, TP. Hồ Chí Minh\nThiết kế không gian mở tối đa không gian đón sáng, view sông trực diện đắt giá.\nTrang bị đồ gỗ cao cấp, hệ thống điều hòa Daikin âm trần.\nTiện ích tiêu chuẩn 5 sao: Hồ bơi Olimpic 50m, phòng chiếu phim, xông hơi.\nGiá thuê: 36 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đại lộ Trống Đồng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
88	30	Căn 3PN The River Thủ Thiêm thang máy riêng nội thất siêu sang	62000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN THE RIVER THỦ THIÊM THANG MÁY RIÊNG 125M2\nĐịa chỉ: Đại lộ Trống Đồng, Phường Thủ Thiêm, TP. Hồ Chí Minh.\nCăn hộ có sảnh thang máy riêng mang lại sự riêng tư riêng biệt cho gia chủ.\nBàn giao đầy đủ thiết bị bếp thương hiệu Miele (Đức).\nTầm nhìn ôm trọn công viên bờ sông và cầu Ba Sơn.\nGiá thuê: 62 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đại lộ Trống Đồng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
89	44	Căn Pool Villa The River Thủ Thiêm có hồ bơi riêng xa hoa	130000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nPOOL VILLA THE RIVER THỦ THIÊM HỒ BƠI RIÊNG 240M2\nĐịa chỉ: Đại lộ Trống Đồng, Phường Thủ Thiêm, TP. Hồ Chí Minh.\nSiêu căn hộ Pool Villa sở hữu hồ bơi riêng ngoài ban công rộng lớn ngắm sông.\nThiết kế kiến trúc đỉnh cao, 4 phòng ngủ master trang bị phòng thay đồ riêng.\nDịch vụ quản lý tòa nhà chất lượng chuẩn quốc tế.\\n- Giá thuê: 130 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đại lộ Trống Đồng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
90	68	Căn 1PN Landmark 1 Vinhomes Central Park full nội thất cao cấp	16500000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN LANDMARK 1 VINHOMES CENTRAL PARK 54M2\nĐịa chỉ: 208 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn hộ 1PN tòa Landmark 1 ngay sát tháp Landmark 81 sầm uất.\nNội thất cao cấp hiện đại: Sofa da, tivi 55 inch, máy giặt sấy, tủ lạnh 2 cánh.\nBước vài bước chân ra công viên ven sông 14ha lộng gió.\nGiá thuê: 16.5 Triệu/tháng.\nLiên hệ: 090x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	208 Nguyễn Hữu Cảnh	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
91	76	Cho thuê căn 2PN Park 3 view trực diện công viên 14ha lộng gió	23000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN PARK 3 VINHOMES CENTRAL PARK VIEW CÔNG VIÊN 78M2\nĐịa chỉ: 208 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn hộ 2PN 2WC tòa Park 3, ban công hướng Đông Nam ngắm trọn công viên ven sông 14ha.\nTrang bị full nội thất nhập khẩu, nhà trống sẵn sàng bàn giao ngay.\nĐầy đủ tiện ích: Bệnh viện Vinmec, trường Vinschool, bến du thuyền, TTTM.\nGiá thuê: 23 Triệu/tháng.\nLiên hệ: 090x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	208 Nguyễn Hữu Cảnh	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
92	100	Căn góc 3PN Central 2 Vinhomes Central Park nội thất nhập khẩu	35000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN CENTRAL 2 VINHOMES CENTRAL PARK 115M2\nĐịa chỉ: 208 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn góc 3PN diện tích lớn, các phòng ngủ đều có cửa sổ lớn ngắm cảnh thành phố.\nTrang bị dàn nội thất xịn xò nhập khẩu hoàn toàn từ Châu Âu.\nCư dân tận hưởng tiện ích hồ bơi, phòng gym, sân cờ ngoài trời hoàn toàn miễn phí.\nGiá thuê: 35 Triệu/tháng.\\nLiên hệ: 090x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	208 Nguyễn Hữu Cảnh	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
93	77	Cho thuê căn 4PN Landmark 81 tầng cao view toàn cảnh thành phố	70000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 4PN LANDMARK 81 TẦNG CAO DIỆN TÍCH 144M2\nĐịa chỉ: 208 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nSiêu căn hộ 4PN nằm trong tòa tháp cao nhất Việt Nam Landmark 81.\nTầm nhìn triệu đô ngắm toàn cảnh thành phố lung linh về đêm từ độ cao ấn tượng.\nDịch vụ quản gia, sảnh chờ VIP đẳng cấp hàng đầu.\nGiá thuê: 70 Triệu/tháng.\\nLiên hệ: 090x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	208 Nguyễn Hữu Cảnh	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
94	95	Cho thuê căn Studio The Rainbow Vinhomes Grand Park full đồ	6500000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ STUDIO VINHOMES GRAND PARK DIỆN TÍCH 33M2\nĐịa chỉ: Đường Nguyễn Xiển, Phường Long Bình, TP. Hồ Chí Minh\nCăn hộ Studio nhỏ gọn thiết kế thông minh, tối ưu diện tích sử dụng.\nĐầy đủ nội thất: Sofa, tủ lạnh, máy giặt, máy lạnh, bếp từ.\nMiễn phí sử dụng công viên ánh sáng 36ha, biển nhân tạo, sân thể thao ngoài trời.\nGiá thuê: 6.5 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Nguyễn Xiển	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
95	42	Căn 2PN1WC The Origami Vinhomes Grand Park nội thất Nhật Bản	9000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN1WC THE ORIGAMI VINHOMES GRAND PARK 59M2\nĐịa chỉ: Đường Nguyễn Xiển, Phường Long Bình, TP. Hồ Chí Minh\nCăn hộ phân khu The Origami phong cách chuẩn Nhật, view công viên vườn tùng.\nThiết kế 2PN xinh xắn, nội thất gỗ ấm cúng nhẹ nhàng.\nHệ thống xe bus điện VinBus đưa đón cư dân miễn phí kết nối trung tâm.\nGiá thuê: 9 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Nguyễn Xiển	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
96	46	Căn 2PN2WC Masteri Centre Point Vinhomes Grand Park cực sang	14000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN2WC MASTERI CENTRE POINT GRAND PARK 72M2\nĐịa chỉ: Đường Nguyễn Xiển, Phường Long Bình, TP. Hồ Chí Minh\nCăn hộ thuộc phân khu compound cao cấp nhất đại đô thị Vinhomes Grand Park.\nBàn giao nội thất chuẩn cao cấp: Bếp Hafele, kính Kohler, hệ điều hòa âm trần.\nHồ bơi phi thuyền 2 tầng và sảnh đón sang trọng như khách sạn.\nGiá thuê: 14 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Nguyễn Xiển	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
97	72	Căn 3PN The Beverly Vinhomes Grand Park view trực diện công viên 36ha	20000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN THE BEVERLY VINHOMES GRAND PARK 100M2\nĐịa chỉ: Đường Nguyễn Xiển, Phường Long Bình, TP. Hồ Chí Minh\nCăn hộ phân khu The Beverly đắt giá đối diện TTTM Vincom Mega Mall lớn nhất miền Nam.\nBan công trực diện công viên 36ha ngắm trọn biển hồ nhân tạo.\nTrang bị toàn bộ thiết bị nội thất xịn xò nhập khẩu.\nGiá thuê: 20 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	Đường Nguyễn Xiển	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
98	14	Căn 1PN Aqua 1 Vinhomes Golden River full đồ sang trọng	21000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN AQUA 1 VINHOMES GOLDEN RIVER 50M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nCăn hộ 1PN tòa Aqua 1 ngay trung tâm Bến Nghé, kính Low-E cản nhiệt phủ toàn bộ mặt ngoài.\nTrang bị hệ thống Smarthome, thiết bị vệ sinh Duravit và thiết bị bếp Bosch.\nTầm nhìn view sông Sài Gòn và kênh Thị Nghè mát mẻ.\nGiá thuê: 21 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	2 Tôn Đức Thắng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
99	41	Cho thuê căn 2PN Lux 6 Vinhomes Golden River view trực diện sông	32000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN LUX 6 VINHOMES GOLDEN RIVER VIEW SÔNG 78M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nCăn hộ 2PN tòa Luxury 6 đắt giá, ban công ngắm trực diện sông Sài Gòn và thảo cầm viên.\nNội thất hiện đại nhập khẩu full Option.\nTiện ích: Ga Metro Ba Son ngay nội khu, đường chạy bộ ven sông, bến du thuyền 5 sao.\nGiá thuê: 32 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	2 Tôn Đức Thắng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
100	35	Căn góc 3PN Aqua 2 Vinhomes Golden River nội thất xa xỉ	50000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN AQUA 2 VINHOMES GOLDEN RIVER 110M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nCăn góc 3PN diện tích rộng, view ôm trọn cầu Ba Sơn và tháp Bitexco.\nĐã chuẩn bị sẵn sàng toàn bộ trang thiết bị sinh hoạt cao cấp nhất.\nVị trí kim cương ngay trái tim trung tâm thành phố.\nGiá thuê: 50 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	2 Tôn Đức Thắng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
101	58	Căn 4PN Penthouse Vinhomes Golden River đẳng cấp đỉnh cao	95000000.00	\N	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE 4PN VINHOMES GOLDEN RIVER BA SON 160M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nPenthouse tầng cao tầm nhìn panorama không giới hạn ngắm toàn cảnh sông nước Sài Gòn.\nKhông gian sống riêng tư, thượng lưu dành cho các chủ nhân thành đạt.\nAn ninh bảo vệ 24/7 với hệ thống camera AI hiện đại.\nGiá thuê: 95 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]	2 Tôn Đức Thắng	AVAILABLE	2026-10-11 15:43:02.119508	2026-10-11 15:43:02.119508	RENT	t
\.


--
-- TOC entry 5581 (class 0 OID 17309)
-- Dependencies: 232
-- Data for Name: property_images; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.property_images (image_id, property_id, image_url, is_thumbnail, uploaded_at) FROM stdin;
1	1	images/vinhomes-1.jpg	1	2026-10-11 12:56:50.41717
2	1	images/vinhomes-1-detail.jpg	0	2026-10-11 12:56:50.41717
3	2	images/vinhomes-2.jpg	1	2026-10-11 12:56:50.41717
4	3	images/masteri-1.jpg	1	2026-10-11 12:56:50.41717
5	4	images/masteri-2.jpg	1	2026-10-11 12:56:50.41717
6	5	images/sunrise-1.jpg	1	2026-10-11 12:56:50.41717
7	7	images/rentals/rental_22.jpg	1	2026-10-11 15:43:02.119508
8	7	images/rentals/rental_15.jpg	0	2026-10-11 15:43:02.119508
9	7	images/rentals/rental_16.jpg	0	2026-10-11 15:43:02.119508
10	8	images/rentals/rental_01.jpg	1	2026-10-11 15:43:02.119508
11	8	images/rentals/rental_08.jpg	0	2026-10-11 15:43:02.119508
12	9	images/rentals/rental_28.jpg	1	2026-10-11 15:43:02.119508
13	9	images/rentals/rental_18.jpg	0	2026-10-11 15:43:02.119508
14	10	images/rentals/rental_13.jpg	1	2026-10-11 15:43:02.119508
15	10	images/rentals/rental_16.jpg	0	2026-10-11 15:43:02.119508
16	10	images/rentals/rental_22.jpg	0	2026-10-11 15:43:02.119508
17	11	images/rentals/rental_03.jpg	1	2026-10-11 15:43:02.119508
18	11	images/rentals/rental_29.jpg	0	2026-10-11 15:43:02.119508
19	12	images/rentals/rental_21.jpg	1	2026-10-11 15:43:02.119508
20	12	images/rentals/rental_18.jpg	0	2026-10-11 15:43:02.119508
21	13	images/rentals/rental_16.jpg	1	2026-10-11 15:43:02.119508
22	13	images/rentals/rental_30.jpg	0	2026-10-11 15:43:02.119508
23	13	images/rentals/rental_15.jpg	0	2026-10-11 15:43:02.119508
24	14	images/rentals/rental_14.jpg	1	2026-10-11 15:43:02.119508
25	14	images/rentals/rental_29.jpg	0	2026-10-11 15:43:02.119508
26	15	images/rentals/rental_21.jpg	1	2026-10-11 15:43:02.119508
27	15	images/rentals/rental_25.jpg	0	2026-10-11 15:43:02.119508
28	16	images/rentals/rental_27.jpg	1	2026-10-11 15:43:02.119508
29	16	images/rentals/rental_17.jpg	0	2026-10-11 15:43:02.119508
30	16	images/rentals/rental_20.jpg	0	2026-10-11 15:43:02.119508
31	17	images/rentals/rental_11.jpg	1	2026-10-11 15:43:02.119508
32	17	images/rentals/rental_29.jpg	0	2026-10-11 15:43:02.119508
33	18	images/rentals/rental_06.jpg	1	2026-10-11 15:43:02.119508
34	18	images/rentals/rental_23.jpg	0	2026-10-11 15:43:02.119508
35	19	images/rentals/rental_07.jpg	1	2026-10-11 15:43:02.119508
36	19	images/rentals/rental_28.jpg	0	2026-10-11 15:43:02.119508
37	19	images/rentals/rental_18.jpg	0	2026-10-11 15:43:02.119508
38	20	images/rentals/rental_08.jpg	1	2026-10-11 15:43:02.119508
39	20	images/rentals/rental_02.jpg	0	2026-10-11 15:43:02.119508
40	21	images/rentals/rental_19.jpg	1	2026-10-11 15:43:02.119508
41	21	images/rentals/rental_07.jpg	0	2026-10-11 15:43:02.119508
42	22	images/rentals/rental_21.jpg	1	2026-10-11 15:43:02.119508
43	22	images/rentals/rental_04.jpg	0	2026-10-11 15:43:02.119508
44	22	images/rentals/rental_18.jpg	0	2026-10-11 15:43:02.119508
45	23	images/rentals/rental_13.jpg	1	2026-10-11 15:43:02.119508
46	23	images/rentals/rental_26.jpg	0	2026-10-11 15:43:02.119508
47	24	images/rentals/rental_09.jpg	1	2026-10-11 15:43:02.119508
48	24	images/rentals/rental_12.jpg	0	2026-10-11 15:43:02.119508
49	25	images/rentals/rental_07.jpg	1	2026-10-11 15:43:02.119508
50	25	images/rentals/rental_24.jpg	0	2026-10-11 15:43:02.119508
51	25	images/rentals/rental_28.jpg	0	2026-10-11 15:43:02.119508
52	26	images/rentals/rental_07.jpg	1	2026-10-11 15:43:02.119508
53	26	images/rentals/rental_05.jpg	0	2026-10-11 15:43:02.119508
54	27	images/rentals/rental_11.jpg	1	2026-10-11 15:43:02.119508
55	27	images/rentals/rental_10.jpg	0	2026-10-11 15:43:02.119508
56	28	images/rentals/rental_16.jpg	1	2026-10-11 15:43:02.119508
57	28	images/rentals/rental_26.jpg	0	2026-10-11 15:43:02.119508
58	28	images/rentals/rental_13.jpg	0	2026-10-11 15:43:02.119508
59	29	images/rentals/rental_23.jpg	1	2026-10-11 15:43:02.119508
60	29	images/rentals/rental_25.jpg	0	2026-10-11 15:43:02.119508
61	30	images/rentals/rental_06.jpg	1	2026-10-11 15:43:02.119508
62	30	images/rentals/rental_23.jpg	0	2026-10-11 15:43:02.119508
63	31	images/rentals/rental_30.jpg	1	2026-10-11 15:43:02.119508
64	31	images/rentals/rental_16.jpg	0	2026-10-11 15:43:02.119508
65	31	images/rentals/rental_15.jpg	0	2026-10-11 15:43:02.119508
66	32	images/rentals/rental_07.jpg	1	2026-10-11 15:43:02.119508
67	32	images/rentals/rental_05.jpg	0	2026-10-11 15:43:02.119508
68	33	images/rentals/rental_21.jpg	1	2026-10-11 15:43:02.119508
69	33	images/rentals/rental_04.jpg	0	2026-10-11 15:43:02.119508
70	34	images/rentals/rental_03.jpg	1	2026-10-11 15:43:02.119508
71	34	images/rentals/rental_14.jpg	0	2026-10-11 15:43:02.119508
72	34	images/rentals/rental_29.jpg	0	2026-10-11 15:43:02.119508
73	35	images/rentals/rental_17.jpg	1	2026-10-11 15:43:02.119508
74	35	images/rentals/rental_20.jpg	0	2026-10-11 15:43:02.119508
75	36	images/rentals/rental_28.jpg	1	2026-10-11 15:43:02.119508
76	36	images/rentals/rental_24.jpg	0	2026-10-11 15:43:02.119508
77	6	images/rentals/rental_02.jpg	1	2026-10-11 15:43:02.119508
78	6	images/rentals/rental_01.jpg	0	2026-10-11 15:43:02.119508
79	6	images/rentals/rental_08.jpg	0	2026-10-11 15:43:02.119508
80	37	images/rentals/rental_11.jpg	1	2026-10-11 15:43:02.119508
81	37	images/rentals/rental_10.jpg	0	2026-10-11 15:43:02.119508
82	38	images/rentals/rental_19.jpg	1	2026-10-11 15:43:02.119508
83	38	images/rentals/rental_07.jpg	0	2026-10-11 15:43:02.119508
84	39	images/rentals/rental_17.jpg	1	2026-10-11 15:43:02.119508
85	39	images/rentals/rental_27.jpg	0	2026-10-11 15:43:02.119508
86	39	images/rentals/rental_20.jpg	0	2026-10-11 15:43:02.119508
87	40	images/rentals/rental_09.jpg	1	2026-10-11 15:43:02.119508
88	40	images/rentals/rental_12.jpg	0	2026-10-11 15:43:02.119508
89	41	images/rentals/rental_04.jpg	1	2026-10-11 15:43:02.119508
90	41	images/rentals/rental_21.jpg	0	2026-10-11 15:43:02.119508
91	42	images/rentals/rental_02.jpg	1	2026-10-11 15:43:02.119508
92	42	images/rentals/rental_08.jpg	0	2026-10-11 15:43:02.119508
93	42	images/rentals/rental_01.jpg	0	2026-10-11 15:43:02.119508
94	43	images/rentals/rental_29.jpg	1	2026-10-11 15:43:02.119508
95	43	images/rentals/rental_03.jpg	0	2026-10-11 15:43:02.119508
96	44	images/rentals/rental_13.jpg	1	2026-10-11 15:43:02.119508
97	44	images/rentals/rental_26.jpg	0	2026-10-11 15:43:02.119508
98	45	images/rentals/rental_27.jpg	1	2026-10-11 15:43:02.119508
99	45	images/rentals/rental_20.jpg	0	2026-10-11 15:43:02.119508
100	45	images/rentals/rental_17.jpg	0	2026-10-11 15:43:02.119508
101	46	images/rentals/rental_09.jpg	1	2026-10-11 15:43:02.119508
102	46	images/rentals/rental_12.jpg	0	2026-10-11 15:43:02.119508
103	47	images/rentals/rental_29.jpg	1	2026-10-11 15:43:02.119508
104	47	images/rentals/rental_14.jpg	0	2026-10-11 15:43:02.119508
105	48	images/rentals/rental_16.jpg	1	2026-10-11 15:43:02.119508
106	48	images/rentals/rental_30.jpg	0	2026-10-11 15:43:02.119508
107	48	images/rentals/rental_15.jpg	0	2026-10-11 15:43:02.119508
108	49	images/rentals/rental_07.jpg	1	2026-10-11 15:43:02.119508
109	49	images/rentals/rental_05.jpg	0	2026-10-11 15:43:02.119508
110	50	images/rentals/rental_23.jpg	1	2026-10-11 15:43:02.119508
111	50	images/rentals/rental_06.jpg	0	2026-10-11 15:43:02.119508
112	51	images/rentals/rental_24.jpg	1	2026-10-11 15:43:02.119508
113	51	images/rentals/rental_28.jpg	0	2026-10-11 15:43:02.119508
114	51	images/rentals/rental_07.jpg	0	2026-10-11 15:43:02.119508
115	52	images/rentals/rental_22.jpg	1	2026-10-11 15:43:02.119508
116	52	images/rentals/rental_15.jpg	0	2026-10-11 15:43:02.119508
117	53	images/rentals/rental_11.jpg	1	2026-10-11 15:43:02.119508
118	53	images/rentals/rental_10.jpg	0	2026-10-11 15:43:02.119508
119	54	images/rentals/rental_25.jpg	1	2026-10-11 15:43:02.119508
120	54	images/rentals/rental_04.jpg	0	2026-10-11 15:43:02.119508
121	54	images/rentals/rental_21.jpg	0	2026-10-11 15:43:02.119508
122	55	images/rentals/rental_07.jpg	1	2026-10-11 15:43:02.119508
123	55	images/rentals/rental_19.jpg	0	2026-10-11 15:43:02.119508
124	56	images/rentals/rental_29.jpg	1	2026-10-11 15:43:02.119508
125	56	images/rentals/rental_14.jpg	0	2026-10-11 15:43:02.119508
126	57	images/rentals/rental_16.jpg	1	2026-10-11 15:43:02.119508
127	57	images/rentals/rental_15.jpg	0	2026-10-11 15:43:02.119508
128	57	images/rentals/rental_22.jpg	0	2026-10-11 15:43:02.119508
129	58	images/rentals/rental_28.jpg	1	2026-10-11 15:43:02.119508
130	58	images/rentals/rental_24.jpg	0	2026-10-11 15:43:02.119508
131	59	images/rentals/rental_07.jpg	1	2026-10-11 15:43:02.119508
132	59	images/rentals/rental_05.jpg	0	2026-10-11 15:43:02.119508
133	60	images/rentals/rental_23.jpg	1	2026-10-11 15:43:02.119508
134	60	images/rentals/rental_25.jpg	0	2026-10-11 15:43:02.119508
135	60	images/rentals/rental_06.jpg	0	2026-10-11 15:43:02.119508
136	61	images/rentals/rental_11.jpg	1	2026-10-11 15:43:02.119508
137	61	images/rentals/rental_10.jpg	0	2026-10-11 15:43:02.119508
138	62	images/rentals/rental_07.jpg	1	2026-10-11 15:43:02.119508
139	62	images/rentals/rental_19.jpg	0	2026-10-11 15:43:02.119508
140	63	images/rentals/rental_16.jpg	1	2026-10-11 15:43:02.119508
141	63	images/rentals/rental_30.jpg	0	2026-10-11 15:43:02.119508
142	63	images/rentals/rental_15.jpg	0	2026-10-11 15:43:02.119508
143	64	images/rentals/rental_08.jpg	1	2026-10-11 15:43:02.119508
144	64	images/rentals/rental_02.jpg	0	2026-10-11 15:43:02.119508
145	65	images/rentals/rental_12.jpg	1	2026-10-11 15:43:02.119508
146	65	images/rentals/rental_09.jpg	0	2026-10-11 15:43:02.119508
147	66	images/rentals/rental_16.jpg	1	2026-10-11 15:43:02.119508
148	66	images/rentals/rental_26.jpg	0	2026-10-11 15:43:02.119508
149	66	images/rentals/rental_13.jpg	0	2026-10-11 15:43:02.119508
150	67	images/rentals/rental_29.jpg	1	2026-10-11 15:43:02.119508
151	67	images/rentals/rental_03.jpg	0	2026-10-11 15:43:02.119508
152	68	images/rentals/rental_20.jpg	1	2026-10-11 15:43:02.119508
153	68	images/rentals/rental_27.jpg	0	2026-10-11 15:43:02.119508
154	69	images/rentals/rental_01.jpg	1	2026-10-11 15:43:02.119508
155	69	images/rentals/rental_08.jpg	0	2026-10-11 15:43:02.119508
156	69	images/rentals/rental_02.jpg	0	2026-10-11 15:43:02.119508
157	70	images/rentals/rental_28.jpg	1	2026-10-11 15:43:02.119508
158	70	images/rentals/rental_18.jpg	0	2026-10-11 15:43:02.119508
159	71	images/rentals/rental_15.jpg	1	2026-10-11 15:43:02.119508
160	71	images/rentals/rental_30.jpg	0	2026-10-11 15:43:02.119508
161	72	images/rentals/rental_25.jpg	1	2026-10-11 15:43:02.119508
162	72	images/rentals/rental_23.jpg	0	2026-10-11 15:43:02.119508
163	72	images/rentals/rental_06.jpg	0	2026-10-11 15:43:02.119508
164	73	images/rentals/rental_20.jpg	1	2026-10-11 15:43:02.119508
165	73	images/rentals/rental_17.jpg	0	2026-10-11 15:43:02.119508
166	74	images/rentals/rental_08.jpg	1	2026-10-11 15:43:02.119508
167	74	images/rentals/rental_01.jpg	0	2026-10-11 15:43:02.119508
168	75	images/rentals/rental_07.jpg	1	2026-10-11 15:43:02.119508
169	75	images/rentals/rental_18.jpg	0	2026-10-11 15:43:02.119508
170	75	images/rentals/rental_05.jpg	0	2026-10-11 15:43:02.119508
171	76	images/rentals/rental_24.jpg	1	2026-10-11 15:43:02.119508
172	76	images/rentals/rental_28.jpg	0	2026-10-11 15:43:02.119508
173	77	images/rentals/rental_27.jpg	1	2026-10-11 15:43:02.119508
174	77	images/rentals/rental_20.jpg	0	2026-10-11 15:43:02.119508
175	78	images/rentals/rental_29.jpg	1	2026-10-11 15:43:02.119508
176	78	images/rentals/rental_03.jpg	0	2026-10-11 15:43:02.119508
177	78	images/rentals/rental_14.jpg	0	2026-10-11 15:43:02.119508
178	79	images/rentals/rental_10.jpg	1	2026-10-11 15:43:02.119508
179	79	images/rentals/rental_11.jpg	0	2026-10-11 15:43:02.119508
180	80	images/rentals/rental_13.jpg	1	2026-10-11 15:43:02.119508
181	80	images/rentals/rental_26.jpg	0	2026-10-11 15:43:02.119508
182	81	images/rentals/rental_18.jpg	1	2026-10-11 15:43:02.119508
183	81	images/rentals/rental_04.jpg	0	2026-10-11 15:43:02.119508
184	81	images/rentals/rental_21.jpg	0	2026-10-11 15:43:02.119508
185	82	images/rentals/rental_19.jpg	1	2026-10-11 15:43:02.119508
186	82	images/rentals/rental_07.jpg	0	2026-10-11 15:43:02.119508
187	83	images/rentals/rental_09.jpg	1	2026-10-11 15:43:02.119508
188	83	images/rentals/rental_12.jpg	0	2026-10-11 15:43:02.119508
189	84	images/rentals/rental_22.jpg	1	2026-10-11 15:43:02.119508
190	84	images/rentals/rental_15.jpg	0	2026-10-11 15:43:02.119508
191	84	images/rentals/rental_16.jpg	0	2026-10-11 15:43:02.119508
192	85	images/rentals/rental_06.jpg	1	2026-10-11 15:43:02.119508
193	85	images/rentals/rental_23.jpg	0	2026-10-11 15:43:02.119508
194	86	images/rentals/rental_03.jpg	1	2026-10-11 15:43:02.119508
195	86	images/rentals/rental_29.jpg	0	2026-10-11 15:43:02.119508
196	87	images/rentals/rental_16.jpg	1	2026-10-11 15:43:02.119508
197	87	images/rentals/rental_15.jpg	0	2026-10-11 15:43:02.119508
198	87	images/rentals/rental_22.jpg	0	2026-10-11 15:43:02.119508
199	88	images/rentals/rental_10.jpg	1	2026-10-11 15:43:02.119508
200	88	images/rentals/rental_11.jpg	0	2026-10-11 15:43:02.119508
201	89	images/rentals/rental_25.jpg	1	2026-10-11 15:43:02.119508
202	89	images/rentals/rental_21.jpg	0	2026-10-11 15:43:02.119508
203	90	images/rentals/rental_07.jpg	1	2026-10-11 15:43:02.119508
204	90	images/rentals/rental_18.jpg	0	2026-10-11 15:43:02.119508
205	90	images/rentals/rental_19.jpg	0	2026-10-11 15:43:02.119508
206	91	images/rentals/rental_07.jpg	1	2026-10-11 15:43:02.119508
207	91	images/rentals/rental_05.jpg	0	2026-10-11 15:43:02.119508
208	92	images/rentals/rental_20.jpg	1	2026-10-11 15:43:02.119508
209	92	images/rentals/rental_17.jpg	0	2026-10-11 15:43:02.119508
210	93	images/rentals/rental_16.jpg	1	2026-10-11 15:43:02.119508
211	93	images/rentals/rental_26.jpg	0	2026-10-11 15:43:02.119508
212	93	images/rentals/rental_13.jpg	0	2026-10-11 15:43:02.119508
213	94	images/rentals/rental_29.jpg	1	2026-10-11 15:43:02.119508
214	94	images/rentals/rental_14.jpg	0	2026-10-11 15:43:02.119508
215	95	images/rentals/rental_21.jpg	1	2026-10-11 15:43:02.119508
216	95	images/rentals/rental_04.jpg	0	2026-10-11 15:43:02.119508
217	96	images/rentals/rental_20.jpg	1	2026-10-11 15:43:02.119508
218	96	images/rentals/rental_27.jpg	0	2026-10-11 15:43:02.119508
219	96	images/rentals/rental_17.jpg	0	2026-10-11 15:43:02.119508
220	97	images/rentals/rental_24.jpg	1	2026-10-11 15:43:02.119508
221	97	images/rentals/rental_28.jpg	0	2026-10-11 15:43:02.119508
222	98	images/rentals/rental_02.jpg	1	2026-10-11 15:43:02.119508
223	98	images/rentals/rental_08.jpg	0	2026-10-11 15:43:02.119508
224	99	images/rentals/rental_15.jpg	1	2026-10-11 15:43:02.119508
225	99	images/rentals/rental_30.jpg	0	2026-10-11 15:43:02.119508
226	99	images/rentals/rental_16.jpg	0	2026-10-11 15:43:02.119508
227	100	images/rentals/rental_08.jpg	1	2026-10-11 15:43:02.119508
228	100	images/rentals/rental_01.jpg	0	2026-10-11 15:43:02.119508
229	101	images/rentals/rental_12.jpg	1	2026-10-11 15:43:02.119508
230	101	images/rentals/rental_09.jpg	0	2026-10-11 15:43:02.119508
\.


--
-- TOC entry 5592 (class 0 OID 18248)
-- Dependencies: 243
-- Data for Name: property_viewings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.property_viewings (viewing_id, customer_id, property_id, start_time, end_time, status, note, cancellation_reason, created_at, updated_at) FROM stdin;
1	2	2	2026-10-12 09:00:00	2026-10-12 10:00:00	CONFIRMED	Lich xem da xac nhan	\N	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717
2	3	2	2026-10-12 10:00:00	2026-10-12 11:00:00	PENDING	Lich xem cho xac nhan	\N	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717
3	4	2	2026-10-09 12:56:50.41717	2026-10-09 13:56:50.41717	COMPLETED	Da xem bat dong san	\N	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717
4	4	3	2026-10-13 14:00:00	2026-10-13 15:00:00	CANCELLED	\N	Bat dong san da duoc khach khac dat coc	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717
\.


--
-- TOC entry 5596 (class 0 OID 18326)
-- Dependencies: 247
-- Data for Name: rental_apartment_images; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rental_apartment_images (image_id, rental_id, image_url, sort_order, is_thumbnail, is_illustrative) FROM stdin;
225	1	images/rentals/rental_22.jpg	1	1	t
226	1	images/rentals/rental_15.jpg	2	0	t
227	1	images/rentals/rental_16.jpg	3	0	t
228	2	images/rentals/rental_01.jpg	1	1	t
229	2	images/rentals/rental_08.jpg	2	0	t
230	3	images/rentals/rental_28.jpg	1	1	t
231	3	images/rentals/rental_18.jpg	2	0	t
232	4	images/rentals/rental_13.jpg	1	1	t
233	4	images/rentals/rental_16.jpg	2	0	t
234	4	images/rentals/rental_22.jpg	3	0	t
235	5	images/rentals/rental_03.jpg	1	1	t
236	5	images/rentals/rental_29.jpg	2	0	t
237	6	images/rentals/rental_21.jpg	1	1	t
238	6	images/rentals/rental_18.jpg	2	0	t
239	7	images/rentals/rental_16.jpg	1	1	t
240	7	images/rentals/rental_30.jpg	2	0	t
241	7	images/rentals/rental_15.jpg	3	0	t
242	8	images/rentals/rental_14.jpg	1	1	t
243	8	images/rentals/rental_29.jpg	2	0	t
244	9	images/rentals/rental_21.jpg	1	1	t
245	9	images/rentals/rental_25.jpg	2	0	t
246	10	images/rentals/rental_27.jpg	1	1	t
247	10	images/rentals/rental_17.jpg	2	0	t
248	10	images/rentals/rental_20.jpg	3	0	t
249	11	images/rentals/rental_11.jpg	1	1	t
250	11	images/rentals/rental_29.jpg	2	0	t
251	12	images/rentals/rental_06.jpg	1	1	t
252	12	images/rentals/rental_23.jpg	2	0	t
253	13	images/rentals/rental_07.jpg	1	1	t
254	13	images/rentals/rental_28.jpg	2	0	t
255	13	images/rentals/rental_18.jpg	3	0	t
256	14	images/rentals/rental_08.jpg	1	1	t
257	14	images/rentals/rental_02.jpg	2	0	t
258	15	images/rentals/rental_19.jpg	1	1	t
259	15	images/rentals/rental_07.jpg	2	0	t
260	16	images/rentals/rental_21.jpg	1	1	t
261	16	images/rentals/rental_04.jpg	2	0	t
262	16	images/rentals/rental_18.jpg	3	0	t
263	17	images/rentals/rental_13.jpg	1	1	t
264	17	images/rentals/rental_26.jpg	2	0	t
265	18	images/rentals/rental_09.jpg	1	1	t
266	18	images/rentals/rental_12.jpg	2	0	t
267	19	images/rentals/rental_07.jpg	1	1	t
268	19	images/rentals/rental_24.jpg	2	0	t
269	19	images/rentals/rental_28.jpg	3	0	t
270	20	images/rentals/rental_07.jpg	1	1	t
271	20	images/rentals/rental_05.jpg	2	0	t
272	21	images/rentals/rental_11.jpg	1	1	t
273	21	images/rentals/rental_10.jpg	2	0	t
274	22	images/rentals/rental_16.jpg	1	1	t
275	22	images/rentals/rental_26.jpg	2	0	t
276	22	images/rentals/rental_13.jpg	3	0	t
277	23	images/rentals/rental_23.jpg	1	1	t
278	23	images/rentals/rental_25.jpg	2	0	t
279	24	images/rentals/rental_06.jpg	1	1	t
280	24	images/rentals/rental_23.jpg	2	0	t
281	25	images/rentals/rental_30.jpg	1	1	t
282	25	images/rentals/rental_16.jpg	2	0	t
283	25	images/rentals/rental_15.jpg	3	0	t
284	26	images/rentals/rental_07.jpg	1	1	t
285	26	images/rentals/rental_05.jpg	2	0	t
286	27	images/rentals/rental_21.jpg	1	1	t
287	27	images/rentals/rental_04.jpg	2	0	t
288	28	images/rentals/rental_03.jpg	1	1	t
289	28	images/rentals/rental_14.jpg	2	0	t
290	28	images/rentals/rental_29.jpg	3	0	t
291	29	images/rentals/rental_17.jpg	1	1	t
292	29	images/rentals/rental_20.jpg	2	0	t
293	30	images/rentals/rental_28.jpg	1	1	t
294	30	images/rentals/rental_24.jpg	2	0	t
295	31	images/rentals/rental_02.jpg	1	1	t
296	31	images/rentals/rental_01.jpg	2	0	t
297	31	images/rentals/rental_08.jpg	3	0	t
298	32	images/rentals/rental_11.jpg	1	1	t
299	32	images/rentals/rental_10.jpg	2	0	t
300	33	images/rentals/rental_19.jpg	1	1	t
301	33	images/rentals/rental_07.jpg	2	0	t
302	34	images/rentals/rental_17.jpg	1	1	t
303	34	images/rentals/rental_27.jpg	2	0	t
304	34	images/rentals/rental_20.jpg	3	0	t
305	35	images/rentals/rental_09.jpg	1	1	t
306	35	images/rentals/rental_12.jpg	2	0	t
307	36	images/rentals/rental_04.jpg	1	1	t
308	36	images/rentals/rental_21.jpg	2	0	t
309	37	images/rentals/rental_02.jpg	1	1	t
310	37	images/rentals/rental_08.jpg	2	0	t
311	37	images/rentals/rental_01.jpg	3	0	t
312	38	images/rentals/rental_29.jpg	1	1	t
313	38	images/rentals/rental_03.jpg	2	0	t
314	39	images/rentals/rental_13.jpg	1	1	t
315	39	images/rentals/rental_26.jpg	2	0	t
316	40	images/rentals/rental_27.jpg	1	1	t
317	40	images/rentals/rental_20.jpg	2	0	t
318	40	images/rentals/rental_17.jpg	3	0	t
319	41	images/rentals/rental_09.jpg	1	1	t
320	41	images/rentals/rental_12.jpg	2	0	t
321	42	images/rentals/rental_29.jpg	1	1	t
322	42	images/rentals/rental_14.jpg	2	0	t
323	43	images/rentals/rental_16.jpg	1	1	t
324	43	images/rentals/rental_30.jpg	2	0	t
325	43	images/rentals/rental_15.jpg	3	0	t
326	44	images/rentals/rental_07.jpg	1	1	t
327	44	images/rentals/rental_05.jpg	2	0	t
328	45	images/rentals/rental_23.jpg	1	1	t
329	45	images/rentals/rental_06.jpg	2	0	t
330	46	images/rentals/rental_24.jpg	1	1	t
331	46	images/rentals/rental_28.jpg	2	0	t
332	46	images/rentals/rental_07.jpg	3	0	t
333	47	images/rentals/rental_22.jpg	1	1	t
334	47	images/rentals/rental_15.jpg	2	0	t
335	48	images/rentals/rental_11.jpg	1	1	t
336	48	images/rentals/rental_10.jpg	2	0	t
337	49	images/rentals/rental_25.jpg	1	1	t
338	49	images/rentals/rental_04.jpg	2	0	t
339	49	images/rentals/rental_21.jpg	3	0	t
340	50	images/rentals/rental_07.jpg	1	1	t
341	50	images/rentals/rental_19.jpg	2	0	t
342	51	images/rentals/rental_29.jpg	1	1	t
343	51	images/rentals/rental_14.jpg	2	0	t
344	52	images/rentals/rental_16.jpg	1	1	t
345	52	images/rentals/rental_15.jpg	2	0	t
346	52	images/rentals/rental_22.jpg	3	0	t
347	53	images/rentals/rental_28.jpg	1	1	t
348	53	images/rentals/rental_24.jpg	2	0	t
349	54	images/rentals/rental_07.jpg	1	1	t
350	54	images/rentals/rental_05.jpg	2	0	t
351	55	images/rentals/rental_23.jpg	1	1	t
352	55	images/rentals/rental_25.jpg	2	0	t
353	55	images/rentals/rental_06.jpg	3	0	t
354	56	images/rentals/rental_11.jpg	1	1	t
355	56	images/rentals/rental_10.jpg	2	0	t
356	57	images/rentals/rental_07.jpg	1	1	t
357	57	images/rentals/rental_19.jpg	2	0	t
358	58	images/rentals/rental_16.jpg	1	1	t
359	58	images/rentals/rental_30.jpg	2	0	t
360	58	images/rentals/rental_15.jpg	3	0	t
361	59	images/rentals/rental_08.jpg	1	1	t
362	59	images/rentals/rental_02.jpg	2	0	t
363	60	images/rentals/rental_12.jpg	1	1	t
364	60	images/rentals/rental_09.jpg	2	0	t
365	61	images/rentals/rental_16.jpg	1	1	t
366	61	images/rentals/rental_26.jpg	2	0	t
367	61	images/rentals/rental_13.jpg	3	0	t
368	62	images/rentals/rental_29.jpg	1	1	t
369	62	images/rentals/rental_03.jpg	2	0	t
370	63	images/rentals/rental_20.jpg	1	1	t
371	63	images/rentals/rental_27.jpg	2	0	t
372	64	images/rentals/rental_01.jpg	1	1	t
373	64	images/rentals/rental_08.jpg	2	0	t
374	64	images/rentals/rental_02.jpg	3	0	t
375	65	images/rentals/rental_28.jpg	1	1	t
376	65	images/rentals/rental_18.jpg	2	0	t
377	66	images/rentals/rental_15.jpg	1	1	t
378	66	images/rentals/rental_30.jpg	2	0	t
379	67	images/rentals/rental_25.jpg	1	1	t
380	67	images/rentals/rental_23.jpg	2	0	t
381	67	images/rentals/rental_06.jpg	3	0	t
382	68	images/rentals/rental_20.jpg	1	1	t
383	68	images/rentals/rental_17.jpg	2	0	t
384	69	images/rentals/rental_08.jpg	1	1	t
385	69	images/rentals/rental_01.jpg	2	0	t
386	70	images/rentals/rental_07.jpg	1	1	t
387	70	images/rentals/rental_18.jpg	2	0	t
388	70	images/rentals/rental_05.jpg	3	0	t
389	71	images/rentals/rental_24.jpg	1	1	t
390	71	images/rentals/rental_28.jpg	2	0	t
391	72	images/rentals/rental_27.jpg	1	1	t
392	72	images/rentals/rental_20.jpg	2	0	t
393	73	images/rentals/rental_29.jpg	1	1	t
394	73	images/rentals/rental_03.jpg	2	0	t
395	73	images/rentals/rental_14.jpg	3	0	t
396	74	images/rentals/rental_10.jpg	1	1	t
397	74	images/rentals/rental_11.jpg	2	0	t
398	75	images/rentals/rental_13.jpg	1	1	t
399	75	images/rentals/rental_26.jpg	2	0	t
400	76	images/rentals/rental_18.jpg	1	1	t
401	76	images/rentals/rental_04.jpg	2	0	t
402	76	images/rentals/rental_21.jpg	3	0	t
403	77	images/rentals/rental_19.jpg	1	1	t
404	77	images/rentals/rental_07.jpg	2	0	t
405	78	images/rentals/rental_09.jpg	1	1	t
406	78	images/rentals/rental_12.jpg	2	0	t
407	79	images/rentals/rental_22.jpg	1	1	t
408	79	images/rentals/rental_15.jpg	2	0	t
409	79	images/rentals/rental_16.jpg	3	0	t
410	80	images/rentals/rental_06.jpg	1	1	t
411	80	images/rentals/rental_23.jpg	2	0	t
412	81	images/rentals/rental_03.jpg	1	1	t
413	81	images/rentals/rental_29.jpg	2	0	t
414	82	images/rentals/rental_16.jpg	1	1	t
415	82	images/rentals/rental_15.jpg	2	0	t
416	82	images/rentals/rental_22.jpg	3	0	t
417	83	images/rentals/rental_10.jpg	1	1	t
418	83	images/rentals/rental_11.jpg	2	0	t
419	84	images/rentals/rental_25.jpg	1	1	t
420	84	images/rentals/rental_21.jpg	2	0	t
421	85	images/rentals/rental_07.jpg	1	1	t
422	85	images/rentals/rental_18.jpg	2	0	t
423	85	images/rentals/rental_19.jpg	3	0	t
424	86	images/rentals/rental_07.jpg	1	1	t
425	86	images/rentals/rental_05.jpg	2	0	t
426	87	images/rentals/rental_20.jpg	1	1	t
427	87	images/rentals/rental_17.jpg	2	0	t
428	88	images/rentals/rental_16.jpg	1	1	t
429	88	images/rentals/rental_26.jpg	2	0	t
430	88	images/rentals/rental_13.jpg	3	0	t
431	89	images/rentals/rental_29.jpg	1	1	t
432	89	images/rentals/rental_14.jpg	2	0	t
433	90	images/rentals/rental_21.jpg	1	1	t
434	90	images/rentals/rental_04.jpg	2	0	t
435	91	images/rentals/rental_20.jpg	1	1	t
436	91	images/rentals/rental_27.jpg	2	0	t
437	91	images/rentals/rental_17.jpg	3	0	t
438	92	images/rentals/rental_24.jpg	1	1	t
439	92	images/rentals/rental_28.jpg	2	0	t
440	93	images/rentals/rental_02.jpg	1	1	t
441	93	images/rentals/rental_08.jpg	2	0	t
442	94	images/rentals/rental_15.jpg	1	1	t
443	94	images/rentals/rental_30.jpg	2	0	t
444	94	images/rentals/rental_16.jpg	3	0	t
445	95	images/rentals/rental_08.jpg	1	1	t
446	95	images/rentals/rental_01.jpg	2	0	t
447	96	images/rentals/rental_12.jpg	1	1	t
448	96	images/rentals/rental_09.jpg	2	0	t
\.


--
-- TOC entry 5594 (class 0 OID 18296)
-- Dependencies: 245
-- Data for Name: rental_apartments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rental_apartments (rental_id, source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description, listing_type, status, created_at) FROM stdin;
31	HDC-103	Haado Centrosa Garden	Căn 2PN+1 Hà Đô Centrosa Garden góc 2 mặt thoáng cực rộng	24000000.00	107.00	3	2	200 3 Tháng 2	Phường Hòa Hưng	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 2PN+1 HÀ ĐÔ CENTROSA GARDEN 107M2\nĐịa chỉ: 200 3 Tháng 2, Phường Hòa Hưng, TP. Hồ Chí Minh\nCăn góc diện tích lớn 107m2 thiết kế 2PN lớn + 1 phòng đọc sách/làm việc.\nBếp riêng biệt nối liền ra logia phơi đồ kín đáo.\nAn ninh bảo vệ 3 lớp thẻ từ thang máy an toàn.\nGiá thuê: 24 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
1	CTG-101	City Garden	Căn 1PN City Garden Bình Thạnh thiết kế gợn sóng độc đáo	20000000.00	70.00	1	1	59 Ngô Tất Tố	Phường Thạnh Mỹ Tây	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN CITY GARDEN NGÔ TẤT TỐ DIỆN TÍCH 70M2\nĐịa chỉ: 59 Ngô Tất Tố, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn 1PN diện tích lớn 70m2 với đường nét kiến trúc hình gợn sóng độc bản.\nĐầy đủ trang thiết bị nội thất xịn xò, tone màu trầm ấm cúng tinh tế.\nMật độ xanh bao phủ lên tới 70%, tạo môi trường sống trong lành như resort.\nGiá thuê: 20 Triệu/tháng.\\nLiên hệ: 092x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
2	CTG-102	City Garden	Căn 2PN City Garden tháp Crescent tầng cao view Landmark 81	31000000.00	105.00	2	2	59 Ngô Tất Tố	Phường Thạnh Mỹ Tây	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN CITY GARDEN THÁP CRESCENT 105M2\nĐịa chỉ: 59 Ngô Tất Tố, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn hộ 2 phòng ngủ rộng rãi, ban công cong độc đáo ngắm trọn Landmark 81.\nNội thất thiết kế hiện đại sang trọng, trang bị máy rửa bát và tủ lạnh lớn.\nTiện ích: Hồ bơi tràn bờ 50m, nhà hàng cao cấp, mảng xanh bãi cỏ nội khu.\nGiá thuê: 31 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
3	CTG-103	City Garden	Căn 3PN City Garden nội thất Châu Âu thiết kế cực sang	46000000.00	140.00	3	2	59 Ngô Tất Tố	Phường Thạnh Mỹ Tây	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN CITY GARDEN NGÔ TẤT TỐ DIỆN TÍCH 140M2\nĐịa chỉ: 59 Ngô Tất Tố, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn 3PN thiết kế mở, khung cửa kính từ sàn đến trần đón trọn ánh sáng tự nhiên.\nĐã chuẩn bị sẵn đầy đủ đồ dùng, chỉ việc xách vali vào ở ngay.\nVị trí đắc địa di chuyển sang trung tâm Bến Nghé chỉ mất 5 phút.\nGiá thuê: 46 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
4	CTG-104	City Garden	Penthouse City Garden thiết kế Duplex đỉnh cao kiến trúc	90000000.00	220.00	4	4	59 Ngô Tất Tố	Phường Thạnh Mỹ Tây	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE DUPLEX CITY GARDEN DIỆN TÍCH 220M2\nĐịa chỉ: 59 Ngô Tất Tố, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn Penthouse thông tầng đẳng cấp sở hữu tầm nhìn 360 độ ôm trọn trung tâm TP.HCM.\nNội thất xa hoa được đặt riêng từng chi tiết từ các hãng thiết kế danh tiếng.\nSảnh thang máy thẻ từ bảo mật tuyệt đối.\nGiá thuê: 90 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
5	DMI-101	Đảo Kim Cương (Diamond Island)	Căn 1PN tháp Hawaii Đảo Kim Cương view sông Sài Gòn êm đềm	18000000.00	55.00	1	1	Số 1 Đường số 104	Phường Bình Trưng	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN ĐẢO KIM CƯƠNG THÁP HAWAII DIỆN TÍCH 55M2\nĐịa chỉ: Số 1 Đường số 104, Phường Bình Trưng, TP. Hồ Chí Minh\nCăn hộ 1PN trên hòn đảo tự nhiên duy nhất tại TP.HCM, không gian sống nghỉ dưỡng tuyệt đối.\nĐầy đủ nội thất nhập khẩu, ban công hướng sông mát mẻ quanh năm.\nTiện ích đặc quyền: Hồ bơi mặn 2.300m2, bến du thuyền riêng, công viên thủy cung.\nGiá thuê: 18 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
6	DMI-102	Đảo Kim Cương (Diamond Island)	Căn 2PN tháp Bora Bora Đảo Kim Cương full nội thất hiện đại	26000000.00	88.00	2	2	Số 1 Đường số 104	Phường Bình Trưng	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN ĐẢO KIM CƯƠNG THÁP BORA BORA DIỆN TÍCH 88M2\nĐịa chỉ: Số 1 Đường số 104, Phường Bình Trưng, TP. Hồ Chí Minh\nCăn hộ 2 phòng ngủ tòa Bora Bora đón trọn bình minh ngập tràn sức sống.\nThiết kế tối giản tinh tế, sofa da bò, hệ thống bếp điện và lò nướng âm tủ.\nTận hưởng 86.5% mật độ mảng xanh và mặt nước bao phủ xung quanh đảo.\nGiá thuê: 26 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
7	DMI-103	Đảo Kim Cương (Diamond Island)	Căn góc 3PN tháp Maldives Đảo Kim Cương view sông trực diện	45000000.00	125.00	3	2	Số 1 Đường số 104	Phường Bình Trưng	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN ĐẢO KIM CƯƠNG THÁP MALDIVES DIỆN TÍCH 125M2\nĐịa chỉ: Số 1 Đường số 104, Phường Bình Trưng, TP. Hồ Chí Minh\nCăn góc đắt giá nhất tháp Maldives, view nhìn 220 độ ôm trọn sông Sài Gòn và Bitexco.\nTrang bị nội thất siêu xa hoa nhập khẩu hoàn toàn từ Châu Âu.\nKhông gian sống yên tĩnh hoàn hảo cách biệt hoàn toàn khỏi khói bụi.\nGiá thuê: 45 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
8	DMI-104	Đảo Kim Cương (Diamond Island)	Căn Pool Villa Đảo Kim Cương sân vườn hồ bơi riêng xa xỉ	100000000.00	210.00	4	4	Số 1 Đường số 104	Phường Bình Trưng	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nPOOL VILLA ĐẢO KIM CƯƠNG HỒ BƠI SÂN VƯỜN RIÊNG 210M2\nĐịa chỉ: Số 1 Đường số 104, Phường Bình Trưng, TP. Hồ Chí Minh\nCăn hộ Pool Villa tầng trệt có hồ bơi riêng và sân vườn bao quanh nhà.\nMang đến sự riêng tư tối đa chuẩn resort đẳng cấp giữa lòng thành phố.\nĐầy đủ trang thiết bị nội thất đạt chuẩn khách sạn 5 sao. \nGiá thuê: 100 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
9	EGR-101	Eco Green Sài Gòn	Căn 1PN Eco Green Sài Gòn Nguyễn Văn Linh full đồ xinh xắn	12000000.00	45.00	1	1	39/1B Nguyễn Văn Linh	Phường Tân Thuận	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN ECO GREEN SÀI GÒN DIỆN TÍCH 45M2\nĐịa chỉ: 39/1B Nguyễn Văn Linh, Phường Tân Thuận, TP. Hồ Chí Minh\nCăn hộ 1PN thiết kế xinh xắn tối ưu không gian, ban công thoáng mát.\nĐầy đủ nội thất: Sofa, tủ lạnh, tivi, máy giặt, bếp từ âm, máy lạnh Daikin.\nNằm ngay cạnh công viên Hương Tràm rộng 22ha cực kỳ xanh mát.\nGiá thuê: 12 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
10	EGR-102	Eco Green Sài Gòn	Căn 2PN Eco Green Sài Gòn view công viên Hương Tràm 22ha	16000000.00	65.00	2	2	39/1B Nguyễn Văn Linh	Phường Tân Thuận	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN ECO GREEN SÀI GÒN DIỆN TÍCH 65M2\nĐịa chỉ: 39/1B Nguyễn Văn Linh, Phường Tân Thuận, TP. Hồ Chí Minh\nCăn hộ 2PN 2WC thiết kế hợp lý, các phòng ngủ đều có cửa sổ đón sáng tự nhiên.\nTrang bị kính khoang âm cản nhiệt cách âm tuyệt đối.\nTiện ích: Hồ bơi tràn bờ, trường tiểu học Kim Đồng ngay trong dự án, TTTM.\nGiá thuê: 16 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
11	EGR-103	Eco Green Sài Gòn	Căn góc 3PN Eco Green Sài Gòn tầng cao view sông cầu Phú Mỹ	22000000.00	85.00	3	2	39/1B Nguyễn Văn Linh	Phường Tân Thuận	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN ECO GREEN SÀI GÒN 85M2\nĐịa chỉ: 39/1B Nguyễn Văn Linh, Phường Tân Thuận, TP. Hồ Chí Minh\nCăn góc 3PN sở hữu tầm nhìn panorama tuyệt đẹp ngắm cầu Phú Mỹ lung linh về đêm.\nBàn giao thiết bị bếp Teka, thiết bị vệ sinh Duravit cao cấp.\nKết nối sang trung tâm Bến Nghé qua cầu Tân Thuận chỉ 5 phút.\nGiá thuê: 22 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
12	EGR-104	Eco Green Sài Gòn	Căn 3PN Eco Green Sài Gòn full nội thất gỗ cao cấp	24000000.00	95.00	3	2	39/1B Nguyễn Văn Linh	Phường Tân Thuận	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN ECO GREEN SÀI GÒN DIỆN TÍCH 95M2\nĐịa chỉ: 39/1B Nguyễn Văn Linh, Phường Tân Thuận, TP. Hồ Chí Minh\nCăn 3PN diện tích lớn, thiết kế hiện đại sang trọng thích hợp cho gia đình ở dài hạn.\nTrang bị full đồ gỗ tự nhiên, tivi 65 inch, tủ lạnh side-by-side.\nDịch vụ quản lý tòa nhà chuyên nghiệp an toàn 24/7.\nGiá thuê: 24 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
13	EMP-101	Empire City	Căn 1PN Linden Empire City Thủ Thiêm full nội thất xịn	23000000.00	64.00	1	1	Khu đô thị mới Thủ Thiêm	Phường Thủ Thiêm	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN LINDEN RESIDENCES EMPIRE CITY DIỆN TÍCH 64M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh.\nCăn hộ 1PN diện tích cực rộng 64m2 tại phân khu Linden Residences.\nThiết kế tinh tế, không gian bếp thoáng đạt kết nối trực tiếp ra ban công.\nTiện ích: Hồ bơi nước mặn 50m, phòng sauna khô/ướt, khu BBQ ngoài trời.\nGiá thuê: 23 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
14	EMP-102	Empire City	Cho thuê căn 2PN Tilia Empire City tầng cao view nội khu mát mẻ	34000000.00	93.00	2	2	Khu đô thị mới Thủ Thiêm	Phường Thủ Thiêm	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN TILIA RESIDENCES EMPIRE CITY DIỆN TÍCH 93M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh\nCăn hộ 2PN phân khu Tilia Residences, layout thiết kế vuông vức phong thủy tốt.\nĐã trang bị đầy đủ đồ dùng sinh hoạt, máy giặt sấy, lò nướng âm tủ.\nMôi trường sống chuẩn quốc tế, cư dân văn minh tri thức.\nGiá thuê: 34 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
15	EMP-103	Empire City	Căn 3PN Cove Empire City view trực diện sông thang máy riêng	70000000.00	155.00	3	3	Khu đô thị mới Thủ Thiêm	Phường Thủ Thiêm	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN COVE RESIDENCES EMPIRE CITY THANG MÁY RIÊNG 155M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh\nCăn hộ đắt giá thuộc tòa Cove Residences – tòa căn hộ sát sông nhất dự án Empire City.\nTrang bị thang máy riêng mở thẳng vào căn hộ, tầm nhìn ôm trọn sông Sài Gòn.\nBàn giao nội thất cao cấp chuẩn resort 5 sao.\nGiá thuê: 70 Triệu/tháng.\\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
16	EMP-104	Empire City	Penthouse Empire City Thủ Thiêm tầng cao view 360 độ cực phẩm	120000000.00	220.00	4	4	Khu đô thị mới Thủ Thiêm	Phường Thủ Thiêm	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE EMPIRE CITY THỦ THIÊM TẦNG CAO DIỆN TÍCH 220M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh\nCăn Penthouse thiết kế Duplex thông tầng đẳng cấp nhất tại dự án.\nBan công siêu rộng ôm trọn góc view 360 độ ngắm toàn cảnh sông Sài Gòn và thành phố.\nThang máy riêng biệt, hệ thống an ninh 3 lớp tuyệt đối bảo mật.\nGiá thuê: 120 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
17	ESH-101	Estella Heights	Căn 1PN Estella Heights thiết kế nghỉ dưỡng full nội thất	22000000.00	60.00	1	1	88 Xa Lộ Hà Nội	Phường Thảo Điền	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN ESTELLA HEIGHTS PHONG CÁCH RESORT DIỆN TÍCH 60M2\nĐịa chỉ: 88 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn hộ 1PN ban công rộng hướng hồ bơi tràn bờ phong cách nghỉ dưỡng.\nBàn giao full nội thất cao cấp sang trọng chuẩn 5 sao.\nTiện ích đẳng cấp: Hồ bơi lướt sóng, đường chạy bộ trên cao, phòng gym hiện đại.\nTTTM Estella Place ngay bên dưới cung cấp mọi nhu cầu mua sắm, ẩm thực.\nGiá thuê: 22 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx"\n  },	RENT	AVAILABLE	2026-10-11 15:10:29.993521
18	ESH-102	Estella Heights	Cho thuê căn 2PN Estella Heights tháp T3 view hồ bơi tràn bờ	32000000.00	90.00	2	2	88 Xa Lộ Hà Nội	Phường Thảo Điền	TP. Thủ Đức	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN ESTELLA HEIGHTS THÁP T3 DIỆN TÍCH 90M2\nĐịa chỉ: 88 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh\nThiết kế phòng khách nối liền ban công kính tràn viền vô cùng thông thoáng.\nTrang bị đầy đủ thiết bị điện tử cao cấp, sofa da, bàn ăn gỗ sồi.\nMôi trường sống xanh, mát mẻ với mật độ cây xanh che phủ cao.\nGiá thuê: 32 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
19	ESH-103	Estella Heights	Căn 3PN Estella Heights tầng cao view trọn thành phố lộng lẫy	48000000.00	130.00	3	2	88 Xa Lộ Hà Nội	Phường Thảo Điền	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN ESTELLA HEIGHTS TẦNG CAO DIỆN TÍCH 130M2\nĐịa chỉ: 88 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Thủ Đức\nCăn 3 phòng ngủ rộng rãi, view tầng cao ngắm trọn bình minh và hoàng hôn thành phố.\nBếp đóng riêng biệt chống ám mùi, trang bị lò nướng và máy rửa bát cao cấp.\nQuản lý vận hành bởi tập đoàn uy tín Keppel Land.\nGiá thuê: 48 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
20	ESH-104	Estella Heights	Căn Penthouse Estella Heights sân vườn riêng đẳng cấp thượng lưu	95000000.00	250.00	4	4	88 Xa Lộ Hà Nội	Phường Thảo Điền	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE ESTELLA HEIGHTS SÂN VƯỜN RIÊNG DIỆN TÍCH 250M2\nĐịa chỉ: 88 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn Penthouse đỉnh cao sở hữu sân vườn riêng rộng lớn ngắm view 360 độ.\nThiết kế nội thất độc bản từ các nhà thiết kế hàng đầu, không gian xa hoa.\nThang máy thẻ từ riêng, dịch vụ chăm sóc căn hộ đặc quyền VIP.\nGiá thuê: 95 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
21	GMS-101	Grand Marina Saigon	Căn 1PN Tòa Lake Grand Marina Saigon quản lý chuẩn Marriott	38000000.00	59.00	1	1	2 Tôn Đức Thắng	Phường Bến Nghé	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ HÀNG HIỆU MARRIOTT GRAND MARINA SAIGON 59M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nCăn hộ dịch vụ hàng hiệu chuẩn Marriott International đầu tiên tại trung tâm Sài Gòn.\nBàn giao full nội thất nhập khẩu Ý, thiết bị bếp và vệ sinh Gaggenau & Duravit.\nDịch vụ quản gia, lễ tân và concierge tiêu chuẩn khách sạn 5 sao quốc tế 24/7.\nGiá thuê: 38 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
22	GMS-102	Grand Marina Saigon	Cho thuê căn 2PN Grand Marina Saigon view sông cực đẹp	58000000.00	88.00	2	2	2 Tôn Đức Thắng	Phường Bến Nghé	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN GRAND MARINA SAIGON VIEW SÔNG 88M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nCăn hộ 2PN view trực diện sông Sài Gòn và cầu Ba Sơn, ban công kính tràn viền siêu sang.\nTận hưởng các đặc quyền tiện ích: Hồ bơi mây trên tầng cao, rạp chiếu phim riêng, phòng họp VIP.\nMôi trường sống tinh hoa tôn vinh đẳng cấp gia chủ.\nGiá thuê: 58 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
23	GMS-103	Grand Marina Saigon	Căn 3PN Hàng hiệu Marriott Grand Marina view trung tâm Q1	95000000.00	133.00	3	3	2 Tôn Đức Thắng	Phường Bến Nghé	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN MARRIOTT GRAND MARINA SAIGON 133M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nCăn 3PN góc 2 mặt thoáng ngắm toàn cảnh đại lộ Tôn Đức Thắng và sông Sài Gòn.\nThiết kế tỉ mỉ đến từng chi tiết nhỏ bởi các kiến trúc sư thế giới.\nBàn giao đầy đủ trang thiết bị nội thất xa hoa nhất.\nGiá thuê: 95 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
24	GMS-104	Grand Marina Saigon	Căn Penthouse Masterise Grand Marina Bến Nghé siêu sang	180000000.00	220.00	4	4	2 Tôn Đức Thắng	Phường Bến Nghé	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE GRAND MARINA SAIGON BẾN NGHÉ 220M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nSiêu căn hộ Penthouse hàng hiệu Marriott bậc nhất Việt Nam.\nSở hữu tầm nhìn kiệt tác ôm trọn dòng sông Sài Gòn và trung tâm đô thị.\nĐặc quyền phục vụ riêng biệt theo chuẩn mực toàn cầu của tập đoàn Marriott. \nGiá thuê: 180 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
25	GTW-101	The Gateway Thảo Điền	Cho thuê căn 1PN Gateway Thảo Điền full nội thất hiện đại	19000000.00	52.00	1	1	2 Trần Ngọc Diện	Phường Thảo Điền	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN THE GATEWAY THẢO ĐIỀN DIỆN TÍCH 52M2\nĐịa chỉ: 2 Trần Ngọc Diện, Phường Thảo Điền, TP. Hồ Chí Minh.\nCăn hộ 1PN thiết kế tinh tế, tối ưu từng khoảng không gian sống.\nNội thất nhập khẩu cao cấp, trang bị hệ thống Smart Home tiện lợi.\nTọa lạc tại khu phố tây Trần Ngọc Diện sầm uất với nhiều nhà hàng, cafe cao cấp.\nGiá thuê: 19 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
26	GTW-102	The Gateway Thảo Điền	Căn 2PN Gateway Thảo Điền tầng cao view sông Sài Gòn tuyệt đẹp	28000000.00	85.00	2	2	2 Trần Ngọc Diện	Phường Thảo Điền	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN THE GATEWAY THẢO ĐIỀN VIEW SÔNG DIỆN TÍCH 85M2\nĐịa chỉ: 2 Trần Ngọc Diện, Phường Thảo Điền, TP. Hồ Chí Minh\nBan công kính tràn chiều cao ceiling 3.1m tạo sự thông thoáng vượt trội.\nView sông Sài Gòn thơ mộng không bị che chắn.\nTiện ích: Hồ bơi nước mặn, phòng xông hơi, khu nướng BBQ ngoài trời.\n Giá thuê: 28 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
27	GTW-103	The Gateway Thảo Điền	Căn 3PN Gateway Thảo Điền thiết kế sang trọng nội thất cao cấp	42000000.00	122.00	3	2	2 Trần Ngọc Diện	Phường Thảo Điền	TP. Thủ Đức	=== MÔ TẢ CHI TIẾT ==\nCĂN HỘ 3PN THE GATEWAY THẢO ĐIỀN DIỆN TÍCH 122M2\nĐịa chỉ: 2 Trần Ngọc Diện, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn 3PN diện tích lớn, thiết kế mở đón ánh sáng tự nhiên cho toàn bộ các phòng.\nBếp đảo hiện đại trang bị thiết bị SBG Bosch chất lượng cao.\nVị trí đắc địa gần các trường quốc tế BIS, ISHCMC.\nGiá thuê 42 Triệutháng.\nLiên hệ 092x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
28	GTW-104	The Gateway Thảo Điền	Căn Garden Villa Gateway Thảo Điền có sân vườn rộng thoáng	75000000.00	180.00	4	3	2 Trần Ngọc Diện	Phường Thảo Điền	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nGARDEN VILLA THE GATEWAY THẢO ĐIỀN DIỆN TÍCH 180M2\nĐịa chỉ: 2 Trần Ngọc Diện, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn hộ sân vườn đặc quyền tầng trệt mang đến không gian sống chuẩn biệt thự.\nSân vườn riêng xanh mát thích hợp tổ chức tiệc trà, BBQ gia đình.\nThiết kế 4 phòng ngủ riêng tư, nội thất siêu sang trọng.\nGiá thuê: 75 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
29	HDC-101	Haado Centrosa Garden	Căn 1PN1WC Hà Đô Centrosa Garden full nội thất hiện đại	15000000.00	53.00	1	1	200 3 Tháng 2	Phường Hòa Hưng	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN HÀ ĐÔ CENTROSA GARDEN 53M2\nĐịa chỉ: 200 3 Tháng 2, Phường Hòa Hưng, TP. Hồ Chí Minh\nCăn hộ 1PN thiết kế thông minh + 1 phòng đa năng làm việc rộng rãi.\nFull nội thất đẹp, tông màu tươi sáng, trang bị tivi, tủ lạnh, máy giặt.\nVị trí trung tâm kết nối giao thông đi các khu vực vô cùng thuận tiện.\nGiá thuê: 15 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
30	HDC-102	Haado Centrosa Garden	Cho thuê căn 2PN2WC Hà Đô Centrosa tháp Orchid view hồ bơi	20000000.00	86.00	2	2	200 3 Tháng 2	Phường Hòa Hưng	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN HÀ ĐÔ CENTROSA GARDEN ORCHID 86M2\nĐịa chỉ: 200 3 Tháng 2, Phường Hòa Hưng, TP. Hồ Chí Minh\nCăn hộ 2PN 2WC tòa Orchid, ban công nhìn trực diện hồ bơi tràn tràn mây nội khu.\nĐã được trang bị đầy đủ trang thiết bị nội thất xịn xò.\nTiện ích: 21 khu vườn treo trên không, hồ bơi tràn bờ, phòng gym, siêu thị.\nGiá thuê: 20 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
32	HDC-104	Haado Centrosa Garden	Căn 3PN Hà Đô Centrosa Garden tầng cao view trọn thành phố	29000000.00	123.00	3	2	200 3 Tháng 2	Phường Hòa Hưng	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN HÀ ĐÔ CENTROSA GARDEN 123M2\nĐịa chỉ: 200 3 Tháng 2, Phường Hòa Hưng, TP. Hồ Chí Minh\nCăn hộ 3PN diện tích lớn thích hợp cho gia đình nhiều thế hệ sinh sống.\nTrang bị full nội thất cao cấp: Sofa da, bàn ăn 6 ghế, máy lạnh âm trần.\nGiá thuê: 29 Triệu/tháng.\nLiên hệ: 097x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
33	INF-101	The Infiniti at Riviera Point	Căn 1PN The Infiniti Riviera Point full nội thất mới 100%	15000000.00	58.00	1	1	584 Huỳnh Tấn Phát	Phường Phú Thuận	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN THE INFINITI RIVIERA POINT 58M2\nĐịa chỉ: 584 Huỳnh Tấn Phát, Phường Phú Thuận, TP. Hồ Chí Minh\nCăn hộ 1PN mang cảm hứng thiên nhiên Hawaii do Keppel Land phát triển.\nBan công hướng sông Cả Cấm vô cùng mát mẻ.\nTiện ích đột phá: Sân chơi nước nội khu lớn nhất TP.HCM, hồ bơi tràn bờ 50m.\nGiá thuê: 15 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
34	INF-102	The Infiniti at Riviera Point	Cho thuê căn 2PN Riviera Point view sông thoáng mát	21000000.00	82.00	2	2	584 Huỳnh Tấn Phát	Phường Phú Thuận	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN THE INFINITI RIVIERA POINT 82M2\nĐịa chỉ: 584 Huỳnh Tấn Phát, Phường Phú Thuận, TP. Hồ Chí Minh\nCăn 2PN thiết kế vuông vức, không gian phòng khách nối liền ban công thông thoáng.\nTrang bị đầy đủ thiết bị bếp, máy lạnh âm trần, nội thất gỗ hiện đại.\nKết nối sang trung tâm Phú Mỹ Hưng chỉ 2 phút qua cầu Phú Thuận.\nGiá thuê: 21 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
35	INF-103	The Infiniti at Riviera Point	Căn góc 3PN Riviera Point tầng cao view toàn cảnh Quận 7	30000000.00	120.00	3	2	584 Huỳnh Tấn Phát	Phường Phú Thuận	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN THE INFINITI RIVIERA POINT 120M2\nĐịa chỉ: 584 Huỳnh Tấn Phát, Phường Phú Thuận, TP. Hồ Chí Minh\nCăn góc 3 phòng ngủ thoáng đạt, đón nắng và gió tự nhiên tràn ngập các phòng.\nBàn giao trọn bộ nội thất xịn xò chuẩn phong cách resort nghỉ dưỡng.\nGiá thuê: 30 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
36	INF-104	The Infiniti at Riviera Point	Căn Duplex The Infiniti Riviera Point thiết kế thông tầng xa hoa	48000000.00	150.00	3	3	584 Huỳnh Tấn Phát	Phường Phú Thuận	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ DUPLEX THE INFINITI RIVIERA POINT 150M2\nĐịa chỉ: 584 Huỳnh Tấn Phát, Phường Phú Thuận, TP. Hồ Chí Minh\nCăn Duplex thông tầng ấn tượng với hệ kính cao kịch trần ngắm trọn view sông.\nNội thất xa hoa được đặt riêng phù hợp không gian sang trọng.\nQuản lý vận hành chuẩn mực bởi Keppel Land.\nGiá thuê: 48 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
37	LMN-101	Leman Luxury Apartments	Căn 2PN Leman Luxury Nguyễn Đình Chiểu full nội thất Thụy Sỹ	32000000.00	75.00	2	2	117 Nguyễn Đình Chiểu	Phường Xuân Khánh	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN LEMAN LUXURY XUÂN KHÁNH DIỆN TÍCH 75M2\nĐịa chỉ: 117 Nguyễn Đình Chiểu, Phường Xuân Khánh, TP. Hồ Chí Minh\nCăn hộ mang đậm kiến trúc Thụy Sỹ giữa tâm xanh thành phố.\nTrang bị full nội thất cao cấp cổ điển pha lẫn hiện đại sang trọng.\nSiêu thị Bon Grocer và chuỗi nhà hàng cao cấp ngay tại khối đế tòa nhà.\nGiá thuê: 32 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
38	LMN-102	Leman Luxury Apartments	Cho thuê căn 3PN Leman Luxury không gian sống yên tĩnh đẳng cấp	45000000.00	96.00	3	2	117 Nguyễn Đình Chiểu	Phường Xuân Khánh	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN LEMAN LUXURY APARTMENTS 96M2\nĐịa chỉ: 117 Nguyễn Đình Chiểu, Phường Xuân Khánh, TP. Hồ Chí Minh\nCăn hộ 3PN thiết kế thông thoáng, ô cửa kính lớn đón nắng tự nhiên mát mẻ.\nĐầy đủ tiện ích sinh hoạt, lò nướng, máy giặt sấy, giường nệm cao cấp.\nHồ bơi chân mây trên tầng mây ngắm trọn trung tâm thành phố.\nGiá thuê: 45 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
39	LMN-103	Leman Luxury Apartments	Căn góc 3PN Leman Luxury ban công thoáng mát nội thất xịn	52000000.00	113.00	3	2	117 Nguyễn Đình Chiểu	Phường Xuân Khánh	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN LEMAN LUXURY DIỆN TÍCH 113M2\nĐịa chỉ: 117 Nguyễn Đình Chiểu, Phường Xuân Khánh, TP. Hồ Chí Minh\nCăn góc 2 mặt tiền đường Nguyễn Đình Chiểu - Trương Định vô cùng đắt giá.\nThiết kế nội thất sang trọng, trang thiết bị điện tử âm tường hiện đại.\nGiá thuê: 52 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
40	LMN-104	Leman Luxury Apartments	Penthouse Leman Luxury tầng cao sân vườn riêng cực hiếm	90000000.00	200.00	4	4	117 Nguyễn Đình Chiểu	Phường Xuân Khánh	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE LEMAN LUXURY SÂN VƯỜN RIÊNG 200M2\nĐịa chỉ: 117 Nguyễn Đình Chiểu, Phường Xuân Khánh, TP. Hồ Chí Minh\nPenthouse đẳng cấp có khu sân vườn ngợp bóng mát ngay trên tầng cao.\nKhông gian sống thượng lưu riêng biệt hoàn toàn giữa lòng trung tâm.\nNội thất thiết kế độc bản siêu sang trọng. \nGiá thuê: 90 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
41	MDT-101	Midtown Phú Mỹ Hưng	Căn 1PN The Grande Midtown Phú Mỹ Hưng thiết kế Nhật Bản	17000000.00	62.00	1	1	Đường Nguyễn Lương Bằng	Phường Tân Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN MIDTOWN PHÚ MỸ HƯNG 62M2\nĐịa chỉ: Đường Nguyễn Lương Bằng, Phường Tân Phú, TP. Hồ Chí Minh\nCăn 1PN thuộc phân khu The Grande, thiết kế tối giản chuẩn phong cách Nhật Bản.\nBan công đón ánh sáng tự nhiên, full nội thất gỗ cao cấp.\nCông viên hoa anh đào Sakura Park ngay sát chân tòa nhà.\nGiá thuê: 17 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
42	MDT-102	Midtown Phú Mỹ Hưng	Cho thuê căn 2PN The Symphony Midtown view Sakura Park	25000000.00	89.00	2	2	Đường Nguyễn Lương Bằng	Phường Tân Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN THE SYMPHONY MIDTOWN PHÚ MỸ HƯNG 89M2\nĐịa chỉ: Đường Nguyễn Lương Bằng, Phường Tân Phú, TP. Hồ Chí Minh\nCăn 2PN view trực diện công viên hoa anh đào Sakura Park thơ mộng.\nĐầy đủ thiết bị điện tử hiện đại, thiết bị vệ sinh Toto thông minh.\nTiện ích: Hồ bơi massage Jacuzzi, phòng sauna khô/ướt, phòng chơi trẻ em.\nGiá thuê: 25 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
43	MDT-103	Midtown Phú Mỹ Hưng	Căn góc 3PN The Signature Midtown tầng trung view sông biệt thự	40000000.00	121.00	3	2	Đường Nguyễn Lương Bằng	Phường Tân Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN THE SIGNATURE MIDTOWN 121M2\nĐịa chỉ: Đường Nguyễn Lương Bằng, Phường Tân Phú, TP. Hồ Chí Minh\nCăn góc đắt giá thuộc tòa The Signature có cầu đi bộ trên không biểu tượng.\nView trực diện sông Cả Cấm và khu biệt thự Phú Mỹ Hưng sang trọng.\nTrang bị full đồ gỗ tự nhiên nhập khẩu cao cấp.\\n- Giá thuê: 40 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
44	MDT-104	Midtown Phú Mỹ Hưng	Căn 4PN The Peak Midtown Phú Mỹ Hưng full nội thất cao cấp	62000000.00	160.00	4	3	Đường Nguyễn Lương Bằng	Phường Tân Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 4PN THE PEAK MIDTOWN PHÚ MỸ HƯNG 160M2\nĐịa chỉ: Đường Nguyễn Lương Bằng, Phường Tân Phú, TP. Hồ Chí Minh\nCăn hộ 4PN thuộc phân khu đỉnh cao nhất The Peak Midtown.\nĐầy đủ tiện ích thác nước vô cực, đài ngắm cảnh waterfall, phòng gym hiện đại.\nKhông gian sống xanh thư thái chuẩn mực đẳng cấp quốc tế.\nGiá thuê: 62 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
45	MST-101	Masteri Thảo Điền	Cho thuê căn Studio Masteri Thảo Điền T4 full nội thất xinh xắn	13500000.00	48.00	1	1	159 Xa Lộ Hà Nội	Phường Thảo Điền	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ STUDIO MASTERI THẢO ĐIỀN TÒA T4 DIỆN TÍCH 48M2\nĐịa chỉ: 159 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn hộ Studio tầng trung thiết kế tối ưu diện tích, đón ánh sáng tự nhiên tốt.\nĐầy đủ nội thất cao cấp: Giường tủ, sofa, máy giặt, tủ lạnh, bếp từ.\nTiện ích nội khu: Hồ bơi ngoài trời, phòng Gym, TTTM Vincom Mega Mall ngay dưới chân nhà.\nKết nối giao thông thuận tiện qua tuyến Metro số 1 và đại lộ Xa Lộ Hà Nội.\nGiá thuê: 13.5 Triệu/tháng.\nLiên hệ: 090x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
46	MST-102	Masteri Thảo Điền	Căn hộ 2PN2WC Masteri Thảo Điền T2 view sông Sài Gòn thoáng mát	18000000.00	68.00	2	2	159 Xa Lộ Hà Nội	Phường Thảo Điền	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN2WC MASTERI THẢO ĐIỀN VIEW SÔNG DIỆN TÍCH 68M2\nĐịa chỉ: 159 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn hộ 2 phòng ngủ tòa T2, ban công hướng Đông Bắc view trực diện sông lộng gió. \nBàn giao đầy đủ trang thiết bị nội thất xịn, chỉ cần xách vali vào ở ngay.\nCộng đồng cư dân văn minh, nhiều chuyên gia nước ngoài sinh sống. \nAn ninh 24/7, thẻ từ thang máy riêng biệt cho từng tầng.\nGiá thuê: 18 Triệu/tháng.\nLiên hệ: 090x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
47	MST-103	Masteri Thảo Điền	Căn góc 3PN Masteri Thảo Điền T1 tầng cao view Vincom sang trọng	26000000.00	90.00	3	2	159 Xa Lộ Hà Nội	Phường Thảo Điền	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN MASTERI THẢO ĐIỀN TÒA T1 DIỆN TÍCH 90M2\nĐịa chỉ: 159 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn góc 2 mặt thoáng, tầm nhìn panorama ôm trọn khu Thảo Điền năng động.\nThiết kế 3PN rộng rãi, thích hợp cho gia đình đông thành viên hoặc nhóm chuyên gia.\nNội thất nhập khẩu phong cách hiện đại, tông màu ấm cúng.\nTiện ích cao cấp: Sân tennis, công viên nội khu, khu vui chơi trẻ em.\nGiá thuê: 26 Triệu/tháng.\nLiên hệ: 090x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
48	MST-104	Masteri Thảo Điền	Cho thuê Duplex Masteri Thảo Điền thiết kế hiện đại, đầy đủ tiện nghi	45000000.00	130.00	3	3	159 Xa Lộ Hà Nội	Phường Thảo Điền	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ DUPLEX MASTERI THẢO ĐIỀN THÔNG TẦNG DIỆN TÍCH 130M2\nĐịa chỉ: 159 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh\nCăn Duplex thông tầng siêu rộng, trần cao thoáng đạt tạo cảm giác như biệt thự.\nTrang bị hệ thống điều hòa âm trần, thiết bị bếp và vệ sinh chuẩn Châu Âu.\nTận hưởng không gian sống riêng tư, hiện đại ngay trung tâm Thảo Điền. \nGiá thuê: 45 Triệu/tháng.\nLiên hệ: 090x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
49	MTP-101	The Metropole Thủ Thiêm	Căn 1PN Galleria Metropole Thủ Thiêm full nội thất cao cấp	25000000.00	55.00	1	1	Khu đô thị mới Thủ Thiêm	Phường Thủ Thiêm	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN THE METROPOLE THỦ THIÊM DIỆN TÍCH 55M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh \nCăn hộ 1PN tại phân khu Galleria Residence, thiết kế tinh tế chuẩn phong cách Châu Âu.\nTrang bị toàn bộ thiết bị nội thất thông minh tích hợp điều khiển giọng nói.\nNgay chân cầu Ba Sơn, kết nối sang trung tâm Bến Nghé chỉ 2 phút di chuyển.\nGiá thuê: 25 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
50	MTP-102	The Metropole Thủ Thiêm	Cho thuê căn 2PN The Crest Metropole view cầu Ba Sơn tuyệt đẹp	38000000.00	82.00	2	2	Khu đô thị mới Thủ Thiêm	Phường Thủ Thiêm	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN THE CREST RESIDENCE METROPOLE DIỆN TÍCH 82M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh\nCăn hộ 2PN tầng trung ban công rộng view trực diện cầu Ba Sơn và tháp Bitexco.\nThiết kế sang trọng với thiết bị vệ sinh tự động, bếp từ Bosch cao cấp.\nTiện ích đỉnh cao: Hồ bơi vô cực tràn bờ, phòng tập Golf 3D giả lập.\nGiá thuê: 38 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
51	MTP-103	The Metropole Thủ Thiêm	Căn 3PN Opera Metropole Thủ Thiêm ban công rộng view sông	60000000.00	120.00	3	2	Khu đô thị mới Thủ Thiêm	Phường Thủ Thiêm	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN THE OPERA RESIDENCE METROPOLE DIỆN TÍCH 120M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh\nCăn hộ thuộc phân khu Opera đắt giá nhất dự án, nằm sát Nhà hát Thành phố mới.\nBan công kính chạy dài view trực diện sông Sài Gòn lung linh về đêm.\nHệ thống lọc không khí và lọc nước trung tâm đạt chuẩn quốc tế.\nGiá thuê: 60 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
52	MTP-104	The Metropole Thủ Thiêm	Căn 4PN VIP Metropole Thủ Thiêm thang máy riêng biệt xa hoa	110000000.00	170.00	4	4	Khu đô thị mới Thủ Thiêm	Phường Thủ Thiêm	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 4PN VIP METROPOLE THỦ THIÊM THANG MÁY RIÊNG 170M2\nĐịa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh.\nCăn hộ 4PN hạng sang trang bị sảnh thang máy riêng tư đi thẳng vào phòng khách.\nNội thất siêu xa hoa nhập khẩu nguyên chiếc từ Ý và Đức.\nView sông ngắm toàn bộ skyline trung tâm thành phố.\nGiá thuê: 110 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
53	PMC-101	Palm Heights / Palm City	Căn 1PN Palm Heights An Phú full nội thất xinh xắn	14000000.00	55.00	1	1	Đường Song Hành	Phường An Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN PALM HEIGHTS AN PHÚ DIỆN TÍCH 55M2\nĐịa chỉ: Đường Song Hành, Phường An Phú, TP. Hồ Chí Minh\nCăn hộ 1PN thiết kế thông minh, tối ưu diện tích đón gió tự nhiên từ sông Giồng Ông Tố.\nĐầy đủ nội thất cao cấp: Sofa, tivi, tủ lạnh, bếp âm, giường tủ.\nQuản lý vận hành bởi tập đoàn Keppel Land danh tiếng.\nGiá thuê: 14 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
54	PMC-102	Palm Heights / Palm City	Căn 2PN Palm Heights view sông mát mẻ tầng cao	18500000.00	78.00	2	2	Đường Song Hành	Phường An Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN PALM HEIGHTS TẦNG CAO VIEW SÔNG 78M2\nĐịa chỉ: Đường Song Hành, Phường An Phú, TP. Hồ Chí Minh\nBan công hướng Nam mát mẻ view sông trọn vẹn không bị che chắn.\nĐã được trang bị full nội thất đẹp mắt, chỉ việc xách vali vào ở.\nTiện ích: Hồ bơi phong cách nghỉ dưỡng, phòng sauna, khu tiệc BBQ ngoài trời.\nGiá thuê: 18.5 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
55	PMC-103	Palm Heights / Palm City	Căn góc 3PN Palm Heights diện tích rộng full đồ cao cấp	25000000.00	105.00	3	2	Đường Song Hành	Phường An Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN PALM HEIGHTS AN PHÚ DIỆN TÍCH 105M2\nĐịa chỉ: Đường Song Hành, Phường An Phú, TP. Hồ Chí Minh\nCăn góc 3 phòng ngủ thoáng đạt, các phòng ngủ đều có cửa sổ đón ánh sáng trực tiếp.\nNội thất thiết kế riêng hiện đại, trang bị đầy đủ máy giặt sấy, lò nướng.\nVị trí sát nút giao An Phú di chuyển thuận tiện về trung tâm.\nGiá thuê: 25 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
56	PMC-104	Palm Heights / Palm City	Cho thuê căn Duplex Palm Garden không gian thoáng đãng	42000000.00	140.00	3	3	Đường Song Hành	Phường An Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ DUPLEX PALM GARDEN AN PHÚ DIỆN TÍCH 140M2\nĐịa chỉ: Đường Song Hành, Phường An Phú, TP. Hồ Chí Minh\nCăn Duplex thông tầng siêu rộng rãi, không gian phòng khách trần cao cực kỳ sang trọng.\nTrang bị hệ thống điện thông minh, nội thất chọn lọc cao cấp.\nTiện ích nội khu đầy đủ: Sân tennis, phòng tập gym, khu vui chơi trẻ em.\nGiá thuê: 42 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
57	SCV-101	Scenic Valley	Căn 2PN Scenic Valley Phú Mỹ Hưng full nội thất xinh xắn	16000000.00	70.00	2	2	Đường Tôn Dật Tiên	Phường Tân Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN SCENIC VALLEY PHÚ MỸ HƯNG 70M2\nĐịa chỉ: Đường Tôn Dật Tiên, Phường Tân Phú, TP. Hồ Chí Minh\nCăn hộ 2PN 2WC không gian thiết kế vuông vức, tối ưu hóa công năng.\nNội thất hiện đại đầy đủ: Tivi, tủ lạnh, máy giặt, máy lạnh các phòng.\nVị trí kế bên sân golf và bệnh viện FV, bệnh viện Tam Đức.\nGiá thuê: 16 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
58	SCV-102	Scenic Valley	Căn 2PN Scenic Valley view hồ bơi nội khu xanh mát	18000000.00	80.00	2	2	Đường Tôn Dật Tiên	Phường Tân Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN SCENIC VALLEY VIEW HỒ BƠI 80M2\nĐịa chỉ: Đường Tôn Dật Tiên, Phường Tân Phú, TP. Hồ Chí Minh\nCăn hộ tầng trung view trực diện hồ bơi ngoài trời xanh mát quanh năm.\nTrang bị đồ dùng nội thất còn mới nguyên, xách vali vào ở ngay.\nCư dân tận hưởng trọn vẹn tiện ích đô thị Phú Mỹ Hưng.\nGiá thuê: 18 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
59	SCV-103	Scenic Valley	Căn 3PN Scenic Valley Phú Mỹ Hưng căn góc view sân Golf	26000000.00	110.00	3	2	Đường Tôn Dật Tiên	Phường Tân Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN SCENIC VALLEY VIEW SÂN GOLF 110M2\nĐịa chỉ: Đường Tôn Dật Tiên, Phường Tân Phú, TP. Hồ Chí Minh\nCăn góc 3PN tầm nhìn xanh ngút ngàn hướng thẳng ra sân Golf Phú Mỹ Hưng.\nThiết kế nội thất ấm cúng, phù hợp cho gia đình có trẻ nhỏ hoặc người già nghỉ dưỡng.\nAn ninh bảo vệ khép kín 24/7.\nGiá thuê: 26 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
60	SCV-104	Scenic Valley	Cho thuê căn 3PN Scenic Valley tầng cao thoáng mát full đồ	28000000.00	130.00	3	3	Đường Tôn Dật Tiên	Phường Tân Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN SCENIC VALLEY TẦNG CAO 130M2\nĐịa chỉ: Đường Tôn Dật Tiên, Phường Tân Phú, TP. Hồ Chí Minh\nCăn 3PN diện tích lớn nhất dự án, ban công góc lộng gió cả ngày.\nTrang bị đầy đủ nội thất gia đình cao cấp, tủ lạnh Side-by-side.\nHồ bơi trong nhà và hồ bơi ngoài trời sử dụng hoàn toàn miễn phí.\nGiá thuê: 28 Triệu/tháng\nLiên hệ: 092x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
61	SRC-101	Sunrise City	Căn 1PN Sunrise City Central full nội thất đẹp giá tốt	13000000.00	56.00	1	1	23 Brookside / Nguyễn Hữu Thọ	Phường Tân Hưng	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN SUNRISE CITY CENTRAL DIỆN TÍCH 56M2\nĐịa chỉ: 23 Brookside / Nguyễn Hữu Thọ, Phường Tân Hưng, TP. Hồ Chí Minh\nCăn hộ 1PN khu Central đối diện siêu thị Lotte Mart Tân Hưng.\nĐầy đủ nội thất sinh hoạt: Sofa, tivi, tủ lạnh, máy giặt, giường nệm.\nTiện ích: Hồ bơi tràn bờ, phòng gym, khu vui chơi trẻ em, nhà thuốc, ngân hàng.\nGiá thuê: 13 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
62	SRC-102	Sunrise City	Căn 2PN Sunrise City South tầng cao view trung tâm lộng lẫy	17500000.00	76.00	2	2	23 Brookside / Nguyễn Hữu Thọ	Phường Tân Hưng	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN SUNRISE CITY SOUTH DIỆN TÍCH 76M2\nĐịa chỉ: 23 Brookside / Nguyễn Hữu Thọ, Phường Tân Hưng, TP. Hồ Chí Minh\nCăn hộ 2PN khu South Towers chất lượng xây dựng kiên cố vượt trội.\nBan công hướng Bắc đón gió mát ngắm view thành phố lung linh.\nTrang bị full đồ gỗ nội thất tự nhiên bền đẹp.\nGiá thuê: 17.5 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
63	SRC-103	Sunrise City	Căn góc 3PN Sunrise City North thiết kế rộng rãi thoáng mát	23000000.00	120.00	3	2	23 Brookside / Nguyễn Hữu Thọ	Phường Tân Hưng	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN SUNRISE CITY NORTH 120M2\nĐịa chỉ: 23 Brookside / Nguyễn Hữu Thọ, Phường Tân Hưng, TP. Hồ Chí Minh\nCăn góc 3 phòng ngủ thoáng mát, các không gian phòng đều ngập tràn ánh sáng.\nĐã được trang bị full trang thiết bị đồ dùng gia đình.\nVị trí cửa ngõ Nam TP.HCM di chuyển sang trung tâm chỉ 10 phút.\nGiá thuê: 23 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
64	SRC-104	Sunrise City	Căn Penthouse Sunrise City South diện tích lớn view 360 độ	55000000.00	210.00	4	4	23 Brookside / Nguyễn Hữu Thọ	Phường Tân Hưng	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE SUNRISE CITY SOUTH DIỆN TÍCH 210M2\nĐịa chỉ: 23 Brookside / Nguyễn Hữu Thọ, Phường Tân Hưng, TP. Hồ Chí Minh\nCăn Penthouse không gian cực kỳ rộng rãi, ban công lớn ngắm toàn cảnh khu Nam Sài Gòn.\nTrang bị nội thất sang trọng cổ điển cao cấp.\nThang máy bảo mật thẻ từ tầng riêng biệt.\nGiá thuê: 55 Triệu/tháng.\nLiên hệ: 098x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
65	SSV-101	Serenity Sky Villas	Biệt thự trên không Serenity Sky Villas 2PN hồ bơi riêng 136m2	90000000.00	136.00	2	2	259 Điện Biên Phủ	Phường Xuân Khánh	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nBIỆT THỰ TRÊN KHÔNG SIÊU SANG SERENITY SKY VILLAS DIỆN TÍCH 136M2\nĐịa chỉ: 259 Điện Biên Phủ, Phường Xuân Khánh, TP. Hồ Chí Minh\nBiệt thự trên không độc bản chỉ có 45 căn duy nhất tại dự án.\nTích hợp hồ bơi riêng và sân vườn riêng ngay tại ban công từng căn hộ.\nChiều cao trần phòng khách thông tầng lên tới 7m, thiết kế siêu sang trọng.\nGiá thuê: 90 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
66	SSV-102	Serenity Sky Villas	Căn 3PN Serenity Sky Villas thông tầng trần cao 7m đẳng cấp	120000000.00	210.00	3	3	259 Điện Biên Phủ	Phường Xuân Khánh	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nBIỆT THỰ TRÊN KHÔNG 3PN SERENITY SKY VILLAS 210M2\nĐịa chỉ: 259 Điện Biên Phủ, Phường Xuân Khánh, TP. Hồ Chí Minh\nCăn hộ 3PN Duplex thiết kế đỉnh cao, hồ bơi riêng nước mặn ngoài ban công.\nBàn giao đầy đủ siêu nội thất nhập khẩu từ các thương hiệu xa xỉ nhất Châu Âu.\nThang máy nâng ô tô tận hộ và thang máy riêng vào nhà.\nGiá thuê: 120 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
67	SSV-103	Serenity Sky Villas	Căn 4PN Serenity Sky Villas không gian sống riêng tư tuyệt đối	160000000.00	330.00	4	4	259 Điện Biên Phủ	Phường Xuân Khánh	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nSIÊU BIỆT THỰ TRÊN KHÔNG 4PN SERENITY SKY VILLAS 330M2\nĐịa chỉ: 259 Điện Biên Phủ, Phường Xuân Khánh, TP. Hồ Chí Minh\nCăn biệt thự trên không 4PN diện tích cực đại 330m2.\nSân vườn xanh mát và hồ bơi vô cực riêng trải dài theo ban công căn hộ.\nKhớp nối hoàn hảo giữa thiên nhiên và phong cách sống thượng lưu.\nGiá thuê: 160 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
68	SSV-104	Serenity Sky Villas	Penthouse Serenity Sky Villas kiệt tác thượng lưu số 1 Sài Gòn	250000000.00	500.00	5	5	259 Điện Biên Phủ	Phường Xuân Khánh	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE SERENITY SKY VILLAS DIỆN TÍCH 500M2\nĐịa chỉ: 259 Điện Biên Phủ, Phường Xuân Khánh, TP. Hồ Chí Minh\nCăn Penthouse độc bản đỉnh tháp Serenity Sky Villas, biểu tượng sống cao nhất của giới siêu giàu.\nHồ bơi riêng cực lớn, sân vườn riêng ôm trọn 4 mặt góc nhìn thành phố.\nDịch vụ quản gia concierge cá nhân hóa phục vụ 24/7.\nGiá thuê: 250 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
69	SWP-101	Sunwah Pearl	Căn 1PN Sunwah Pearl tháp White House full đồ siêu đẹp	20000000.00	56.00	1	1	90 Nguyễn Hữu Cảnh	Phường Thạnh Mỹ Tây	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN SUNWAH PEARL WHITE HOUSE DIỆN TÍCH 56M2\nĐịa chỉ: 90 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn hộ 1PN tháp White House thiết kế vuông vức, tông màu sáng hiện đại.\nBàn giao full trang thiết bị nội thất xịn, ban công hướng mát đón gió sông.\nVị trí đắc địa ngay chân cầu Thủ Thiêm, di chuyển sang trung tâm chỉ 3 phút.\nGiá thuê: 20 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
70	SWP-102	Sunwah Pearl	Cho thuê căn 2PN Sunwah Pearl tháp Silver House view sông cực phẩm	30000000.00	102.00	2	2	90 Nguyễn Hữu Cảnh	Phường Thạnh Mỹ Tây	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN SUNWAH PEARL SILVER HOUSE 102M2\nĐịa chỉ: 90 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn 2PN diện tích cực rộng 102m2, ban công góc view sông Sài Gòn và Bitexco đỉnh cao.\nThiết kế nội thất phong cách Châu Âu hiện đại sang trọng.\nTiện ích nội khu: Hồ bơi tràn bờ 1.000m2, công viên bến thuyền, phòng tập gym.\nGiá thuê: 30 Triệu/tháng.\\nLiên hệ: 091x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
71	SWP-103	Sunwah Pearl	Căn góc 3PN Sunwah Pearl tháp Golden House ngắm trọn Bason	48000000.00	128.00	3	2	90 Nguyễn Hữu Cảnh	Phường Thạnh Mỹ Tây	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN SUNWAH PEARL GOLDEN HOUSE 128M2\nĐịa chỉ: 90 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn góc đắt giá nhất tháp Golden House, các phòng ngủ đều ngắm trực diện sông.\nBếp kín hiện đại trang bị thiết bị Bosch âm tủ.\nCộng đồng cư dân cao cấp, an ninh bảo vệ khép kín 24/7.\nGiá thuê: 48 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
72	SWP-104	Sunwah Pearl	Penthouse Sunwah Pearl tầm nhìn ôm trọn sông Sài Gòn	110000000.00	230.00	4	4	90 Nguyễn Hữu Cảnh	Phường Thạnh Mỹ Tây	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE SUNWAH PEARL TẦNG CAO DIỆN TÍCH 230M2\nĐịa chỉ: 90 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nSiêu căn hộ Penthouse độc bản trên tầng cao nhất của dự án Sunwah Pearl.\nThiết kế hiện đại đẳng cấp, không gian sân vườn ban công siêu rộng ngắm toàn cảnh.\nTrang bị sảnh thang máy riêng biệt bảo mật cao.\nGiá thuê: 110 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
73	TGC-101	The Global City	Căn 1PN Masteri Rise Mount The Global City thiết kế đẳng cấp	18000000.00	50.00	1	1	Đường Đỗ Xuân Hợp	Phường An Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN THE GLOBAL CITY DIỆN TÍCH 50M2\nĐịa chỉ: Đường Đỗ Xuân Hợp, Phường An Phú, TP. Hồ Chí Minh\nCăn hộ cao cấp nằm trong siêu đô thị biểu tượng do Foster & Partners thiết kế.\nThiết kế tối tân, ban công hướng Nam lộng gió ngắm kênh đào nhạc nước.\nĐầy đủ tiện ích tiêu chuẩn quốc tế: TTTM 123.000m2, khu nhạc nước lớn nhất ĐNA.\nGiá thuê: 18 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
74	TGC-102	The Global City	Căn 2PN The Global City An Phú view kênh đào nhạc nước tuyệt đẹp	27000000.00	75.00	2	2	Đường Đỗ Xuân Hợp	Phường An Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN THE GLOBAL CITY AN PHÚ DIỆN TÍCH 75M2\nĐịa chỉ: Đường Đỗ Xuân Hợp, Phường An Phú, TP. Hồ Chí Minh\nCăn 2PN ban công cực rộng, không gian phòng khách hiện đại ngập tràn ánh sáng.\nNội thất nhập khẩu chuẩn Foster & Partners thiết kế riêng.\nCư dân tận hưởng trọn vẹn hạ tầng chuẩn Downtown mới của TP.HCM.\nGiá thuê: 27 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
75	TGC-103	The Global City	Căn góc 3PN The Global City thiết kế thông minh full tiện nghi	38000000.00	105.00	3	2	Đường Đỗ Xuân Hợp	Phường An Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN THE GLOBAL CITY DIỆN TÍCH 105M2\nĐịa chỉ: Đường Đỗ Xuân Hợp, Phường An Phú, TP. Hồ Chí Minh\nCăn góc 2 mặt thoáng view trọn khu nhà phố SOHO năng động và đường đua Go-kart.\nĐầy đủ đồ dùng cao cấp, hệ thống thiết bị lọc khí thông minh.\nThuận tiện di chuyển qua cao tốc TP.HCM - Long Thành Dầu Giây.\nGiá thuê: 38 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
76	TGC-104	The Global City	Cho thuê Penthouse The Global City tầm nhìn biểu tượng vô tận	85000000.00	190.00	4	4	Đường Đỗ Xuân Hợp	Phường An Phú	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE THE GLOBAL CITY AN PHÚ DIỆN TÍCH 190M2\nĐịa chỉ: Đường Đỗ Xuân Hợp, Phường An Phú, TP. Hồ Chí Minh\nSiêu phẩm Penthouse không gian thượng lưu, chiều cao trần phòng khách vượt trội.\nBan công kính vô cực ngắm trọn vẹn đại lộ mua sắm sầm uất.\nThang máy riêng, dịch vụ quản gia cao cấp riêng cho cư dân.\nGiá thuê: 85 Triệu/tháng.\nLiên hệ: 096x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
77	TMQ-101	The Marq	Căn 1PN The Marq Nguyễn Đình Chiểu full nội thất hạng sang	28000000.00	52.00	1	1	29B Nguyễn Đình Chiểu	Phường Đa Kao	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN THE MARQ NGUYỄN ĐÌNH CHIỂU 52M2\nĐịa chỉ: 29B Nguyễn Đình Chiểu, Phường Đa Kao, TP. Hồ Chí Minh\nCăn hộ 1PN phân khu hạng sang trung tâm Đa Kao, trần cao 3.2m thoáng đạt.\nBàn giao sàn đá Cẩm Thạch (Marble) tự nhiên sang trọng.\nTiện ích tầng tầng mái The Sky Club: Hồ bơi vô cực 30m, Sky Bar, phòng Gym ngắm cảnh.\nGiá thuê: 28 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
78	TMQ-102	The Marq	Cho thuê căn 2PN The Marq Đa Kao view trung tâm thành phố	40000000.00	78.00	2	2	29B Nguyễn Đình Chiểu	Phường Đa Kao	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN THE MARQ NGUYỄN ĐÌNH CHIỂU 78M2\nĐịa chỉ: 29B Nguyễn Đình Chiểu, Phường Đa Kao, TP. Hồ Chí Minh\nCăn hộ 2PN thiết kế tối giản tinh tế theo phong cách Hongkong Land.\nTrang bị đầy đủ nội thất nhập khẩu Châu Âu cao cấp, đồ dùng hiện đại.\nVị trí đắc địa gần các đại sứ quán và tòa nhà văn phòng hạng A.\nGiá thuê: 40 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
79	TMQ-103	The Marq	Căn 3PN The Marq sang trọng có sảnh thang máy riêng biệt	65000000.00	120.00	3	2	29B Nguyễn Đình Chiểu	Phường Đa Kao	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN THE MARQ THANG MÁY RIÊNG 120M2\nĐịa chỉ: 29B Nguyễn Đình Chiểu, Phường Đa Kao, TP. Hồ Chí Minh\nCăn 3PN sở hữu sảnh thang máy riêng biệt mở ra không gian sống đẳng cấp.\nBếp khô và bếp wet trang bị toàn bộ thiết bị Küppersbusch đỉnh cao.\nTầm nhìn ngắm toàn cảnh cây xanh mảng lớn trung tâm thành phố.\nGiá thuê: 65 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
80	TMQ-104	The Marq	Căn 4PN The Marq Đa Kao căn góc tầng cao cực đắt giá	100000000.00	146.00	4	3	29B Nguyễn Đình Chiểu	Phường Đa Kao	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 4PN THE MARQ ĐA KAO DIỆN TÍCH 146M2\nĐịa chỉ: 29B Nguyễn Đình Chiểu, Phường Đa Kao, TP. Hồ Chí Minh\nCăn góc 4PN xuất sắc nhất dự án The Marq với thiết kế trần cao và ban công kính lớn.\nTrang bị sảnh thang máy riêng, nội thất đặt làm riêng thượng thượng thừa.\n An ninh bảo vệ nghiêm ngặt 24/24.\nGiá thuê: 100 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
81	TRV-101	The River Thủ Thiêm	Căn 1PN The River Thủ Thiêm full nội thất thiết kế hiện đại	24000000.00	57.00	1	1	Đại lộ Trống Đồng	Phường Thủ Thiêm	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN THE RIVER THỦ THIÊM DIỆN TÍCH 57M2\nĐịa chỉ: Đại lộ Trống Đồng, Phường Thủ Thiêm, TP. Hồ Chí Minh.\nCăn hộ 1PN phân khu Seine Tower, thiết kế phong cách Châu Âu hiện đại.\nBan công hướng mát, nội thất nhập khẩu cao cấp đầy đủ tiện nghi.\nVị trí sát sông Sài Gòn, không khí xung quanh luôn trong lành thoáng mát.\nGiá thuê: 24 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
82	TRV-102	The River Thủ Thiêm	Căn 2PN The River Thủ Thiêm view trực diện sông lộng gió	36000000.00	84.00	2	2	Đại lộ Trống Đồng	Phường Thủ Thiêm	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN THE RIVER THỦ THIÊM VIEW SÔNG 84M2\nĐịa chỉ: Đại lộ Trống Đồng, Phường Thủ Thiêm, TP. Hồ Chí Minh\nThiết kế không gian mở tối đa không gian đón sáng, view sông trực diện đắt giá.\nTrang bị đồ gỗ cao cấp, hệ thống điều hòa Daikin âm trần.\nTiện ích tiêu chuẩn 5 sao: Hồ bơi Olimpic 50m, phòng chiếu phim, xông hơi.\nGiá thuê: 36 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
83	TRV-103	The River Thủ Thiêm	Căn 3PN The River Thủ Thiêm thang máy riêng nội thất siêu sang	62000000.00	125.00	3	3	Đại lộ Trống Đồng	Phường Thủ Thiêm	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN THE RIVER THỦ THIÊM THANG MÁY RIÊNG 125M2\nĐịa chỉ: Đại lộ Trống Đồng, Phường Thủ Thiêm, TP. Hồ Chí Minh.\nCăn hộ có sảnh thang máy riêng mang lại sự riêng tư riêng biệt cho gia chủ.\nBàn giao đầy đủ thiết bị bếp thương hiệu Miele (Đức).\nTầm nhìn ôm trọn công viên bờ sông và cầu Ba Sơn.\nGiá thuê: 62 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
84	TRV-104	The River Thủ Thiêm	Căn Pool Villa The River Thủ Thiêm có hồ bơi riêng xa hoa	130000000.00	240.00	4	4	Đại lộ Trống Đồng	Phường Thủ Thiêm	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nPOOL VILLA THE RIVER THỦ THIÊM HỒ BƠI RIÊNG 240M2\nĐịa chỉ: Đại lộ Trống Đồng, Phường Thủ Thiêm, TP. Hồ Chí Minh.\nSiêu căn hộ Pool Villa sở hữu hồ bơi riêng ngoài ban công rộng lớn ngắm sông.\nThiết kế kiến trúc đỉnh cao, 4 phòng ngủ master trang bị phòng thay đồ riêng.\nDịch vụ quản lý tòa nhà chất lượng chuẩn quốc tế.\\n- Giá thuê: 130 Triệu/tháng.\nLiên hệ: 094x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
85	VCP-101	Vinhomes Central Park	Căn 1PN Landmark 1 Vinhomes Central Park full nội thất cao cấp	16500000.00	54.00	1	1	208 Nguyễn Hữu Cảnh	Phường Thạnh Mỹ Tây	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN LANDMARK 1 VINHOMES CENTRAL PARK 54M2\nĐịa chỉ: 208 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn hộ 1PN tòa Landmark 1 ngay sát tháp Landmark 81 sầm uất.\nNội thất cao cấp hiện đại: Sofa da, tivi 55 inch, máy giặt sấy, tủ lạnh 2 cánh.\nBước vài bước chân ra công viên ven sông 14ha lộng gió.\nGiá thuê: 16.5 Triệu/tháng.\nLiên hệ: 090x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
86	VCP-102	Vinhomes Central Park	Cho thuê căn 2PN Park 3 view trực diện công viên 14ha lộng gió	23000000.00	78.00	2	2	208 Nguyễn Hữu Cảnh	Phường Thạnh Mỹ Tây	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN PARK 3 VINHOMES CENTRAL PARK VIEW CÔNG VIÊN 78M2\nĐịa chỉ: 208 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn hộ 2PN 2WC tòa Park 3, ban công hướng Đông Nam ngắm trọn công viên ven sông 14ha.\nTrang bị full nội thất nhập khẩu, nhà trống sẵn sàng bàn giao ngay.\nĐầy đủ tiện ích: Bệnh viện Vinmec, trường Vinschool, bến du thuyền, TTTM.\nGiá thuê: 23 Triệu/tháng.\nLiên hệ: 090x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
87	VCP-103	Vinhomes Central Park	Căn góc 3PN Central 2 Vinhomes Central Park nội thất nhập khẩu	35000000.00	115.00	3	2	208 Nguyễn Hữu Cảnh	Phường Thạnh Mỹ Tây	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN CENTRAL 2 VINHOMES CENTRAL PARK 115M2\nĐịa chỉ: 208 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nCăn góc 3PN diện tích lớn, các phòng ngủ đều có cửa sổ lớn ngắm cảnh thành phố.\nTrang bị dàn nội thất xịn xò nhập khẩu hoàn toàn từ Châu Âu.\nCư dân tận hưởng tiện ích hồ bơi, phòng gym, sân cờ ngoài trời hoàn toàn miễn phí.\nGiá thuê: 35 Triệu/tháng.\\nLiên hệ: 090x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
88	VCP-104	Vinhomes Central Park	Cho thuê căn 4PN Landmark 81 tầng cao view toàn cảnh thành phố	70000000.00	144.00	4	3	208 Nguyễn Hữu Cảnh	Phường Thạnh Mỹ Tây	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 4PN LANDMARK 81 TẦNG CAO DIỆN TÍCH 144M2\nĐịa chỉ: 208 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh\nSiêu căn hộ 4PN nằm trong tòa tháp cao nhất Việt Nam Landmark 81.\nTầm nhìn triệu đô ngắm toàn cảnh thành phố lung linh về đêm từ độ cao ấn tượng.\nDịch vụ quản gia, sảnh chờ VIP đẳng cấp hàng đầu.\nGiá thuê: 70 Triệu/tháng.\\nLiên hệ: 090x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
89	VGP-101	Vinhomes Grand Park	Cho thuê căn Studio The Rainbow Vinhomes Grand Park full đồ	6500000.00	33.00	1	1	Đường Nguyễn Xiển	Phường Long Bình	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ STUDIO VINHOMES GRAND PARK DIỆN TÍCH 33M2\nĐịa chỉ: Đường Nguyễn Xiển, Phường Long Bình, TP. Hồ Chí Minh\nCăn hộ Studio nhỏ gọn thiết kế thông minh, tối ưu diện tích sử dụng.\nĐầy đủ nội thất: Sofa, tủ lạnh, máy giặt, máy lạnh, bếp từ.\nMiễn phí sử dụng công viên ánh sáng 36ha, biển nhân tạo, sân thể thao ngoài trời.\nGiá thuê: 6.5 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
90	VGP-102	Vinhomes Grand Park	Căn 2PN1WC The Origami Vinhomes Grand Park nội thất Nhật Bản	9000000.00	59.00	2	1	Đường Nguyễn Xiển	Phường Long Bình	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN1WC THE ORIGAMI VINHOMES GRAND PARK 59M2\nĐịa chỉ: Đường Nguyễn Xiển, Phường Long Bình, TP. Hồ Chí Minh\nCăn hộ phân khu The Origami phong cách chuẩn Nhật, view công viên vườn tùng.\nThiết kế 2PN xinh xắn, nội thất gỗ ấm cúng nhẹ nhàng.\nHệ thống xe bus điện VinBus đưa đón cư dân miễn phí kết nối trung tâm.\nGiá thuê: 9 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
91	VGP-103	Vinhomes Grand Park	Căn 2PN2WC Masteri Centre Point Vinhomes Grand Park cực sang	14000000.00	72.00	2	2	Đường Nguyễn Xiển	Phường Long Bình	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN2WC MASTERI CENTRE POINT GRAND PARK 72M2\nĐịa chỉ: Đường Nguyễn Xiển, Phường Long Bình, TP. Hồ Chí Minh\nCăn hộ thuộc phân khu compound cao cấp nhất đại đô thị Vinhomes Grand Park.\nBàn giao nội thất chuẩn cao cấp: Bếp Hafele, kính Kohler, hệ điều hòa âm trần.\nHồ bơi phi thuyền 2 tầng và sảnh đón sang trọng như khách sạn.\nGiá thuê: 14 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
92	VGP-104	Vinhomes Grand Park	Căn 3PN The Beverly Vinhomes Grand Park view trực diện công viên 36ha	20000000.00	100.00	3	2	Đường Nguyễn Xiển	Phường Long Bình	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 3PN THE BEVERLY VINHOMES GRAND PARK 100M2\nĐịa chỉ: Đường Nguyễn Xiển, Phường Long Bình, TP. Hồ Chí Minh\nCăn hộ phân khu The Beverly đắt giá đối diện TTTM Vincom Mega Mall lớn nhất miền Nam.\nBan công trực diện công viên 36ha ngắm trọn biển hồ nhân tạo.\nTrang bị toàn bộ thiết bị nội thất xịn xò nhập khẩu.\nGiá thuê: 20 Triệu/tháng.\nLiên hệ: 095x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
93	VGR-101	Vinhomes Golden River (Ba Son)	Căn 1PN Aqua 1 Vinhomes Golden River full đồ sang trọng	21000000.00	50.00	1	1	2 Tôn Đức Thắng	Phường Bến Nghé	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 1PN AQUA 1 VINHOMES GOLDEN RIVER 50M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nCăn hộ 1PN tòa Aqua 1 ngay trung tâm Bến Nghé, kính Low-E cản nhiệt phủ toàn bộ mặt ngoài.\nTrang bị hệ thống Smarthome, thiết bị vệ sinh Duravit và thiết bị bếp Bosch.\nTầm nhìn view sông Sài Gòn và kênh Thị Nghè mát mẻ.\nGiá thuê: 21 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
94	VGR-102	Vinhomes Golden River (Ba Son)	Cho thuê căn 2PN Lux 6 Vinhomes Golden River view trực diện sông	32000000.00	78.00	2	2	2 Tôn Đức Thắng	Phường Bến Nghé	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN HỘ 2PN LUX 6 VINHOMES GOLDEN RIVER VIEW SÔNG 78M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nCăn hộ 2PN tòa Luxury 6 đắt giá, ban công ngắm trực diện sông Sài Gòn và thảo cầm viên.\nNội thất hiện đại nhập khẩu full Option.\nTiện ích: Ga Metro Ba Son ngay nội khu, đường chạy bộ ven sông, bến du thuyền 5 sao.\nGiá thuê: 32 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
95	VGR-103	Vinhomes Golden River (Ba Son)	Căn góc 3PN Aqua 2 Vinhomes Golden River nội thất xa xỉ	50000000.00	110.00	3	2	2 Tôn Đức Thắng	Phường Bến Nghé	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nCĂN GÓC 3PN AQUA 2 VINHOMES GOLDEN RIVER 110M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nCăn góc 3PN diện tích rộng, view ôm trọn cầu Ba Sơn và tháp Bitexco.\nĐã chuẩn bị sẵn sàng toàn bộ trang thiết bị sinh hoạt cao cấp nhất.\nVị trí kim cương ngay trái tim trung tâm thành phố.\nGiá thuê: 50 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
96	VGR-104	Vinhomes Golden River (Ba Son)	Căn 4PN Penthouse Vinhomes Golden River đẳng cấp đỉnh cao	95000000.00	160.00	4	3	2 Tôn Đức Thắng	Phường Bến Nghé	TP. Hồ Chí Minh	=== MÔ TẢ CHI TIẾT ===\nPENTHOUSE 4PN VINHOMES GOLDEN RIVER BA SON 160M2\nĐịa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh\nPenthouse tầng cao tầm nhìn panorama không giới hạn ngắm toàn cảnh sông nước Sài Gòn.\nKhông gian sống riêng tư, thượng lưu dành cho các chủ nhân thành đạt.\nAn ninh bảo vệ 24/7 với hệ thống camera AI hiện đại.\nGiá thuê: 95 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx	RENT	AVAILABLE	2026-10-11 15:10:29.993521
\.


--
-- TOC entry 5590 (class 0 OID 17465)
-- Dependencies: 241
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reviews (review_id, customer_id, property_id, rating, comment_text, review_date) FROM stdin;
1	2	1	5	Can ho dep, vi tri tot, quy trinh mua ban nhanh.	2026-10-11 12:56:50.41717
\.


--
-- TOC entry 5586 (class 0 OID 17385)
-- Dependencies: 237
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transactions (transaction_id, transaction_code, customer_id, listing_id, transaction_type, listing_price, agreed_price, deposit_amount, remaining_amount, transaction_date, contract_date, completion_date, payment_method, payment_status, status, note, created_at, updated_at) FROM stdin;
1	TXN-0001	2	1	PURCHASE	3200000000.00	3100000000.00	300000000.00	0.00	2026-10-11 12:56:50.41717	2026-09-21 12:56:50.41717	2026-10-09 12:56:50.41717	BANK_TRANSFER	PAID	COMPLETED	Giao dich mua can ho Vinhomes	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717
2	TXN-0002	3	3	PURCHASE	5200000000.00	5000000000.00	500000000.00	4500000000.00	2026-10-11 12:56:50.41717	\N	\N	BANK_TRANSFER	PARTIAL	DEPOSITED	Khach dang cho xu ly hop dong	2026-10-11 12:56:50.41717	2026-10-11 12:56:50.41717
\.


--
-- TOC entry 5570 (class 0 OID 17163)
-- Dependencies: 221
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (user_id, username, email, password_hash, role, created_at, is_active) FROM stdin;
1	admin	admin@gmail.com	admin_hash	ADMIN	2026-10-11 12:56:50.41717	1
2	customer01	customer01@gmail.com	customer_hash_01	CUSTOMER	2026-10-11 12:56:50.41717	1
3	customer02	customer02@gmail.com	customer_hash_02	CUSTOMER	2026-10-11 12:56:50.41717	1
4	customer03	customer03@gmail.com	customer_hash_03	CUSTOMER	2026-10-11 12:56:50.41717	1
5	owner01	owner01@gmail.com	owner_hash_01	OWNER	2026-10-11 12:56:50.41717	1
6	owner02	owner02@gmail.com	owner_hash_02	OWNER	2026-10-11 12:56:50.41717	1
\.


--
-- TOC entry 5603 (class 0 OID 0)
-- Dependencies: 227
-- Name: apartments_apartment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.apartments_apartment_id_seq', 101, true);


--
-- TOC entry 5604 (class 0 OID 0)
-- Dependencies: 225
-- Name: buildings_building_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.buildings_building_id_seq', 26, true);


--
-- TOC entry 5605 (class 0 OID 0)
-- Dependencies: 234
-- Name: listings_listing_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.listings_listing_id_seq', 101, true);


--
-- TOC entry 5606 (class 0 OID 0)
-- Dependencies: 238
-- Name: payments_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payments_payment_id_seq', 5, true);


--
-- TOC entry 5607 (class 0 OID 0)
-- Dependencies: 229
-- Name: properties_property_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.properties_property_id_seq', 101, true);


--
-- TOC entry 5608 (class 0 OID 0)
-- Dependencies: 231
-- Name: property_images_image_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.property_images_image_id_seq', 230, true);


--
-- TOC entry 5609 (class 0 OID 0)
-- Dependencies: 242
-- Name: property_viewings_viewing_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.property_viewings_viewing_id_seq', 12, true);


--
-- TOC entry 5610 (class 0 OID 0)
-- Dependencies: 246
-- Name: rental_apartment_images_image_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rental_apartment_images_image_id_seq', 448, true);


--
-- TOC entry 5611 (class 0 OID 0)
-- Dependencies: 244
-- Name: rental_apartments_rental_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rental_apartments_rental_id_seq', 192, true);


--
-- TOC entry 5612 (class 0 OID 0)
-- Dependencies: 240
-- Name: reviews_review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reviews_review_id_seq', 1, true);


--
-- TOC entry 5613 (class 0 OID 0)
-- Dependencies: 236
-- Name: transactions_transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.transactions_transaction_id_seq', 3, true);


--
-- TOC entry 5614 (class 0 OID 0)
-- Dependencies: 220
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_user_id_seq', 6, true);


--
-- TOC entry 5379 (class 2606 OID 18269)
-- Name: property_viewings ex_viewing_no_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property_viewings
    ADD CONSTRAINT ex_viewing_no_overlap EXCLUDE USING gist (property_id WITH =, tsrange(start_time, end_time, '[)'::text) WITH &&) WHERE (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'CONFIRMED'::character varying])::text[])));


--
-- TOC entry 5336 (class 2606 OID 17272)
-- Name: apartments pk_apartments; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apartments
    ADD CONSTRAINT pk_apartments PRIMARY KEY (apartment_id);


--
-- TOC entry 5328 (class 2606 OID 17242)
-- Name: buildings pk_buildings; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT pk_buildings PRIMARY KEY (building_id);


--
-- TOC entry 5320 (class 2606 OID 17201)
-- Name: customer_locations pk_customer_locations; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_locations
    ADD CONSTRAINT pk_customer_locations PRIMARY KEY (customer_id, location_name);


--
-- TOC entry 5318 (class 2606 OID 17189)
-- Name: customers pk_customers; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT pk_customers PRIMARY KEY (customer_id);


--
-- TOC entry 5351 (class 2606 OID 17337)
-- Name: favorites pk_favorites; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT pk_favorites PRIMARY KEY (customer_id, property_id);


--
-- TOC entry 5356 (class 2606 OID 17371)
-- Name: listings pk_listings; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT pk_listings PRIMARY KEY (listing_id);


--
-- TOC entry 5322 (class 2606 OID 17212)
-- Name: owners pk_owners; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.owners
    ADD CONSTRAINT pk_owners PRIMARY KEY (owner_id);


--
-- TOC entry 5370 (class 2606 OID 17456)
-- Name: payments pk_payments; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT pk_payments PRIMARY KEY (payment_id);


--
-- TOC entry 5343 (class 2606 OID 17300)
-- Name: properties pk_properties; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT pk_properties PRIMARY KEY (property_id);


--
-- TOC entry 5348 (class 2606 OID 17323)
-- Name: property_images pk_property_images; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property_images
    ADD CONSTRAINT pk_property_images PRIMARY KEY (image_id);


--
-- TOC entry 5375 (class 2606 OID 17478)
-- Name: reviews pk_reviews; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT pk_reviews PRIMARY KEY (review_id);


--
-- TOC entry 5364 (class 2606 OID 17420)
-- Name: transactions pk_transactions; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT pk_transactions PRIMARY KEY (transaction_id);


--
-- TOC entry 5312 (class 2606 OID 17179)
-- Name: users pk_users; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT pk_users PRIMARY KEY (user_id);


--
-- TOC entry 5384 (class 2606 OID 18267)
-- Name: property_viewings property_viewings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property_viewings
    ADD CONSTRAINT property_viewings_pkey PRIMARY KEY (viewing_id);


--
-- TOC entry 5392 (class 2606 OID 18341)
-- Name: rental_apartment_images rental_apartment_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rental_apartment_images
    ADD CONSTRAINT rental_apartment_images_pkey PRIMARY KEY (image_id);


--
-- TOC entry 5394 (class 2606 OID 18343)
-- Name: rental_apartment_images rental_apartment_images_rental_id_sort_order_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rental_apartment_images
    ADD CONSTRAINT rental_apartment_images_rental_id_sort_order_key UNIQUE (rental_id, sort_order);


--
-- TOC entry 5388 (class 2606 OID 18322)
-- Name: rental_apartments rental_apartments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rental_apartments
    ADD CONSTRAINT rental_apartments_pkey PRIMARY KEY (rental_id);


--
-- TOC entry 5390 (class 2606 OID 18324)
-- Name: rental_apartments rental_apartments_source_listing_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rental_apartments
    ADD CONSTRAINT rental_apartments_source_listing_code_key UNIQUE (source_listing_code);


--
-- TOC entry 5338 (class 2606 OID 17274)
-- Name: apartments uq_apartments_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apartments
    ADD CONSTRAINT uq_apartments_code UNIQUE (building_id, apartment_code);


--
-- TOC entry 5330 (class 2606 OID 17244)
-- Name: buildings uq_buildings_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT uq_buildings_code UNIQUE (building_code);


--
-- TOC entry 5358 (class 2606 OID 17373)
-- Name: listings uq_listings_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT uq_listings_code UNIQUE (listing_code);


--
-- TOC entry 5324 (class 2606 OID 17214)
-- Name: owners uq_owners_tax; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.owners
    ADD CONSTRAINT uq_owners_tax UNIQUE (tax_code);


--
-- TOC entry 5372 (class 2606 OID 17458)
-- Name: payments uq_payments_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT uq_payments_code UNIQUE (payment_code);


--
-- TOC entry 5345 (class 2606 OID 17302)
-- Name: properties uq_properties_apartment; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT uq_properties_apartment UNIQUE (apartment_id);


--
-- TOC entry 5377 (class 2606 OID 17480)
-- Name: reviews uq_reviews_customer_property; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT uq_reviews_customer_property UNIQUE (customer_id, property_id);


--
-- TOC entry 5366 (class 2606 OID 17422)
-- Name: transactions uq_transactions_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT uq_transactions_code UNIQUE (transaction_code);


--
-- TOC entry 5314 (class 2606 OID 17183)
-- Name: users uq_users_email; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uq_users_email UNIQUE (email);


--
-- TOC entry 5316 (class 2606 OID 17181)
-- Name: users uq_users_username; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uq_users_username UNIQUE (username);


--
-- TOC entry 5331 (class 1259 OID 17493)
-- Name: idx_apartments_building; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_apartments_building ON public.apartments USING btree (building_id);


--
-- TOC entry 5332 (class 1259 OID 17494)
-- Name: idx_apartments_floor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_apartments_floor ON public.apartments USING btree (floor_number);


--
-- TOC entry 5333 (class 1259 OID 17495)
-- Name: idx_apartments_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_apartments_status ON public.apartments USING btree (status);


--
-- TOC entry 5325 (class 1259 OID 17492)
-- Name: idx_buildings_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_buildings_city ON public.buildings USING btree (city);


--
-- TOC entry 5326 (class 1259 OID 17491)
-- Name: idx_buildings_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_buildings_name ON public.buildings USING btree (building_name);


--
-- TOC entry 5346 (class 1259 OID 17510)
-- Name: idx_images_property; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_images_property ON public.property_images USING btree (property_id);


--
-- TOC entry 5352 (class 1259 OID 17500)
-- Name: idx_listings_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_listings_owner ON public.listings USING btree (owner_id);


--
-- TOC entry 5353 (class 1259 OID 17501)
-- Name: idx_listings_property; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_listings_property ON public.listings USING btree (property_id);


--
-- TOC entry 5354 (class 1259 OID 17502)
-- Name: idx_listings_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_listings_status ON public.listings USING btree (status);


--
-- TOC entry 5367 (class 1259 OID 17508)
-- Name: idx_payments_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_status ON public.payments USING btree (status);


--
-- TOC entry 5368 (class 1259 OID 17507)
-- Name: idx_payments_transaction; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_transaction ON public.payments USING btree (transaction_id);


--
-- TOC entry 5339 (class 1259 OID 17496)
-- Name: idx_properties_apartment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_properties_apartment ON public.properties USING btree (apartment_id);


--
-- TOC entry 5334 (class 1259 OID 17498)
-- Name: idx_properties_area; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_properties_area ON public.apartments USING btree (area);


--
-- TOC entry 5340 (class 1259 OID 17497)
-- Name: idx_properties_price; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_properties_price ON public.properties USING btree (price);


--
-- TOC entry 5341 (class 1259 OID 17499)
-- Name: idx_properties_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_properties_status ON public.properties USING btree (status);


--
-- TOC entry 5385 (class 1259 OID 18349)
-- Name: idx_rental_apartments_building; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rental_apartments_building ON public.rental_apartments USING btree (building_name);


--
-- TOC entry 5386 (class 1259 OID 18350)
-- Name: idx_rental_apartments_rent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rental_apartments_rent ON public.rental_apartments USING btree (monthly_rent);


--
-- TOC entry 5373 (class 1259 OID 17509)
-- Name: idx_reviews_property; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reviews_property ON public.reviews USING btree (property_id);


--
-- TOC entry 5359 (class 1259 OID 17503)
-- Name: idx_transactions_customer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_transactions_customer ON public.transactions USING btree (customer_id);


--
-- TOC entry 5360 (class 1259 OID 17504)
-- Name: idx_transactions_listing; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_transactions_listing ON public.transactions USING btree (listing_id);


--
-- TOC entry 5361 (class 1259 OID 17506)
-- Name: idx_transactions_payment_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_transactions_payment_status ON public.transactions USING btree (payment_status);


--
-- TOC entry 5362 (class 1259 OID 17505)
-- Name: idx_transactions_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_transactions_status ON public.transactions USING btree (status);


--
-- TOC entry 5380 (class 1259 OID 18280)
-- Name: idx_viewings_customer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_viewings_customer ON public.property_viewings USING btree (customer_id);


--
-- TOC entry 5381 (class 1259 OID 18281)
-- Name: idx_viewings_property_start; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_viewings_property_start ON public.property_viewings USING btree (property_id, start_time);


--
-- TOC entry 5382 (class 1259 OID 18282)
-- Name: idx_viewings_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_viewings_status ON public.property_viewings USING btree (status);


--
-- TOC entry 5349 (class 1259 OID 17511)
-- Name: uq_property_one_thumbnail; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_property_one_thumbnail ON public.property_images USING btree (property_id) WHERE (is_thumbnail = 1);


--
-- TOC entry 5417 (class 2620 OID 18289)
-- Name: payments trg_deposit_reserve_property; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_deposit_reserve_property AFTER INSERT OR UPDATE OF status ON public.payments FOR EACH ROW WHEN ((((new.payment_type)::text = 'DEPOSIT'::text) AND ((new.status)::text = 'SUCCESS'::text))) EXECUTE FUNCTION public.fn_deposit_reserve_property();


--
-- TOC entry 5418 (class 2620 OID 18287)
-- Name: payments trg_deposit_validate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_deposit_validate BEFORE INSERT OR UPDATE OF status, amount, transaction_id, payment_type ON public.payments FOR EACH ROW EXECUTE FUNCTION public.fn_deposit_validate();


--
-- TOC entry 5414 (class 2620 OID 17514)
-- Name: listings trg_listings_updated; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_listings_updated BEFORE UPDATE ON public.listings FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- TOC entry 5419 (class 2620 OID 17518)
-- Name: payments trg_payment_success; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_payment_success AFTER INSERT OR UPDATE OF status, amount ON public.payments FOR EACH ROW WHEN (((new.status)::text = 'SUCCESS'::text)) EXECUTE FUNCTION public.fn_payment_success();


--
-- TOC entry 5413 (class 2620 OID 17513)
-- Name: properties trg_properties_updated; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_properties_updated BEFORE UPDATE ON public.properties FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- TOC entry 5415 (class 2620 OID 17516)
-- Name: transactions trg_transaction_completed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_transaction_completed AFTER INSERT OR UPDATE OF status ON public.transactions FOR EACH ROW WHEN (((new.status)::text = 'COMPLETED'::text)) EXECUTE FUNCTION public.fn_transaction_completed();


--
-- TOC entry 5416 (class 2620 OID 17520)
-- Name: transactions trg_transaction_payment_status; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_transaction_payment_status BEFORE UPDATE OF payment_status ON public.transactions FOR EACH ROW WHEN (((new.payment_status)::text = 'PAID'::text)) EXECUTE FUNCTION public.fn_transaction_payment_status();


--
-- TOC entry 5420 (class 2620 OID 18283)
-- Name: property_viewings trg_viewings_updated; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_viewings_updated BEFORE UPDATE ON public.property_viewings FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- TOC entry 5421 (class 2620 OID 18285)
-- Name: property_viewings trg_viewings_validate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_viewings_validate BEFORE INSERT OR UPDATE ON public.property_viewings FOR EACH ROW EXECUTE FUNCTION public.fn_viewing_validate();


--
-- TOC entry 5398 (class 2606 OID 17275)
-- Name: apartments fk_apartments_building; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apartments
    ADD CONSTRAINT fk_apartments_building FOREIGN KEY (building_id) REFERENCES public.buildings(building_id);


--
-- TOC entry 5396 (class 2606 OID 17202)
-- Name: customer_locations fk_custloc_customer; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_locations
    ADD CONSTRAINT fk_custloc_customer FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE CASCADE;


--
-- TOC entry 5395 (class 2606 OID 17190)
-- Name: customers fk_customers_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT fk_customers_users FOREIGN KEY (customer_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 5401 (class 2606 OID 17338)
-- Name: favorites fk_favorites_customer; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT fk_favorites_customer FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE CASCADE;


--
-- TOC entry 5402 (class 2606 OID 17343)
-- Name: favorites fk_favorites_property; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT fk_favorites_property FOREIGN KEY (property_id) REFERENCES public.properties(property_id) ON DELETE CASCADE;


--
-- TOC entry 5400 (class 2606 OID 17324)
-- Name: property_images fk_images_property; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property_images
    ADD CONSTRAINT fk_images_property FOREIGN KEY (property_id) REFERENCES public.properties(property_id) ON DELETE CASCADE;


--
-- TOC entry 5403 (class 2606 OID 17374)
-- Name: listings fk_listings_owner; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT fk_listings_owner FOREIGN KEY (owner_id) REFERENCES public.owners(owner_id);


--
-- TOC entry 5404 (class 2606 OID 17379)
-- Name: listings fk_listings_property; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT fk_listings_property FOREIGN KEY (property_id) REFERENCES public.properties(property_id);


--
-- TOC entry 5397 (class 2606 OID 17215)
-- Name: owners fk_owners_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.owners
    ADD CONSTRAINT fk_owners_users FOREIGN KEY (owner_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 5407 (class 2606 OID 17459)
-- Name: payments fk_payments_transaction; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT fk_payments_transaction FOREIGN KEY (transaction_id) REFERENCES public.transactions(transaction_id) ON DELETE CASCADE;


--
-- TOC entry 5399 (class 2606 OID 17303)
-- Name: properties fk_properties_apartment; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT fk_properties_apartment FOREIGN KEY (apartment_id) REFERENCES public.apartments(apartment_id);


--
-- TOC entry 5408 (class 2606 OID 17481)
-- Name: reviews fk_reviews_customer; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_reviews_customer FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- TOC entry 5409 (class 2606 OID 17486)
-- Name: reviews fk_reviews_property; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_reviews_property FOREIGN KEY (property_id) REFERENCES public.properties(property_id);


--
-- TOC entry 5405 (class 2606 OID 17423)
-- Name: transactions fk_transactions_customer; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT fk_transactions_customer FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- TOC entry 5406 (class 2606 OID 17428)
-- Name: transactions fk_transactions_listing; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT fk_transactions_listing FOREIGN KEY (listing_id) REFERENCES public.listings(listing_id);


--
-- TOC entry 5410 (class 2606 OID 18270)
-- Name: property_viewings property_viewings_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property_viewings
    ADD CONSTRAINT property_viewings_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- TOC entry 5411 (class 2606 OID 18275)
-- Name: property_viewings property_viewings_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property_viewings
    ADD CONSTRAINT property_viewings_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(property_id);


--
-- TOC entry 5412 (class 2606 OID 18344)
-- Name: rental_apartment_images rental_apartment_images_rental_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rental_apartment_images
    ADD CONSTRAINT rental_apartment_images_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES public.rental_apartments(rental_id) ON DELETE CASCADE;


-- Completed on 2026-10-11 17:15:08

--
-- PostgreSQL database dump complete
--

\unrestrict EGX7jGcZiUiKZQ1t53A1oQhYwpOtz4D2EIXmZgF7E0c7FTOoCKn0VdCp4SFBCNH

