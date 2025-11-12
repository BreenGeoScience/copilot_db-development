DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'acc'
          AND table_name = 'account'
          AND column_name = 'company'
    ) THEN
        ALTER TABLE acc.account ADD COLUMN company text;
    END IF;
END
$$;
