                                        --> SHOP MANAGEMENT <--

/*
    this procedures are use to insert data in defrent tables
*/

-- 1. Ingredients:
-- >
-- CREATE OR REPLACE PROCEDURE add_ingred(
--     g_name VARCHAR,
--     g_unit_name VARCHAR, -- this like kg, gm, box
--     g_price_per_unit DECIMAL
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     IF g_price_per_unit <= 0 THEN
--         RAISE EXCEPTION 'price can not be zero or less then zero, you gave; %', g_price_per_unit;
--     END IF;

--     INSERT INTO ingredients (name, unit_name, price_per_unit)
--     VALUES (g_name, g_unit_name, g_price_per_unit);

--     COMMIT;
-- END;
-- $$;


-- 2. Donuts:
-->
-- CREATE OR REPLACE PROCEDURE add_donut(
--     g_name VARCHAR,
--     g_is_gluten_free BOOLEAN,
--     g_price DECIMAL,
--     g_quantity INT
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     IF g_price <= 0 THEN
--         RAISE EXCEPTION 'Price cannot be negative or zero. Given: %', g_price;
--     ELSE
--         INSERT INTO donuts(name, is_gluten_free, price, quantity)
--         VALUES (g_name, g_is_gluten_free, g_price, g_quantity);
--     END IF;

--     COMMIT;
-- END;
-- $$;


-- 3. Donut_Ingredients (The Bridge):
-->
-- CREATE OR REPLACE PROCEDURE connect_ingred_donut(
--     g_donut_id INT,
--     g_ingred_id INT,
--     g_quantity DECIMAL
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     PERFORM 1 FROM donuts WHERE donut_id = g_donut_id;
--     IF NOT FOUND THEN
--         RAISE EXCEPTION 'Invalid id donut_id: % not exists', g_donut_id;
--     END IF;

--     PERFORM 1 FROM ingredients WHERE ingred_id = g_ingred_id;
--     IF NOT FOUND THEN
--         RAISE EXCEPTION 'Invalid id ingred_id: % not exists', g_ingred_id;
--     END IF;

--     IF g_quantity <= 0 THEN
--         RAISE EXCEPTION 'Quantity can not be less then or equal to zero, you gave: %', g_quantity;
--     END IF;

--     INSERT INTO donut_ingreds(donut_id, ingred_id, ingred_quantity_needed)
--     VALUES (g_donut_id, g_ingred_id, g_quantity);

--     COMMIT;
-- END;
-- $$;


-- 4. ingred_stock
-- >
-- CREATE OR REPLACE PROCEDURE add_ingred_stock_requirment(
--     g_ingred_id INT,
--     g_min_requir_level DECIMAL
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     PERFORM 1 FROM ingredients WHERE ingred_id = g_ingred_id;
--     IF NOT FOUND THEN
--         RAISE EXCEPTION 'Invalid id ingred_id: % not exists in ingredients', g_ingred_id;
--     END IF;

--     IF g_min_requir_level <= 0 THEN
--         RAISE EXCEPTION 'min_required_level cannot be <= 0';
--     ELSE
--         INSERT INTO ingred_stock (ingred_id, current_stock_level, min_required_level)
--         VALUES (g_ingred_id, 0, g_min_requir_level);
--     END IF;

--     COMMIT;
-- END;
-- $$;


-- 5. Suppliers
-->
-- CREATE OR REPLACE PROCEDURE add_supplier(
--     g_name VARCHAR,
--     g_phone TEXT[],
--     g_location JSONB -- city, area, zip
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     INSERT INTO suppliers (name, phone, location)
--     VALUES (g_name, g_phone, g_location);
-- END;
-- $$;


-- 5. Purchases (Stock In):
-- >
-- CREATE OR REPLACE PROCEDURE purchase_from(
--     g_supplier_id INT,
--     g_ingred_id INT,
--     g_unit_name VARCHAR,
--     g_quantity INT,
--     g_price_per_unit DECIMAL
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     PERFORM 1 FROM suppliers WHERE supplier_id = g_supplier_id;
--     IF NOT FOUND THEN
--         RAISE EXCEPTION 'Invalid id supplier_id: % not exists', g_supplier_id;
--     END IF;

--     PERFORM 1 FROM ingredients WHERE ingred_id = g_ingred_id;
--     IF NOT FOUND THEN
--         RAISE EXCEPTION 'Invalid id ingred_id: % not exists', g_ingred_id;
--     END IF;

--     IF g_quantity <= 0 OR g_price_per_unit <= 0 THEN
--         RAISE EXCEPTION 'Invalid quantity or price cannot be zero or hint quantity %, price %', g_quantity, g_price_per_unit;
--     ELSE
--         INSERT INTO purchases (supplier_id, ingred_id, unit_name, quantity_bought, price_per_unit)
--         VALUES (g_supplier_id, g_ingred_id, g_unit_name, g_quantity, g_price_per_unit);
--     END IF;

--     COMMIT;
-- END;
-- $$;


                    -- CUSTOMER AND EMPLOYEES MANAGEMENT


-- 6. Customers:
-->
-- CREATE OR REPLACE PROCEDURE add_customer(
--     g_name VARCHAR,
--     g_username TEXT,
--     g_age INT,
--     g_email TEXT,
--     g_phone TEXT[],
--     g_passwd TEXT,
--     g_location JSONB
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     IF g_age < 15 THEN
--         RAISE EXCEPTION 'age mustbe greater then 15 you gave: %', g_age;
--     END IF;

--     INSERT INTO customers (name, username, age, email, phone, password, location, act_stat)
--     VALUES (g_name, g_username, g_age, g_email, g_phone, g_passwd, g_location, true);

--     COMMIT;
-- END;
-- $$;


                 -- CUSTOMER AND EMPLOYEES MANAGEMENT


-- 1. job_roles
-->
-- CREATE OR REPLACE PROCEDURE add_job(
--     g_role_name role_names,
--     g_base_salary INT
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     IF g_base_salary <= 0 THEN
--         RAISE EXCEPTION 'Salary can not be less then or zero you give: %', g_base_salary;
--     END IF;

--     INSERT INTO job_roles (role_name, base_salary)
--     VALUES (g_role_name, g_base_salary);

--     COMMIT;
-- END;
-- $$;


-- 2. employees

-- CREATE OR REPLACE PROCEDURE add_employee(
--     g_name VARCHAR,
--     g_username TEXT,
--     g_role_name VARCHAR,
--     g_age INT,
--     g_email TEXT,
--     g_phone TEXT[],
--     g_passwd TEXT,
--     g_location JSONB,
--     g_shift shifts
-- )
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     job_id INT;
-- BEGIN
--     SELECT role_id INTO job_id FROM job_roles WHERE role_name = g_role_name::role_names;

--     IF NOT FOUND THEN
--         RAISE EXCEPTION '% job not exists', g_role_name;
--     END IF;

--     IF g_age < 18 THEN
--         RAISE EXCEPTION 'age % less then 18 are not allowed', g_age;
--     ELSE
--         INSERT INTO employees (role_id, name, username, age, email, phone, password, location, shift, act_stat)
--         VALUES (job_id, g_name, g_username, g_age, g_email, g_phone, g_passwd, g_location, g_shift, true);
--     END IF;

--     COMMIT;
-- END;
-- $$;


-- 4. sales:
-- 5. sale_items:


-- CREATE OR REPLACE PROCEDURE generate_sale_id(
--     g_pay_method payment_methods,
--     g_phone TEXT,
--     g_customer_id INT,
--     v_sale_id OUT INT
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     INSERT INTO sales (customer_id, phone, payment_method, sale_stat)
--     VALUES (g_customer_id, g_phone, g_pay_method, 'completed')
--     RETURNING sale_id INTO v_sale_id;

--     COMMIT;
-- END;
-- $$;


-- CREATE OR REPLACE PROCEDURE record_items(
--     g_sale_id INT,
--     g_donut_id INT,
--     g_quantity INT,
--     v_total_price OUT DECIMAL
-- )
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     v_quantity INT;
--     v_unit_price DECIMAL;
-- BEGIN
--     SELECT price, quantity INTO v_unit_price, v_quantity FROM donuts WHERE donut_id = g_donut_id;

--     IF NOT FOUND THEN
--         RAISE EXCEPTION 'Invalid donut id: % not exists', g_donut_id;
--     END IF;

--     IF g_quantity > v_quantity THEN
--         RAISE EXCEPTION 'donut quantity is too low current quantity: %, you gave: %', v_quantity, g_quantity;
--     ELSE
--         v_total_price := v_unit_price * g_quantity;

--         INSERT INTO sale_items(sale_id, donut_id, sale_quantity, unit_price, total_price)
--         VALUES (g_sale_id, g_donut_id, g_quantity, v_unit_price, v_total_price);
--     END IF;

--     COMMIT;
-- END;
-- $$;


                        -- edite procedures

/*
    this procedure increace or decreace quantity from donuts table.

    :CALLL donut_stock(g_quantity, g_donut_id, reason);
    g_quantity: how many quantity you want to increace or decreace. NOT: for increace you need to pass only number like 9,3 etc
                but decreace you neet to pass with - operatore like -3, -29 etc
    g_donut_id: donut_id which donut quantity you want to change
    g_reason  : reason must between ('restock', 'add', 'damaged')
*/
-- CREATE OR REPLACE PROCEDURE donut_stock(
--     g_quantity INT,
--     g_donut_id INT,
--     g_reason reasons
-- )
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     v_quantity INT; -- this is for chacking if you want to decreace quantity proce make sure value is less then or equal to quantity using this var
-- BEGIN
--     SELECT quantity INTO v_quantity FROM donuts WHERE donut_id = g_donut_id;

--     IF NOT FOUND THEN
--         RAISE EXCEPTION 'Invalid dount_id % not exists', g_donut_id;
--     END IF;

--     IF g_quantity < 0 THEN
--         IF ABS(g_quantity) > v_quantity THEN
--             RAISE EXCEPTION 'Invalid: you donuts quantity is %, and you decreace %', v_quantity, ABS(g_quantity);
--         END IF;
--     END IF;

--     UPDATE donuts
--     SET quantity = quantity + g_quantity
--     WHERE donut_id = g_donut_id;

--     INSERT INTO inventory_logs (donut_id, change_amount, reason, changed_table)
--     VALUES (g_donut_id, g_quantity, g_reason, 'donuts');

--     COMMIT;
-- END;
-- $$;

/*
    this procedure increace or decreace quantity from sale_items table.

    :CALL change_sale_quantity(g_sale_id, g_sale_id, g_reason, g_quantity);
    g_sale_id : sale_id from sale_items,
    g_donut_id: donut_id which donut quantity you want to change,
    g_reason  : reason must between ('restock', 'add', 'damaged'),
    g_quantity: how many quantity you want to increace or decreace. NOT: for increace you need to pass only number like 9,3 etc
                but decreace you neet to pass with - operatore like -3, -29 etc

*/
-- CREATE OR REPLACE PROCEDURE change_sale_item_quantity(
--     g_sale_id INT,
--     g_donut_id INT,
--     g_reason reasons,
--     g_quantity INT
-- )
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     v_sale_quantity INT; -- this is for chacking if you want to decreace quantity proce make sure value is less then or equal to sale_quantity using this var
--     v_unit_price DECIMAL;
--     v_total_price DECIMAL;
-- BEGIN
--     SELECT sale_quantity, unit_price INTO v_sale_quantity, v_unit_price FROM sale_items
--     WHERE sale_id = g_sale_id AND donut_id = g_donut_id;

--     IF NOT FOUND THEN
--         RAISE EXCEPTION 'Invalid sale_id % or donut_id %', g_sale_id, g_donut_id;
--     END IF;

--     IF g_reason = 'restock' OR g_reason = 'damaged' THEN
--         IF g_quantity > 0 THEN
--             RAISE EXCEPTION 'Invalid: reason for (damaged, restock) you need to give negative value. you gave: %', g_quantity;
--         END IF;
--     END IF;

--     IF g_quantity < 0 THEN
--         IF ABS(g_quantity) > v_sale_quantity THEN
--             RAISE EXCEPTION 'Invalid: you sale quantity is %, and you return %', v_sale_quantity, ABS(g_quantity);
--         END IF;
--     ELSIF g_quantity = 0 THEN
--         RAISE EXCEPTION 'Invalid: quantity you gave: %', g_quantity;
--     END IF;

--     v_total_price := v_unit_price * g_quantity;

--     UPDATE sale_items
--     SET sale_quantity = sale_quantity + g_quantity,
--         total_price = total_price + v_total_price
--     WHERE sale_id = g_sale_id AND donut_id = g_donut_id;

--     INSERT INTO inventory_logs (sale_id, donut_id, change_amount, reason, changed_table)
--     VALUES (g_sale_id, g_donut_id, g_quantity, g_reason, 'sale_items');

--     COMMIT;
-- END;
-- $$;


/*
    This procedure for cancel or exclud any item from sale item.
    The procedure also record change in inventory_logs table.

    How to use:
    :CALL cancel_item(g_sale_id, g_donut_id, g_reason)
    g_sale_id: sale_id customre sale id,
    g_donut_id: which donut customer want to exclud,
    g_reason : reason must between ('restock', 'damaged')
*/
-- CREATE OR REPLACE PROCEDURE cancel_item(
--     g_sale_id INT,
--     g_donut_id INT,
--     g_reason reasons
-- )
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     v_quantity INT;
-- BEGIN
--     INSERT INTO canceled_sale_items (sale_id, donut_id, sale_quantity, unit_price, total_price)
--     SELECT sale_id, donut_id, sale_quantity, unit_price, total_price
--     FROM sale_items WHERE sale_id = g_sale_id AND donut_id = g_donut_id
--     RETURNING sale_quantity INTO v_quantity;

--     IF NOT FOUND THEN
--         RAISE EXCEPTION 'Invalid sale_id -> % or donut_id -> % not found', g_sale_id, g_donut_id;
--     END IF;

--     UPDATE donuts
--     SET quantity = quantity + v_quantity
--     WHERE donut_id = g_donut_id;

--     INSERT INTO inventory_logs (sale_id, donut_id, change_amount, reason, changed_table)
--     VALUES (g_sale_id, g_donut_id, v_quantity, g_reason, 'donuts');

--     DELETE FROM sale_items
--     WHERE sale_id = g_sale_id AND donut_id = g_donut_id;

--     COMMIT;
-- END;
-- $$;


/*
    cancel_sale:
    this procedure for cancel full sale.

    how to use:
    :CALL cancel_sale(g_sale_id, g_reason)
    g_sale_id: sale_id which sale you want to cancel,
    g_reason : reason must between ('restock', 'damaged')
*/
-- CREATE OR REPLACE PROCEDURE cancel_sale(g_sale_id INT, g_reason reasons)
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     r RECORD;
-- BEGIN
--     PERFORM 1 FROM sale_items WHERE sale_id = g_sale_id;
--     IF NOT FOUND THEN
--         RAISE EXCEPTION 'Invalid: sale_id % not found', g_sale_id;
--     END IF;

--     FOR r IN
--         INSERT INTO canceled_sale_items (sale_id, donut_id, sale_quantity, unit_price, total_price)
--         SELECT sale_id, donut_id, sale_quantity, unit_price, total_price
--         FROM sale_items WHERE sale_id = g_sale_id
--         RETURNING donut_id, sale_quantity
--     LOOP
--         UPDATE donuts
--         SET quantity = quantity + r.sale_quantity
--         WHERE donut_id = r.donut_id;
--     END LOOP;

--     INSERT INTO inventory_logs (sale_id, donut_id, change_amount, reason, changed_table)
--     SELECT sale_id, donut_id, sale_quantity, g_reason, 'donut'
--     FROM sale_items WHERE sale_id = g_sale_id;

--     UPDATE sales SET sale_stat = 'canceled' WHERE sale_id = g_sale_id;

--     DELETE FROM sale_items WHERE sale_id = g_sale_id;

--     COMMIT;
--     RAISE NOTICE 'Order canceled for sale_id %', g_sale_id;
-- END;
-- $$;


/*
    ingred_stock
    Use this procedure for when you want increace or decrease ingredients.

    How to use:
    :CALL ingred_quantity(g_ingred_id, g_quantity, g_reason)
    g_ingred_id: which ingredient amount you want to change,
    g_quantity : how many quantity want to change. NOT: for increace you need to pass only number like 9,3 etc
                 but decreace you neet to pass with - operatore like -3, -29 etc,
    g_reason   : reason must between ('damaged', 'use', 'restock')
*/
-- CREATE OR REPLACE PROCEDURE ingred_quantity(
--     g_ingred_id INT,
--     g_quantity DECIMAL,
--     g_reason reasons
-- )
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     current_quantity DECIMAL;
-- BEGIN
--     SELECT current_stock_level INTO current_quantity FROM ingred_stock WHERE ingred_id = g_ingred_id;

--     IF NOT FOUND THEN
--         RAISE EXCEPTION 'Invalid ingred_id % not found', g_ingred_id;
--     END IF;

--     IF g_reason = 'use' OR g_reason = 'damaged' THEN
--         IF g_quantity > 0 THEN
--             RAISE EXCEPTION 'Invalid: reason for (damaged, use) you need to give negative value. you gave: %', g_quantity;
--         END IF;
--     END IF;

--     IF g_quantity < 0 THEN
--         IF ABS(g_quantity) > current_quantity THEN
--             RAISE EXCEPTION 'Invalid: current ingredients quantity is %, and you want %', current_quantity, ABS(g_quantity);
--         END IF;
--     ELSIF g_quantity = 0 THEN
--         RAISE EXCEPTION 'Invalid: quantity you gave: %', g_quantity;
--     END IF;

--     UPDATE ingred_stock
--     SET current_stock_level = current_stock_level + g_quantity
--     WHERE ingred_id = g_ingred_id;

--     INSERT INTO inventory_logs (ingred_id, change_amount, reason, changed_table)
--     VALUES (g_ingred_id, g_quantity, g_reason, 'ingred_stock');

--     COMMIT;
-- END;
-- $$;


/*
    use this procedure for deactivate customer.
    this procedure change customer act_stat (active status) true to false
    mean customer account is deactive.

    :CALL delete_customer(g_customer_id, g_password)
    g_customer_id: customer_id IF NOT remember pass NULL,
    g_username   : username IF NOT remember pass NULL. NOT: for deactivate or delete customer account you must pass customer_id or username or both.
    g_password   : password must need
*/
-- CREATE OR REPLACE PROCEDURE delete_customer(
--     g_customer_id INT,
--     g_username TEXT,
--     g_password TEXT
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     UPDATE customers
--     SET act_stat = false
--     WHERE customer_id = g_customer_id
--     OR username = g_username
--     AND password = g_password;
-- END;
-- $$;


/*
    delete_employee:
    use this procedure for deactivate customer.
    this procedure change customer act_stat (active status) true to false
    mean customer account is deactive.

    :CALL delete_customer(g_employee_id, g_password)
    g_employee_id: employee_id IF NOT remember pass NULL,
    g_username   : username IF NOT remember pass NULL. NOT: for deactivate or delete employee account you must pass employee_id or username or both.
    g_password   : password must need
*/
-- CREATE OR REPLACE PROCEDURE delete_employee(
--     g_employee_id INT,
--     g_username TEXT,
--     g_password TEXT
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     UPDATE customers
--     SET act_stat = false
--     WHERE employee_id = g_employee_id
--     OR username = g_username
--     AND password = g_password;
-- END;
-- $$;
