-- ==========================================
-- 1. BASIC SETUP (Ingredients & Job Roles)
-- ==========================================

-- Adding Ingredients
-- CALL add_ingred('Organic Flour', 'kg', 1.20);
-- CALL add_ingred('Premium Cocoa Powder', 'kg', 15.50);
-- CALL add_ingred('Cane Sugar', 'kg', 0.80);
-- CALL add_ingred('Whole Milk', 'liter', 1.10);
-- CALL add_ingred('Unsalted Butter', 'kg', 5.00);

-- Setting up Job Roles
-- CALL add_job('cook', 3500);
-- CALL add_job('manager', 4200);
-- CALL add_job('cash', 2800);

-- -- ==========================================
-- -- 2. DONUT CREATION & RECIPE (The Bridge)
-- -- ==========================================

-- Adding Donuts
-- CALL add_donut('Midnight Chocolate Dream', FALSE, 3.50);
-- CALL add_donut('Classic Glazed Bliss', FALSE, 2.50);
-- CALL add_donut('Gluten-Free Berry Spark', TRUE, 4.00);

-- Connecting Ingredients with Quantity (The new column logic)
-- Format: CALL connect_ingred_donut(donut_id, ingred_id, quantity_needed)
-- CALL connect_ingred_donut(1, 1, 0.050); -- 50g Flour for Midnight Chocolate
-- CALL connect_ingred_donut(1, 2, 0.020); -- 20g Cocoa for Midnight Chocolate
-- CALL connect_ingred_donut(1, 5, 0.015); -- 15g Butter for Midnight Chocolate

-- -- ==========================================
-- -- 3. HUMAN RESOURCES (Employees & Customers)
-- -- ==========================================

-- -- Adding Employees (Using JSONB for international location format)
-- CALL add_employee(
--     'John Doe', 'johndoe_staff', 'cook', 28,
--     'john.doe@email.com', ARRAY['+12025550101'], 'securePass123',
--     '{"city": "New York", "area": "Brooklyn", "zip": "11201"}', 'day'
-- );

-- Adding a Permanent Customer
-- CALL add_customer(
--     'Alice Smith', 'alice_01', 24,
--     'alice.s@email.com', ARRAY['+12025550199'], 'password88',
--     '{"city": "New York", "area": "Manhattan", "zip": "10001"}'
-- );

-- -- ==========================================
-- -- 4. SUPPLY CHAIN (Suppliers & Purchases)
-- -- ==========================================

-- Adding a Supplier
-- CALL add_supplier(
--     'Global Grain Co.', ARRAY['+18005550122'],
--     '{"city": "Chicago", "area": "Industrial Zone", "zip": "60601"}'
-- );

-- ==========================================
-- SETTING MINIMUM STOCK REQUIREMENTS
-- (This must be done before purchases or sales)
-- ==========================================

-- Setting requirements for our ingredients
-- Format: CALL add_ingred_stock_requirment(g_ingred_id, g_min_requir_level)

-- CALL add_ingred_stock_requirment(1, 10.00); -- Minimum 10kg Flour needed
-- CALL add_ingred_stock_requirment(2, 5.00);  -- Minimum 5kg Cocoa needed
-- CALL add_ingred_stock_requirment(3, 8.00);  -- Minimum 8kg Sugar needed
-- CALL add_ingred_stock_requirment(4, 20.00); -- Minimum 20 Liters Milk needed
-- CALL add_ingred_stock_requirment(5, 5.00);  -- Minimum 5kg Butter needed

-- ==========================================
-- NOW PROCEED TO PURCHASES (Stock In)
-- ==========================================

-- After setting the requirements, we add stock from suppliers
-- CALL purchase_from(1, 1, 'kg', 100, 1.10); -- 100kg Flour bought
-- CALL purchase_from(1, 2, 'kg', 20, 15.00); -- 20kg Cocoa bought


-- ==========================================
-- NOW PLACE ORDER OR BY SOME DONUTS
-- ==========================================

-- generate_sale_id(IN g_pay_method payment_methods, g_phone text, g_customer_id integer, OUT v_sale_id integer); -- this is for genrate sale_id
-- record_items(g_sale_id integer, g_donut_id integer, g_quantity integer, OUT v_total_price numeric); -- this is for record items

-- this methods for if customer have permanent account or customer have customer_id
-- DO $$
-- DECLARE
--     v_sale_id INT; -- for extract sale_id
--     sub_total DECIMAL; -- for extract total_price per sale
--     total_price DECIMAL; -- this is for calculate full total
-- BEGIN
--     -- this gererate sale_id for customer
--     CALL generate_sale_id('cash', NULL, 1, v_sale_id);

--     -- now customer by many product with record_items
--     CALL record_items(v_sale_id, 3, 3, sub_total);
--     total_price := total_price + sub_total;

--     CALL record_items(v_sale_id, 1, 10, sub_total);
--     total_price := total_price + sub_total;

--     CALL record_items(v_sale_id, 2, 7, sub_total);
--     total_price := total_price + sub_total;

--     RAISE NOTICE 'Total price of donuts is %', total_price;
-- END;
-- $$;


-- this methods for if customer not have permanent account or customer_id
-- DO $$
-- DECLARE
--     v_sale_id INT; -- for extract sale_id
--     sub_total DECIMAL; -- for extract total_price per sale
--     total_price DECIMAL; -- this is for calculate full total
-- BEGIN
--     -- this gererate sale_id for customer
--     CALL generate_sale_id('cash', '+12025550999', NULL, v_sale_id);

--     -- now customer by many product with record_items
--     CALL record_items(v_sale_id, 3, 3, sub_total);
--     total_price := total_price + sub_total;

--     CALL record_items(v_sale_id, 1, 10, sub_total);
--     total_price := total_price + sub_total;

--     CALL record_items(v_sale_id, 2, 7, sub_total);
--     total_price := total_price + sub_total;

--     RAISE NOTICE 'Total price of donuts is %', total_price;
-- END;
-- $$;
