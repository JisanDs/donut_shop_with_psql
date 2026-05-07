### **hr (human resource)**:

  ### ***Tables***:
  #### **job_roles**: (role_id, role_name, base_salary)
    This simply table containt all jobs.

    for add new job use
    :CALL add_job(g_role_name role_names, g_base_salary INT)
    g_role_name: role name must be between ('cook', 'sales', 'manager', 'cashier'),
    g_base_salary: give base salary


  #### **shifts**: (shift_id, shift_name, start_time, end_time)
    This table containt employees shifts like morning, day

    for add shifts use
    :CALL add_shift(g_name Shifts, g_start_item time_s, g_end_time time_s)
    g_name: name of shift must between ('morning', 'day'), 
    g_start_item: start time must between ('9 AM', '2 PM'), 
    g_end_time: end time must between ('2 PM', '10 PM')
    
  
  #### **employees**: (
    employee_id, role_id, shift_id, current_salary, name, username, age, email, phone, password, 
    account, account_company, account_type, location, act_stat, join_date
    )
    This table containt all employees details.

    for add new employee use
    :CALL add_employee(g_role_id INT, g_shift_id INT, g_name VARCHAR, g_username TEXT, g_age INT, g_email TEXT, g_phone TEXT[], g_passwd TEXT, g_current_salary INT, g_account TEXT, g_account_company VARCHAR, g_account_type pay_types, g_location JSONB, g_shift shifts)
      g_role_id: role_id from job_roles tables
      g_shift_id: shift id from shifts table
      g_name: employee name,
      g_username: username like emp908_em,
      g_age: age mustbe grater then 18,
      g_email: email address,
      g_phone: employees phone number it's a list so you can sore moer then 1 phone number,
      g_passwd: password, NOT password are hased column and this hased generate by python so you don't worry,
      g_current_salary: current salary
      g_account: accout for bank you give bank accout number and for mobile banking you give phone number, 
      g_account_company: account companey name for banck you neet to pass bank name,
      g_account_type: pay type must between ('bnk', 'm_bk') bnk = 'bank', m_bnk = 'mobile banking',
      g_location: employee location. this is jsonb data type so you use this format
          '{"city": city_name, "area": are_name, "zip": zip_number}'.
      g_shift: shift between 'day', 'evening'.


  #### **shift_history**: (employee_id, old_shift_id, new_shift_id, change_date)
    This table containt all shifts change history.
    This maintain by trigger name record 'record_shift_change'

  
  #### **salary_history**: (employee_id, role_id, old_salary, new_salary, change_date)
    This table record all salary changes from employees table.
    This table maintain by trigger name 'record_emp_salary_change'


  #### ***payments_history***: (emploee_id, role_id, salary, pay_type, account, account_company, payment_date)
    This table all employees salary record.

    for pay salary use
    :CALL pay_salary(g_employee_id INT, g_role_id INT)
    g_employee_id: employee id,
    g_role_id: empoyee role id


  ### ***Procedures***:
  *use this procedures to do more operation on this tables*

  #### **change_emp_shift**:
    This procedure for changing employees shifts.
    
    Syntax:
    :CALL change_emp_shift(g_employee_id INT, g_new_shifts_id INT)
    g_employee_id: employee id from employees table,
    g_new_shifts_id: new_shift id from shifts table


  #### ***change_emp_salary***:
    This procedure for changing employees shifts.

    Syntax:
    :CALL change_emp_salary(g_employee_id INT, g_new_salary INT)
    g_employee_id: employee id from employees table,
    g_new_salary: new salary


  #### ***delete_employee***:
    Use this procedure for deactivate employee.
    This procedure change employee act_stat (active status) true to false mean employee account is deactive.

    Syntax:
    :CALL delete_employee(g_employee_id INT, g_username TEXT)
    g_employee_id: employee_id,
    g_username   : username,



  #### ***get_passwd***:
    This procedure use to get employee password.

    Syntax:
    :CALL get_employee_passwd(g_employee_id INT,g_username TEXT,v_passwd OUT TEXT,v_return_code OUT INT)
    g_employee_id : employee_id,
    g_username    : username,
    v_passwd      : this is output variabe this variabe containt password,
    v_return_code : return code for check password is founded or not if found this return 0 else 1
    

  ### ***Triggers***:

  #### ***record_emp_shift_change***
    When 'change_emp_shift' procedure used trigger activate and record
    (employee_id, old_shift_id, new_shift_id, change_date) this columns in shift_history from employees.


  #### ***record_emp_salary_change***:
    When 'change_salary' procedure used this trigger activate and
    record (employee_id, role_id, old_salary, new_salary, change_date) this columns in salary_history from employees.
