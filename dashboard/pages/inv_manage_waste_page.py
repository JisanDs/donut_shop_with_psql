import plotly.express as px
from pathlib import Path
import streamlit as st
import polars as pl
import sys


# setup path for importing sales_revenue_ana file
root_path = str(Path(__file__).resolve().parent.parent)
if root_path not in sys.path:
    sys.path.append(root_path)


from src.inv_manage_waste import (
    ingred_purchases,
    donut_waste,
    ingred_stock,
    donut_waste_by_month,
    donut_waste_by_name,
    supplier_purchases
)


# setup refresh button for update dashboard data
if st.button("Refresh", help="Click refresh if database is updated or after insert data related to this page."):
    # clear all cache
    donut_waste().clear()
    ingred_purchases().clear()
    ingred_stock().clear()
    donut_waste_by_month().clear()
    donut_waste_by_name().clear()
    supplier_purchases().clear()

    # rerun function and collect new data or update data
    st.rerun()


# this table containt full purchases history
df_purchas = ingred_purchases()

# this table record weste
df_waste = donut_waste()

# this table containt donut waste statictic by month
df_waste_mnt = donut_waste_by_month()

# this table containt donut waste by donut_name
df_waste_name = donut_waste_by_name()

# this table containt all stock status
df_stock = ingred_stock()

# this table containt purchese summary for every supplier
df_supplier = supplier_purchases()


# this line chart show donut weste statistic by month
def weste_month_line_chart():
    fig = px.line(
        data_frame=df_waste_mnt,
        x="month_name",
        y="total_lose_price",
        title="Donut Weste Stats For Every Month",
        markers=True
    )

    fig.update_layout(
        title_font_size=20,
        hovermode="x unified",
        plot_bgcolor="rgba(200,200,200,0.2)",
        margin=dict(l=30, r=30, t=30, b=30)
    )

    fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor="rgba(200,200,200,0.3)")
    fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor="rgba(200,200,200,0.3)")

    return fig


# this bar chart show which donut is wested most
def donut_weste_chart():
    fig = px.bar(
        data_frame=df_waste_name,
        x="name",
        y="waste_quantity",
        color="name",
        title="Donut Weste Status For Every Donut",
        text_auto=".2f",
        labels={
            "name": "donut_name"
        }
    )

    fig.update_layout(
        title_font_size=20,
        showlegend=False
    )

    return fig


# this bar chart show ingred current stock level and min require level
def stock_status_with_bar():
    fig = px.bar(
        data_frame=df_stock,
        x="name",
        y=["min_required_level", "current_stock_level"],
        title="Ingredients Stock Status",
        text_auto=".2f",
        labels={
            "name": "donut_name"
        }
    )

    fig.update_layout(
        title_font_size=20,
        showlegend=False
    )

    return fig


# this bar chart shwo purchases status for every supplier
def ingred_purchase_chart():
    fig = px.bar(
        data_frame=df_supplier,
        x="supplier_name",
        y="total_price",
        color="supplier_name",
        title="Supplier Performance"
    )

    fig.update_layout(
        title_font_size=20,
        showlegend=False
    )

    return fig




st.title("Inventory & Food Waste Management")
st.divider()


# calculate total purchases amount, waste quantity, lose amount
total_purchas = df_purchas["total_price"].sum()
total_waste = df_waste_mnt["waste_quantity"].sum()
total_lose = df_waste_mnt["total_lose_price"].sum()


# setup for columns
purchas, waste, lose = st.columns(3)

# show in metric
with purchas:
    with st.container(border=True):
        st.metric(
            "Total Purchases Amount",
            f"${round(total_purchas)}"
        )

with waste:
    with st.container(border=True):
        st.metric(
            "Total Donut Waste Quantity",
            f"${total_waste}"
        )

with lose:
    with st.container(border=True):
        st.metric(
            "Total Lose Price",
            f"${round(total_lose, 2)}"
        )




# setup tabs
tables, charts = st.tabs(["Tables", "Charts"])


# show all tables
with tables:
    # extract all month name
    month_names = (
        df_waste["month_name"]
        .drop_nulls()
        .unique()
        .sort()
        .to_list()
    )

    # setup selectbox for filter
    month_name = st.selectbox(
        label="Select Month Name",
        options=month_names,
        help="Using this you can filter data by month name"
    )

    # filter table and extract selected month deatils
    df = (
        df_waste.filter(
            pl.col("month_name") == month_name
        )
        .group_by("name").agg(
            pl.col("donut_id").first().alias("donut_id"),
            pl.col("date").first().alias("date"),
            pl.col("quantity").sum().alias("quantity"),
            pl.col("lose_price").sum().alias("lose_price")
        )
        .sort(by="date")
        .select(["donut_id", "name", "quantity", "lose_price", "date"])
    )

    st.header("This Table Show Donut Weste History")
    # show data frame
    st.dataframe(df)


    st.header("This Table Show Full Purchases History")
    # show full purchases history
    st.dataframe(df_purchas)


# show all charts
with charts:
    with st.container(border=True):
        fig = weste_month_line_chart()
        st.plotly_chart(fig)


    with st.container(border=True):
        fig = donut_weste_chart()
        st.plotly_chart(fig)


    with st.container(border=True):
        fig = stock_status_with_bar()
        st.plotly_chart(fig)


    with st.container(border=True):
        fig = ingred_purchase_chart()
        st.plotly_chart(fig)
