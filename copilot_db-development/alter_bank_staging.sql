-- Add category column if missing (ideally before gl_account_code, see note below)
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

-- Add mod_fuzzy column after gl_account_code if missing.
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

-- Note: To physically reorder columns in Postgres you must recreate the table.
-- Column order does not affect scripts or queries.

