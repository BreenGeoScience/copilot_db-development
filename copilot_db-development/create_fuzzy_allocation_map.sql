CREATE TABLE IF NOT EXISTS acc.fuzzy_allocation_map (
    id SERIAL PRIMARY KEY,
    keyword TEXT NOT NULL,           -- e.g. 'HYATT', 'SHELL', 'PANERA'
    category TEXT NOT NULL,          -- e.g. 'lodging', 'fuel', 'meals'
    gl_account_code TEXT NOT NULL,   -- e.g. 'bgm:proj exp:lodging'
    active BOOLEAN DEFAULT TRUE
);
