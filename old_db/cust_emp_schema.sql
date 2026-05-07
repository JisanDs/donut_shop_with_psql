                                -- CUSTOMER AND EMPLOYEES MANAGEMENT


CREATE TYPE role_names AS ENUM('cook', 'cash', 'manager', 'saler');

CREATE TABLE job_roles(
    role_id SERIAL PRIMARY KEY,
    role_name role_names,
    base_salary INT NOT NULL
);


CREATE TYPE shifts AS ENUM('day', 'evening');

CREATE TABLE employees(
    employee_id SERIAL PRIMARY KEY,
    role_id INT,
    name VARCHAR(50) NOT NULL,
    username TEXT NOT NULL UNIQUE,
    age INT NOT NULL CHECK(age > 18),
    email TEXT NOT NULL,
    phone TEXT[],
    password TEXT,
    location JSONB,
    shift shifts,
    act_stat BOOLEAN,
    join_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY(role_id) REFERENCES job_roles(role_id) ON DELETE CASCADE
);


CREATE TABLE customers(
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


CREATE TYPE sale_status AS ENUM('completed', 'canceled');
CREATE TYPE payment_methods AS ENUM('cash', 'mobile_banking', 'card');

CREATE TABLE sales(
    sale_id SERIAL PRIMARY KEY,
    customer_id INT,
    phone TEXT,
    payment_method payment_methods,
    sale_stat sale_status,
    sale_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);


CREATE TABLE sale_items(
    sale_id INT,
    donut_id INT,
    sale_quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    sub_total DECIMAL(10, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    FOREIGN KEY(sale_id) REFERENCES sales(sale_id) ON DELETE CASCADE,
    FOREIGN KEY(donut_id) REFERENCES donuts(donut_id) ON DELETE CASCADE
);
