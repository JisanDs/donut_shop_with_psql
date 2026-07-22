## **inventory**:
   #### **ingredients**:
    This table for storing all ingred need to createing donuts.
    Columns: ingred_id, name, unit_name, price_per_unit
    
    for insert data you use this procedure
    :CALL add_ingred(g_name VARCHAR, g_unit_name VARCHAR, g_price_per_unit DECIMAL);
      g_name: name of ingredient,
      g_unit_name: unit name like gm, kg, box,
      g_price_per_unit: price;


   #### **categories**:
    This table simply save cataories.
    Columns: (cat_id INT, categorie VARCHAR)

    for add catagories use procedure
    :Call add_catagorie(g_name VARCHAR)
      g_name: the of categories, not name must be unique.


   #### **donuts**: 
    Simply this table store all donuts details.
    Columns: donut_id, cat_id, name, is_gluten_free, price, quantity
    
    For insert data in donuts you use
    :CALL add_donut(g_name VARCHAR, g_cat_id INT, g_is_gluten_free BOOLEAN, g_price DECIMAL, g_quantity INT)
      g_name: the name of donut,
      g_cat_id: this is catagorie id,
      g_is_gluten_free: store boolean data,
      g_price: price per donut,
      g_quantity: how maney donuts in shop. NOT: after order or sales quantity is automatic decrease using after_order_items_insert trigger,
                  And this trigger also record change data and store in inventory_logs tables with reason, date, sale_id.

  
   #### **donut_Ingreds**: 
    This table have all dependencies for creating donuts.
    This table store connection between donut and dependentenis as id from.
    Columns: donut_id, ingred_id, ingred_quantity_needed
    
    insert data use procedure
    :CALL connect_ingred_donut(g_donut_id INT, g_ingred_id INT, g_quantity INT)
      g_donut_id: donut_id,
      g_ingred_id: ingred_id,
      g_quantity: how maney ingredient needed for each donut.


   #### **ingred_stock**: 
    This table record ingred stock like current stock level, minimum requirment level
    NOT: for current_stock_level: You don't neet to pass current stock level it's store corrent stock
        when you purchess some ingredient or when you store data in purchases. Using trigger 'update_current_stock_level'
        automatic add data in current_stock_level from quantity_bought,
        so you need to insert first in this table using procedures before insert data on purchases table.
    Columns: ingred_id, current_stock_level, min_required_level, last_update_dt

    for insert data use
    :CALL add_ingred_stock_requirment(g_ingred_id INT, g_min_requir_level DECIMAL);
      g_ingred_id: ingred_id,
      g_min_requir_level: this is minimum requirment level of ingredient,

  
   #### **suppliers**: 
    This table save suppliers small details.
    Columns: supplier_id, name, phone, location
    
    for store data in table use
    :CALL add_supplier(g_name VARCHAR, g_phone TEXT[], g_location JSONB);
      g_name: supplier name,
      g_phone: supplier phone number it's a list so you can sore moer then 1 phone number,
      g_location: supplie or depo location. this is jsonb data type so you use this format
          '{"city": city_name, "area": are_name, "zip": zip_number}'.


   #### **purchases**: 
    this table recored all purchases.
    like supplier id, ingred id etc.
    Columns: supplier_id, ingred_id, unit_name, quantity_bought, price_per_unit, purchase_date
    
    for store data use
    :CALL purchase_from(g_supplier_id INT, g_ingred_id INT, g_unit_name VARCHAR, g_quantity INT, g_price_per_unit VARCHAR);
    g_supplier_id: supplier_id from suppliers table,
    g_ingred_id: store ingred_id from ingred_id which ingredient you by if ingredient not exists before buy
                you neet to store ingredient in ingredients.
    g_unit_name: unit name like gm, kg etc,
    g_quantity: how many quantity you bought,
    g_price_per_unit: price per like gm, kg etc.

      
   #### **discounts**: 
    This table use for adding discount for donuts.
    Column: (donut_id, discount_percent, start_date, end_date, add_date)

    for gave discount use procedure
    :Call give_discount(g_donut_id INT, g_discount_percent INT, g_start_date DATE, g_end_date DATE)
    g_donut_id: for which donut you want to add discount. give donut_id form donut table, 
    g_discount_percent: give discount percent, 
    g_start_date: give discount start date, 
    g_end_date: give discount end date

  #### ***ingred_price_history***:
    Column: ingred_id, old_price, update_price, change_date
   
    This table record all ingredient price change history,
    This table maintain by trigger when you change ingredient price using procedure name 'change_ingred_price'
    then 'record_ingred_price_change' is activated and add data in this table.

   
  #### **donut_price_history**: 
    Columns: donut_id, old_price, new_price, change_date
   
    This table record all donut price change history,
    This table maintain by trigger when you change donut price using procedure name 'change_donut_price'
    then 'record_donut_price_change' is activated and add data in this table.


   #### **inventory_logs**:
    This table containt verius table stock updates, inserts record.
    This table is maintain by differents triggers and procedures.
    Columns: (log_id, donut_id, sale_id, ingred_id, changed_table, change_amount, reason, log_date)
    
    for instance when any sales hapens
    'after_order_items_insert' trigger activate and update quantity of donuts
    and after that it's store data in in inventory_logs table,
    it store (log_id, donut_id, sales_id, change_amount, reason, changed_table, join_date).

    and other perspactive we have like
    if you store data in table purchases using procedure
    purchase_from(g_supplier_id, g_ingred_id, g_unit_name, g_quantity, g_price_per_unit, changed_table);
    then 'update_ingred_stock' activate and and store (log_id, ingred_id, change_amount, reason, log_date) thats all.

  
   #### **waste_logs**: 
    This table record all waste donut quantity.
    Column: donut_id, quantity, date
    
    for record waste use procedure
    :Call record_waste(g_donut_id INT, g_quantity INT)
    g_donut_id: donut id,
    g_quantity: give quantity

   
  #### **warnings**:
    This table store warnings for donuts and ingredients.
    Column: warn_id, table_name, donut_id, ingred_id, massage, warn_date
    
    for instance donut quantity is updated donut_quantity_check trigger is activate and donut quantity is less then or equle to 10 then, 
    donut_quantity_check trigger sent warning in this table. And this hapen also for ingredients quantity. 
    When ingred current_stock_level is less then or equle to min_required_level



