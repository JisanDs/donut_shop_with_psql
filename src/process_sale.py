from services import SetUpConnection, Sales
import sys


def main():
        # create connection
    conn = SetUpConnection("root", "panda908jisan")
    conn.connect_db()
    try:
        process_sale(conn)
    except Exception as e:
        sys.stderr.write(f"{e}\n")
    finally:
        conn.close_conn()


def process_sale(conn):
    phone = input("Enter phone number: ").strip()
    customer_id = input("Enter customer id: ").strip()

    if not phone and not customer_id:
        sys.stderr.write("\033[91mError: phone number must given and customer_id (opsional)\033[0m\n")
        return 1

    customer_id = int(customer_id) if customer_id else None
    if not phone:
        phone = input("Enter phone number: ")

    sales = Sales(conn)
    sale_id = sales.generate_sale_id(phone=phone, customer_id=customer_id)

    if not sale_id:
        sys.stderr.write("\033[91mSomething went wrong, try again\033[0m\n")
        return 1

    total = 0
    while True:
        donut_id_input = input("Enter donut id (or press Enter to finish): ").strip()
        if not donut_id_input:
            break

        quantity_input = input("Enter quantity: ").strip()
        if not quantity_input:
            sys.stderr.write("\033[91mQuantity cannot be empty!\033[0m\n")
            continue

        try:
            donut_id = int(donut_id_input)
            quantity = int(quantity_input)


            item_total = sales.record_items(sale_id, donut_id, quantity)
            if item_total:
                total += item_total
        except ValueError:
            sys.stderr.write("\033[91mInvalid ID or Quantity. Must be numbers.\033[0m\n")
            continue

    if total == 0:
        sys.stderr.write("\033[91mNo items added. Sale canceled.\033[0m\n")
        return 1

    sys.stdout.write(f"\033[94mTotal amount to pay: {total} TK\033[0m\n")

    while True:
        payment_method = input("Payment method (Cash/Card/MFS): ").strip()
        amount_input = input("Enter amount: ").strip()

        if not amount_input:
            sys.stderr.write("\033[91mEnter valid amount\033[0m\n")
            continue

        try:
            amount = float(amount_input)
        except ValueError:
            sys.stderr.write("\033[91mInvalid amount format.\033[0m\n")
            continue

        pay_stat = sales.record_payment(sale_id, payment_method, amount)
        if pay_stat == 1:
            sys.stderr.write("\033[91mPayment incompleted/Rejected\033[0m\n")
            return 1

        if sales.is_payment_complete(sale_id) == 0:
            sys.stdout.write(f"\033[92mTotal payment '{total}' completed successfully!\033[0m\n")
            break

    return 0



if __name__ == "__main__":
    main()
