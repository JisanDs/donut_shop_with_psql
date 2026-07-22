/*
            this is hr human recource scheam tests
*/

/*
    lets add some job ro add data in job_role tables
*/
-- CALL add_job('manager', 5000);
-- CALL add_job('cook', 3000);
-- CALL add_job('cash', 2500);
-- CALL add_job('saler', 2200);


/*
    lets add shifts in shifts table
*/
-- CALL add_shift('morning', '9 AM', '2 PM');
-- CALL add_shift('day', '2 PM', '10 PM');


/*
    lets add employee in donut_shop
*/
-- CALL add_employee(1, 1, 'Alexander Müller', 'alex_m', 34, 'alex@example.com', ARRAY['+49123456789'], 'pass123', 5500, 'DE1234567890', 'Deutsche Bank', 'bank', '{"city": "Berlin", "zip": "10115"}'::jsonb);
-- CALL add_employee(2, 2, 'Sarah Jenkins', 'sarah_j', 28, 'sarah@example.com', ARRAY['+13125550199'], 'cookpass', 3200, '123456789', 'PayPal', 'm_bk', '{"city": "Chicago", "zip": "60601"}'::jsonb);
-- CALL add_employee(3, 1, 'Yuki Tanaka', 'yuki_t', 25, 'yuki@example.com', ARRAY['+819012345678'], 'cashier789', 2700, 'JP987654321', 'Mizuho Bank', 'bank', '{"city": "Tokyo", "zip": "100-0001"}'::jsonb);
-- CALL add_employee(4, 2, 'Carlos Rodriguez', 'carlos_r', 30, 'carlos@example.com', ARRAY['+34600123456'], 'sale99', 2400, '34600123456', 'Bizum', 'm_bk', '{"city": "Madrid", "zip": "28001"}'::jsonb);
-- CALL add_employee(4, 2, 'Fatima Al-Sayed', 'fatima_s', 27, 'fatima@example.com', ARRAY['+971501234567'], 'dubai_secure', 2600, 'AE76001000', 'Emirates NBD', 'bank', '{"city": "Dubai", "zip": "00000"}'::jsonb);


/*
    changeing shifts for emoloyee_id 1 morning to day
*/
-- CALL change_emp_shift(1, 2);


/*
    changeing salary for emoloyee_id 2 3200 to 3500
*/
-- CALL change_emp_salary(2, 3500);


/*
    lets pay salary
*/
-- CALL pay_salary(3, 3);
-- CALL pay_salary(1, 1);
-- CALL pay_salary(4, 2); -- this give error msg


/*
    let's deactivate employee
*/
-- CALL delete_employee(4, 'carlos_r');
-- CALL delete_employee(4, 'jisan_j');
-- CALL delete_employee(3, 'yuki_t');


/*
    let's see employee password
*/
-- DO $$
-- DECLARE
--     v_passwd TEXT;
--     v_return_code INT;
-- BEGIN
--     CALL get_employee_passwd(1, 'alex_m', v_passwd, v_return_code);

--     IF v_return_code = 0 THEN
--         RAISE NOTICE 'Employee password: %', v_passwd;
--     ELSE
--         RAISE EXCEPTION 'Password not found return code %', v_return_code;
--     END IF;
-- END;
-- $$;


/*
            this is inventory schema test
*/

/*
    lets add ingredients in ingredients table
*/
-- CALL add_ingred('Flour', 'kg', 60.00);
-- CALL add_ingred('Sugar', 'kg', 90.00);
-- CALL add_ingred('Chocolate', 'gm', 0.50);
-- CALL add_ingred('Yeast', 'box', 120.00);


/*
    add some categories in categories
*/
-- CALL add_categorie('Classic');
-- CALL add_categorie('Chocolate Special');
-- CALL add_categorie('Gluten Free');

/*
    add donuts in donuts table
*/
-- CALL add_donut('Classic Glazed', 1, false, 4.00, 50);
-- CALL add_donut('Choco Blast', 2, false, 8.00, 30);
-- CALL add_donut('Healthy Oats Donut', 3, true, 20.00, 20);


/*
    connect donuts to ingredients this data saved in donut_ingreds table
*/
    -- Choco Blast for 100 gm chocolate:
