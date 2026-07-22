from services import SetUpConnection, cancel_report, daily_total_report, daily_sale_by_donut_report, sale_status_by_month_report
import sys


def main():
    # create connection
    conn = SetUpConnection("root", "panda908jisan")
    conn.connect_db()
    try:
        sys.stdout.write("Daily Total report:\n")
        daily_total_report(conn)
        print("\n")

        sys.stdout.write("Daily Report By Donut:\n")
        daily_sale_by_donut_report(conn)
        print("\n")

        sys.stdout.write("Sale Status Report By Month:\n")
        sale_status_by_month_report(conn)
        print("\n")

        sys.stdout.write("Canceled Sale Items Report:\n")
        cancel_report(conn)
    except Exception as e:
        sys.stderr.write(f"Error: {e}\n")
    finally:
        conn.close_conn()


if __name__ == "__main__":
    main()
