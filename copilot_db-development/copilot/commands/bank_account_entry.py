import psycopg2
import getpass
import datetime

def get_connection():
    host = input("Postgres host [localhost]: ") or "localhost"
    port = input("Port [5432]: ") or 5432
    dbname = input("Database name [copilot_db]: ") or "copilot_db"
    user = input("Username [frank]: ") or "frank"
    password = getpass.getpass("Password: ")
    return psycopg2.connect(
        host=host,
        port=port,
        dbname=dbname,
        user=user,
        password=password
    )

def prompt_account():
    print("\nEnter bank/mortgage/investment account info (leave blank to cancel entry).")
    code = input("System code (e.g. 'chase:oper', 'flagstar:mortgage:711pine') : ").strip()
    if not code:
        return None
    institution = input("Institution (e.g. 'Chase', 'Vanguard') : ").strip()
    account_number = input("Account # (last 4 or masked) : ").strip()
    account_name = input("Account name/label : ").strip()
    account_type = input("Type (checking, savings, mortgage, ira, roth, brokerage, medical, tax, etc): ").strip()
    property_code = input("Property/unit code (if applicable) : ").strip() or None
    gl_account_code = input("GL account code (link to acc.gl_account.code) : ").strip() or None
    open_date = input("Open date [YYYY-MM-DD] (blank for today) : ").strip()
    if not open_date:
        open_date = datetime.date.today().isoformat()
    close_date = input("Close date [YYYY-MM-DD, blank if active] : ").strip() or None
    status = input("Status [active]: ").strip() or "active"
    notes = input("Notes/description : ").strip() or None
    return {
        'code': code,
        'institution': institution,
        'account_number': account_number,
        'account_name': account_name,
        'account_type': account_type,
        'property_code': property_code,
        'gl_account_code': gl_account_code,
        'open_date': open_date,
        'close_date': close_date,
        'status': status,
        'notes': notes
    }

def insert_account(conn, account):
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO acc.bank_account
            (code, institution, account_number, account_name, account_type, property_code, gl_account_code, open_date, close_date, status, notes)
            VALUES (%(code)s, %(institution)s, %(account_number)s, %(account_name)s, %(account_type)s, %(property_code)s, %(gl_account_code)s, %(open_date)s, %(close_date)s, %(status)s, %(notes)s)
        """, account)
    conn.commit()
    print(f"Account {account['code']} saved.")

def main():
    print("=== Bank/Mortgage/Investment Account Entry ===")
    conn = get_connection()
    try:
        while True:
            account = prompt_account()
            if not account:
                print("Account entry canceled.")
                break
            try:
                insert_account(conn, account)
            except Exception as e:
                print(f"Error saving account: {e}")
            cont = input("Enter another account? [Y/n]: ").strip().lower()
            if cont not in ('', 'y', 'yes'):
                break
    finally:
        conn.close()
        print("Done. (Connection closed)")

if __name__ == "__main__":
    main()
