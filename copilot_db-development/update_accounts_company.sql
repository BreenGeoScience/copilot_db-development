ALTER TABLE acc.accounts ADD COLUMN IF NOT EXISTS company text;

UPDATE acc.accounts SET company = 'bgs' WHERE code IN ('bgm', 'debit');
UPDATE acc.accounts SET company = 'mhb' WHERE code IN ('mhb', '711pine', '905brown', '819helen');
UPDATE acc.accounts SET company = 'personal' WHERE code IN ('csb', 'parnell', 'medical', 'tax');
