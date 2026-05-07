CREATE TABLE inventory.ingredients(
    ingred_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    unit_name VARCHAR(20) NOT NULL,
    price_per_unit DECIMAL(10, 2) NOT NULL
);


CREATE TABLE inventory.categories(
    cat_id SERIAL PRIMARY KEY,
    categorie VARCHAR(100) NOT NULL UNIQUE
);


CREATE TABLE inventory.donuts(
    donut_id SERIAL PRIMARY KEY,
    cat_id INT,
    name VARCHAR(100) NOT NULL UNIQUE,
    is_gluten_free BOOLEAN NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY(cat_id) REFERENCES inventory.categories(cat_id) ON DELETE CASCADE
);


CREATE TABLE inventory.donut_ingreds(
    donut_id INT,
    ingred_id INT,
    ingred_quantity_needed DECIMAL(5,10) NOT NULL,
    FOREIGN KEY(donut_id) REFERENCES inventory.donuts(donut_id) ON DELETE CASCADE,
    FOREIGN KEY(ingred_id) REFERENCES inventory.ingredients(ingred_id) ON DELETE CASCADE
);


CREATE TABLE inventory.ingred_price_history(
    ingred_id INT,
    old_price DECIMAL(10, 2),
    new_price DECIMAL(10, 2),
    change_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY(ingred_id) REFERENCES inventory.ingredients(ingred_id) ON DELETE CASCADE
);


CREATE TABLE inventory.donut_price_history(
    donut_id INT,
    old_price DECIMAL(10, 2),
    new_price DECIMAL(10, 2),
    change_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY(donut_id) REFERENCES inventory.donuts(donut_id) ON DELETE CASCADE
);


CREATE TABLE inventory.suppliers(
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone TEXT[] NOT NULL,
    location JSONB
);


CREATE TABLE inventory.purchases(
    supplier_id INT,
    ingred_id INT,
    unit_name VARCHAR,
    quantity_bought INT NOT NULL,
    price_per_unit DECIMAL,
    purchase_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY(supplier_id) REFERENCES inventory.suppliers(supplier_id) ON DELETE CASCADE,
    FOREIGN KEY(ingred_id) REFERENCES inventory.ingredients(ingred_id) ON DELETE CASCADE
);


CREATE TABLE inventory.ingred_stock(
    ingred_id INT,
    current_stock_level DECIMAL,
    min_required_level DECIMAL,
    last_update_dt TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY(ingred_id) REFERENCES inventory.ingredients(ingred_id) ON DELETE CASCADE
);


CREATE TABLE inventory.discounts(
    donut_id INT,
    discount_percent INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    add_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY(donut_id) REFERENCES inventory.donuts(donut_id) ON DELETE CASCADE
);


CREATE TYPE inventory.for_s AS ENUM('donuts', 'ingred_stock');

CREATE TABLE inventory.warnings(
    warn_id SERIAL PRIMARY KEY,
    table_name inventory.for_s,
    donut_id INT,
    ingred_id INT,
    massage TEXT NOT NULL,
    warn_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY(donut_id) REFERENCES inventory.donuts(donut_id) ON DELETE CASCADE,
    FOREIGN KEY(ingred_id) REFERENCES inventory.ingredients(ingred_id) ON DELETE CASCADE
);


CREATE TABLE inventory.inventory_logs(
    log_id SERIAL PRIMARY KEY,
    donut_id INT,
    sale_id INT,
    ingred_id INT,
    changed_table VARCHAR,
    change_amount INT NOT NULL,
    reason reasons,
    log_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY(donut_id) REFERENCES  inventory.donuts(donut_id) ON DELETE CASCADE,
    FOREIGN KEY(sale_id) REFERENCES  sales.sales(sale_id) ON DELETE CASCADE,
    FOREIGN KEY(ingred_id) REFERENCES  inventory.ingredients(ingred_id) ON DELETE CASCADE
);


CREATE TABLE inventory.waste_logs(
    donut_id INT,
    quantity INT NOT NULL,
    date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY(donut_id) REFERENCES inventory.donuts(donut_id) ON DELETE CASCADE
);
