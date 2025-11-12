-- 1. Show affected accounts before update (for review):
SELECT code
FROM acc.gl_accounts
WHERE code NOT LIKE 'bgs:%'
  AND code NOT LIKE 'mhb:%'
  AND code NOT LIKE 'per:%';

-- 2. Update gl_accounts table codes:
UPDATE acc.gl_accounts
SET code = 'per:' || code
WHERE code NOT LIKE 'bgs:%'
  AND code NOT LIKE 'mhb:%'
  AND code NOT LIKE 'per:%';

-- 3. Update allocation table, if needed:
UPDATE acc.gl_account_allocations
SET gl_account_code = 'per:' || gl_account_code
WHERE gl_account_code NOT LIKE 'bgs:%'
  AND gl_account_code NOT LIKE 'mhb:%'
  AND gl_account_code NOT LIKE 'per:%';

-- 4. (Optional) Show after update:
SELECT code
FROM acc.gl_accounts
WHERE code LIKE 'per:%';
