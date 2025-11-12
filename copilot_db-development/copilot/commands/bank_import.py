import csv
import psycopg2
from datetime import datetime

PG_HOST = "192.168.30.180"
PG_DB = "copilot_db"
PG_USER = "frank"
PG_PASS = "basalt63"
PG_SCHEMA = "stage"
TABLE = "tier1_stage"

def prompt(msg, default=None):
    if default:
        resp = input(f"{msg} [{default}]: ")
        return resp.strip() or default
    else:
        return input(f"{msg}: ").strip()

def parse_date(date_str):
    for fmt in ("%Y-%m-%d", "%m/%d/%Y", "%m/%d/%y", "%d-%b-%Y"):
        try:
            return datetime.strptime(date_str, fmt).date()
        except Exception:
            continue
    return None

def main():
    print("=== Bank Data Import Utility ===")
    csv_file = prompt("Enter path to bank CSV file")
    has_headers = prompt("Does the CSV have column headers? (yes/no)", "yes").lower().startswith('y')
    src_institution = prompt("Source institution (e.g., Huntington, Central Savings)").strip()
    src_account_code = prompt("Source account code").strip()
    default_entity = prompt("Entity (leave blank for NULL)", "")
    default_tags = prompt("Tags (comma-separated, optional)", "")

    insert_sql = f"""
        INSERT INTO {PG_SCHEMA}.{TABLE} (
            source_institution, source_account_code, raw_date, normalized_date, description, amount, direction,
            entity, tags, status, category, gl_account_code, mod_fuzzy
        )
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """

    with psycopg2.connect(host=PG_HOST, dbname=PG_DB, user=PG_USER, password=PG_PASS) as conn:
        with conn.cursor() as cur:
            with open(csv_file, newline='', encoding='utf-8-sig') as f:
                reader = csv.reader(f)
                if has_headers:
                    headers = [h.lower().strip() for h in next(reader)]
                else:
                    headers = ["date", "description", "debit", "credit"]
                    f.seek(0)
                    reader = csv.reader(f)
                count = 0
                for row in reader:
                    if not row or all(not x.strip() for x in row):
                        continue
                    rowdict = dict(zip(headers, row))
                    raw_date = rowdict.get("date", rowdict.get("txn_date", "")).strip()
                    norm_date = parse_date(raw_date)
                    description = rowdict.get("description", "").strip()
                    category = rowdict.get("category", "").strip() if "category" in headers else None
                    amt = rowdict.get("amount")
                    if amt is None:
                        debit = rowdict.get("debit")
                        credit = rowdict.get("credit")
                        if credit and credit.strip():
                            amt = credit.replace(",", "")
                        elif debit and debit.strip():
                            amt = "-" + debit.replace(",", "")
                        else:
                            amt = None
                    amt_val = float(amt.replace("$", "").replace(",", "")) if amt and amt.strip() else None
                    entry_direction = "credit" if amt_val and amt_val > 0 else "debit" if amt_val is not None else None
                    cur.execute(insert_sql, (
                        src_institution,
                        src_account_code,
                        raw_date,
                        norm_date,
                        description,
                        amt_val,
                        entry_direction,
                        default_entity if default_entity else None,
                        default_tags if default_tags else None,
                        "imported",
                        category,
                        "TODO",         # Always set to 'TODO'
                        None            # mod_fuzzy starts as NULL
                    ))
                    count += 1
                conn.commit()
                print(f"Imported {count} transactions into acc.bank_staging.")

if __name__ == "__main__":
    main()
