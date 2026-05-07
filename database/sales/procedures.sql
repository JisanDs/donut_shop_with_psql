CREATE OR REPLACE PROCEDURE sales.add_customer(
    g_name VARCHAR,
    g_username TEXT,
    g_age INT,
    g_email TEXT,
    g_phone TEXT[],
    g_passwd TEXT,
    g_location JSONB
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF g_age < 15 THEN
        RAISE EXCEPTION 'age mustbe greater then 15 you gave: %', g_age;
    END IF;

    INSERT INTO sales.customers (name, username, age, email, phone, password, location, act_stat)
    VALUES (g_name, g_username, g_age, g_email, g_phone, g_passwd, g_location, true);

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE sales.delete_customer(
    g_customer_id INT,
    g_username TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM sales.customers
    WHERE customer_id = g_customer_id AND username = g_username;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid: customer_id or oter details are wrong';
    END IF;

    UPDATE sales.customers SET act_stat = false
    WHERE customer_id = g_customer_id AND username = g_username;

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE sales.get_passwd(
    g_customer_id INT,
    g_username TEXT,
    v_passwd OUT TEXT,
    v_return_code OUT INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT password INTO v_passwd FROM sales.customers
    WHERE username = g_username AND customer_id = g_customer_id;

    IF NOT FOUND THEN
        v_return_code := 1;
    ELSE
        v_return_code := 0;
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE sales.generate_sale_id(
    g_phone TEXT,
    g_customer_id INT,
    v_sale_id OUT INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO sales.sales (customer_id, phone, sale_stat)
    VALUES (g_customer_id, g_phone, 'completed')
    RETURNING sale_id INTO v_sale_id;

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE sales.record_items(
    g_sale_id INT,
    g_donut_id INT,
    g_quantity INT,
    v_total_price OUT DECIMAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_quantity INT;
    v_unit_price DECIMAL;
BEGIN
    SELECT price, quantity INTO v_unit_price, v_quantity FROM inventory.donuts WHERE donut_id = g_donut_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid donut id: % not exists', g_donut_id;
    END IF;

    IF g_quantity > v_quantity THEN
        RAISE EXCEPTION 'donut quantity is too low current quantity: %, you gave: %', v_quantity, g_quantity;
    ELSE
        v_total_price := v_unit_price * g_quantity;

        INSERT INTO sales.sale_items(sale_id, donut_id, sale_quantity, unit_price, sub_total)
        VALUES (g_sale_id, g_donut_id, g_quantity, v_unit_price, v_total_price);
    END IF;

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE sales.record_payment(
    g_sale_id INT,
    g_payment_method pay_types,
    g_amount DECIMAL,
    v_pay_stat OUT INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1 mean payment not successful
    v_pay_stat := 1;

    INSERT INTO sales.payments(sale_id, payment_method, amount, payment_status)
    VALUES (g_sale_id, g_payment_method, g_amount, 'completed');

    COMMIT;

    -- 0 mean payment successful
    v_pay_stat := 0;
END;
$$;


CREATE OR REPLACE PROCEDURE sales.is_payment_complete(
    g_sale_id INT,
    v_status OUT INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    requird_bill DECIMAL; -- this customer need to pay
    payed DECIMAL; -- customer is payed
BEGIN
    SELECT COALESCE(SUM(sub_total), 0) INTO requird_bill FROM sales.sale_items
    WHERE sale_id = g_sale_id;

    SELECT COALESCE(SUM(amount), 0) INTO payed FROM sales.payments
    WHERE sale_id = g_sale_id;

    -- check for customer pay full bill
    IF payed >= requird_bill THEN
        v_status := 0;
    ELSE
        v_status := 1;
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE sales.change_sale_item_quantity(
    g_sale_id INT,
    g_donut_id INT,
    g_reason reasons,
    g_quantity INT,
    v_sub_total OUT DECIMAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sale_quantity INT; -- this is for chacking if you want to decreace quantity proce make sure value is less then or equal to sale_quantity using this var
    v_unit_price DECIMAL;
    v_total_price DECIMAL;
BEGIN
    SELECT sale_quantity, unit_price INTO v_sale_quantity, v_unit_price FROM sales.sale_items
    WHERE sale_id = g_sale_id AND donut_id = g_donut_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid sale_id % or donut_id %', g_sale_id, g_donut_id;
    END IF;

    IF g_reason = 'restock' OR g_reason = 'damaged' THEN
        IF g_quantity > 0 THEN
            RAISE EXCEPTION 'Invalid: reason for (damaged, restock) you need to give negative value. you gave: %', g_quantity;
        END IF;
    END IF;

    IF g_quantity < 0 THEN
        IF ABS(g_quantity) > v_sale_quantity THEN
            RAISE EXCEPTION 'Invalid: you sale quantity is %, and you return %', v_sale_quantity, ABS(g_quantity);
        END IF;
    ELSIF g_quantity = 0 THEN
        RAISE EXCEPTION 'Invalid: quantity you gave: %', g_quantity;
    END IF;

    v_total_price := v_unit_price * g_quantity;

    UPDATE sales.sale_items
    SET sale_quantity = sale_quantity + g_quantity,
        sub_total = sub_total + v_total_price
    WHERE sale_id = g_sale_id AND donut_id = g_donut_id;

    SELECT SUM(sub_total) INTO v_sub_total FROM sales.sale_items
    WHERE donut_id = g_donut_id AND sale_id = g_sale_id;

    INSERT INTO inventory.inventory_logs (sale_id, donut_id, change_amount, reason, changed_table)
    VALUES (g_sale_id, g_donut_id, g_quantity, g_reason, 'sale_items');

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE cancel_item(
    g_sale_id INT,
    g_donut_id INT,
    g_reason reasons
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_quantity INT;
BEGIN
    INSERT INTO sales.canceled_sale_items (sale_id, donut_id, sale_quantity, unit_price, total_price)
    SELECT sale_id, donut_id, sale_quantity, unit_price, sub_total
    FROM sale_items WHERE sale_id = g_sale_id AND donut_id = g_donut_id
    RETURNING sale_quantity INTO v_quantity;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid sale_id -> % or donut_id -> % not found', g_sale_id, g_donut_id;
    END IF;

    UPDATE inventory.donuts
    SET quantity = quantity + v_quantity
    WHERE donut_id = g_donut_id;

    INSERT INTO inventory.inventory_logs (sale_id, donut_id, change_amount, reason, changed_table)
    VALUES (g_sale_id, g_donut_id, v_quantity, g_reason, 'donuts');

    DELETE FROM sales.sale_items
    WHERE sale_id = g_sale_id AND donut_id = g_donut_id;

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE cancel_sale(g_sale_id INT, g_reason reasons)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    PERFORM 1 FROM sales.sale_items WHERE sale_id = g_sale_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid: sale_id % not found', g_sale_id;
    END IF;

    FOR r IN
        INSERT INTO sales.canceled_sale_items (sale_id, donut_id, sale_quantity, unit_price, total_price)
        SELECT sale_id, donut_id, sale_quantity, unit_price, sub_total
        FROM sale_items WHERE sale_id = g_sale_id
        RETURNING donut_id, sale_quantity
    LOOP
        UPDATE inventory.donuts
        SET quantity = quantity + r.sale_quantity
        WHERE donut_id = r.donut_id;
    END LOOP;

    INSERT INTO inventory.inventory_logs (sale_id, donut_id, change_amount, reason, changed_table)
    SELECT sale_id, donut_id, sale_quantity, g_reason, 'donuts'
    FROM sale_items WHERE sale_id = g_sale_id;

    UPDATE sales.sales SET sale_stat = 'canceled' WHERE sale_id = g_sale_id;

    DELETE FROM sales.sale_items WHERE sale_id = g_sale_id;

    COMMIT;
END;
$$;
