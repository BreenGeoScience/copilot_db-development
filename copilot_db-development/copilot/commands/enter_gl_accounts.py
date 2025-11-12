import psycopg2
from psycopg2 import sql
import datetime

def get_connection():
    return psycopg2.connect(
        host="192.168.30.180",
        port=5432,
        dbname="copilot_db",
        user="frank"
    )

def like_search(conn):
    val = input("\nEnter search value for code, name, description, etc. (SQL LIKE, % for wildcard): ").strip()
    rows = []
    if val:
        with conn.cursor() as cur:
            q = sql.SQL("""
                SELECT code, major, sub, detail, description, account_type, tax_category, parent_code, status
                FROM acc.gl_accounts
                WHERE code ILIKE %s OR description ILIKE %s OR major ILIKE %s OR sub ILIKE %s OR detail ILIKE %s
                ORDER BY code
                LIMIT 30
            """)
            v = f"%{val}%"
            cur.execute(q, (v, v, v, v, v))
            rows = cur.fetchall()
        if rows:
            print("\nMatch results:")
            print("-" * 80)
            print("{:<32} {:<10} {:<16} {:<16} {:<24} {:<10} {:<8} {:<8}".format(
                "Code", "Major", "Sub", "Detail", "Desc", "Type", "Tax", "Status"
            ))
            print("-" * 80)
            for r in rows:
                print("{:<32} {:<10} {:<16} {:<16} {:<24} {:<10} {:<8} {:<8}".format(
                    r[0], r[1] or '', r[2] or '', r[3] or '', r[4] or '', r[5] or '', r[6] or '', r[8] or ''
                ))
            print("-" * 80)
        else:
            print("No results.")
    else:
        print("No search value entered.")

def prompt_gl_account():
    print("\nEnter new GL Account details (leave blank to skip entry).")
    code = input("Code (required, e.g. 'asset:cash'): ").strip()
    if not code:
        return None
    major = input("Major: ").strip() or None
    sub = input("Sub: ").strip() or None
    detail = input("Detail: ").strip() or None
    description = input("Description: ").strip() or None
    account_type = input("Account Type (asset, liability, income, etc.): ").strip() or None
    tax_category = input("Tax Category: ").strip() or None
    parent_code = input("Parent Code: ").strip() or None
    status = input("Status [active]: ").strip() or "active"
    return {
        'code': code,
        'major': major,
        'sub': sub,
        'detail': detail,
        'description': description,
        'account_type': account_type,
        'tax_category': tax_category,
        'parent_code': parent_code,
        'status': status
    }

def insert_gl_account(conn, acc):
    acc['created_at'] = datetime.datetime.now()
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO acc.gl_accounts
            (code, major, sub, detail, description, account_type, tax_category, parent_code, status, created_at)
            VALUES (%(code)s, %(major)s, %(sub)s, %(detail)s, %(description)s, %(account_type)s, %(tax_category)s, %(parent_code)s, %(status)s, %(created_at)s)
            ON CONFLICT (code) DO UPDATE SET
                major=EXCLUDED.major,
                sub=EXCLUDED.sub,
                detail=EXCLUDED.detail,
                description=EXCLUDED.description,
                account_type=EXCLUDED.account_type,
                tax_category=EXCLUDED.tax_category,
                parent_code=EXCLUDED.parent_code,
                status=EXCLUDED.status
        """, acc)
    conn.commit()
    print(f"GL Account '{acc['code']}' added/updated.")

def main():
    print("=== GL Account Entry ===")
    try:
        conn = get_connection()
    except Exception as e:
        print(f"Could not connect to database: {e}")
        return

    try:
        while True:
            print("\nOptions: [L]ike search, [N]ew GL account, [Q]uit")
            act = input("Action [L/n/q]: ").strip().lower()
            if act in ('l', ''):
                like_search(conn)
            elif act == 'n':
                acc = prompt_gl_account()
                if not acc:
                    print("Entry cancelled.")
                    continue
                try:
                    insert_gl_account(conn, acc)
                except Exception as e:
                    print(f"Error saving GL Account: {e}")
            elif act == 'q':
                print("Goodbye.")
                break
            else:
                print("Invalid option.")

    finally:
        conn.close()

if __name__ == "__main__":
    main()
