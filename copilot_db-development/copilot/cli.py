"""Main CLI entry point for Copilot Accounting System"""
import click
import subprocess
from rich.console import Console
from copilot.commands import version, timesheet, new, edit, ar, invoice, client, project

console = Console()

def show_main_menu():
    while True:
        console.print("\n[bold]Copilot Accounting System[/bold]\n")
        options = [
            ("Enter time for BGS projects", lambda: timesheet()),
            ("Invoice management for BGS projects", lambda: invoice()),
            ("Edit existing BGS project - add tasks, etc.", lambda: edit()),
            ("Accounts Receivable aging report", lambda: ar()),
            ("Project management for BGS projects", lambda: project()),
            ("Import bank CSV transaction data for staging", lambda: subprocess.call(["python3", "copilot/commands/bank_import.py"])),
            ("Fuzzy-assign and learn gl_account_code for bank staging", lambda: subprocess.call(["python3", "copilot/commands/fuzzy.py"])),
            ("Enter a property mortgage payment (MHB)", lambda: subprocess.call(["python3", "copilot/commands/copilot_mortgage_payment"])),
            ("Mortgage adjustment entries", lambda: subprocess.call(["python3", "copilot/commands/copilot_mortgage_adjustment"])),
            ("Set up a new property mortgage (MHB)", lambda: subprocess.call(["python3", "copilot/commands/copilot_new_mortgage.py"])),
            ("Quit", lambda: exit(0)),
        ]
        for idx, (desc, _) in enumerate(options, 1):
            console.print(f"[green][{idx}][/green] {desc}")
        choice = input("\nSelect an option (number or q to quit): ").strip().lower()
        if choice == "q" or (choice.isdigit() and int(choice) == len(options)):
            console.print("Exiting Copilot.")
            exit(0)
        if choice.isdigit():
            idx = int(choice) - 1
            if 0 <= idx < len(options):
                try:
                    options[idx][1]()   # Run the selected action
                except Exception as e:
                    console.print(f"[bold red]Error:[/bold red] {e}")
            else:
                console.print("[red]Invalid option! Try again.[/red]")
        else:
            console.print("[red]Invalid input. Try again.[/red]")

@click.group(invoke_without_command=True)
@click.pass_context
def cli(ctx):
    if ctx.invoked_subcommand is None:
        show_main_menu()

cli.add_command(version)
cli.add_command(timesheet)
cli.add_command(new)
cli.add_command(edit)
cli.add_command(ar)
cli.add_command(invoice)
cli.add_command(client)
cli.add_command(project)

@cli.command('enter-accounts')
def enter_accounts():
    """Enter bank/mortgage/investment account info from the terminal."""
    subprocess.call(["python3", "copilot/commands/enter_accounts.py"])

@cli.command('enter-gl-accounts')
def enter_gl_accounts():
    """Enter GL accounts interactively from the terminal."""
    subprocess.call(["python3", "copilot/commands/enter_gl_accounts.py"])

@cli.command('enter-gl-account-allocations')
def enter_gl_account_allocations():
    """Enter/modify account allocation splits for GL accounts."""
    subprocess.call(["python3", "copilot/commands/enter_gl_account_allocations.py"])

@cli.command('bank-import')
def bank_import():
    """Import bank CSV transaction data for staging."""
    subprocess.call(["python3", "copilot/commands/bank_import.py"])

@cli.command('fuzzy')
def fuzzy():
    """Fuzzy-assign and learn gl_account_code for bank staging."""
    subprocess.call(["python3", "copilot/commands/fuzzy.py"])

@cli.command('mortgage')
def mortgage():
    """Enter a property mortgage payment (MHB)."""
    subprocess.call(["python3", "copilot/commands/copilot_mortgage_payment"])

@cli.command('new-mortgage')
def new_mortgage():
    """Set up a new property mortgage (MHB)."""
    subprocess.call(["python3", "copilot/commands/copilot_new_mortgage.py"])

@cli.command('mortgage-adjustment')
def mortgage_adjustment():
    """Make a mortgage adjustment entry."""
    subprocess.call(["python3", "copilot/commands/copilot_mortgage_adjustment.py"])

if __name__ == '__main__':
    cli()
