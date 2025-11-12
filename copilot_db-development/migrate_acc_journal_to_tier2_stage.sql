-- One-time migration from acc.journal to stage.tier2_stage
INSERT INTO stage.tier2_stage (
    entry_date, gl_account_code, debit, credit, line_description, entity, status, created_at, updated_at, operator, memo
)
SELECT
    entry_date,
    gl_account_code,
    debit,
    credit,
    line_description,
    entity,
    'imported',
    now(),
    now(),
    'migration',
    'migrated from acc.journal'
FROM acc.journal;
