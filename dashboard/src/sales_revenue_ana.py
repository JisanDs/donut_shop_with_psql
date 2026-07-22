import streamlit as st
import polars as pl


URL = "postgresql://username:password@127.0.0.1:5432/donut_shop"


def load_data_from_db(query: str):
    """This function load data from donut_shop database by query.
       Syntax:
           load_data_from_db(SELECT * FROM inventory.donuts)
    """
    return pl.read_database_uri(query=query, uri=URL, engine="connectorx")


@st.cache_data()
def total_spending_per_donut():
    """this func calculate total spending per donut."""

    donut_spending = """
        SELECT donut_id,
            ROUND(SUM(price_per_unit * ingred_quantity_needed), 2) AS total_spending
        FROM inventory.donut_ingreds
        INNER JOIN inventory.ingredients USING(ingred_id)
        GROUP BY donut_id
    """
    return load_data_from_db(donut_spending)


@st.cache_data()
def total_sales():
    """this function return total_sale, donut_name, donut_id, sale_quantity"""

    donut_sale = """
        SELECT name, donut_id,
            SUM(sale_quantity) AS sale_quantity,
            SUM(sub_total) AS total_sale
        FROM sales.sale_items
        INNER JOIN inventory.donuts USING(donut_id)
        GROUP BY name, donut_id
        ORDER BY donut_id
    """
    return load_data_from_db(donut_sale)


@st.cache_data()
def total_revenue_cal():
    """this function show total spending, revenue, profit for every donut from start to end."""

    df_spend = total_spending_per_donut()
    df_sale = total_sales()

    df = (
        # this join df_sale table with df_spend table
        df_sale.join(df_spend, on="donut_id", how="inner")
        .with_columns([
            # this calculate total spending for total sale_quantity
            (pl.col("sale_quantity") * pl.col("total_spending")).alias("total_spending"),

            # this calculate total revenue after cutting spending
            (pl.col("total_sale") - (pl.col("sale_quantity") * pl.col("total_spending"))).alias("total_profit")
        ])
        .sort(by="total_profit", descending=True)  # finally sort value by donut id
        .select(["donut_id", "name", "sale_quantity", "total_spending", "total_sale", "total_profit"])
    ).sort(by="sale_quantity", descending=True)

    return df


@st.cache_data()
def categorie_wise():
    """This function return table that containt total sale quantity, total_revenue, total_profit by categorie."""

    # load categories table from database
    query = """
        SELECT cat_id, donut_id, categorie
        FROM inventory.categories
        JOIN inventory.donuts USING(cat_id)
    """
    df_categories = load_data_from_db(query)
    df_donut_summary = total_revenue_cal()

    df = (
        df_categories.join(df_donut_summary, on="donut_id")
        .group_by("categorie").agg(
            sale_quantity=pl.col("sale_quantity").sum(),
            total_profit=pl.col("total_profit").sum()
        )
        .sort(by="sale_quantity", descending=True)
    )

    return df


@st.cache_data()
def sale_by_discount():
    """
        This function calculates sales when a discount is running
        versus sales without any discount.
        """

    query = """
        SELECT *
        FROM sales.sales
        JOIN sales.sale_items USING(sale_id)
        LEFT JOIN  inventory.discounts USING(donut_id)
        WHERE sale_stat = 'completed'
    """

    df_row = load_data_from_db(query)

    # mark True if sale date is in discount date else False
    df_with_flage = df_row.with_columns(
        pl.when(
            pl.col("discount_percent").is_not_null() &
            pl.col("sale_date").is_between(pl.col("start_date"), pl.col("end_date"))
        )
        .then(True)
        .otherwise(False)
        .alias("is_discount_active")
    )

    df = df_with_flage.group_by("donut_id").agg(
        # calculate sale quantity without discount
        pl.when(pl.col("is_discount_active") == True)
        .then(pl.col("sale_quantity"))
        .otherwise(0)
        .sum()
        .alias("with_discount_sale"),

        # calculate sale quantity without discount
        pl.when(pl.col("is_discount_active") == False)
        .then(pl.col("sale_quantity"))
        .otherwise(0)
        .sum()
        .alias("without_discount_sale")
    )
    return df


@st.cache_data()
def sale_by_month_day():
    """This function create sale by month_day."""

    query = """
        SELECT *
        FROM sales.sales
        JOIN sales.sale_items USING(sale_id)
    """

    df_row = load_data_from_db(query)

    df = (
        # extract month and day as numbers
        df_row.with_columns(
            pl.col("sale_date").dt.month().alias("sale_month"),
            pl.col("sale_date").dt.day().alias("sale_day")
        )
        # calculate total sale quantity and revenue by day
        .group_by("sale_day").agg(
            pl.col("sale_date").first(),
            pl.col("sale_month").first(),
            pl.col("sale_quantity").sum().alias("total_sale_count"),
            pl.col("sub_total").sum().alias("total_revenue")
        )
        .sort(by="sale_month")
        .select(["sale_date", "sale_month", "sale_day", "total_sale_count", "total_revenue"])
    )

    return df
