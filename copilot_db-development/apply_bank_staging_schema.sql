-- Remove source_category if it exists
ALTER TABLE acc.bank_staging DROP COLUMN IF EXISTS source_category;

-- Ensure 'category' column exists (no effect if already present)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='acc'
          AND table_name='bank_staging'
          AND column_name='category'
    ) THEN
        ALTER TABLE acc.bank_staging ADD COLUMN category text;
    END IF;
END
$$;

-- Ensure 'mod_fuzzy' column exists (as TEXT)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='acc'
          AND table_name='bank_staging'
          AND column_name='mod_fuzzy'
    ) THEN
        ALTER TABLE acc.bank_staging ADD COLUMN mod_fuzzy text;
    END IF;
END
$$;
