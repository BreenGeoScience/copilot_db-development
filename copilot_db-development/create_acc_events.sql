CREATE TABLE IF NOT EXISTS acc.events (
    id SERIAL PRIMARY KEY,
    major TEXT NOT NULL,                -- bgm, mhb, per, etc.
    event_type TEXT NOT NULL,           -- e.g., project, vacation, trip
    gl_account_code TEXT,               -- Default GL code for this event
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    ref_code TEXT,                      -- Project code, client code, etc.
    event_city TEXT,                    -- For matching location in descriptions
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
