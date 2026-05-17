import sys


def daily_total_report(conn):
    """
    Fetches and displays the daily summary of the shop.
    Outputs: Total unique customers, total donuts sold, and gross income for the current day.
    """
    try:
        with conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                cur.execute("SELECT * FROM sales.daily_total_report")
                data = cur.fetchone()

                if not data:
                    sys.stderr.write(f"\033[91mNo data recored\033[0m\n")
                    return

                # extract data
                total_customer, total_saled_donuts, total_income = data

                # header
                sys.stdout.write(f"\n\033[94m{'Total Customer':<15}|{'Total Sold Donuts':<20}|{'Total Income':<15}\033[0m\n")
                sys.stdout.write("-" * 55 + "\n")

                sys.stdout.write(f"{total_customer:<15}|{total_saled_donuts:<20}|{total_income:<15} TK\n")
    except Exception as msg:
        sys.stderr.write(f"\033[91mError: {msg}\033[0m\n")


def cancel_report(conn):
    """
    Analyzes canceled items to monitor revenue loss and operational issues.
    Outputs: Canceled donut name, total number of cancellation instances, total quantity lost, total lost revenue, cancellation reasons, and the month.
    """
    try:
        with conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                cur.execute("SELECT * FROM sales.canceled_items_analysis")
                can_analysis = cur.fetchall()

                if not can_analysis:
                    sys.stderr.write(f"\033[91mNo data recored\033[0m\n")
                    return

                # header
                sys.stdout.write(f"{'name':<20}|{'total_cancellations':<10}|{'total_canceled_quantity':<10}|{'total_lost_revenue':<10}|{'reason':<10}|{'month':<5}\n")
                sys.stdout.write("-" * 107 + "\n")

                # main data
                for name, total_cancellations, total_canceled_quantity, total_lost_revenue, reason, month in can_analysis:
                    sys.stdout.write(f"{name:<20}|{total_cancellations:<20}|{total_canceled_quantity:<20}|{total_lost_revenue:<20}|{reason:<20}|{month:<5}\n")
    except Exception as msg:
        sys.stderr.write(f"\033[91mError: {msg}\033[0m\n")


def daily_sale_by_donut_report(conn):
    """
    Generates a daily performance report broken down by individual donuts.
    Outputs: Donut name, unique customer count per donut, total quantity sold, and total revenue per product.
    """
    try:
        with conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                cur.execute("SELECT * FROM sales.daily_sale_report_by_donut")
                donut_report = cur.fetchall()

                if not donut_report:
                    sys.stderr.write(f"\033[91mNo data recored\033[0m\n")
                    return

                # header
                sys.stdout.write(f"{'Donut Name':<20}|{'Customer Count':<15}|{'Total Sold':<12}|{'Total Amount':<15}\n")
                sys.stdout.write("-" * 65 + "\n")

                # main data
                for name, customer_count, total_saled, total_amount in donut_report:
                    sys.stdout.write(f"{name:<20}|{customer_count:<15}|{total_saled:<12}|{total_amount:<15} TK\n")
    except Exception as msg:
        sys.stderr.write(f"\033[91mError: {msg}\033[0m\n")


def sale_status_by_month_report(conn):
    """
    Tracks and breaks down sales trends periodically.
    Outputs: Donut ID, name, total quantity sold, grouped by specific weeks and months.
    """
    try:
        with conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                cur.execute("SELECT * FROM sales.sale_status_by_month")
                month_report = cur.fetchall()

                if not month_report:
                    sys.stderr.write(f"\033[91mNo data recored\033[0m\n")
                    return

                sys.stdout.write(f"{'Donut ID':<10}|{'Donut Name':<20}|{'Total Sold':<12}|{'Week':<6}|{'Month':<6}\n")
                sys.stdout.write("-" * 60 + "\n")

                for donut_id, name, total_saled, week, month in month_report:
                    sys.stdout.write(f"{donut_id:<10}|{name:<20}|{total_saled:<12}|{week:<6}|{month:<6}\n")
    except Exception as msg:
        sys.stderr.write(f"\033[91mError: {msg}\033[0m\n")
