CREATE OR REPLACE VIEW sales.daily_total_report AS
    SELECT
        COUNT(s.sale_id) AS total_customer,
        SUM(item.sale_quantity) AS total_saled_donut,
        SUM(item.sub_total) AS total_income
    FROM sales.sales as s
    JOIN sales.sale_items as item USING (sale_id)
    GROUP BY s.sale_date
    HAVING s.sale_date = CURRENT_DATE;


CREATE OR REPLACE VIEW sales.daily_sale_report_by_donut AS
    SELECT d.name,
        COUNT(s.sale_id) AS customer_count,
        SUM(items.sale_quantity) AS total_saled,
        SUM(items.sub_total) AS total_amount
    FROM inventory.donuts AS d
    JOIN sales.sale_items AS items ON items.donut_id = d.donut_id
    JOIN sales.sales AS s ON s.sale_id = items.sale_id
    WHERE s.sale_date = CURRENT_DATE
    GROUP BY d.name;


CREATE OR REPLACE VIEW sales.sale_status_by_month AS
    WITH donut_sales AS (
        SELECT d.donut_id, d.name,
            SUM(items.sale_quantity) AS total_saled,
            TO_CHAR(s.sale_date, 'Week') AS week,
            TO_CHAR(s.sale_date, 'Month') AS month
        FROM inventory.donuts AS d
        JOIN sale_items AS items USING(donut_id)
        JOIN sales AS s USING(sale_id)
        GROUP BY s.sale_date, d.donut_id
        ORDER BY total_saled DESC
    )
    SELECT donut_id, name, total_saled, week, month FROM donut_sales
    ORDER BY week;


CREATE OR REPLACE VIEW sales.canceled_items_analysis AS
    SELECT
        d.name,
        COUNT(c.sale_id) AS total_cancellations,
        SUM(c.sale_quantity) AS total_canceled_quantity,
        SUM(c.total_price) AS total_lost_revenue,
        l.reason,
        EXTRACT(MONTH FROM canceled_date) AS month
    FROM sales.canceled_sale_items c
    JOIN inventory.donuts d ON c.donut_id = d.donut_id
    JOIN inventory.inventory_logs l ON c.sale_id = l.sale_id AND c.donut_id = l.donut_id
    WHERE l.reason = 'restock' OR l.reason = 'damaged'
    GROUP BY d.name, l.reason, month
    ORDER BY total_lost_revenue DESC;