-- CALL connect_ingred_donut(2, 3, 100);
    -- Classic Glazed for 0.5 gm flour:
-- CALL connect_ingred_donut(1, 1, 0.5);


/*
    add supplier in suppliers table
*/
-- CALL add_supplier('Global Foods', ARRAY['+12345678', '+98765432'], '{"city": "New York", "zip": "10001"}'::jsonb);

/*
    add ingred stock requirment this data saved in ingred_stock.
    flour minimum requirment 10 kg
*/
-- CALL add_ingred_stock_requirment(1, 10.00);


/*
    buy 100 kg flour this data saved in purchases table
*/
-- CALL purchase_from(1, 1, 'kg', 100, 55.00);

/*
    give discount this data saved in discounts
*/
-- CALL give_discount(2, 10, '2026-05-06', '2026-05-13');


/*
    change price for donut this data saved in donut_price_history
*/
-- CALL change_donut_price(1, 130.00);

/*
    change price for ingredients this data saved in ingred_price_history
*/
-- CALL change_ingred_price(3, 0.60);

/*
   10 donut are waste:
   this data saved in waste_logs table
*/
-- CALL record_waste(2, 10);

/*
    5 kg flour are damaged:
    this data saved in inventory_logs table
*/
-- CALL update_ingred_quantity(1, -5, 'damaged');


/*
    get donut price from donuts table. this procedure mainly created for python
*/
-- DO $$
-- DECLARE
--     v_price DECIMAL;
-- BEGIN
--     CALL get_donut_price(1, v_price);

--     RAISE NOTICE 'Classic Glazed price: %', v_price;
-- END;
-- $$;


/*
    add more donut
*/
-- CALL increace_donut_quantity(1, 70);
-- CALL increace_donut_quantity(2, 70);
-- CALL increace_donut_quantity(3, 70);


/*
    let's add some customers
*/
-- CALL sales.add_customer('Liam Smith', 'liam_smith98', 28, 'liam.smith@gmail.com', ARRAY['+12025550101'], 'hashed_pass_1', '{"city": "New York", "country": "USA"}'::jsonb);
-- CALL add_customer('Emma Watson', 'emma_w_uk', 24, 'emma.watson@outlook.com', ARRAY['+442079460958'], 'hashed_pass_2', '{"city": "London", "country": "UK"}'::jsonb);
-- CALL add_customer('Hans Müller', 'hans_m_dev', 32, 'hans.m@company.de', ARRAY['+4930123456', '+49170112233'], 'hashed_pass_3', '{"city": "Berlin", "country": "Germany"}'::jsonb);
-- CALL add_customer('Yuki Tanaka', 'yuki_chan', 21, 'tanaka.yuki@yahoo.jp', ARRAY['+81312345678'], 'hashed_pass_4', '{"city": "Tokyo", "country": "Japan"}'::jsonb);
-- CALL add_customer('Oliver Brown', 'ollie_b', 30, 'oliver.brown@icloud.com', ARRAY['+61298765432'], 'hashed_pass_5', '{"city": "Sydney", "country": "Australia"}'::jsonb);


/*
    give order
*/

-- DO $$
-- DECLARE
--     v_sale_id INT; -- this variable for store sale id
--     v_total DECIMAL DEFAULT 0; -- total price
--     sub_total DECIMAL; -- this for extract sub_total for per sale
--     v_pay_stat INT; -- this for extract payment status if pay completed this return 0 else 1
--     v_status INT; -- this for extract full bill clear status if customer pay full bill this return 0 else 1
-- BEGIN
--     CALL generate_sale_id('+12025550101', 1, v_sale_id); -- generate sale id

--     CALL record_items(v_sale_id, 1, 3, sub_total); -- Classic Glazed 3 pice)
--     v_total := v_total + sub_total; -- extract total price per sale and add in v_total

--     CALL record_items(v_sale_id, 2, 2, sub_total); -- Choco Blast pice
--     v_total := v_total + sub_total; -- extract total price per sale and add in v_total

--     CALL record_payment(v_sale_id, 'crd', v_total, v_pay_stat); -- customer pay full bill with card
--     CALL is_payment_complete(v_sale_id, v_status);

