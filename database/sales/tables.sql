CREATE TYPE sales.status AS ENUM('completed', 'canceled');

CREATE TABLE sales.customers(
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    username TEXT NOT NULL UNIQUE,
    age INT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT[],
    password TEXT NOT NULL,
    location JSONB,
    act_stat BOOLEAN,
    join_date DATE DEFAULT CURRENT_DATE
);


CREATE TABLE sales.sales(
    sale_id SERIAL PRIMARY KEY,
    customer_id INT,
    phone TEXT NOT NULL,
    sale_stat sales.status,
    sale_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY(customer_id) REFERENCES sales.customers(customer_id) ON DELETE CASCADE
);


CREATE TABLE sales.sale_items(
    sale_id INT NOT NULL,
    donut_id INT NOT NULL,
    sale_quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    sub_total DECIMAL(10, 2),
    FOREIGN KEY(sale_id) REFERENCES sales.sales(sale_id) ON DELETE CASCADE,
    FOREIGN KEY(donut_id) REFERENCES inventory.donuts(donut_id) ON DELETE CASCADE
);


CREATE TABLE sales.payments(
    transaction_id SERIAL PRIMARY KEY,
    sale_id INT NOT NULL,
    payment_method pay_types NOT NULL,
    amount NUMERIC(15, 2) NOT NULL,
    payment_status sales.status NOT NULL,
    paid_date TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY(sale_id) REFERENCES sales.sales(sale_id) ON DELETE CASCADE
);


CREATE TABLE sales.canceled_sale_items(
    sale_id INT NOT NULL,
    donut_id INT NOT NULL,
    sale_quantity INT NOT NULL,
    unit_price DECIMAL NOT NULL,
    total_price DECIMAL,
    canceled_date TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY(sale_id) REFERENCES sales.sales(sale_id) ON DELETE CASCADE,
    FOREIGN KEY(donut_id) REFERENCES inventory.donuts(donut_id) ON DELETE CASCADE
);
