CREATE TABLE acc.bank_account (
    id               SERIAL PRIMARY KEY,
    code             VARCHAR(100) UNIQUE NOT NULL,
    institution      VARCHAR(100) NOT NULL,
    account_number   VARCHAR(50),
    account_name     VARCHAR(100),
    account_type     VARCHAR(50),
    property_code    VARCHAR(100),
    gl_account_code  VARCHAR(200),
    open_date        DATE,
    close_date       DATE,
    status           VARCHAR(20) DEFAULT 'active',
    notes            TEXT,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
