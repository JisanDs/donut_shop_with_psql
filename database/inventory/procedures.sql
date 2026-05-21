/*
    insert procedures:
    this procedures are use to insert data in defrent tables
*/


1. Ingredients:
>
CREATE OR REPLACE PROCEDURE inventory.add_ingred(
    g_name VARCHAR,
    g_unit_name VARCHAR, -- this like kg, gm, box
    g_price_per_unit DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF g_price_per_unit <= 0 THEN
        RAISE EXCEPTION 'price can not be zero or less then zero, you gave; %', g_price_per_unit;
    END IF;

    INSERT INTO inventory.ingredients (name, unit_name, price_per_unit)
    VALUES (g_name, g_unit_name, g_price_per_unit);

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE inventory.add_categorie(g_name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO inventory.categories(categorie)
    VALUES (g_name);

    COMMIT;
END;
$$;


-- 2. Donuts:
-->
CREATE OR REPLACE PROCEDURE inventory.add_donut(
    g_name VARCHAR,
    g_cat_id INT,
    g_is_gluten_free BOOLEAN,
    g_price DECIMAL,
    g_quantity INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM categories WHERE cat_id = g_cat_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid categorie id % not found.', g_cat_id;
    END IF;

    IF g_price <= 0 THEN
        RAISE EXCEPTION 'Price cannot be negative or zero. Given: %', g_price;
    ELSE
        INSERT INTO inventory.donuts(name, cat_id, is_gluten_free, price, quantity)
        VALUES (g_name, g_cat_id, g_is_gluten_free, g_price, g_quantity);
    END IF;

    COMMIT;
END;
$$;


-- 3. Donut_Ingredients (The Bridge):
-->
CREATE OR REPLACE PROCEDURE inventory.connect_ingred_donut(
    g_donut_id INT,
    g_ingred_id INT,
    g_quantity DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM inventory.donuts WHERE donut_id = g_donut_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid id donut_id: % not exists', g_donut_id;
    END IF;

    PERFORM 1 FROM inventory.ingredients WHERE ingred_id = g_ingred_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid id ingred_id: % not exists', g_ingred_id;
    END IF;

    INSERT INTO inventory.donut_ingreds(donut_id, ingred_id, ingred_quantity_needed)
    VALUES (g_donut_id, g_ingred_id, g_quantity);

    COMMIT;
END;
$$;


-- 4. ingred_stock
-- >
CREATE OR REPLACE PROCEDURE inventory.add_ingred_stock_requirment(
    g_ingred_id INT,
    g_min_requir_level DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM inventory.ingredients WHERE ingred_id = g_ingred_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid id ingred_id: % not exists in ingredients', g_ingred_id;
    END IF;

    IF g_min_requir_level <= 0 THEN
        RAISE EXCEPTION 'min_required_level cannot be <= 0';
    ELSE
        INSERT INTO inventory.ingred_stock (ingred_id, current_stock_level, min_required_level)
        VALUES (g_ingred_id, 0, g_min_requir_level);
    END IF;

    COMMIT;
END;
$$;


-- 5. Suppliers
-->
CREATE OR REPLACE PROCEDURE inventory.add_supplier(
    g_name VARCHAR,
    g_phone TEXT[],
    g_location JSONB -- city, area, zip
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO inventory.suppliers (name, phone, location)
    VALUES (g_name, g_phone, g_location);

    COMMIT;
END;
$$;


-- 5. Purchases (Stock In):
-- >
CREATE OR REPLACE PROCEDURE inventory.purchase_from(
    g_supplier_id INT,
    g_ingred_id INT,
    g_unit_name VARCHAR,
    g_quantity INT,
    g_price_per_unit DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM inventory.suppliers WHERE supplier_id = g_supplier_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid id supplier_id: % not exists', g_supplier_id;
    END IF;

    PERFORM 1 FROM inventory.ingredients WHERE ingred_id = g_ingred_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid id ingred_id: % not exists', g_ingred_id;
    END IF;

    IF g_quantity <= 0 OR g_price_per_unit <= 0 THEN
        RAISE EXCEPTION 'Invalid quantity or price cannot be zero or hint quantity %, price %', g_quantity, g_price_per_unit;
    ELSE
        INSERT INTO inventory.purchases (supplier_id, ingred_id, unit_name, quantity_bought, price_per_unit)
        VALUES (g_supplier_id, g_ingred_id, g_unit_name, g_quantity, g_price_per_unit);
    END IF;

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE inventory.give_discount(
    g_donut_id INT,
    g_discount_percent INT,
    g_start_date DATE,
    g_end_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM inventory.donuts WHERE donut_id = g_donut_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid donut_id % not found.', g_donut_id;
    END IF;

    INSERT INTO inventory.discounts(donut_id, discount_percent, start_date, end_date)
    VALUES (g_donut_id, g_discount_percent, g_start_date, g_end_date);

    COMMIT;
END


CREATE OR REPLACE PROCEDURE inventory.record_waste(
    g_donut_id INT,
    g_quantity INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM donuts WHERE donut_id = g_donut_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid donut_id % not found.', g_donut_id;
    END IF;

    INSERT INTO inventory.waste_logs(donut_id, quantity)
    VALUES (g_donut_id, g_quantity);

    UPDATE donuts SET quantity = quantity - g_quantity
    WHERE donut_id = g_donut_id;

    COMMIT;
END;
$$;



/*
    edite procedures:
    this procedures are use to perform operation is column
*/


CREATE OR REPLACE PROCEDURE inventory.change_donut_price(
    g_donut_id INT,
    new_price DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM inventory.donuts WHERE donut_id = g_donut_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid donut_id % not found.', g_donut_id;
    END IF;

    IF new_price <= 0 THEN
        RAISE EXCEPTION 'Invalid: price can not be less then or equel to zero you give: %', new_price;
    END IF;

    UPDATE inventory.donuts SET price = new_price
    WHERE donut_id = g_donut_id;

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE inventory.change_ingred_price(
    g_ingred_id INT,
    new_price DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM inventory.ingredients WHERE ingred_id = g_ingred_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid ingred_id % not found.', g_ingred_id;
    END IF;

    IF new_price <= 0 THEN
        RAISE EXCEPTION 'Invalid: price can not be less then or equel to zero you give: %', new_price;
    END IF;

    UPDATE inventory.ingredients SET price_per_unit = new_price WHERE ingred_id = g_ingred_id;

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE inventory.get_donut_price(
    g_donut_id INT,
    v_price OUT DECIMAL,
    v_stat_code OUT INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT price INTO v_price FROM inventory.donuts WHERE donut_id = g_donut_id;

    IF NOT FOUND THEN
        v_stat_code := 1;
    END IF;

    v_stat_code := 0;
END;
$$;


CREATE OR REPLACE PROCEDURE inventory.update_ingred_quantity(
    g_ingred_id INT,
    g_quantity DECIMAL,
    g_reason reasons
)
LANGUAGE plpgsql
AS $$
DECLARE
    current_quantity DECIMAL;
BEGIN
    SELECT current_stock_level INTO current_quantity FROM inventory.ingred_stock WHERE ingred_id = g_ingred_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid ingred_id % not found', g_ingred_id;
    END IF;

    IF g_reason = 'use' OR g_reason = 'damaged' THEN
        IF g_quantity > 0 THEN
            RAISE EXCEPTION 'Invalid: reason for (damaged, use) you need to give negative value. you gave: %', g_quantity;
        END IF;
    END IF;

    IF g_quantity < 0 THEN
        IF ABS(g_quantity) > current_quantity THEN
            RAISE EXCEPTION 'Invalid: current ingredients quantity is %, and you want %', current_quantity, ABS(g_quantity);
        END IF;
    ELSIF g_quantity = 0 THEN
        RAISE EXCEPTION 'Invalid: quantity you gave: %', g_quantity;
    END IF;

    UPDATE inventory.ingred_stock
    SET current_stock_level = current_stock_level + g_quantity
    WHERE ingred_id = g_ingred_id;

    INSERT INTO inventory.inventory_logs (ingred_id, change_amount, reason, changed_table)
    VALUES (g_ingred_id, g_quantity, g_reason, 'ingred_stock');

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE inventory.increace_donut_quantity(
    g_donut_id INT,
    g_quantity DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM donuts WHERE donut_id = g_donut_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid donut_id % not found', g_donut_id;
    END IF;

    IF g_quantity < 0 THEN
        RAISE EXCEPTION 'Invalid: quantity %', g_quantity;
    END IF;

    UPDATE inventory.donuts
    SET quantity = quantity + g_quantity
    WHERE donut_id = g_donut_id;

    INSERT INTO inventory.inventory_logs (donut_id, change_amount, reason, changed_table)
    VALUES (g_donut_id, g_quantity, 'add', 'donuts');

    COMMIT;
END;
$$;
