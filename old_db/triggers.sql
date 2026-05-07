/*
after_sale_items_insert
	This trigger activate when insert data in 'sale_items' table
	and then this trigger update donuts table's quantity.

	This trigger also record inserted data in inventory_logs.
*/

-- CREATE OR REPLACE FUNCTION update_stock()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     UPDATE donuts
--     SET quantity = quantity - NEW.sale_quantity
--     WHERE donut_id = NEW.donut_id;

--     INSERT INTO inventory_logs (donut_id, sale_id, change_amount, reason, changed_table)
--     VALUES (NEW.donut_id, NEW.sale_id, -NEW.sale_quantity, 'sale', 'sale_items');

--     RETURN NEW;
-- END;
-- $$;

-- CREATE TRIGGER after_order_items_insert
-- AFTER INSERT ON sale_items
-- FOR EACH ROW
-- EXECUTE FUNCTION update_stock();


/*
donut_quantity_check
    this trigger check when donuts table's quantity is updated
	if quantity is less then 10 then it's sent warning massage in warnings table
*/
-- CREATE OR REPLACE FUNCTION sent_warning_msg_for_donut()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     warn TEXT;
-- BEGIN
--     IF NEW.quantity <= 10 THEN
--         warn := format('Warning: donut id %s quantity is too low %s', NEW.donut_id, NEW.quantity);
--         INSERT INTO warnings(type, donut_id, massage)
--         VALUES ('donut', NEW.donut_id, warn);
--     END IF;

--     RETURN NEW;
-- END;
-- $$;

-- CREATE TRIGGER donut_quantity_check
-- AFTER UPDATE ON donuts
-- FOR EACH ROW
-- EXECUTE FUNCTION sent_warning_msg_for_donut();


/*
ingred_quantity_check
    This trigger check when ingred_stock table's current_stock_level is updated,
	if current_stock_level is less then min_required_level then it's sent warning massage in warnings table
*/
-- CREATE OR REPLACE FUNCTION sent_warning_msg_for_ingred()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     warn TEXT;
-- BEGIN
--     IF NEW.current_stock_level <= NEW.min_required_level THEN
--         warn := format('Warning: ingred id %s quantity is too low %s', NEW.current_stock_level, NEW.min_required_level);
--         INSERT INTO warnings(type, ingred_id, massage)
--         VALUES ('ingred', NEW.ingred_id, warn);
--     END IF;

--     RETURN NEW;
-- END;
-- $$;

-- CREATE TRIGGER ingred_quantity_check
-- AFTER UPDATE ON ingred_stock
-- FOR EACH ROW
-- EXECUTE FUNCTION sent_warning_msg_for_ingred();


/*
after_insert_donut
	this trigger activate when insert data in 'donuts' table
	and then this trigger update donuts table's quantity
*/
-- CREATE OR REPLACE FUNCTION record_donut_insert()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     INSERT INTO inventory_logs (donut_id, change_amount, reason)
--     VALUES (NEW.donut_id, NEW.change_amount, 'add');

--     RETURN NEW;
-- END;
-- $$;

-- CREATE TRIGGER after_insert_donut
-- AFTER INSERT ON donuts
-- FOR EACH ROW
-- EXECUTE FUNCTION record_donut_insert();


/*
ingred_stock_update
    this trigger activate when data insert on purchases
    this trigger add ingred quantity in ingred_stock
*/
-- CREATE OR REPLACE FUNCTION update_ingred_stock()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     UPDATE ingred_stock
--     SET current_stock_level = current_stock_level + NEW.quantity_bought
--     WHERE ingred_id = NEW.ingred_id;

--     INSERT INTO inventory_logs(ingred_id, change_amount, reason)
--     VALUES (NEW.ingred_id, NEW.quantity_bought, 'add');

--     RETURN NEW;
-- END;
-- $$;

-- CREATE TRIGGER ingred_stock_update
-- AFTER INSERT ON purchases
-- FOR EACH ROW
-- EXECUTE FUNCTION update_ingred_stock();
