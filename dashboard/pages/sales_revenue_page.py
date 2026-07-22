import sys
import polars as pl
import streamlit as st
from pathlib import Path
import plotly.express as px


# this code help to import module from src dir
root_path = Path(__file__).resolve().parent.parent
if  str(root_path) not in sys.path:
    sys.path.append(str(root_path))


# import all anslysis from src/anlsysis file
from src.sales_revenue_ana import (
    total_revenue_cal,
    categorie_wise,
    sale_by_discount,
    sale_by_month_day
)


# setup botton for refersh full page
if st.button("Refresh", help="Click refresh if database is updated or after insert data related to this page."):
    # clear all cache
    total_revenue_cal().clear()
    categorie_wise().clear()
    sale_by_discount().clear()
    sale_by_month_day().clear()

    # rerun all function
    st.rerun()


# this table containt columns with, without discount sale quantity
df_dis = sale_by_discount().sort(by="donut_id")

# this table have total revenue and profit by per donut
df_rev_profit = total_revenue_cal()

# this table containt total sale quantity, total profit
df_cat_profit = categorie_wise()

# this table containt sale stats for every month and day
df_sale = sale_by_month_day()


# extract month name as string
df_sale = df_sale.with_columns(
    pl.col("sale_date").dt.to_string("%B").alias("month_name")
)


# this analysis for showing line chart
df_sale_line = df_sale.group_by("month_name").agg(
    pl.col("total_sale_count").sum().alias("sale_quantity"),
    pl.col("total_revenue").sum().alias("total_revenue")
).sort(by="sale_quantity", descending=True)




# ---- viaualization part ----

def line_chart_for_by_month():
    fig = px.line(
        data_frame=df_sale_line,
        x="month_name",
        y=["sale_quantity", "total_revenue"],
        title="Donut Sale Statistic By Month",
        markers=True
    )

    fig.update_layout(
        title_font_size=20,
        plot_bgcolor="rgba(200, 200, 200, 0.1)",
        hovermode="x unified",
        margin=dict(l=30, r=30, t=30, b=30)
    )

    fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor="rgba(200,200,200,0.2)")
    fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor="rgba(200,200,200,0.2)")

    return fig


# this bar chart show donut sale stats
def donut_sale_bar_chart():
    fig = px.bar(
        data_frame=df_rev_profit,
        x="sale_quantity",
        y="name",
        color="name",
        title="Donuts Sale Statistic",
        text_auto=".1f",
        labels={
            "name": "donut_name"
        }
    )

    fig.update_layout(
        title_font_size=20,
        showlegend=False,
        plot_bgcolor="rgba(0,0,0,0)",       # this make chart background transparent
        margin=dict(l=20, r=20, t=50, b=20)
    )

    return fig



# this donut chart shwo sale quantity by categorie
def cat_donut_sale_quantity():
    fig = px.pie(
        data_frame=df_cat_profit,
        names="categorie",
        values="sale_quantity",
        title="Sale Quantity By Categories",
        hole=0.4
    )

    fig.update_traces(
        pull=[0.2, 0, 0],
        textposition="inside",
        textinfo="percent+label"
    )

    fig.update_layout(
        title_font_size=20,
        showlegend=False,
        margin=dict(l=30, r=30, t=50, b=30)
    )

    return fig


# this donut chart show sale profit by donut categorie
def cat_donut_chart():
    fig = px.pie(
        data_frame=df_cat_profit,
        names="categorie",
        values="total_profit",
        title="Profit By Categorie",
        hole=0.4
    )

    fig.update_traces(
        pull=[0.2, 0, 0],
        textposition="inside",
        textinfo="percent+label"
    )

    fig.update_layout(
        title_font_size=20,
        showlegend=False,
        margin=dict(l=30, r=30, t=50, b=30)
    )

    return fig


# This Chart Show Total spending vs Total Profit Per Donut
def scatter_chart_spd_profit():
    fig = px.scatter(
        data_frame=df_rev_profit,
        x="total_spending",
        y="total_profit",
        color="name",
        hover_name="name",
        labels={
            "name": "donut_name"
        },
        title="Total Spending vs Total Profit Per Donut"
    )

    fig.update_layout(
        title_font_size=20,
        plot_bgcolor="rgba(200, 200, 200, 0.1)",
        margin=dict(l=30, r=30, t=50, b=30)
    )

    fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor="rgba(200,200,200,0.2)")
    fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor="rgba(200,200,200,0.2)")

    return fig




# ---- interface part ----

st.title("Sales Revenue Analysis")
st.divider()


# calculate total profit for all donut
df_total_profit = df_rev_profit["total_profit"].sum()
df_total_quantity = df_rev_profit["sale_quantity"].sum()

# extract top selled donut name
top_selled_donut = df_rev_profit["name"][0]


# show data in columns bolock
quantity, profit, top_donut = st.columns(3)

with top_donut:
    with st.container(border=True):
        st.metric(
            "Top Selled Donut",
            f"{top_selled_donut}"
        )

with quantity:
    with st.container(border=True):
        st.metric(
            "Total Quantity Soled",
            f"{df_total_quantity}"
        )

with profit:
    with st.container(border=True):
        st.metric(
            "Total profit",
            f"${round(df_total_profit, 3)}"
        )


# setup for tables to organize
tables, charts = st.tabs(["Tables", "Charts"])

with tables:
    st.header("Sale Statistic With and Without Discount")
    st.dataframe(df_dis)


    st.header("Donut Statistic By Sale Date and Month")
    # extract all month name
    month_names = (
        df_sale["month_name"]
        .drop_nulls()
        .unique()
        .sort()
        .to_list()
    )
    # setup select box
    selected_month = st.selectbox(
        label="Select Month",
        options=month_names,
        help="Using this you can filter data by month name"
    )
    # filter data user selected by month and remove necessary columns
    df_sale = (
        df_sale.filter(
            pl.col("month_name") == selected_month
        ).with_columns(
            pl.col("sale_date").dt.date().alias("sale_date"),
            pl.col("total_sale_count").alias("total_sale_quantity")
        ).select(["sale_date", "total_sale_quantity", "total_revenue"])
    )
    st.dataframe(df_sale)




with charts:
    # this show sale by month
    with st.container(border=True):
        line_fig = line_chart_for_by_month()
        st.plotly_chart(line_fig)


    # show scatter chart for spending and profit
    with st.container(border=True):
        scatter_fig = scatter_chart_spd_profit()
        st.plotly_chart(scatter_fig)


    # this bar_chart show statistic by donut
    with st.container(border=True):
        bar_fig = donut_sale_bar_chart()
        st.plotly_chart(bar_fig)


    # setup donut columns for donut chart
    profit, quantity = st.columns(2)

    # show donut chart for profit by categorie
    with profit:
        with st.container(border=True):
            donut_fig = cat_donut_chart()
            st.plotly_chart(donut_fig)

    # show donut chart for sale quantity by categorie
    with quantity:
        with st.container(border=True):
            donut_fig = cat_donut_sale_quantity()
            st.plotly_chart(donut_fig)
