                                        -- SHOP MANAGEMENT

CREATE TABLE ingredients(
    ingred_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    unit_name VARCHAR(20) NOT NULL,
    price_per_unit DECIMAL(10, 2) NOT NULL
);


CREATE TABLE donuts(
    donut_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    is_gluten_free BOOLEAN NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL
);


CREATE TABLE donut_ingreds(
    donut_id INT,
    ingred_id INT,
    ingred_quantity_needed DECIMAL(5,10) NOT NULL,
    FOREIGN KEY(donut_id) REFERENCES donuts(donut_id) ON DELETE CASCADE,
    FOREIGN KEY(ingred_id) REFERENCES ingredients(ingred_id) ON DELETE CASCADE
);


CREATE TABLE suppliers(
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone TEXT[],
    location JSONB
);


CREATE TABLE purchases(
    supplier_id INT,
    ingred_id INT,
    unit_name VARCHAR,
    quantity_bought INT NOT NULL,
    price_per_unit DECIMAL,
    purchase_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY(supplier_id) REFERENCES suppliers(supplier_id) ON DELETE CASCADE,
    FOREIGN KEY(ingred_id) REFERENCES ingredients(ingred_id) ON DELETE CASCADE
);


CREATE TABLE ingred_stock(
    ingred_id INT,
    current_stock_level DECIMAL,
    min_required_level DECIMAL,
    last_update_dt TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY(ingred_id) REFERENCES ingredients(ingred_id) ON DELETE CASCADE
);
