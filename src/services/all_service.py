from psycopg.types.json import Jsonb
from dataclasses import dataclass
from psycopg import errors
from typing import Any
import sys


# this decorator use to handle all errors
def handle_db_errors(func):
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except errors.UniqueViolation:
            sys.stderr.write("\033[91mDuplicate entry error\033[0m\n") # \033[91 for show read color message
        except errors.RaiseException as msg:
            sys.stderr.write(f"\033[91m{msg.diag.message_primary}\033[0m\n")
    return wrapper


@dataclass
class Inventory:
    """
        This class use to handle inventory procedures in PostgreSql database.
        This class take connection.
    """
    conn: Any

    @handle_db_errors
    def add_ingred(self, name: str, unit_name: str, price: float):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (name, unit_name, price)
                cur.execute("CALL inventory.add_ingred(%s::VARCHAR, %s::VARCHAR, %s::NUMERIC)", data)

    @handle_db_errors
    def add_categorie(self, name: str):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                cur.execute("CALL inventory.add_categorie(%s)", (name,))


    @handle_db_errors
    def add_donut(self, name: str, cat_id: int, is_gluten_free: bool, price: float, quantity: int):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (name, cat_id, is_gluten_free, price, quantity)
                cur.execute("CALL inventory.add_donut(%s::VARCHAR, %s::INT, %s::BOOLEAN, %s::NUMERIC, %s::INT)", data)

    @handle_db_errors
    def connect_ingred_donut(self, donut_id: int, ingred_id: int, quantity: float):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (donut_id, ingred_id, quantity)
                cur.execute("CALL inventory.connect_ingred_donut(%s::INT, %s::INT, %s::NUMERIC)", data)

    @handle_db_errors
    def add_ingred_stock_requirment(self, ingred_id: int, min_requir_level: float):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (ingred_id, min_requir_level)
                cur.execute("CALL inventory.add_ingred_stock_requirment(%s::INT, %s::NUMERIC)", data)

    @handle_db_errors
    def add_supplier(self, name: str, phone: str, city: str, area: str):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                location = {"city": city, "area": area}
                data = (name, [phone], Jsonb(location))
                cur.execute("CALL inventory.add_supplier(%s, %s, %s)", data)

    @handle_db_errors
    def purchase_from(self, supplier_id: int, ingred_id: int, unit_name: str, quantity: int, price_per_unit: float):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (supplier_id, ingred_id, unit_name, quantity, price_per_unit)
                cur.execute("CALL inventory.purchase_from(%s::INT, %s::INT, %s::VARCHAR, %s::INT, %s::NUMERIC)", data)

    @handle_db_errors
    def give_discount(self, donut_id: int, discount_percent: int, start_date: str, end_date: str):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (donut_id, discount_percent, start_date, end_date)
                cur.execute("CALL inventory.give_discount(%s::INT, %s::INT, %s::DATE, %s::DATE)", data)

    @handle_db_errors
    def change_ingred_price(self, ingred_id: int, new_price: float):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (ingred_id, new_price)
                cur.execute("CALL inventory.change_ingred_price(%s::INT, %s::NUMERIC)", data)

    @handle_db_errors
    def change_donut_price(self, donut_id: int, new_price: float):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (donut_id, new_price)
                cur.execute("CALL inventory.change_donut_price(%s::INT, %s::NUMERIC)", data)

    @handle_db_errors
    def get_donut_price(self, donut_id: int) -> float:
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (donut_id, None, None)
                cur.execute("CALL inventory.get_donut_price(%s, %s, %s)", data)
                result = cur.fetchone()
                if result:
                    price, stat_code = result
                    if stat_code == 1:
                        return
                    return price

    @handle_db_errors
    def record_waste(self, donut_id: int, quantity: int):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (donut_id, quantity)
                cur.execute("CALL inventory.record_waste(%s, %s)", data)

    @handle_db_errors
    def update_ingred_quantity(self, ingred_id: int, quantity: float, reason: str):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (ingred_id, quantity, reason)
                cur.execute("CALL inventory.update_ingred_quantity(%s, %s, %s)", data)

    @handle_db_errors
    def increace_donut_quantity(self, donut_id: int, quantity: int):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (donut_id, quantity)
                cur.execute("CALL inventory.increace_donut_quantity(%s, %s)", data)


