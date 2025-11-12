import psycopg2
from psycopg2 import sql

def get_connection():
    return psycopg2.connect(
        host="192.168.30.180",
        port=5432,
        dbname="copilot_db",
        user="frank"
    )

def search_gl_accounts(conn):
    val = input("\nSearch accounts by code, major, sub, description (% SQL wildcard allowed): ").strip()
    rows = []
    if val:
        with conn.cursor() as cur:
            q = sql.SQL("""
                SELECT code, description
                FROM acc.gl_accounts
                WHERE code ILIKE %s OR description ILIKE %s
                ORDER BY code
                LIMIT 30
            """)
            v = f"%{val}%"
            cur.execute(q, (v, v))
            rows = cur.fetchall()
        if rows:
            print("\nAccounts found:")
            print("-" * 70)
            print("{:<32} {:<34}".format("Code", "Description"))
            print("-" * 70)
            for r in rows:
                print("{:<32} {:<34}".format(r[0], r[1] or ""))
            print("-" * 70)
        else:
            print("No results.")
    else:
        print("No search text entered.")

def show_allocations(conn, gl_code):
    with conn.cursor() as cur:
        cur.execute("""
            SELECT entity, proportion
            FROM acc.gl_account_allocations
            WHERE gl_account_code = %s
            ORDER BY entity
        """, (gl_code,))
        rows = cur.fetchall()
    if not rows:
        print("No allocations currently set for this account.")
    else:
        print("\nCurrent Allocations for", gl_code)
        total = sum(r[1] for r in rows)
        for ent, prop in rows:
            print(f"  - {ent:10}: {prop:.4f}")
        print(f"  Total:    {total:.4f}")
        if abs(total - 1.0) > 0.0001:
            print("  WARNING: ** DOES NOT SUM TO 1.0 **")

def input_allocations():
    allocations = []
    print("Enter entity and percentage allocations. Leave entity blank to finish.")
    while True:
        entity = input("  Entity/major (required, blank to finish): ").strip()
        if not entity:
            break
        while True:
            prop = input(f"  Proportion for {entity} (as decimal, e.g. 0.25): ").strip()
            try:
                if prop == "":
                    break
                prop_val = float(prop)
                if not (0 <= prop_val <= 1):
                    print("    Value must be between 0 and 1.")
                    continue
            except ValueError:
                print("    Invalid number.")
                continue
            allocations.append((entity, prop_val))
            break
    return allocations

def save_allocations(conn, gl_code, allocations):
    with conn.cursor() as cur:
        # Remove current allocations
        cur.execute("DELETE FROM acc.gl_account_allocations WHERE gl_account_code = %s", (gl_code,))
        for entity, prop in allocations:
            cur.execute(
                "INSERT INTO acc.gl_account_allocations (gl_account_code, entity, proportion) VALUES (%s, %s, %s)",
                (gl_code, entity, prop)
            )
    conn.commit()
    print("Allocations saved.")

def main():
    print("=== Enter GL Account Allocations ===")
    try:
        conn = get_connection()
    except Exception as e:
        print(f"Could not connect to database: {e}")
        return
    try:
        while True:
            print("\nOptions: [S]earch, [E]nter allocations, [Q]uit")
            act = input("Action [S/e/q]: ").strip().lower()
            if act in ("s", ""):
                search_gl_accounts(conn)
            elif act == "e":
                gl_code = input("Enter the GL account code for allocations: ").strip()
                if not gl_code:
                    print("No GL code entered.")
                    continue
                show_allocations(conn, gl_code)
                allocations = input_allocations()
                if allocations:
                    tot = sum(x[1] for x in allocations)
                    print(f"  Total entered = {tot:.4f}")
                    if abs(tot - 1.0) > 0.0001:
                        print("  WARNING: Allocations do not sum to 1.0, are you sure you want to save?")
                        if input("  Save anyway? (y/N): ").strip().lower() != "y":
                            print("  Not saved.")
                            continue
                    save_allocations(conn, gl_code, allocations)
                else:
                    print("No allocations entered.")
            elif act == "q":
                print("Goodbye.")
                break
            else:
                print("Invalid option.")
    finally:
        conn.close()

if __name__ == "__main__":
    main()
