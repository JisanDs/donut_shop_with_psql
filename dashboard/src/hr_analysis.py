from pathlib import Path
import streamlit as st
import polars as pl
import sys


# setup import path for importing sales_revenue_ana for access load_data_from_db
root_path = str(Path(__file__).resolve().parent.parent)
if root_path not in sys.path:
    sys.path.append(root_path)


# this function use to load data from db
from src.sales_revenue_ana import load_data_from_db


@st.cache_data()
def employees_details():
    """This function is use to collect employees details"""

    query = """
        SELECT e.employee_id, e.role_id, e.shift_id, e.name, e.username, e.email, e.age, e.current_salary,
        r.role_name, s.shift_name, e.join_date, e.act_stat, s.start_time, s.end_time
        FROM hr.employees AS e
        JOIN hr.job_roles AS r USING(role_id)
        JOIN hr.shifts AS s USING(shift_id)
    """

    return load_data_from_db(query)


@st.cache_data()
def salary_payments():
    "This function return table that containt employees salary payments history"

    query = """
        SELECT e.name, e.username, j.role_name, p.salary,
            p.pay_type, p.account_company, p.payment_date
        FROM hr.payments_history AS p
        JOIN hr.employees AS e USING(employee_id)
        JOIN hr.job_roles AS j
            ON j.role_id = p.role_id
    """

    return load_data_from_db(query)


@st.cache_data()
def employee_growth():
    """This calculate total employee for every month"""

    df = (
        employees_details()

        # extract month name
        .with_columns(
            pl.col("join_date").dt.to_string("%B").alias("month_name")
        )
        # calulate total employees for every month
        .group_by("month_name").agg(
            pl.col("employee_id").count().alias("total_employees"),
        )
    )

    return df


@st.cache_data()
def salary_payments_by_month():
    """This function return table that containt month_name, total_salary for every month"""

    query = """
        SELECT salary, payment_date
        FROM hr.payments_history
    """

    df = (
        load_data_from_db(query)
        # extract month name
        .with_columns(
            pl.col("payment_date").dt.to_string("%B").alias("month_name")
        )
        # calculate total salary for every month
        .group_by("month_name").agg(
            pl.col("salary").sum().alias("total_salary")
        )
    )

    return df


@st.cache_data()
def shift_wise_emp_stats():
    """This function return table that containt total salary, total employee by shift"""

    df = (
        employees_details().group_by("shift_name").agg(
            # count employee for every shift
            pl.when(pl.col("act_stat") == True)
            .then(1)
            .otherwise(0)
            .sum()
            .alias("total_employees"),

            # calculate total salary for every shift
            pl.when(pl.col("act_stat") == True)
            .then(pl.col("current_salary"))
            .otherwise(0)
            .sum()
            .alias("total_salary")
        )
    )

    return df