@dataclass
class HR:
    """
        This class use to manage hr or employees resources.
        This class take connection as input.
    """
    conn: Any

    @handle_db_errors
    def add_job(self, role_name: str, base_salary: int):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (role_name, base_salary)
                cur.execute("CALL hr.add_job(%s, %s)", data)

    @handle_db_errors
    def add_shift(self, name: str, start_time: str, end_time: str):
        try:
            with self.conn.get_conn() as ctn:
                with ctn.cursor() as cur:
                    data = (name, start_time, end_time)
                    cur.execute("CALL hr.add_shift(%s, %s, %s)", data)
        except errors.InvalidTextRepresentation:
            sys.stderr.write(f"shift {name} already exists or start_time or end_time must be between ('9 AM', '10 PM', '2 PM')\n")

    @handle_db_errors
    def add_employee(self, role_id: int, shift_id: int, name: str, username: str, age: int, email: str, phone: str, passwd: str, current_salary: int, account: str, account_company: str, account_type: str, city: str, area: str):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                location = {"city": city, "area": area}
                data = (role_id, shift_id, name, username, age, email, [phone], passwd, current_salary, account, account_company, account_type, Jsonb(location))
                cur.execute("CALL hr.add_employee(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", data)

    @handle_db_errors
    def change_emp_shift(self, employee_id: int, new_shifts_id: int):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (employee_id, new_shifts_id)
                cur.execute("CALL hr.change_emp_shift(%s, %s)", data)

    @handle_db_errors
    def change_emp_salary(self, employee_id: int, new_salary: int):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (employee_id, new_salary)
                cur.execute("CALL hr.change_emp_salary(%s, %s)", data)

    @handle_db_errors
    def pay_salary(self, employee_id: int, role_id: int):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (employee_id, role_id)
                cur.execute("CALL hr.pay_salary(%s, %s)", data)

    @handle_db_errors
    def delete_employee(self, employee_id: int, username: str):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (employee_id, username)
                cur.execute("CALL hr.delete_employee(%s, %s)", data)

    @handle_db_errors
    def get_employee_passwd(self, employee_id: int, username: str) -> str:
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (employee_id, username, None, None)
                cur.execute("CALL hr.get_employee_passwd(%s, %s, %s, %s)", data)
                result = cur.fetchone()
                if result:
                    passwd, stat_code = result
                    if stat_code == 1:
                        return
                    return passwd



@dataclass
class Sales:
    """
        This class use to handle all sales stuffs, this class take connection as argument.
    """
    conn: Any

    @handle_db_errors
    def add_customer(self, name: str, username: str, age: str, email: str, phone: str, passwd: str, city: str, area: str):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                location = {"city": city, "area": area}
                data = (name, username, age, email, [phone], passwd, Jsonb(location))
                cur.execute("CALL sales.add_customer(%s, %s, %s, %s, %s, %s, %s)", data)

    @handle_db_errors
    def delete_customer(self, customer_id: int, username: str):
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (customer_id, username)
                cur.execute("CALL sales.delete_customer(%s, %s)", data)

    @handle_db_errors
    def get_passwd(self, customer_id: int, username: str) -> str:
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (customer_id, username, None, None)
                cur.execute("CALL sales.get_passwd(%s, %s, %s, %s)", data)
                result = cur.fetchone()
                if result:
                    passwd, return_code = result
                    if return_code == 0:
                        return passwd

    @handle_db_errors
    def generate_sale_id(self, phone: str=None, customer_id: int=None) -> int:
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                if phone == None and customer_id == None:
                    sys.stderr.write("customer id and phone number both can not be None\n")
                    return
                data = (phone, customer_id, None)
                cur.execute("CALL sales.generate_sale_id(%s, %s, %s)", data)
                sale_id = cur.fetchone()
                if sale_id:
                    return sale_id[0]

    @handle_db_errors
    def record_items(self, sale_id: int, donut_id: int, quantity: int) -> float:
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (sale_id, donut_id, quantity, None)
                cur.execute("CALL sales.record_items(%s, %s, %s, %s)", data)
                total_price = cur.fetchone()
                if total_price:
                    return total_price[0]

    @handle_db_errors
    def record_payment(self, sale_id: int, payment_method: int, amount: float) -> int:
        try:
            with self.conn.get_conn() as ctn:
                with ctn.cursor() as cur:
                    data = (sale_id, payment_method, amount, None)
                    cur.execute("CALL sales.record_payment(%s::INT, %s::pay_types, %s::NUMERIC, %s::INT)", data)
                    pay_stat = cur.fetchone()
                    if pay_stat:
                        return pay_stat[0]
        except errors.InvalidTextRepresentation:
            sys.stdout.write(f"Payment methods must between (cash, m_bk, cad)\n")

    @handle_db_errors
    def change_sale_item_quantity(self, sale_id: int, donut_id: int,  quantity: int, reason: int) -> float:
        # this operation convert positive value to negative. read sales folder plan.md file for better understanding path: database/sales/plan.md
        if reason == 'damaged' or reason == 'restock':
            quantity = -quantity

        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (sale_id, donut_id, reason, quantity, None)
                cur.execute("CALL sales.change_sale_item_quantity(%s, %s, %s, %s, %s)", data)
                new_total = cur.fetchone()
                if new_total:
                    return new_total[0]

    @handle_db_errors
    def cancel_item(self, sale_id: int, donut_id: int, reason: str) -> float:
        try:
            with self.conn.get_conn() as ctn:
                with ctn.cursor() as cur:
                    data = (sale_id, donut_id, reason, None)
                    cur.execute("CALL sales.cancel_item(%s, %s, %s, %s)", data)
                    new_total = cur.fetchone()
                    if new_total:
                        return new_total[0]
        except errors.InvalidTextRepresentation:
            sys.stdout.write(f"Invalid reason '{reason}'. reason must between ('restock', 'damaged')\n")

    @handle_db_errors
    def cancel_sale(self, sale_id: int, reason: str):
            with self.conn.get_conn() as ctn:
                with ctn.cursor() as cur:
                    data = (sale_id, reason)
                    cur.execute("CALL sales.cancel_sale(%s, %s)", data)

    @handle_db_errors
    def is_payment_complete(self, sale_id: int) -> int:
        with self.conn.get_conn() as ctn:
            with ctn.cursor() as cur:
                data = (sale_id, None)
                cur.execute("CALL sales.is_payment_complete(%s, %s)", data)
                status = cur.fetchone()
                if status:
                    return status[0]
