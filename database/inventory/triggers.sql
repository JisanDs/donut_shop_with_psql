CREATE OR REPLACE FUNCTION sent_warning_msg_for_donut()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    warn TEXT;
BEGIN
    IF NEW.quantity <= 10 THEN
        warn := format('Warning: donut id %s quantity is too low %s', NEW.donut_id, NEW.quantity);
        INSERT INTO inventory.warnings(table_name, donut_id, massage)
        VALUES ('donuts', NEW.donut_id, warn);
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER donut_quantity_check
AFTER UPDATE ON inventory.donuts
FOR EACH ROW
EXECUTE FUNCTION sent_warning_msg_for_donut();


CREATE OR REPLACE FUNCTION sent_warning_msg_for_ingred()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    warn TEXT;
BEGIN
    IF NEW.current_stock_level <= NEW.min_required_level THEN
        warn := format('Warning: ingred id %s quantity is too low %s', NEW.current_stock_level, NEW.min_required_level);
        INSERT INTO inventory.warnings(table_name, ingred_id, massage)
        VALUES ('ingred_stock', NEW.ingred_id, warn);
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER ingred_quantity_check
AFTER UPDATE ON inventory.ingred_stock
FOR EACH ROW
EXECUTE FUNCTION sent_warning_msg_for_ingred();


CREATE OR REPLACE FUNCTION record_price_change_ingred()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO inventory.ingred_price_history (ingred_id, old_price, new_price)
    VALUES (NEW.ingred_id, OLD.price_per_unit, NEW.price_per_unit);

    RETURN NEW;
END;
$$;

CREATE TRIGGER record_ingred_price_change
AFTER UPDATE OF price_per_unit ON inventory.ingredients
FOR EACH ROW
EXECUTE FUNCTION record_price_change_ingred();


CREATE OR REPLACE FUNCTION record_price_change_donut()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO inventory.donut_price_history(donut_id, old_price, new_price)
    VALUES (NEW.donut_id, OLD.price, NEW.price);

    RETURN NEW;
END;
$$;

CREATE TRIGGER record_donut_price_change
AFTER UPDATE OF price ON inventory.donuts
FOR EACH ROW
EXECUTE FUNCTION record_price_change_donut();


CREATE OR REPLACE FUNCTION record_donut_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO inventory_logs (donut_id, changed_table, change_amount, reason)
    VALUES (NEW.donut_id, 'donuts', NEW.quantity, 'add');

    RETURN NEW;
END;
$$;

CREATE TRIGGER after_insert_donut
AFTER INSERT ON inventory.donuts
FOR EACH ROW
EXECUTE FUNCTION record_donut_insert();


CREATE OR REPLACE FUNCTION add_current_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE inventory.ingred_stock
    SET current_stock_level = current_stock_level + NEW.quantity_bought
    WHERE ingred_id = NEW.ingred_id;

    INSERT INTO inventory.inventory_logs(ingred_id, changed_table, change_amount, reason)
    VALUES (NEW.ingred_id, 'ingred_stock', NEW.quantity_bought, 'add');

    RETURN NEW;
END;
$$;

CREATE TRIGGER update_current_stock_level
AFTER INSERT ON inventory.purchases
FOR EACH ROW
EXECUTE FUNCTION add_current_stock();
