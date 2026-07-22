### sales:
   #### **customers**: (customer_id, name, username, age, email, phone, password, location, act_stat, join_date)
    This table store all permanent customers.
    for store or add customer details use

    :CALL add_customer(g_name VARCHAR, g_username VARCHAR, g_age INT, g_email TEXT, g_phone TEXT[], g_passwd TEXT, g_location JSONB);
    g_name: customer name,
    g_username: username like na908_em,
    g_age: age mustbe grater then 15,
    g_email: email address,
    g_phone: customer phone number it's a list so you can sore moer then 1 phone number, 
    g_passwd: password. NOT password are hased column and this hased generate by python so you don't worry,
    g_location: suppli or depo location. this is jsonb data type so you use this format
        '{"city": city_name, "area": are_name, "zip": zip_number}'.

        
   #### **sales**: (sale_id, customer_id, phone, sale_stat, sale_date)
   #### **sale_items**: (sale_id, donut_id, sale_quantity, unit_price, sub_total)
   #### **payments**: (transaction_id, sale_id, payment_method, amount, payment_status, paid_date)
    sales, sale_items and payments are inter connected. this table record all sales history.
    sales table for handling sale_id using 1 sale_id customer can buy many products,
    sale_items for record all items name, quantity, price etc.
    payments for reocrd payments

   
   #### **canceled_sale_items**: (sale_id, donut_id, sale_quantity, unit_price, total_price, canceled_date)
    This table store all canceled sale items,
    the table content all value from sale_items.


### **analysis_view**:
#### This simple views use to generate daly_sale_report, monthly_sale_report etc.

  #### **daily_total_report**:
    This view show you daly total sale report like total_customer, total_saled_donuts, total_income.

  #### **daily_sale_report_by_donut**:
    This view show sale report this show 4 columns name, customer_count, total_saled, total_amount.

    columns:
      name          : name of the donut,
      customer_count: how many customer buy this donut,
      total_saled   : how many donuts are saled,
      total_amount  : total amount

  #### **sale_status_by_month**:
    This view show week and monthly report, this show donut_id, name, total_saled, week, month      
  
  #### **cancel_item_report**:
    This view show cancel item or product report with reason. Using this view you can find way this sales are canceled.
    this show name, total_cancellations, total_canceled_quantity, total_lost_revenue, reason, month
  


### ***Procedures***:

  #### ***generate_sale_id***:
    This procedure for generate sale_id so customer can by many product with 1 sale_id.

    Syntax:
    :CALL generate_sale_id(g_phone TEXT, g_customer_id INT DEFAULT NULL, v_sale_id OUT INT)
    g_phone      : give phone number if customer not have custmoer id else pass null,
    g_customer_id: give customer id if customer have else pass null
    v_sale_id    : it's a output variable so you can extract sale_id


  #### ***record_items***:
    This procedure for record product. This procedure return total price of product.

    :CALL record_items(sale_id INT, g_donut_id INT, g_quantity INT, v_total_price OUT DECIMAL)
    g_sale_id  : sale_id from generate_sale_id,
    g_donut_id : donut id,
    g_quantity : quantity
    v_total_price OUT DECIMAL: this is a output variable so you can extract total_price for each products


  #### ***record_payment***:(id, sale_id, payment_method, amount, payment_status, paid_at)
    This procedure record payment details.

    for record payment use:
    CALL record_payment(g_sale_id INT, g_payment_method pay_tyeps, g_amount INT, v_pay_stat INT)
    g_sale_id : sale_id from generate_sale_id procedure
    g_payment_method: payment methods must between (cash, m_bk, crd) crd = card, m_bk = mobile_banking
    g_amount: amount
    v_pay_stat: if payment successful then this return 0 this for python. python check if 0 transaction are successful if code is 1 then payment unsuccessful

    This porcedures are do many thinks automatic so you dont wary about.


  #### ***delete_customer***:
    use this procedure for deactivate customer.
    this procedure change customer act_stat (active status) true to false
    mean customer account is deactive.

    :CALL delete_customer(g_customer_id INT, g_username TEXT)
    g_customer_id: customer_id IF NOT remember pass NULL,
    g_username   : username IF NOT remember pass NULL. NOT: for deactivate or delete customer account you must pass customer_id or username or both.

    NOT: for delete_customer procedure not have password perameter becuse password are check by python


  #### ***change_sale_item_quantity***:
    This procedure increace or decreace quantity from sale_items table.

    :CALL change_sale_item_quantity(g_sale_id INT, g_donut_id INT, g_reason reasons, g_quantity INT, v_sub_total OUT DECIMAL);
    g_sale_id : sale_id from sale_items,
    g_donut_id: donut_id which donut quantity you want to change,
    g_reason  : reason must between ('restock', 'add', 'damaged'),
    g_quantity: how many quantity you want to increace or decreace. NOT: for increace you need to pass only number like 9,3 etc
                but decreace you neet to pass with - operatore like -3, -29 etc.
    v_sub_total: this is return new total price after increace or decreace


  #### ***cancel_item***:
    This procedure for cancel or exclud any item from sale item.
    The procedure also record change in inventory_logs table.

    Syntax:
    :CALL cancel_item(g_sale_id INT, g_donut_id INT, g_reason reasons, v_new_total OUT DECIMAL)
    g_sale_id: sale_id customre sale id,
    g_donut_id: which donut customer want to exclud,
    g_reason : reason must between ('restock', 'damaged')
    v_sub_total: this is return new total price after cancel item


  #### ***cancel_sale***:
    This procedure for cancel full sale.

    Syntax:
    :CALL cancel_sale(g_sale_id INT, g_reason reasons)
    g_sale_id: sale_id which sale you want to cancel,
    g_reason : reason must between ('restock', 'damaged')


  #### ***is_payment_complete***:
    This procedure check customer pay his bill completely or not.
    if customer pay his bill completely this give 0 mean payment successful,
    if payment not completed this give 1 maan unsuccessful.

    Syntax:
    :CALL is_payment_complete(g_sale_id INT, v_status OUT INT)
    g_sale_id: sale_id from procedure 'generate_sale_id'
    v_status: this return status the form of o or 1.

  #### ***get_passwd***:
    This procedure use to get customer password.

    Syntax:
    :CALL get_passwd(g_customer_id INT, g_username TEXT, v_passwd OUT TEXT, v_return_code OUT INT)
    g_customer_id : customer_id,
    g_username    : username,
    v_passwd      : this is output variabe this variabe containt password,
    v_return_code : return code for check password is founded or not if found this return 0 else 1
    

### ***Triggers***:
  ***after_sale_items_insert***
  	This trigger activate when insert data in 'sale_items' table
  	and then this trigger update donuts table's quantity.

  	This trigger also record inserted data in inventory_logs.
    for inventory_logs it's record (donut_id, sale_id, change_amount, reason, changed_table) this columns.
