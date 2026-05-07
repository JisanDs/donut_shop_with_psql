CREATE OR REPLACE FUNCTION record_shift_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO hr.shift_history (employee_id, old_shift_id, new_shift_id)
    VALUES (NEW.employee_id, OLD.shift_id, NEW.shift_id);

    RETURN NEW;
END;
$$;

CREATE TRIGGER record_emp_shift_change
AFTER UPDATE OF shift_id ON employees
FOR EACH ROW
EXECUTE FUNCTION record_shift_change();


CREATE OR REPLACE FUNCTION record_salary_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO hr.salary_history (employee_id, role_id, old_salary, new_salary)
    VALUES (NEW.employee_id, NEW.role_id, OLD.current_salary, NEW.current_salary);

    RETURN NEW;
END;
$$;

CREATE TRIGGER record_emp_salary_change
AFTER UPDATE OF current_salary ON employees
FOR EACH ROW
EXECUTE FUNCTION record_salary_change();
