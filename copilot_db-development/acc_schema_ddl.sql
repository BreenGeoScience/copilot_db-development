--
-- PostgreSQL database dump
--

\restrict EElMpWHwA7c0YHs6NPFMbBOeeVieSnDVyJb2RAN1bDboaelvoxECFtguML8DldP

-- Dumped from database version 16.8
-- Dumped by pg_dump version 17.6

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
-- Name: acc; Type: SCHEMA; Schema: -; Owner: frank
--

CREATE SCHEMA acc;


ALTER SCHEMA acc OWNER TO frank;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bank_account; Type: TABLE; Schema: acc; Owner: frank
--

CREATE TABLE acc.bank_account (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(200) NOT NULL,
    account_type character varying(50) NOT NULL,
    institution character varying(200),
    account_number character varying(50),
    opening_balance numeric(12,2) DEFAULT 0,
    opening_date date,
    status character varying(20) DEFAULT 'active'::character varying,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE acc.bank_account OWNER TO frank;

--
-- Name: TABLE bank_account; Type: COMMENT; Schema: acc; Owner: frank
--

COMMENT ON TABLE acc.bank_account IS 'Bank accounts across all entities';


--
-- Name: bank_account_id_seq; Type: SEQUENCE; Schema: acc; Owner: frank
--

CREATE SEQUENCE acc.bank_account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE acc.bank_account_id_seq OWNER TO frank;

--
-- Name: bank_account_id_seq; Type: SEQUENCE OWNED BY; Schema: acc; Owner: frank
--

ALTER SEQUENCE acc.bank_account_id_seq OWNED BY acc.bank_account.id;


--
-- Name: category; Type: TABLE; Schema: acc; Owner: frank
--

CREATE TABLE acc.category (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(200) NOT NULL,
    parent_id integer,
    account_type character varying(50) NOT NULL,
    entity character varying(50),
    is_taxable boolean DEFAULT true,
    description text,
    sort_order integer,
    status character varying(20) DEFAULT 'active'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE acc.category OWNER TO frank;

--
-- Name: TABLE category; Type: COMMENT; Schema: acc; Owner: frank
--

COMMENT ON TABLE acc.category IS 'Chart of accounts - hierarchical category structure';


--
-- Name: category_id_seq; Type: SEQUENCE; Schema: acc; Owner: frank
--

CREATE SEQUENCE acc.category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE acc.category_id_seq OWNER TO frank;

--
-- Name: category_id_seq; Type: SEQUENCE OWNED BY; Schema: acc; Owner: frank
--

ALTER SEQUENCE acc.category_id_seq OWNED BY acc.category.id;


--
-- Name: import_log; Type: TABLE; Schema: acc; Owner: frank
--

CREATE TABLE acc.import_log (
    id integer NOT NULL,
    account_code character varying(50) NOT NULL,
    import_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    file_name character varying(500),
    file_hash character varying(64),
    records_imported integer,
    records_skipped integer,
    date_range_start date,
    date_range_end date,
    notes text
);


ALTER TABLE acc.import_log OWNER TO frank;

--
-- Name: TABLE import_log; Type: COMMENT; Schema: acc; Owner: frank
--

COMMENT ON TABLE acc.import_log IS 'Track bank statement imports to prevent duplicates';


--
-- Name: import_log_id_seq; Type: SEQUENCE; Schema: acc; Owner: frank
--

CREATE SEQUENCE acc.import_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE acc.import_log_id_seq OWNER TO frank;

--
-- Name: import_log_id_seq; Type: SEQUENCE OWNED BY; Schema: acc; Owner: frank
--

ALTER SEQUENCE acc.import_log_id_seq OWNED BY acc.import_log.id;


--
-- Name: payee_alias; Type: TABLE; Schema: acc; Owner: frank
--

CREATE TABLE acc.payee_alias (
    id integer NOT NULL,
    payee_pattern text NOT NULL,
    normalized_name character varying(200) NOT NULL,
    default_category_id integer,
    entity character varying(50),
    confidence integer DEFAULT 100,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE acc.payee_alias OWNER TO frank;

--
-- Name: TABLE payee_alias; Type: COMMENT; Schema: acc; Owner: frank
--

COMMENT ON TABLE acc.payee_alias IS 'Payee name patterns for auto-categorization';


--
-- Name: payee_alias_id_seq; Type: SEQUENCE; Schema: acc; Owner: frank
--

CREATE SEQUENCE acc.payee_alias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE acc.payee_alias_id_seq OWNER TO frank;

--
-- Name: payee_alias_id_seq; Type: SEQUENCE OWNED BY; Schema: acc; Owner: frank
--

ALTER SEQUENCE acc.payee_alias_id_seq OWNED BY acc.payee_alias.id;


--
-- Name: transaction; Type: TABLE; Schema: acc; Owner: frank
--

CREATE TABLE acc.transaction (
    id integer NOT NULL,
    account_code character varying(50) NOT NULL,
    trans_date date NOT NULL,
    post_date date,
    payee text,
    memo text,
    amount numeric(12,2) NOT NULL,
    category_id integer,
    allocation character varying(500),
    entity character varying(50),
    project_code character varying(50),
    invoice_code character varying(100),
    property_code character varying(50),
    reconciled boolean DEFAULT false,
    source character varying(50) DEFAULT 'manual'::character varying,
    import_id character varying(200),
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE acc.transaction OWNER TO frank;

--
-- Name: TABLE transaction; Type: COMMENT; Schema: acc; Owner: frank
--

COMMENT ON TABLE acc.transaction IS 'All bank transactions across all accounts';


--
-- Name: COLUMN transaction.amount; Type: COMMENT; Schema: acc; Owner: frank
--

COMMENT ON COLUMN acc.transaction.amount IS 'Positive = income/deposit, Negative = expense/payment';


--
-- Name: COLUMN transaction.allocation; Type: COMMENT; Schema: acc; Owner: frank
--

COMMENT ON COLUMN acc.transaction.allocation IS 'Legacy allocation string from old system';


--
-- Name: COLUMN transaction.project_code; Type: COMMENT; Schema: acc; Owner: frank
--

COMMENT ON COLUMN acc.transaction.project_code IS 'Format: CLIENT.YY.PROJNO (e.g., tbls.25.1904)';


--
-- Name: COLUMN transaction.invoice_code; Type: COMMENT; Schema: acc; Owner: frank
--

COMMENT ON COLUMN acc.transaction.invoice_code IS 'Format: CLIENT.YY.PROJNO.INVNO (e.g., tbls.25.1904.0001)';


--
-- Name: transaction_id_seq; Type: SEQUENCE; Schema: acc; Owner: frank
--

CREATE SEQUENCE acc.transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE acc.transaction_id_seq OWNER TO frank;

--
-- Name: transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: acc; Owner: frank
--

ALTER SEQUENCE acc.transaction_id_seq OWNED BY acc.transaction.id;


--
-- Name: vw_account_balance; Type: VIEW; Schema: acc; Owner: frank
--

CREATE VIEW acc.vw_account_balance AS
 SELECT ba.code,
    ba.name,
    ba.account_type,
    ba.opening_balance,
    COALESCE(sum(t.amount), (0)::numeric) AS total_transactions,
    (ba.opening_balance + COALESCE(sum(t.amount), (0)::numeric)) AS current_balance,
    max(t.trans_date) AS last_transaction_date
   FROM (acc.bank_account ba
     LEFT JOIN acc.transaction t ON (((t.account_code)::text = (ba.code)::text)))
  WHERE ((ba.status)::text = 'active'::text)
  GROUP BY ba.code, ba.name, ba.account_type, ba.opening_balance
  ORDER BY ba.code;


ALTER VIEW acc.vw_account_balance OWNER TO frank;

--
-- Name: vw_monthly_summary; Type: VIEW; Schema: acc; Owner: frank
--

CREATE VIEW acc.vw_monthly_summary AS
 SELECT (date_trunc('month'::text, (t.trans_date)::timestamp with time zone))::date AS month,
    c.name AS category,
    c.account_type,
    t.entity,
    count(*) AS transaction_count,
    sum(t.amount) AS total_amount
   FROM (acc.transaction t
     LEFT JOIN acc.category c ON ((c.id = t.category_id)))
  GROUP BY (date_trunc('month'::text, (t.trans_date)::timestamp with time zone)), c.name, c.account_type, t.entity
  ORDER BY ((date_trunc('month'::text, (t.trans_date)::timestamp with time zone))::date) DESC, (sum(t.amount)) DESC;


ALTER VIEW acc.vw_monthly_summary OWNER TO frank;

--
-- Name: vw_uncategorized; Type: VIEW; Schema: acc; Owner: frank
--

CREATE VIEW acc.vw_uncategorized AS
 SELECT id,
    account_code,
    trans_date,
    payee,
    amount,
    memo,
    allocation
   FROM acc.transaction
  WHERE ((category_id IS NULL) AND (reconciled = false))
  ORDER BY trans_date DESC;


ALTER VIEW acc.vw_uncategorized OWNER TO frank;

--
-- Name: bank_account id; Type: DEFAULT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.bank_account ALTER COLUMN id SET DEFAULT nextval('acc.bank_account_id_seq'::regclass);


--
-- Name: category id; Type: DEFAULT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.category ALTER COLUMN id SET DEFAULT nextval('acc.category_id_seq'::regclass);


--
-- Name: import_log id; Type: DEFAULT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.import_log ALTER COLUMN id SET DEFAULT nextval('acc.import_log_id_seq'::regclass);


--
-- Name: payee_alias id; Type: DEFAULT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.payee_alias ALTER COLUMN id SET DEFAULT nextval('acc.payee_alias_id_seq'::regclass);


--
-- Name: transaction id; Type: DEFAULT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.transaction ALTER COLUMN id SET DEFAULT nextval('acc.transaction_id_seq'::regclass);


--
-- Name: bank_account bank_account_code_key; Type: CONSTRAINT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.bank_account
    ADD CONSTRAINT bank_account_code_key UNIQUE (code);


--
-- Name: bank_account bank_account_pkey; Type: CONSTRAINT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.bank_account
    ADD CONSTRAINT bank_account_pkey PRIMARY KEY (id);


--
-- Name: category category_code_key; Type: CONSTRAINT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.category
    ADD CONSTRAINT category_code_key UNIQUE (code);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: import_log import_log_pkey; Type: CONSTRAINT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.import_log
    ADD CONSTRAINT import_log_pkey PRIMARY KEY (id);


--
-- Name: payee_alias payee_alias_pkey; Type: CONSTRAINT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.payee_alias
    ADD CONSTRAINT payee_alias_pkey PRIMARY KEY (id);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (id);


--
-- Name: idx_category_entity; Type: INDEX; Schema: acc; Owner: frank
--

CREATE INDEX idx_category_entity ON acc.category USING btree (entity);


--
-- Name: idx_category_parent; Type: INDEX; Schema: acc; Owner: frank
--

CREATE INDEX idx_category_parent ON acc.category USING btree (parent_id);


--
-- Name: idx_category_type; Type: INDEX; Schema: acc; Owner: frank
--

CREATE INDEX idx_category_type ON acc.category USING btree (account_type);


--
-- Name: idx_import_hash; Type: INDEX; Schema: acc; Owner: frank
--

CREATE INDEX idx_import_hash ON acc.import_log USING btree (file_hash);


--
-- Name: idx_payee_pattern; Type: INDEX; Schema: acc; Owner: frank
--

CREATE INDEX idx_payee_pattern ON acc.payee_alias USING btree (payee_pattern);


--
-- Name: idx_trans_account; Type: INDEX; Schema: acc; Owner: frank
--

CREATE INDEX idx_trans_account ON acc.transaction USING btree (account_code);


--
-- Name: idx_trans_category; Type: INDEX; Schema: acc; Owner: frank
--

CREATE INDEX idx_trans_category ON acc.transaction USING btree (category_id);


--
-- Name: idx_trans_date; Type: INDEX; Schema: acc; Owner: frank
--

CREATE INDEX idx_trans_date ON acc.transaction USING btree (trans_date);


--
-- Name: idx_trans_entity; Type: INDEX; Schema: acc; Owner: frank
--

CREATE INDEX idx_trans_entity ON acc.transaction USING btree (entity);


--
-- Name: idx_trans_import; Type: INDEX; Schema: acc; Owner: frank
--

CREATE INDEX idx_trans_import ON acc.transaction USING btree (import_id);


--
-- Name: idx_trans_invoice; Type: INDEX; Schema: acc; Owner: frank
--

CREATE INDEX idx_trans_invoice ON acc.transaction USING btree (invoice_code);


--
-- Name: idx_trans_project; Type: INDEX; Schema: acc; Owner: frank
--

CREATE INDEX idx_trans_project ON acc.transaction USING btree (project_code);


--
-- Name: idx_trans_reconciled; Type: INDEX; Schema: acc; Owner: frank
--

CREATE INDEX idx_trans_reconciled ON acc.transaction USING btree (reconciled);


--
-- Name: category category_parent_id_fkey; Type: FK CONSTRAINT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.category
    ADD CONSTRAINT category_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES acc.category(id);


--
-- Name: import_log import_log_account_code_fkey; Type: FK CONSTRAINT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.import_log
    ADD CONSTRAINT import_log_account_code_fkey FOREIGN KEY (account_code) REFERENCES acc.bank_account(code);


--
-- Name: payee_alias payee_alias_default_category_id_fkey; Type: FK CONSTRAINT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.payee_alias
    ADD CONSTRAINT payee_alias_default_category_id_fkey FOREIGN KEY (default_category_id) REFERENCES acc.category(id);


--
-- Name: transaction transaction_account_code_fkey; Type: FK CONSTRAINT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.transaction
    ADD CONSTRAINT transaction_account_code_fkey FOREIGN KEY (account_code) REFERENCES acc.bank_account(code);


--
-- Name: transaction transaction_category_id_fkey; Type: FK CONSTRAINT; Schema: acc; Owner: frank
--

ALTER TABLE ONLY acc.transaction
    ADD CONSTRAINT transaction_category_id_fkey FOREIGN KEY (category_id) REFERENCES acc.category(id);


--
-- PostgreSQL database dump complete
--

\unrestrict EElMpWHwA7c0YHs6NPFMbBOeeVieSnDVyJb2RAN1bDboaelvoxECFtguML8DldP

