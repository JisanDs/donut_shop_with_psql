/*
    'inventory_logs'
    This table containt verius table stock updates, inserts record.
    This table maintain by differents triggers and procedures.

    for instance when any sales hapens
    'after_order_items_insert' trigger activate and update quantity of donuts
    and after that it's store data in in inventory_logs table,
    it store (log_id, donut_id, sales_id, change_amount, reason, changed_table, join_date).

    and other perspactive we have like
    if you store data in table purchases using procedure
    purchase_from(g_supplier_id, g_ingred_id, g_unit_name, g_quantity, g_price_per_unit, changed_table);
    then 'update_ingred_stock' activate and and store (log_id, ingred_id, change_amount, reason, log_date).
    thats all.
*/
-- CREATE TYPE reasons AS ENUM('sale', 'restock', 'add', 'damaged', 'use');

--  CREATE TABLE inventory_logs(
--      log_id SERIAL PRIMARY KEY,
--      donut_id INT,
--      sale_id INT,
--      ingred_id INT,
--      changed_table VARCHAR,
--     	change_amount INT NOT NULL,
--     	reason reasons,
--     	log_date DATE DEFAULT CURRENT_DATE,
--      FOREIGN KEY(donut_id) REFERENCES  donuts(donut_id) ON DELETE CASCADE,
--      FOREIGN KEY(sale_id) REFERENCES  sales(sale_id) ON DELETE CASCADE,
--      FOREIGN KEY(ingred_id) REFERENCES  ingredients(ingred_id) ON DELETE CASCADE
-- );

/*
    'warnings'
    table store warnings for donuts and ingredients.

    for instance donut quantity is updated donut_quantity_check trigger is activate and donut quantity is less then or equle to 10 then.
    donut_quantity_check trigger sent warning in this table. And this hapen also for ingredients quantity.
*/
-- CREATE TYPE for_s AS ENUM('donut', 'ingred');

-- CREATE TABLE warnings(
--     warn_id SERIAL PRIMARY KEY,
--     type for_s,
--     donut_id INT,
--     ingred_id INT,
--     massage TEXT NOT NULL,
--     waring_date DATE DEFAULT CURRENT_DATE,
--     FOREIGN KEY(donut_id) REFERENCES donuts(donut_id) ON DELETE CASCADE,
--     FOREIGN KEY(ingred_id) REFERENCES ingredients(ingred_id) ON DELETE CASCADE
-- );


/*
    'canceled_sale_items'
    this table store all canceled sale items,
    the table content all value from sale_items.
*/
-- CREATE TABLE canceled_sale_items(
--     sale_id INT,
--     donut_id INT,
--     sale_quantity INT NOT NULL,
--     unit_price DECIMAL NOT NULL,
--     total_price DECIMAL,
--     canceled_date TIMESTAMP DEFAULT NOW()
-- );
