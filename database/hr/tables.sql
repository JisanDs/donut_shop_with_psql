CREATE TYPE hr.role_names AS ENUM('cook', 'cash', 'manager', 'saler');

CREATE TABLE hr.job_roles(
    role_id SERIAL PRIMARY KEY,
    role_name hr.role_names NOT NULL UNIQUE,
    base_salary INT NOT NULL
);


CREATE TYPE hr.emp_shifts AS ENUM('morning', 'day');
CREATE TYPE hr.time_s AS ENUM('9 AM', '2 PM', '10 PM');

CREATE TABLE hr.shifts(
    shift_id SERIAL PRIMARY KEY,
    shift_name hr.emp_shifts NOT NULL UNIQUE,
    start_time hr.time_s NOT NULL,
    end_time hr.time_s NOT NULL
);


CREATE TABLE hr.employees(
    employee_id SERIAL PRIMARY KEY,
    role_id INT NOT NULL,
    shift_id INT NOT NULL,
    current_salary INT,
    name VARCHAR(50) NOT NULL,
    username TEXT NOT NULL UNIQUE,
    age INT NOT NULL CHECK(age > 18),
    email TEXT NOT NULL,
    phone TEXT[] NULL,
    password TEXT NOT NULL,
    account TEXT NOT NULL,
    account_company VARCHAR(50) NOT NULL,
    account_type pay_types NOT NULL,
    location JSONB NOT NULL,
    act_stat BOOLEAN NOT NULL,
    join_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY(role_id) REFERENCES hr.job_roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY(shift_id) REFERENCES hr.shifts(shift_id) ON DELETE CASCADE
);


CREATE TABLE hr.shift_history(
    employee_id INT NOT NULL,
    old_shift_id INT NOT NULL,
    new_shift_id INT NOT NULL,
    change_date TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY(employee_id) REFERENCES hr.employees(employee_id) ON DELETE CASCADE
);


CREATE TABLE hr.salary_history(
    employee_id INT NOT NULL,
    role_id INT NOT NULL,
    old_salary INT NOT NULL,
    new_salary INT NOT NULL,
    change_date TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY(employee_id) REFERENCES hr.employees(employee_id) ON DELETE CASCADE,
    FOREIGN KEY(role_id) REFERENCES hr.job_roles(role_id) ON DELETE CASCADE
);


CREATE TABLE hr.payments_history(
    employee_id INT NOT NULL,
    role_id INT NOT NULL,
    salary INT NOT NULL,
    pay_type pay_types NOT NULL,
    account TEXT NOT NULL,
    account_company VARCHAR(50) NOT NULL,
    payment_date TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY(employee_id) REFERENCES hr.employees(employee_id) ON DELETE CASCADE,
    FOREIGN KEY(role_id) REFERENCES hr.job_roles(role_id) ON DELETE CASCADE
)
