CREATE TABLE acc.bank_staging (
    id serial PRIMARY KEY,
    source_institution text,
    source_account_code text,
    normalized_date date,
    description text,
    amount numeric,
    direction text,
    category text,
    gl_account_code text,
    mod_fuzzy text,
    entity text,
    tags text,
    status text,
    raw_date text
);
