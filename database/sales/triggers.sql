/*
    1.  after_sale_items_insert
*/
CREATE OR REPLACE FUNCTION update_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE inventory.donuts
    SET quantity = quantity - NEW.sale_quantity
    WHERE donut_id = NEW.donut_id;

    INSERT INTO inventory.inventory_logs (donut_id, sale_id, change_amount, reason, changed_table)
    VALUES (NEW.donut_id, NEW.sale_id, -NEW.sale_quantity, 'sale', 'donuts');

    RETURN NEW;
END;
$$;

CREATE TRIGGER after_order_items_insert
AFTER INSERT ON sales.sale_items
FOR EACH ROW
EXECUTE FUNCTION update_stock();
