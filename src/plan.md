### **This folder containt full details about python source code.**


#### **📁 Folder Structure**
```
src/ 
│── plan.md              This is plan file this containt all tha details about all this dbms system in with python 
│── hasher_setup         This folder containt C source code of the make_hsah function
│   └── hash.c
│── services             This file containt all classes and function 
│   │── __init__.py
│   │── dBconnect.py
│   │── all_service.py
│   │── hasher.so
│   └── py_utils.py
│── process_sale.py      simple sales process
└── simple_report.py     Ths is main operation file 
```



### 1. **📁 hasher_src**: 
  #### **This Diractory containt hash system source code in C.** 

  * **hash.c**:\
        The dir containt hash.c file which containt super simple hash source code.\
        This file have ***int make_hash(*char pass)*** function. This function return password as an number,\
        and we use this number as a hash and this hash we store in database.
  * **hasher.so**:\
        This is sheard objict file, using this file we can use C function directly in Python.


### 2. **service** 
  #### **This is a module or library directory.**
  This dir have files that containt **Classes** and **functinos** these are use to create **CLI** app. \
  These **Classes** internaly use **DBConnect** class from **dBconnect.py** file.

 ### 1. **dBconect.py** 
  #### **This is a dBconect.py module or library file. This file have 1 Class.**
   #### **Class DBConnect**:
    This class have all functions that you neet to connect with database.

    0. DBConnect(username, passwd)
         username: postgreSql username,
         passwd  : database password

    1. connect_db:
        This is connection function use to connect with database this is also initial function, 
        so we need to use this function first.

    2. get_conn:
        This function return connection you need to use this function after connect_db() function.

    3. close_conn:
        This function use to off connection with database.


    Syntax:
    from psycopg.rows import dict_row
    
    conn = DBConnect(username, passwd)
  
    try:
        with conn.get_conn() as ctn:
            with ctn.cursor(row_factory=dict_row) as cur:
                cur.execute("SELECT donut_id, name FROM inventory.donuts LIMIT 1")
                table = fetchone()
                if table:
                    print(f"donut_id: {table['donut_id']}, donut_name: {table['name']})
    finaly:
        # this block off connection automatic
        conn.close_conn()


 ### 2. **all_service.py**: 
  This file containt all the classes and function that we neet to maintain donut_shop database.
  
   #### **Classes**
   ***NOT:*** Every class take connection as argument, must pass connection.\
   You can setup connection easily using services module in main.py file.
   ```
from services import SetUpConnection, HR 
import sys

# DBConnect as SetUpConnection 

def main():
    conn = SetUpConnection("username", "password") # give your user and password
    conn.connect_db()
    try:
        hr = HR(conn)
        hr.add_job("cook", 3000)
    except Exception as e:
        sys.stderr.write(f"Error: {e}\n")
    finally:
        conn.close_conn()


if __name__ == "__main__":
    main()
   ```
   
   ##### **Inventory**:
    This class have all the functions that's are use to manage **Inventory** in donut_shop PostgreSql database.

    add_ingred(name: str, unit_name: str, price: float):
      This function are use to add ingredients in database.
      Parameter:
        name      : ingredient name,
        unit_name : unit name like kg, gm and box etc,
        price     : ingredient price per unit

    add_categorie(name: str):
        This function are use to add catagorie for donuts
        Parameter:
          name: categorie name

    add_donut(name: str, cat_id: int, is_gluten_free: bool, price: float, quantity: int):
      This function are use to add donut.
      Parameter:
        name          : donut name,
        cat_id        : categorie id from categorie table,
        is_gluten_free: enter true of false,
        price         : donut price,
        quantity      : donut quantity you want to store

    connect_ingred_donut(donut_id: int, ingred_id: int, quantity: float):
      This function use to connect ingred with donut using donut and ingred id.
      Parameter:
        donut_id  : donut id,
        ingred id : ingredient id,
        quantity  : how maney quantity neet to create one donut

    add_ingred_stock_requirment(ingred_id: int, min_requir_level: float):
      This function use to add ingred minimum requirment level.
      Parameter:
        ingred_id       : ingredient id,
        min_requir_level: minimum requirment level,
        
    add_supplier(name: str, phone: str, city: str, area: str):
      This function use to add supplier.
      Parameter:
        name  : supplier name,
        phone : mobile number,
        city  : city,
        area  : city area
      
    purchase_from(supplier_id: int, ingred_id: int, unit_name: str, quantity: int, price_per_unit: float):
      This function use to record purchase from the supplier.
      Parameter:
        supplier_id   : supplier id from suppliers table,
        ingred_id     : ingredient id,
        unit_name     : unit like kg, gm etc,
        quantity      : how many quantity you bought,
        price_per_unit: price per unit
    
    give_discount(donut_id: int, discount_percent: int, start_date: str, end_date: str):
      This function use to give discount, basically it's reocrd discount details.
      Parameter:      
        donut_id        : donut_id,
        discount_percent: discount percent number 
        start_date      : discount start date,
        end_date        : discount end date
    
    change_ingred_price(ingred_id: int, new_price: float):
      This function use to change ingredient price.    
      Parameter:      
        ingred_id: ingredient id,
        new_price: new price of ingredient
    
    change_donut_price(donut_id: int, new_price: float):
      This function use to change donut price.
      Parameter:      
        donut_id  : donut id,
        new_price : new price of donut id

    get_donut_price(donut_id: int) -> float:
      This function use to get donut price by donut_id.
      Parameter:      
        donut_id: donut id
    
    record_waste(donut_id: int, quantity: int):
      This function use to record wasts.
      Parameter:     
        donut_id: donut id,
        quantity: quantity
    
    update_ingred_quantity(ingred_id: int, quantity: float, reason: str):
      This function use to update ingredient quantity. 
      Parameter:      
        ingred_id: ingredient id,
        quantity : quantity
        reason   : reason must between ('damaged', 'use', 'restock').
        
    increace_donut_quantity(donut_id: int, quantity: int): 
      This function use to increase donut quantity.
      Parameter:      
        donut_id
        quantity

    

  #### **HR**:
    This functions are use to manage hr like employees.
  
    add_job(role_names: str, base_salary: int)
      This function are use to add jobs.
      Parameter:
        role_name  : role must ('cook', 'cash', 'manager', 'saler')
        base_salary: salary or starting salary.
        
    add_shift(name: str, start_time: str, end_time: str)
      This function use to add employee shifts.
      Parameter:
        name      : shift name must be ('morging', 'day'),
        start_date: duty start time must be ('9 AM', '2 PM'),
        end_time  : duty start time must be ('2 PM', '10 PM')
    
    add_employee(role_id: int, shift_id: int, name: str, username: str, age: int, email: str, phone: str, passwd: str, current_salary: int, account: str, account_company: str, account_type: str, city: str, area: str)
      This function are use to add employee.
      Parameter:
        role_id         : role_id from job_roles table,
        shift_id        : shift id from, 
        name            : name employee name,
        username        : username like json_908,
        age             : age of employee must be grater then 18,
        email           : emali address,
        phone           : phone number,
        passwd          : password len must grater then 8 check by python regex,
        current_salary  : current salary for this cmployee,
        account         : bank or mobile banking account,
        account_company : account company for bank give bank name
        account_type    : account type is bank for bank for mobile banking enter m_bk
        city            : employee city,
        area            : leve 
    
    change_emp_shift(employee_id; int, new_shifts_id; int)
      This change employee shift function use to change employee shift.
      Parameter:
        employee_id  : employee id from employee table,
        new_shifts_id: new shift id from shifts table

    change_emp_salary(employee_id: int, new_salary: int)
      This change employee salary function use to change employee salary.
      Parameter:
        employee_id: employee id,
        new_salary : new salary

    pay_salary(employee_id: int, role_id: int)
      This payment salary function use to pay salary for employees.
      Parameter:
        employee_id: employee id,
        role_id    : role id from job_roles table

    delete_employee(employee_id: int, username: str)
      This delete employee function use to deactivate employee. This function update employees tables act_stat(active status) true to false.
      Parameter:
        employee_id: employee id,
        username   : username of employee from employees table,

    get_employee_passwd(employee_id: int, username: str)
      This function return employee password.
      Parameter:
        employee_id: employee id,
        username   : username


  
  ### **Sales**:
    This functions are use to manage customer and orders.

    add_customer(name: str, username: str, age: str, email: str, phone: str, passwd: str, city: str, area: str):
      This function use to add customer in customers table in donut_shop database.
      Parameter: 
        name    : name of customer, 
        username: username must unique, 
        age     : age must grater then 15, 
        email   : email address, 
        phone   : phone number, 
        passwd  : password len must grater then 8 check by python regex, 
        city    : city, 
        area    : area of city
      
    delete_customer(customer_id: int, username: str):
      This function use to deactivate customer. This customer update act_stat (active status) column in customers table true to false.
      Parameter:
        customer_id: customer id from customers table,
        username   : customer username from customers table
    
    get_passwd(customer_id: int, username: str) -> str:
      This function use to get customer password, if customer present this return password.
      Parameter:
        customer_id: customer id,
        username   : username      
    
    generate_sale_id(phone: str=None, customer_id: int=None) -> int:
      This function use to generate sale id for customer so customer can by maney product using this sale_id.
      Not down blow all function need sale id, so you can generate sale_id using this function.
      Parateter:
        phone       : if customer not have customer id then pass phone number,
        customer_id : if customer have customer id or customer account then pass

    record_items(sale_id: int, donut_id: int, quantity: int) -> float:
      This function use to record items or product using sale_id.
      Parameter:
        sale_id: sale id from generate_sale_id function,
        donut_id: donut id from donuts table,
        quantity: quantity
    
    record_payment(sale_id: int, payment_method: int, amount) -> int:
      This function use to record payment using sale_id. this function if return value 0 mean payment completed 
      if return 1 payment uncompleted.
      Paramter:
        sale_id       : sale_id,
        payment_method: Payment methods must between (cash, m_bk, cad) m_bk = mobile banking, crd = card
        amount        : amount

    change_sale_item_quantity(sale_id: int, donut_id: int,  quantity: int, reason: int) -> float:
      This function use to change saled item or product quantity after saled and before payment.
      This function also return new total price after changing quantity of product. Not function return full total price.
      Parameter:
        sale_id : sale_id,
        donut_id: donut id,
        quantity: quantity,
        reaosn  : reason for increase give 'add' and for decrease give 'damaged' or 'restock'

    cancel_item(sale_id: int, donut_id: int, reason: str) -> float:
      This function use to cancel sale item. This function also return new total price after cancel of product. 
      Not function return full total price.
      Parameter:
        sale_id : sale id,
        donut_id: donut id,
        reason  : reason must between ('damaged', 'restock')
        
    cancel_sale(sale_id: int, reason: str):
      This function use to cancel full sale or order.
      Parameter:
        sale_id: sale id,
        reason : reason must between ('damaged', 'restock')
        
    is_payment_complete(sale_id: int) -> int:
      You can check payment status using this function if return value 0 mean payment completed if return 1 payment uncompleted.
      Parameter:
        sale_id: sale id


  ### **py_utils.py**:
    This file containt 3 usefull and importent function.

    is_email(email: str) -> bool:
      This function use to check is valid email or not. This function return boolean value. 
      Email address can containt special character like _.#$%&'*/=?^`{|}\-~
      Parameter:  email

    is_valid_passwd(passwd: str) -> bool:
      This function validate password. This function return boolean value. Password must containt number, upper, lower case character 
      also password contain special character but it's opsional and password can not containt word password. 
      Example: 'jisan908password' this password is invalid becouse this containt password.
      Parameter: password

    make_hash(passwd: str) -> int:
      This function make password hash so you can store password or check password securely.
      This function writen in C langage you can see source file in '/donut_shop/src/hasher_src/hash.c'.
      Parameter: passwd
