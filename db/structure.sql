SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: brands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE brands (
    brand_id bigint NOT NULL,
    name character varying(100),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE brands; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE brands IS 'Brand definition';


--
-- Name: COLUMN brands.brand_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN brands.brand_id IS 'Globally unique id for brand';


--
-- Name: COLUMN brands.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN brands.name IS 'Brand name';


--
-- Name: brands_brand_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brands_brand_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brands_brand_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brands_brand_id_seq OWNED BY brands.brand_id;


--
-- Name: concept_brands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE concept_brands (
    concept_brand_id bigint NOT NULL,
    brand_id bigint NOT NULL,
    concept_id bigint NOT NULL,
    source_brand_id bigint NOT NULL,
    active boolean NOT NULL,
    status character varying(10) NOT NULL,
    name character varying(100),
    description character varying(1000),
    source_created_by bigint DEFAULT 0 NOT NULL,
    source_created_at timestamp without time zone NOT NULL,
    source_updated_by bigint DEFAULT 0 NOT NULL,
    source_updated_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE concept_brands; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE concept_brands IS 'Concept specific attribute for brand';


--
-- Name: COLUMN concept_brands.concept_brand_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_brands.concept_brand_id IS 'Unique id for concept + brand intersection';


--
-- Name: COLUMN concept_brands.brand_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_brands.brand_id IS 'Global brand Id';


--
-- Name: COLUMN concept_brands.source_brand_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_brands.source_brand_id IS 'Brand Id in source system';


--
-- Name: COLUMN concept_brands.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_brands.active IS 'Concept-specific active flag';


--
-- Name: COLUMN concept_brands.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_brands.status IS 'Concept-specific status';


--
-- Name: COLUMN concept_brands.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_brands.name IS 'Concept-specific name';


--
-- Name: COLUMN concept_brands.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_brands.description IS 'Concept-specific description';


--
-- Name: concept_brands_concept_brand_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE concept_brands_concept_brand_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: concept_brands_concept_brand_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE concept_brands_concept_brand_id_seq OWNED BY concept_brands.concept_brand_id;


--
-- Name: concept_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE concept_products (
    concept_product_id bigint NOT NULL,
    product_id bigint NOT NULL,
    concept_id bigint NOT NULL,
    source_product_id bigint NOT NULL,
    active boolean NOT NULL,
    status character varying(10) NOT NULL,
    name character varying(100),
    description character varying(1000),
    pdp_url character varying(255),
    source_created_by bigint DEFAULT 0 NOT NULL,
    source_created_at timestamp without time zone NOT NULL,
    source_updated_by bigint DEFAULT 0 NOT NULL,
    source_updated_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE concept_products; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE concept_products IS 'Concept specific attributes for product';


--
-- Name: COLUMN concept_products.concept_product_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_products.concept_product_id IS 'Unique id for concept + product intersection';


--
-- Name: COLUMN concept_products.product_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_products.product_id IS 'Global product Id';


--
-- Name: COLUMN concept_products.source_product_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_products.source_product_id IS 'Product Id in source system';


--
-- Name: COLUMN concept_products.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_products.active IS 'Concept-specific active flag';


--
-- Name: COLUMN concept_products.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_products.status IS 'Concept-specific status';


--
-- Name: COLUMN concept_products.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_products.name IS 'Concept-specific name';


--
-- Name: COLUMN concept_products.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_products.description IS 'Concept-specific description';


--
-- Name: COLUMN concept_products.pdp_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_products.pdp_url IS 'Product description page URL';


--
-- Name: concept_products_concept_product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE concept_products_concept_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: concept_products_concept_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE concept_products_concept_product_id_seq OWNED BY concept_products.concept_product_id;


--
-- Name: concept_sku_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE concept_sku_attributes (
    concept_sku_attribute_id bigint NOT NULL,
    sku_id bigint NOT NULL,
    concept_id bigint NOT NULL,
    concept_sku_id bigint NOT NULL,
    name character varying(40),
    value character varying(255),
    source_created_by bigint DEFAULT 0 NOT NULL,
    source_created_at timestamp without time zone NOT NULL,
    source_updated_by bigint DEFAULT 0 NOT NULL,
    source_updated_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE concept_sku_attributes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE concept_sku_attributes IS 'Concept-specific sparse sku attributes';


--
-- Name: COLUMN concept_sku_attributes.concept_sku_attribute_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_sku_attributes.concept_sku_attribute_id IS 'Unique id for concept + sku + attribute intersection';


--
-- Name: COLUMN concept_sku_attributes.sku_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_sku_attributes.sku_id IS 'Global sku Id';


--
-- Name: COLUMN concept_sku_attributes.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_sku_attributes.name IS 'Attribute name';


--
-- Name: COLUMN concept_sku_attributes.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_sku_attributes.value IS 'Attribute value';


--
-- Name: concept_sku_attributes_concept_sku_attribute_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE concept_sku_attributes_concept_sku_attribute_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: concept_sku_attributes_concept_sku_attribute_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE concept_sku_attributes_concept_sku_attribute_id_seq OWNED BY concept_sku_attributes.concept_sku_attribute_id;


--
-- Name: concept_skus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE concept_skus (
    concept_sku_id bigint NOT NULL,
    sku_id bigint NOT NULL,
    concept_id bigint NOT NULL,
    source_sku_id bigint NOT NULL,
    active boolean NOT NULL,
    status character varying(10) NOT NULL,
    status_reason_cd character varying(5),
    name character varying(100),
    description character varying(1000),
    color character varying(100),
    source_created_by bigint DEFAULT 0 NOT NULL,
    source_created_at timestamp without time zone NOT NULL,
    source_updated_by bigint DEFAULT 0 NOT NULL,
    source_updated_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE concept_skus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE concept_skus IS 'Concept-specific attributes for SKU';


--
-- Name: COLUMN concept_skus.concept_sku_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_skus.concept_sku_id IS 'Unique id for concept + sku intersection';


--
-- Name: COLUMN concept_skus.sku_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_skus.sku_id IS 'Global sku Id';


--
-- Name: COLUMN concept_skus.source_sku_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_skus.source_sku_id IS 'Sku Id in source system';


--
-- Name: COLUMN concept_skus.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_skus.active IS 'Concept-specific active flag';


--
-- Name: COLUMN concept_skus.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_skus.status IS 'Concept-specific status';


--
-- Name: COLUMN concept_skus.status_reason_cd; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_skus.status_reason_cd IS 'Optional reason code for the SKU/concept status';


--
-- Name: COLUMN concept_skus.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_skus.name IS 'Concept-specific name';


--
-- Name: COLUMN concept_skus.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_skus.description IS 'Concept-specific description';


--
-- Name: COLUMN concept_skus.color; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concept_skus.color IS 'Concept-specific SKU color';


--
-- Name: concept_skus_concept_sku_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE concept_skus_concept_sku_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: concept_skus_concept_sku_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE concept_skus_concept_sku_id_seq OWNED BY concept_skus.concept_sku_id;


--
-- Name: concepts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE concepts (
    concept_id bigint NOT NULL,
    name character varying(30) NOT NULL,
    abbreviation character varying(8) NOT NULL,
    legal_name character varying(100) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE concepts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE concepts IS 'Master concept definition';


--
-- Name: COLUMN concepts.concept_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concepts.concept_id IS 'Concept Id';


--
-- Name: COLUMN concepts.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concepts.name IS 'Name';


--
-- Name: COLUMN concepts.abbreviation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concepts.abbreviation IS 'Abbreviation';


--
-- Name: COLUMN concepts.legal_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN concepts.legal_name IS 'Legal name';


--
-- Name: concepts_concept_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE concepts_concept_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: concepts_concept_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE concepts_concept_id_seq OWNED BY concepts.concept_id;


--
-- Name: inbound_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inbound_batches (
    inbound_batch_id bigint NOT NULL,
    source character varying(10) NOT NULL,
    data_type character varying(40) NOT NULL,
    status character varying(30) DEFAULT 'in progress'::character varying NOT NULL,
    status_reason character varying(255),
    file_name character varying(255),
    start_datetime timestamp without time zone DEFAULT now() NOT NULL,
    stop_datetime timestamp without time zone
);


--
-- Name: TABLE inbound_batches; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE inbound_batches IS 'Log of batches received';


--
-- Name: COLUMN inbound_batches.source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_batches.source IS 'OKL / PDM / CPWM';


--
-- Name: COLUMN inbound_batches.data_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_batches.data_type IS 'sku / product';


--
-- Name: COLUMN inbound_batches.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_batches.status IS 'in progress / complete / error';


--
-- Name: COLUMN inbound_batches.status_reason; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_batches.status_reason IS 'Additional status details';


--
-- Name: COLUMN inbound_batches.file_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_batches.file_name IS 'Optional: backup of message or SQL script';


--
-- Name: inbound_batches_inbound_batch_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inbound_batches_inbound_batch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inbound_batches_inbound_batch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inbound_batches_inbound_batch_id_seq OWNED BY inbound_batches.inbound_batch_id;


--
-- Name: inbound_okl_product_revisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inbound_okl_product_revisions (
    id bigint NOT NULL,
    inbound_batch_id bigint NOT NULL,
    product_id bigint NOT NULL,
    status character varying(40),
    name character varying(255),
    description text,
    pdp_url character varying(512)
);


--
-- Name: inbound_okl_product_revisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inbound_okl_product_revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inbound_okl_product_revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inbound_okl_product_revisions_id_seq OWNED BY inbound_okl_product_revisions.id;


--
-- Name: inbound_okl_sku_attribute_revisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inbound_okl_sku_attribute_revisions (
    id bigint NOT NULL,
    inbound_batch_id bigint NOT NULL,
    sku_id bigint NOT NULL,
    sku_attribute_id integer,
    code character varying,
    value character varying
);


--
-- Name: inbound_okl_sku_attribute_revisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inbound_okl_sku_attribute_revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inbound_okl_sku_attribute_revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inbound_okl_sku_attribute_revisions_id_seq OWNED BY inbound_okl_sku_attribute_revisions.id;


--
-- Name: inbound_okl_sku_dimensions_revisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inbound_okl_sku_dimensions_revisions (
    id bigint NOT NULL,
    inbound_batch_id bigint NOT NULL,
    sku_id bigint NOT NULL,
    cost numeric(8,2),
    item_width numeric(8,2),
    item_height numeric(8,2),
    item_length numeric(8,2),
    item_weight numeric(8,2),
    shipping_width numeric(8,2),
    shipping_height numeric(8,2),
    shipping_length numeric(8,2),
    shipping_weight numeric(8,2)
);


--
-- Name: inbound_okl_sku_dimensions_revisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inbound_okl_sku_dimensions_revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inbound_okl_sku_dimensions_revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inbound_okl_sku_dimensions_revisions_id_seq OWNED BY inbound_okl_sku_dimensions_revisions.id;


--
-- Name: inbound_okl_sku_image_revisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inbound_okl_sku_image_revisions (
    id bigint NOT NULL,
    inbound_batch_id bigint NOT NULL,
    sku_id bigint NOT NULL,
    image_id bigint NOT NULL,
    hosting_service character varying,
    resource_folder character varying,
    resource_path character varying,
    resource_name character varying,
    sort_order integer,
    "primary" boolean,
    active boolean
);


--
-- Name: inbound_okl_sku_image_revisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inbound_okl_sku_image_revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inbound_okl_sku_image_revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inbound_okl_sku_image_revisions_id_seq OWNED BY inbound_okl_sku_image_revisions.id;


--
-- Name: inbound_okl_sku_revisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inbound_okl_sku_revisions (
    id bigint NOT NULL,
    inbound_batch_id bigint NOT NULL,
    sku_id bigint NOT NULL,
    jda_id bigint NOT NULL,
    upc bigint,
    brand_id bigint,
    name character varying(255),
    line_of_business character varying(255),
    product_id bigint,
    cost numeric(8,2),
    price numeric(8,2),
    pre_markdown_price numeric(8,2),
    color character varying(255),
    color_family character varying(255),
    size character varying(255),
    material character varying(255),
    shipping_method character varying(40)
);


--
-- Name: inbound_okl_sku_revisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inbound_okl_sku_revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inbound_okl_sku_revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inbound_okl_sku_revisions_id_seq OWNED BY inbound_okl_sku_revisions.id;


--
-- Name: inbound_okl_sku_shipping_revisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inbound_okl_sku_shipping_revisions (
    id bigint NOT NULL,
    inbound_batch_id bigint NOT NULL,
    sku_id bigint NOT NULL,
    virtual_delivery boolean,
    returnable boolean,
    non_merchandise boolean,
    perishable boolean,
    white_glove boolean,
    entryway boolean,
    extra_shipping_charge numeric(8,2),
    vdc boolean,
    lead_time integer,
    min_aad_offset_days integer,
    max_aad_offset_days integer
);


--
-- Name: inbound_okl_sku_shipping_revisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inbound_okl_sku_shipping_revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inbound_okl_sku_shipping_revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inbound_okl_sku_shipping_revisions_id_seq OWNED BY inbound_okl_sku_shipping_revisions.id;


--
-- Name: inbound_okl_sku_state_revisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inbound_okl_sku_state_revisions (
    id bigint NOT NULL,
    inbound_batch_id bigint NOT NULL,
    sku_id bigint NOT NULL,
    content_ready boolean,
    copy_ready boolean,
    vetted boolean,
    exists_in_storefront boolean,
    exclusivity_tier character varying,
    inactive_reason_id integer,
    "obsolete reason id" integer,
    status_reason character varying,
    "obsolete reason name" character varying
);


--
-- Name: inbound_okl_sku_state_revisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inbound_okl_sku_state_revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inbound_okl_sku_state_revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inbound_okl_sku_state_revisions_id_seq OWNED BY inbound_okl_sku_state_revisions.id;


--
-- Name: product_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE product_memberships (
    product_membership_id bigint NOT NULL,
    product_id bigint,
    sku_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE product_memberships; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE product_memberships IS 'Sku membership for each product';


--
-- Name: product_memberships_product_membership_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE product_memberships_product_membership_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_memberships_product_membership_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE product_memberships_product_membership_id_seq OWNED BY product_memberships.product_membership_id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE products (
    product_id bigint NOT NULL,
    membership_hash bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE products; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE products IS 'Product definition';


--
-- Name: COLUMN products.product_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN products.product_id IS 'Globally unique id for product';


--
-- Name: COLUMN products.membership_hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN products.membership_hash IS 'Hash of member sku_ids';


--
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE products_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE products_product_id_seq OWNED BY products.product_id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: skus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE skus (
    sku_id bigint NOT NULL,
    gtin bigint,
    unit_of_measure_cd character varying(3),
    vmf boolean,
    color_family character varying(20),
    non_taxable boolean,
    vintage boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: COLUMN skus.sku_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN skus.sku_id IS 'ID in BBBY systems';


--
-- Name: COLUMN skus.gtin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN skus.gtin IS 'UPC or EAN';


--
-- Name: COLUMN skus.unit_of_measure_cd; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN skus.unit_of_measure_cd IS 'Unit of measure code';


--
-- Name: COLUMN skus.vmf; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN skus.vmf IS 'is VMF flag for OKL items?';


--
-- Name: COLUMN skus.color_family; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN skus.color_family IS 'SKU color family';


--
-- Name: COLUMN skus.non_taxable; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN skus.non_taxable IS 'is item non-taxable?';


--
-- Name: COLUMN skus.vintage; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN skus.vintage IS 'is vintage?';


--
-- Name: skus_sku_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE skus_sku_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: skus_sku_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE skus_sku_id_seq OWNED BY skus.sku_id;


--
-- Name: brands brand_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY brands ALTER COLUMN brand_id SET DEFAULT nextval('brands_brand_id_seq'::regclass);


--
-- Name: concept_brands concept_brand_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_brands ALTER COLUMN concept_brand_id SET DEFAULT nextval('concept_brands_concept_brand_id_seq'::regclass);


--
-- Name: concept_products concept_product_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_products ALTER COLUMN concept_product_id SET DEFAULT nextval('concept_products_concept_product_id_seq'::regclass);


--
-- Name: concept_sku_attributes concept_sku_attribute_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_sku_attributes ALTER COLUMN concept_sku_attribute_id SET DEFAULT nextval('concept_sku_attributes_concept_sku_attribute_id_seq'::regclass);


--
-- Name: concept_skus concept_sku_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_skus ALTER COLUMN concept_sku_id SET DEFAULT nextval('concept_skus_concept_sku_id_seq'::regclass);


--
-- Name: concepts concept_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY concepts ALTER COLUMN concept_id SET DEFAULT nextval('concepts_concept_id_seq'::regclass);


--
-- Name: inbound_batches inbound_batch_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_batches ALTER COLUMN inbound_batch_id SET DEFAULT nextval('inbound_batches_inbound_batch_id_seq'::regclass);


--
-- Name: inbound_okl_product_revisions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_product_revisions ALTER COLUMN id SET DEFAULT nextval('inbound_okl_product_revisions_id_seq'::regclass);


--
-- Name: inbound_okl_sku_attribute_revisions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_attribute_revisions ALTER COLUMN id SET DEFAULT nextval('inbound_okl_sku_attribute_revisions_id_seq'::regclass);


--
-- Name: inbound_okl_sku_dimensions_revisions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_dimensions_revisions ALTER COLUMN id SET DEFAULT nextval('inbound_okl_sku_dimensions_revisions_id_seq'::regclass);


--
-- Name: inbound_okl_sku_image_revisions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_image_revisions ALTER COLUMN id SET DEFAULT nextval('inbound_okl_sku_image_revisions_id_seq'::regclass);


--
-- Name: inbound_okl_sku_revisions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_revisions ALTER COLUMN id SET DEFAULT nextval('inbound_okl_sku_revisions_id_seq'::regclass);


--
-- Name: inbound_okl_sku_shipping_revisions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_shipping_revisions ALTER COLUMN id SET DEFAULT nextval('inbound_okl_sku_shipping_revisions_id_seq'::regclass);


--
-- Name: inbound_okl_sku_state_revisions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_state_revisions ALTER COLUMN id SET DEFAULT nextval('inbound_okl_sku_state_revisions_id_seq'::regclass);


--
-- Name: product_memberships product_membership_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_memberships ALTER COLUMN product_membership_id SET DEFAULT nextval('product_memberships_product_membership_id_seq'::regclass);


--
-- Name: products product_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY products ALTER COLUMN product_id SET DEFAULT nextval('products_product_id_seq'::regclass);


--
-- Name: skus sku_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY skus ALTER COLUMN sku_id SET DEFAULT nextval('skus_sku_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (brand_id);


--
-- Name: concept_brands concept_brands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_brands
    ADD CONSTRAINT concept_brands_pkey PRIMARY KEY (concept_brand_id);


--
-- Name: concept_products concept_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_products
    ADD CONSTRAINT concept_products_pkey PRIMARY KEY (concept_product_id);


--
-- Name: concept_sku_attributes concept_sku_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_sku_attributes
    ADD CONSTRAINT concept_sku_attributes_pkey PRIMARY KEY (concept_sku_attribute_id);


--
-- Name: concept_skus concept_skus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_skus
    ADD CONSTRAINT concept_skus_pkey PRIMARY KEY (concept_sku_id);


--
-- Name: concepts concepts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY concepts
    ADD CONSTRAINT concepts_pkey PRIMARY KEY (concept_id);


--
-- Name: inbound_batches inbound_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_batches
    ADD CONSTRAINT inbound_batches_pkey PRIMARY KEY (inbound_batch_id);


--
-- Name: inbound_okl_product_revisions inbound_okl_product_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_product_revisions
    ADD CONSTRAINT inbound_okl_product_revisions_pkey PRIMARY KEY (id);


--
-- Name: inbound_okl_sku_attribute_revisions inbound_okl_sku_attribute_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_attribute_revisions
    ADD CONSTRAINT inbound_okl_sku_attribute_revisions_pkey PRIMARY KEY (id);


--
-- Name: inbound_okl_sku_dimensions_revisions inbound_okl_sku_dimensions_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_dimensions_revisions
    ADD CONSTRAINT inbound_okl_sku_dimensions_revisions_pkey PRIMARY KEY (id);


--
-- Name: inbound_okl_sku_image_revisions inbound_okl_sku_image_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_image_revisions
    ADD CONSTRAINT inbound_okl_sku_image_revisions_pkey PRIMARY KEY (id);


--
-- Name: inbound_okl_sku_revisions inbound_okl_sku_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_revisions
    ADD CONSTRAINT inbound_okl_sku_revisions_pkey PRIMARY KEY (id);


--
-- Name: inbound_okl_sku_shipping_revisions inbound_okl_sku_shipping_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_shipping_revisions
    ADD CONSTRAINT inbound_okl_sku_shipping_revisions_pkey PRIMARY KEY (id);


--
-- Name: inbound_okl_sku_state_revisions inbound_okl_sku_state_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_state_revisions
    ADD CONSTRAINT inbound_okl_sku_state_revisions_pkey PRIMARY KEY (id);


--
-- Name: product_memberships product_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_memberships
    ADD CONSTRAINT product_memberships_pkey PRIMARY KEY (product_membership_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: skus skus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY skus
    ADD CONSTRAINT skus_pkey PRIMARY KEY (sku_id);


--
-- Name: index_concept_brands_on_brand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concept_brands_on_brand_id ON concept_brands USING btree (brand_id);


--
-- Name: index_concept_brands_on_concept_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concept_brands_on_concept_id ON concept_brands USING btree (concept_id);


--
-- Name: index_concept_products_on_concept_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concept_products_on_concept_id ON concept_products USING btree (concept_id);


--
-- Name: index_concept_products_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concept_products_on_product_id ON concept_products USING btree (product_id);


--
-- Name: index_concept_sku_attributes_on_concept_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concept_sku_attributes_on_concept_id ON concept_sku_attributes USING btree (concept_id);


--
-- Name: index_concept_sku_attributes_on_concept_sku_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concept_sku_attributes_on_concept_sku_id ON concept_sku_attributes USING btree (concept_sku_id);


--
-- Name: index_concept_sku_attributes_on_sku_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concept_sku_attributes_on_sku_id ON concept_sku_attributes USING btree (sku_id);


--
-- Name: index_concept_skus_on_concept_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concept_skus_on_concept_id ON concept_skus USING btree (concept_id);


--
-- Name: index_concept_skus_on_sku_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concept_skus_on_sku_id ON concept_skus USING btree (sku_id);


--
-- Name: index_inbound_okl_product_revisions_on_inbound_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inbound_okl_product_revisions_on_inbound_batch_id ON inbound_okl_product_revisions USING btree (inbound_batch_id);


--
-- Name: index_inbound_okl_sku_attribute_revisions_on_inbound_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inbound_okl_sku_attribute_revisions_on_inbound_batch_id ON inbound_okl_sku_attribute_revisions USING btree (inbound_batch_id);


--
-- Name: index_inbound_okl_sku_dimensions_revisions_on_inbound_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inbound_okl_sku_dimensions_revisions_on_inbound_batch_id ON inbound_okl_sku_dimensions_revisions USING btree (inbound_batch_id);


--
-- Name: index_inbound_okl_sku_image_revisions_on_inbound_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inbound_okl_sku_image_revisions_on_inbound_batch_id ON inbound_okl_sku_image_revisions USING btree (inbound_batch_id);


--
-- Name: index_inbound_okl_sku_revisions_on_inbound_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inbound_okl_sku_revisions_on_inbound_batch_id ON inbound_okl_sku_revisions USING btree (inbound_batch_id);


--
-- Name: index_inbound_okl_sku_shipping_revisions_on_inbound_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inbound_okl_sku_shipping_revisions_on_inbound_batch_id ON inbound_okl_sku_shipping_revisions USING btree (inbound_batch_id);


--
-- Name: index_inbound_okl_sku_state_revisions_on_inbound_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inbound_okl_sku_state_revisions_on_inbound_batch_id ON inbound_okl_sku_state_revisions USING btree (inbound_batch_id);


--
-- Name: index_skus_on_gtin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_skus_on_gtin ON skus USING btree (gtin);


--
-- Name: product_memberships__idx_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX product_memberships__idx_product_id ON product_memberships USING btree (product_id);


--
-- Name: product_memberships__idx_product_id_sku_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX product_memberships__idx_product_id_sku_id ON product_memberships USING btree (product_id, sku_id);


--
-- Name: product_to_memberships__idx_sku_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX product_to_memberships__idx_sku_id ON product_memberships USING btree (sku_id);


--
-- Name: concept_brands concept_brands__fk_brand_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_brands
    ADD CONSTRAINT concept_brands__fk_brand_id FOREIGN KEY (brand_id) REFERENCES brands(brand_id);


--
-- Name: concept_brands concept_brands__fk_concept_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_brands
    ADD CONSTRAINT concept_brands__fk_concept_id FOREIGN KEY (concept_id) REFERENCES concepts(concept_id);


--
-- Name: concept_products concept_products__fk_concept_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_products
    ADD CONSTRAINT concept_products__fk_concept_id FOREIGN KEY (concept_id) REFERENCES concepts(concept_id);


--
-- Name: concept_products concept_products__fk_product_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_products
    ADD CONSTRAINT concept_products__fk_product_id FOREIGN KEY (product_id) REFERENCES products(product_id);


--
-- Name: concept_skus concept_skus__fk_concept_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_skus
    ADD CONSTRAINT concept_skus__fk_concept_id FOREIGN KEY (concept_id) REFERENCES concepts(concept_id);


--
-- Name: concept_skus concept_skus__fk_sku_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_skus
    ADD CONSTRAINT concept_skus__fk_sku_id FOREIGN KEY (sku_id) REFERENCES skus(sku_id);


--
-- Name: concept_sku_attributes csku_attributes__fk_concept_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_sku_attributes
    ADD CONSTRAINT csku_attributes__fk_concept_id FOREIGN KEY (concept_id) REFERENCES concepts(concept_id);


--
-- Name: concept_sku_attributes csku_attributes__fk_concept_sku_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_sku_attributes
    ADD CONSTRAINT csku_attributes__fk_concept_sku_id FOREIGN KEY (concept_sku_id) REFERENCES concept_skus(concept_sku_id);


--
-- Name: concept_sku_attributes csku_attributes__fk_sku_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY concept_sku_attributes
    ADD CONSTRAINT csku_attributes__fk_sku_id FOREIGN KEY (sku_id) REFERENCES skus(sku_id);


--
-- Name: inbound_okl_sku_revisions inb_okl_sku_rvn__fk_inbound_batch_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_revisions
    ADD CONSTRAINT inb_okl_sku_rvn__fk_inbound_batch_id FOREIGN KEY (inbound_batch_id) REFERENCES inbound_batches(inbound_batch_id);


--
-- Name: inbound_okl_sku_shipping_revisions inb_okl_sku_rvn__fk_inbound_batch_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_shipping_revisions
    ADD CONSTRAINT inb_okl_sku_rvn__fk_inbound_batch_id FOREIGN KEY (inbound_batch_id) REFERENCES inbound_batches(inbound_batch_id);


--
-- Name: inbound_okl_sku_dimensions_revisions inb_okl_sku_rvn__fk_inbound_batch_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_dimensions_revisions
    ADD CONSTRAINT inb_okl_sku_rvn__fk_inbound_batch_id FOREIGN KEY (inbound_batch_id) REFERENCES inbound_batches(inbound_batch_id);


--
-- Name: inbound_okl_sku_state_revisions inb_okl_sku_rvn__fk_inbound_batch_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_state_revisions
    ADD CONSTRAINT inb_okl_sku_rvn__fk_inbound_batch_id FOREIGN KEY (inbound_batch_id) REFERENCES inbound_batches(inbound_batch_id);


--
-- Name: inbound_okl_sku_attribute_revisions inb_okl_sku_rvn__fk_inbound_batch_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_attribute_revisions
    ADD CONSTRAINT inb_okl_sku_rvn__fk_inbound_batch_id FOREIGN KEY (inbound_batch_id) REFERENCES inbound_batches(inbound_batch_id);


--
-- Name: inbound_okl_sku_image_revisions inb_okl_sku_rvn__fk_inbound_batch_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_sku_image_revisions
    ADD CONSTRAINT inb_okl_sku_rvn__fk_inbound_batch_id FOREIGN KEY (inbound_batch_id) REFERENCES inbound_batches(inbound_batch_id);


--
-- Name: inbound_okl_product_revisions inb_okl_sku_rvn__fk_inbound_batch_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_okl_product_revisions
    ADD CONSTRAINT inb_okl_sku_rvn__fk_inbound_batch_id FOREIGN KEY (inbound_batch_id) REFERENCES inbound_batches(inbound_batch_id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20170818211750'),
('20170818231646'),
('20170818231757'),
('20170821204421'),
('20170821204944'),
('20170821235948'),
('20170822000122'),
('20170823172949'),
('20170825201307'),
('20170914170447'),
('20170914175801'),
('20170914175802'),
('20170914175803'),
('20170914175804'),
('20170914175805'),
('20170914175806'),
('20170914175901');