--     RAISE NOTICE 'sale_id: %', v_sale_id;
--     RAISE NOTICE 'total price for all items: %', v_total;
--     RAISE NOTICE 'pay status: %', v_pay_stat;
--     RAISE NOTICE 'full payment status: %', v_status;
-- END;
-- $$;

        -- order B
-- DO $$
-- DECLARE
--     v_sale_id INT;
--     v_total DECIMAL;
--     v_pay_stat INT;
--     v_status INT;
-- BEGIN
--     CALL generate_sale_id('+442079460958', 2, v_sale_id);
--     CALL record_items(v_sale_id, 3, 5, v_total); -- Gluten Free donuts
--     CALL record_payment(v_sale_id, 'cash', 200, v_pay_stat);
--     CALL is_payment_complete(v_sale_id, v_status);

--     IF v_status = 1 THEN
--         RAISE NOTICE 'incomplete payment total price: %', v_total;
--     END IF;
-- END;
-- $$;

        -- order C
-- DO $$
-- DECLARE
--     v_sale_id INT;
--     v_total DECIMAL;
--     full_total DECIMAL;
-- BEGIN
--     CALL generate_sale_id('+4930123456', 3, v_sale_id);

--     CALL record_items(v_sale_id, 1, 2, v_total);
--     RAISE NOTICE '1. total: %', v_total;

--     full_total := v_total;

--     CALL record_items(v_sale_id,2, 2, v_total);
--     full_total := full_total + v_total;

--     RAISE NOTICE '1 full total %', full_total;

--     CALL cancel_item(v_sale_id, 2, 'damaged', full_total);
--     RAISE NOTICE 'Total sale price: %', full_total;
-- END;
-- $$;


        -- order D
-- DO $$
-- DECLARE
--     v_sale_id INT;
--     v_total DECIMAL DEFAULT 0;
--     sub_total DECIMAL;
--     v_pay_stat INT;
--     v_status INT;
-- BEGIN
--     CALL generate_sale_id('+12025550101', 3, v_sale_id);

--     CALL record_items(v_sale_id, 1, 3, sub_total);
--     v_total := v_total + sub_total;

--     CALL record_items(v_sale_id, 2, 2, sub_total);
--     v_total := v_total + sub_total;

--     CALL cancel_sale(v_sale_id, 'restock');
-- END;
-- $$;


            -- order D
-- DO $$
-- DECLARE
--     v_sale_id INT;
--     v_total DECIMAL DEFAULT 0;
--     sub_total DECIMAL;
--     v_pay_stat INT;
--     v_status INT;
-- BEGIN
--     CALL generate_sale_id('+44028880101', NULL, v_sale_id);

--     CALL record_items(v_sale_id, 1, 10, sub_total);
--     v_total := v_total + sub_total;

--     CALL record_items(v_sale_id, 2, 7, sub_total);
--     v_total := v_total + sub_total;

--     CALL change_sale_item_quantity(v_sale_id, 2, 'add', 3, sub_total);
--     v_total := sub_total;

--     CALL change_sale_item_quantity(v_sale_id, 1, 'restock', -3, sub_total);
--     v_total := v_total + sub_total;

--     CALL record_payment(v_sale_id, 'crd', v_total, v_pay_stat);
--     CALL is_payment_complete(v_sale_id, v_status);

--     RAISE NOTICE 'sale_id: %', v_sale_id;
--     RAISE NOTICE 'total price for all items: %', v_total;
--     RAISE NOTICE 'pay status: %', v_pay_stat;
--     RAISE NOTICE 'full payment status: %', v_status;
-- END;
-- $$;


/*
    let's get user password
*/
-- DO $$
-- DECLARE
--     v_passwd TEXT;
--     v_return_code INT;
-- BEGIN
--     CALL get_passwd(3, 'hans_m_dev', v_passwd, v_return_code);

--     IF v_return_code = 0 THEN
--         RAISE NOTICE 'Customer password: %', v_passwd;
--     ELSE
--         RAISE EXCEPTION 'Password not found return code %', v_return_code;
--     END IF;
-- END;
-- $$;



/*
    deactivate customer this mean in customers table customer act_stat fales mean deactivated customer
*/
-- CALL delete_customer(1, 'liam_smith98');
    -- check if act_stat 't' mean customer active if 'f' customer deactivated successfully
-- SELECT username, act_stat FROM customers WHERE customer_id = 1;
