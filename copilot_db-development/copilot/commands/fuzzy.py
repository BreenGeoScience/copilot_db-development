import psycopg2

PG_HOST = "192.168.30.180"
PG_DB = "copilot_db"
PG_USER = "frank"
PG_PASS = "basalt63"

def get_fuzzy_map(cur):
    cur.execute("SELECT LOWER(keyword), gl_account_code, category FROM stage.fuzzy_allocation_map")
    return [(kw.strip(), acct, cat) for kw, acct, cat in cur.fetchall()]

def find_best_match(fuzzy_map, fields):
    for field in fields:
        if not field:
            continue
        lc_field = field.lower()
        for kw, acct, cat in fuzzy_map:
            if kw and kw in lc_field:
                return acct, kw, cat  # Return account, matched keyword, original category (may be None)
    return None, None, None

def update_gl_accounts():
    conn = psycopg2.connect(host=PG_HOST, dbname=PG_DB, user=PG_USER, password=PG_PASS)
    cur = conn.cursor()

    # === 1. Fuzzy-assign missing gl_account_code and category (to lowercase matched keyword) ===
    fuzzy_map = get_fuzzy_map(cur)
    cur.execute("SELECT id, description, category FROM stage.tier1_stage WHERE gl_account_code = 'TODO' AND (mod_fuzzy IS NULL OR mod_fuzzy = '')")
    rows = cur.fetchall()
    print(f"Scanning {len(rows)} transactions for fuzzy gl_account_code allocation...")
    for row in rows:
        rowid, description, category = row
        match_acct, match_kw, match_cat = find_best_match(fuzzy_map, [description, category])
        if match_acct and match_kw:
            # category: use mapped category if present, else the fuzzy keyword as lower
            category_update = match_cat if match_cat else match_kw.lower()
            cur.execute(
                "UPDATE stage.tier1_stage SET gl_account_code=%s, category=%s WHERE id=%s",
                (match_acct, category_update, rowid)
            )
            print(f"Updated id {rowid}: gl_account_code -> {match_acct}, category -> {category_update}")
    conn.commit()

    # === 2. Learn from manual (mod_fuzzy='1'), mark as consumed if inserted/updated ===
    cur.execute("SELECT id, description, category, gl_account_code FROM stage.tier1_stage WHERE mod_fuzzy = '1'")
    learn_rows = cur.fetchall()
    print(f"Processing {len(learn_rows)} manual mappings (mod_fuzzy='1'):")
    for row in learn_rows:
        rowid, description, category, gl_acc = row
        # Scan for new keywords in description & category
        mapped = False
        for field in [description, category]:
            if not field:
                continue
            test_keywords = [field.strip()]
            test_keywords += [w.strip(",.?!") for w in field.split() if len(w.strip(",.?!")) > 2]
            for kw in test_keywords:
                key_norm = kw.lower()
                # Check if mapping exists
                cur.execute("SELECT 1 FROM stage.fuzzy_allocation_map WHERE keyword=%s AND gl_account_code=%s", (key_norm, gl_acc))
                exists = cur.fetchone()
                if not exists and key_norm:
                    # Insert new mapping
                    cur.execute(
                        "INSERT INTO stage.fuzzy_allocation_map (keyword, gl_account_code, category) VALUES (%s, %s, %s) ON CONFLICT DO NOTHING",
                        (key_norm, gl_acc, category.lower() if category else key_norm)
                    )
                    mapped = True
                    print(f"Learned: '{key_norm}' -> '{gl_acc}', category -> '{category.lower() if category else key_norm}' from row {rowid}")
                    break  # Only add one mapping per manual row
                elif exists and key_norm:
                    # Optional: Update category if needed
                    cur.execute(
                        "UPDATE stage.fuzzy_allocation_map SET category=%s WHERE keyword=%s AND gl_account_code=%s",
                        (category.lower() if category else key_norm, key_norm, gl_acc)
                    )
                    mapped = True
                    print(f"Updated category for: '{key_norm}' -> '{gl_acc}' to '{category.lower() if category else key_norm}' from row {rowid}")
                    break
            if mapped:
                cur.execute("UPDATE stage.tier1_stage SET mod_fuzzy = NULL WHERE id = %s", (rowid,))
                break    # Only unset mod_fuzzy if we mapped

    conn.commit()
    cur.close()
    conn.close()
    print("Fuzzy allocation complete. All applicable mod_fuzzy flags cleared.")

if __name__ == "__main__":
    update_gl_accounts()
