-- Create schema
CREATE SCHEMA IF NOT EXISTS stage;

-- Create tier1_stage table (structure mirrors acc.bank_stage, with metadata columns & surrogate PK)
CREATE TABLE IF NOT EXISTS stage.tier1_stage (
    id SERIAL PRIMARY KEY,
    source_identifier TEXT,
    -- (columns copied from acc.bank_stage, adjust types accordingly)
    txn_date DATE,
    amount NUMERIC(16,4),
    description TEXT,
    -- Add further transactional columns as needed

    -- Metadata columns
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    operator TEXT,
    memo TEXT
);

-- Create tier2_stage table (double-entry, references tier1_stage.id, with audit columns)
CREATE TABLE IF NOT EXISTS stage.tier2_stage (
    id SERIAL PRIMARY KEY,
    tier1_stage_id INTEGER REFERENCES stage.tier1_stage(id) ON DELETE SET NULL,
    entry_date DATE,
    gl_account_code TEXT,
    debit NUMERIC(16,4) DEFAULT 0,
    credit NUMERIC(16,4) DEFAULT 0,
    line_description TEXT,
    entity TEXT,
    -- Metadata columns
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    operator TEXT,
    memo TEXT
);

-- Create tier3_stage table (final review stage, mirrors tier2_stage with audit trail)
CREATE TABLE IF NOT EXISTS stage.tier3_stage (
    id SERIAL PRIMARY KEY,
    tier2_stage_id INTEGER REFERENCES stage.tier2_stage(id) ON DELETE SET NULL,
    entry_date DATE,
    gl_account_code TEXT,
    debit NUMERIC(16,4) DEFAULT 0,
    credit NUMERIC(16,4) DEFAULT 0,
    line_description TEXT,
    entity TEXT,
    -- Metadata columns
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    operator TEXT,
    memo TEXT
);

-- Permissions: restrict insert/update/delete to specific roles only
REVOKE ALL ON ALL TABLES IN SCHEMA stage FROM public;
GRANT SELECT ON ALL TABLES IN SCHEMA stage TO readonly_role;
GRANT INSERT, UPDATE, DELETE, SELECT ON ALL TABLES IN SCHEMA stage TO stage_processor_role;
