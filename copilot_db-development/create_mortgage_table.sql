CREATE TABLE IF NOT EXISTS acc.mortgages (
    id SERIAL PRIMARY KEY,
    gl_account_code TEXT NOT NULL,         
    property_label TEXT NOT NULL,          
    issued_on DATE NOT NULL,               
    original_balance NUMERIC(14, 2),       
    interest_rate NUMERIC(6, 3),           
    matures_on DATE,                       
    lender TEXT,                           
    notes TEXT,
    UNIQUE (gl_account_code)
);
