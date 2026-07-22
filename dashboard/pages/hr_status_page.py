import plotly.express as px
from pathlib import Path
import streamlit as st
import polars as pl
import sys


# setup path for importing hr_analysis file
root_path = str(Path(__file__).resolve().parent.parent)
if root_path not in sys.path:
    sys.path.append(root_path)


from src.hr_analysis import (
    employees_details,
    employee_growth,
    shift_wise_emp_stats,
    salary_payments_by_month,
    salary_payments
)


# setup refresh button for update dashboard data
if st.button("Refresh", help="Click refresh if database is updated or after insert data related to this page."):
    # clear all cache
    employees_details().clear()
    employee_growth().clear()
    shift_wise_emp_stats().clear()
    salary_payments_by_month().clear()
    salary_payments().clear()

    # rerun function and collect new data or update data
    st.rerun()


# this table containt details about employees
df_emp = employees_details().sort("employee_id")

# this table containt employees count for every month
df_emp_grow = employee_growth()

# this table containt total employees count and salary for every shift
df_shift_wise = shift_wise_emp_stats()

# salary pay history for every month
df_pay_month = salary_payments_by_month()

# this table containt salary pay details
df_payments = salary_payments()


# --- create charts for ---

# this bar chart shows employees count for every shifts
def emp_count_chart():
    fig = px.bar(
        data_frame=df_shift_wise,
        x="shift_name",
        y="total_employees",
        color="shift_name",
        title="Total Employees For Every Shifts"
    )

    fig.update_layout(
        title_font_size=20,
        showlegend=False
    )

    return fig


# this histogram chart show employees count by age group
def age_hist_chart():
    fig = px.histogram(
        data_frame=df_emp,
        x="age",
        nbins=3,
        title="Employees Count By Age Group",
        color_discrete_sequence=["#636EFA"]
    )

    fig.update_layout(
        title_font_size=20
    )

    return fig


# this line chart reprecent employees join for every month
def emp_join_chart_month():
    fig = px.line(
        data_frame=df_emp_grow,
        x="month_name",
        y="total_employees",
        title="Employees Join For Every Month",
        markers=True
    )

    fig.update_layout(
        title_font_size=20,
        hovermode="x unified",
        plot_bgcolor="rgba(200,200,200,0.2)",
        margin=dict(l=20, r=20, t=20, b=20)
    )

    fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor="rgba(200,200,200,0.3)")
    fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor="rgba(200,200,200,0.3)")

    return fig


# this line chart reprecent employees salary for every month
def emp_salary_payment_month():
    fig = px.line(
        data_frame=df_pay_month,
        x="month_name",
        y="total_salary",
        title="Salary Payments For Every Month",
        markers=True
    )

    fig.update_layout(
        title_font_size=20,
        hovermode="x unified",
        plot_bgcolor="rgba(200,200,200,0.2)",
        margin=dict(l=20, r=20, t=20, b=20)
    )

    fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor="rgba(200,200,200,0.3)")
    fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor="rgba(200,200,200,0.3)")

    return fig




st.title("HR & Operational Efficiency")
st.divider()


# --- kpi part ---

# setup columns
total_emp, total_salary, emp_avg_salary = st.columns(3)

# calculate total employee and total salary
emp_count = df_shift_wise["total_employees"].sum()
emp_salary = df_shift_wise["total_salary"].sum()

# calculate employees avg salary
avg_salary = df_emp["current_salary"].mean()


with total_emp:
    with st.container(border=True):
        st.metric(
            "Total Employees",
            emp_count
        )

with total_salary:
    with st.container(border=True):
        st.metric(
            "Total Salary",
            emp_salary
        )

with emp_avg_salary:
    with st.container(border=True):
        st.metric(
            "Average Salary",
            round(avg_salary, 2)
        )


# ---- table ----
# last_10_salary_payments with pay_type filter
# 	employees details with role_name filter


tables, charts = st.tabs(["Tables", "Charts"])

with tables:
    st.header("Employees Detalis")

    # setup filter option clickbox
    if st.checkbox("Filter Option", help="Using filter option you can filter employees data by selecting employees role_name"):

        # extract all role names
        options = (
            df_emp["role_name"]
            .drop_nulls()
            .unique()
            .sort()
            .to_list()
        )

        # setup for selectbox
        selected = st.selectbox("Select Role Nmae", options)

        # extract only selected employees
        df_emp = df_emp.filter(
            (pl.col("role_name") == selected),
            (pl.col("act_stat") == True)
        )

        st.dataframe(df_emp)
    else:

        # extract all active employees
        df_emp = df_emp.filter(
            (pl.col("act_stat") == True)
        )

        st.dataframe(df_emp)


    st.header("Last 10 salay payments")

    # extract last 10 salary payment
    df_payments = (
        df_payments
        .sort(by="payment_date", descending=True)
        .head(10)
    )

    st.dataframe(df_payments)


with charts:

    # setup columns
    bar, hist = st.columns(2)

    with bar:
        with st.container(border=True):
            shift_emp_count = emp_count_chart()
            st.plotly_chart(shift_emp_count)


    with hist:
        with st.container(border=True):
            age_group = age_hist_chart()
            st.plotly_chart(age_group)


    with st.container(border=True):
        count_emp = emp_join_chart_month()
        st.plotly_chart(count_emp, key="employees_count")


    with st.container(border=True):
        pay_stat = emp_salary_payment_month()
        st.plotly_chart(pay_stat, key="payments")
