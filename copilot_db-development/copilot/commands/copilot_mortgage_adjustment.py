#!/usr/bin/env python3

import psycopg2
from datetime import datetime
import getpass

def get_input(prompt, cast=str, required=True):
    while True:
        val = input(prompt)
        if not val and not required:
            return None
        try:
            return cast(val)
        except Exception:
            print(f"Invalid input. Expected {cast.__name__}.")

def main():
    print("Manual Mortgage Adjustment Entry (to stage.tier2_stage)")
    db_params = {
        'database': 'copilot_db',
        'user': 'frank',
        'host': '192.168.30.180'
    }

    operator = getpass.getuser()
    entry_date = get_input("Entry date (YYYY-MM-DD): ", str)
    entity = get_input("Entity: ", str)
    adj_gl_account = get_input("Adjustment GL account code: ", str)
    contra_gl_account = get_input("Contra GL account code: ", str)
    amount = get_input("Adjustment amount: ", float)
    is_credit = get_input("Is this a credit adjustment? (y/n): ", str).lower().startswith('y')
    line_description = get_input("Memo/description: ", str, required=False) or f"Mortgage adjustment {entry_date}"

    with psycopg2.connect(**db_params) as conn:
        with conn.cursor() as cur:
            now = datetime.now()
            if is_credit:
                # Credit adjustment to adj_gl_account, debit to contra (e.g., overpayment)
                credit_amt = amount
                debit_amt = amount
                # Debit contra account
                cur.execute("""
                    INSERT INTO stage.tier2_stage (
                        tier1_stage_id, entry_date, gl_account_code, debit, credit,
                        line_description, entity, status, created_at, updated_at, operator, memo
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    None, entry_date, contra_gl_account, debit_amt, 0,
                    f"Mortgage adjustment (debit) - {line_description}", entity, 'manual',
                    now, now, operator, line_description
                ))
                # Credit adjustment account
                cur.execute("""
                    INSERT INTO stage.tier2_stage (
                        tier1_stage_id, entry_date, gl_account_code, debit, credit,
                        line_description, entity, status, created_at, updated_at, operator, memo
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    None, entry_date, adj_gl_account, 0, credit_amt,
                    f"Mortgage adjustment (credit) - {line_description}", entity, 'manual',
                    now, now, operator, line_description
                ))
            else:
                # Debit adjustment to adj_gl_account, credit to contra (e.g., underpayment)
                debit_amt = amount
                credit_amt = amount
                # Debit adjustment account
                cur.execute("""
                    INSERT INTO stage.tier2_stage (
                        tier1_stage_id, entry_date, gl_account_code, debit, credit,
                        line_description, entity, status, created_at, updated_at, operator, memo
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    None, entry_date, adj_gl_account, debit_amt, 0,
                    f"Mortgage adjustment (debit) - {line_description}", entity, 'manual',
                    now, now, operator, line_description
                ))
                # Credit contra account
                cur.execute("""
                    INSERT INTO stage.tier2_stage (
                        tier1_stage_id, entry_date, gl_account_code, debit, credit,
                        line_description, entity, status, created_at, updated_at, operator, memo
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    None, entry_date, contra_gl_account, 0, credit_amt,
                    f"Mortgage adjustment (credit) - {line_description}", entity, 'manual',
                    now, now, operator, line_description
                ))
            conn.commit()
    print("\nMortgage adjustment posted to stage.tier2_stage.")

if __name__ == "__main__":
    main()
