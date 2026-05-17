# 🍩 Donut Shop Management System (Hybrid Module)

This repository contains a schema-based PostgreSQL database engine paired with a modular Python backend.\
The primary objective of this project is to benchmark and demonstrate proficiency \
in **Advanced Relational Database Design**, **Server-Side Automation (Procedures/Triggers)**, \
and **Object-Oriented Python Integration** using `psycopg` connection pooling.

Rather than processing transactional mechanics at the application level, \
this project enforces a **Database-First Philosophy** to guarantee maximum data integrity, immutability, and raw server-side performance.

---

## 📁 Project Folder Structure

```text
donut_shop/
├── README.md
├── database/                    # SQL Database Layer
│   ├── plan.md                  # Database design blueprints & structural specifications
│   ├── schemas/                 # Custom domain types and schema boundaries
│   │   └── create_schemas.sql
│   ├── inventory/               # Tables, Procedures, and Triggers for Stock tracking
│   ├── hr/                      # Employee profiles, shift management, and Payroll logs
│   ├── sales/                   # Customers, Orders, Payments, and Analytics Views
│   └── tests.sql                # This file containt procedures tests data
│                    
│
└── src/                         # Python Application Layer
    ├── plan.md                  # Detailed Python plan & runtime workflow
    ├── process_sale.py          # Script simulating transactional point-of-sale workflows
    ├── simple_report.py         # Main operational file executing BI analysis view scripts
    ├── hasher_src/              # Low-level cryptographic security module
    │   └── hash.c               # Native C source file for memory-efficient password hashing
    └── services/                # Modular library package
        ├── __init__.py          # API gateway exposing core classes
        ├── dBconnect.py         # Thread-safe Connection Pool Manager
        ├── all_service.py       # Python mapping structures invoking DB procedures
        ├── hasher.so            # Compiled C Shared Object mapped via ctypes
        └── py_utils.py          # Regex data validators and foreign function binders
```

**💡 Important Engineering Guide:** To thoroughly analyze the structural design, constraints, and operational design patterns of this project, please read database/plan.md and src/plan.md. Every module and relational entity is fully documented within their respective directories.


🏗️ Core Architecture & System Logic
### **1. Enforced Database-Level Logic**
Core business invariants are protected directly inside PostgreSQL using 32 Stored Procedures and 9 Triggers over 25 Tables:

**Data Integrity:** Whenever a transaction is updated, server-side triggers (ingred_stock_update) instantly decrement raw ingredients, eliminating synchronization mismatches.

**Audit Control:** Changes to employee wage history, shift patterns, or product pricing are captured immutably at the storage engine level, making them tamper-proof against application-level exploits.

**Network Efficiency:** Multi-step transactional chains execute natively on the server block, reducing costly round-trip communication delays between Python and the database cluster.


### 2. High-Performance Hybrid Integration
**Connection Pooling:** Uses an optimized ConnectionPool pipeline featuring explicit autocommit transaction tuning to avoid overhead and ensure safe, rapid connection cycling.

**The Native C Bridge:** Heavy cryptographic computations are handled off-cpu by compiling a native C file (hash.c) into a shared library (hasher.so). Python leverages ctypes bindings to feed password strings into the library, mapping high-speed numerical hashes to database profiles.


### **🛠️ Python Service Layer API Documentation**
#### **1. dBconnect.py (Database Connectivity Driver)**
**DBConnect(username, passwd):** Configures security profiles.

**connect_db():** Spawns the system-wide active connection pool.

**get_conn():** Yields an isolated live database handle, fully compatible with context managers.

**close_conn():** Disposes of active sockets during graceful engine shutdowns.

```
# Context Manager Connection Pattern:
from services import SetUpConnection
from psycopg.rows import dict_row

conn = SetUpConnection("postgres", "secure_password")
conn.connect_db()
try:
    with conn.get_conn() as ctn:
        with ctn.cursor(row_factory=dict_row) as cur:
            cur.execute("SELECT name FROM inventory.donuts LIMIT 1")
            print(cur.fetchone()['name'])
finally:
    conn.close_conn()
```


