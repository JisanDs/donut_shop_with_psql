-- 1. job_roles
CREATE OR REPLACE PROCEDURE hr.add_job(
g_role_name hr.role_names,
g_base_salary INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF g_base_salary <= 0 THEN
        RAISE EXCEPTION 'Salary can not be less then or zero you give: %', g_base_salary;
    END IF;

    INSERT INTO hr.job_roles (role_name, base_salary)
    VALUES (g_role_name, g_base_salary);

    COMMIT;
END;
$$;


-- -- shifts
CREATE OR REPLACE PROCEDURE hr.add_shift(
    g_name hr.emp_shifts,
    g_start_time hr.time_s,
    g_end_time hr.time_s
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO hr.shifts(shift_name, start_time, end_time)
    VALUES (g_name, g_start_time, g_end_time);

    COMMIT;
END;
$$;


-- 2. employees
CREATE OR REPLACE PROCEDURE hr.add_employee(
    g_role_id INT,
    g_shift_id INT,
    g_name VARCHAR,
    g_username TEXT,
    g_age INT,
    g_email TEXT,
    g_phone TEXT[],
    g_passwd TEXT,
    g_current_salary INT,
    g_account TEXT,
    g_account_company VARCHAR,
    g_account_type pay_types,
    g_location JSONB
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM job_roles WHERE role_id = g_role_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid role_id % not found', g_role_id;
    END IF;

    PERFORM 1 FROM shifts WHERE shift_id = g_shift_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid shift_id % not found', g_shift_id;
    END IF;

    IF g_age < 18 THEN
        RAISE EXCEPTION 'age % less then 18 are not allowed', g_age;
    ELSE
        INSERT INTO hr.employees (
            role_id, shift_id, name, username, age, email, phone, password, current_salary,
            account, account_company, account_type, location, act_stat
        )
        VALUES (
            g_role_id, g_shift_id, g_name, g_username, g_age, g_email, g_phone, g_passwd, g_current_salary,
            g_account, g_account_company, g_account_type, g_location, true
        );
    END IF;

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE hr.change_emp_shift(
    g_employee_id INT,
    g_new_shift_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM employees WHERE employee_id = g_employee_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid employee_id % not found', g_employee_id;
    END IF;

    PERFORM 1 FROM shifts WHERE shift_id = g_new_shift_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid shift_id % not found', g_new_shift_id;
    END IF;

    UPDATE hr.employees
    SET shift_id = g_new_shift_id
    WHERE employee_id = g_employee_id;

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE hr.change_emp_salary(
    g_employee_id INT,
    g_new_salary INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM hr.employees WHERE employee_id = g_employee_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid employee_id % not found', g_employee_id;
    END IF;

    UPDATE hr.employees
    SET current_salary = g_new_salary
    WHERE employee_id = g_employee_id;

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE hr.pay_salary(
    g_employee_id INT,
    g_role_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_salary INT;
    v_pay_type pay_types;
    v_account TEXT;
    v_acc_company VARCHAR;
BEGIN
    PERFORM 1 FROM employees WHERE employee_id = g_employee_id AND role_id = g_role_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid employee_id % or role_id % not found', g_employee_id, g_role_id;
    END IF;

    SELECT current_salary, account, account_company, account_type
    INTO v_salary, v_account, v_acc_company, v_pay_type FROM hr.employees
    WHERE employee_id = g_employee_id AND role_id = g_role_id;

    INSERT INTO hr.payments_history (employee_id, role_id, salary, pay_type, account, account_company)
    VALUES (g_employee_id, g_role_id, v_salary, v_pay_type, v_account, v_acc_company);

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE hr.delete_employee(
    g_employee_id INT,
    g_username TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM hr.employees
    WHERE employee_id = g_employee_id AND username = g_username;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid employee_id or username';
    END IF;

    UPDATE hr.employees SET act_stat = false
    WHERE employee_id = g_employee_id AND username = g_username;

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE hr.get_employee_passwd(
    g_employee_id INT,
    g_username TEXT,
    v_passwd OUT TEXT,
    v_return_code OUT INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT password INTO v_passwd FROM hr.employees
    WHERE username = g_username AND employee_id = g_employee_id;

    IF NOT FOUND THEN
        v_return_code := 1;
    ELSE
        v_return_code := 0;
    END IF;
END;
$$;
