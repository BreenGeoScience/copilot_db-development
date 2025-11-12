CREATE TABLE IF NOT EXISTS acc.bank_staging (
    id SERIAL PRIMARY KEY,
    source_institution TEXT,      -- e.g., Huntington or Central Savings Bank
    source_account_code TEXT,     -- e.g., 'bgm:account'
    raw_date TEXT,
    normalized_date DATE,
    description TEXT,
    source_category TEXT,
    amount NUMERIC(12,2),
    direction TEXT,
    raw_split TEXT,
    tags TEXT,
    entity TEXT,
    gl_account_code TEXT,
    category TEXT,
    notes TEXT,
    status TEXT DEFAULT 'imported',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