### **2. all_service.py (Enterprise Service Mapping)**
#### **📦 Inventory Class**
* **add_ingred(name, unit_name, price) / add_categorie(name) / add_donut(...):** Seeds base master entities. Units are constrained to custom types like kg, gm, or box.

* **connect_ingred_donut(donut_id, ingred_id, quantity):** Builds multi-table mapping properties required for processing custom recipes.

* **add_ingred_stock_requirment(ingred_id, min_requir_level):** Establishes a minimum safe volume index to trigger automated low-stock conditions.

* **purchase_from(...) / record_waste(...):** Evaluates supply chain intake and tracks structural inventory write-offs.

* **change_ingred_price() / change_donut_price():** Mutates current price states while logging the chronological shifts into auditing backup tables.


### **👥 HR Class**
* **add_job(role, base_salary) / add_shift(...) / add_employee(...):** Provisions staff records. Validates structural constraints like age restrictions ($>18$), binds financial routers (bank/m_bk), and assigns protected C-hashes.

* **change_emp_shift() / change_emp_salary():** Updates workforce properties and appends current tracking entries.

* **pay_salary(employee_id, role_id):** Logs monthly execution records for corporate wage compliance.

* **delete_employee(employee_id, username):** Employs a defensive Soft Delete (act_stat = false) rule, safeguarding chronological human behavior records for data pipeline ingestion.


### **🛒 Sales Class**
* **add_customer(...) / delete_customer(...):** Provisions client account vectors with age barriers ($>15$).

* **generate_sale_id(...):** Instantiates a stateful order context, returning a transactional unique token index.

* **record_items(sale_id, donut_id, quantity):** Appends order elements to live carts and evaluates precise row calculations.

* **record_payment(sale_id, payment_method, amount):** Binds checkout mechanisms to cash, m_bk (Mobile Banking), or crd (Card). Returns 0 for clean clearances, and 1 for incomplete balances.

* **cancel_item() / cancel_sale():** Discards individual entries or drops full invoices, using triggers to instantly re-balance shelf products.


#### **3. py_utils.py (Regular Expression & Dynamic Interop Utilities)**
* is_email(email): Validates email strings against technical formatting criteria.

* is_valid_passwd(passwd): Blocks structural risks via strict lookaheads (enforces alpha-numeric variations, mixed casing, and explicitly prevents the word "password").

* make_hash(passwd): Marshals incoming Python text primitives into compiled native machine memory spaces for instant parsing by hasher.so


---
### **📊 Business Intelligence & Operational Views**
The simple_report.py file queries targeted database analytics views, handling terminal alignment strings ({:<X}) and protective fallback handling safely without relying on thick UI dependencies:

**1. Daily Total Report:** Aggregates total unique consumer traffic, aggregate donut products shipped, and gross transactional incoming value for the day.

**2. Daily Sale by Donut Report:** Extracts unit volumes and distinct revenue streams indexed by product types.

**3. Sale Status by Month Report:** Isolates product trends grouped across weekly and monthly temporal metrics.

**4. Cancel Report:** Monitors customer friction variables by computing instances of dropped goods, processing underlying reasons, and reporting lost capital values.



## 👤 About Me

  **My name is **Jisan** and my goal is to become a Data Scientist & Assembly Programmer.**

  *   **Focus:** Data Science, System-level Programming (C/Assembly/Rust), and Backend Architecture.

  *   **Goal:** Building high-performance, data-driven systems with a deep understanding of hardware and software integration.

  *   **Goal Progress:** Currently I am learning **Math**, **Data Analysis with SQL & Python** and **C program for ASM**.


---

*This project main goal is to check my python and postgreSQL skill.*
