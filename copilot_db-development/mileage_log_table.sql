CREATE TABLE IF NOT EXISTS acc.mileage_log (
    id SERIAL PRIMARY KEY,
    vehicle TEXT NOT NULL,
    log_date DATE NOT NULL,
    start_odometer NUMERIC,
    end_odometer NUMERIC,
    miles NUMERIC NOT NULL,
    origin TEXT,
    destination TEXT,
    business_purpose TEXT NOT NULL,
    timesheet_id INTEGER REFERENCES bgs.timesheet(id),
    invoice_code VARCHAR(100) REFERENCES bgs.invoice(invoice_code),
    transaction_id INTEGER REFERENCES acc.transactions(id),
    client_name TEXT,
    entity TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