## **Procedures**:
  *Some Usefull procedures*

  #### ***change_ingred_price***:
    this procedure use to change ingredient price.
  
    Use syntax:
    :Call change_ingred_price(g_id INT, new_price DECIMAL)
    g_id: ingredient id
    new_price: give new price


  #### ***change_donut_price***:
    this procedure use to change donut price.
    
    Use syntax:
    :Call change_donut_price(g_id INT, new_price DECIMAL)
    g_id: donut id
    new_price: give new price


  #### ***get_donut_price***:
    This procedure use to gat donut price by donut_id.
    This is mainly created for use in python.
    
    Syntax:
    :Call get_donut_price(g_donut_id INT, v_price OUT DECIMAL)
    g_donut_id: donut id,
    v_price: this is result variable mean this containt return price


  #### ***update_ingred_quantity***
    Use this procedure use to increace or decrease ingredient from ingredients.
    This procedure also record change in inventory_logs table
    in inventory_logs table this store (ingred_id, change_table, change_amount, reason)

    How to use:
    :CALL update_ingred_quantity(g_ingred_id INT, g_quantity INT, g_reason reasons)
    g_ingred_id: which ingredient amount you want to change,
    g_quantity : how many quantity want to change. 
        NOT: for increace you need to pass only number like 9,3 etc but decreace you neet to pass with - operatore like -3, -29 etc,
    g_reason   : reason must between ('damaged', 'use', 'restock')


  #### ***increace_donut_quantity***
    Use this procedure use to increace donut quantity from donuts.
    This procedure also record change in inventory_logs table
    in inventory_logs table this store (donut_id, change_table, change_amount, reason)

    How to use:
    :CALL increace_donut_quantity(g_ingred_id INT, g_quantity INT)
    g_donut_id: donut_id,
    g_quantity : how many quantity want to change.


## **Triggers**:
  
  #### ***record_ingred_price_change***:
    This trigger record data in 'ingred_price_history'.
    Wher you change price for any donut this table record 
    ingred_id, old_price, update_price.
  
  
  #### ***record_donut_price_price_change***:
    This trigger record data in 'donut_price_history'.
    When you change price for any donut this table record
    donut_id, old_price, update_price.
  	
  
  #### ***donut_quantity_check***:
    This trigger check when donuts table's quantity is updated
  	if quantity is less then 10 then it's sent warning massage in warnings table
    this trigger sent (type, donut_id, massage) this columns in warnings Not: type is table name.


  #### ***ingred_quantity_check***:
    This trigger check when ingred_stock table's current_stock_level is updated,
  	if current_stock_level is less then min_required_level then it's sent warning massage in warnings table
    this sent (type, ingred_id, massage) this tables.


  #### ***after_insert_donut***:
  	this trigger activate when record data in 'inventory_logs' 
    this sent (donut_id, change_amount, reason) columns in inventory_logs from donuts table


  #### ***update_current_stock_level***:
    This trigger activate when data insert on purchases
    this trigger add ingred quantity in ingred_stock table
