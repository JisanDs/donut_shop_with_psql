# 🍩 Donut Shop Enterprise Management System & Analytics Pipeline

This repository contains an end-to-end relational database platform paired with an object-oriented Python backend and a real-time Streamlit analytical dashboard. 

The primary objective of this project is to showcase production-grade software engineering, featuring **Advanced Relational Database Design**, **Server-Side Transaction Automation (Stored Procedures & Triggers)**, **Compiled C Native Extensions**, and a **High-Performance In-Memory Analytics Pipeline** utilizing Polars, ConnectorX, and Plotly.

---

## **🏗️ System Architecture Overview**

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        ANALYTICAL DASHBOARD LAYER                      │
│        Streamlit Multi-Page UI | Plotly Express Visualizations         │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │ Memory Transfer (Arrow)
┌───────────────────────────────────┴────────────────────────────────────┐
│                    HIGH-SPEED ANALYTICAL PIPELINE                      │
│       Polars DataFrames | SQL Query Offloading | ConnectorX Engine     │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │ ConnectorX / Psycopg Pool
┌───────────────────────────────────┴────────────────────────────────────┘
│                   TRANSACTION & DATABASE ENGINE (PostgreSQL)           │
│   25 Tables | 32 Stored Procedures | 9 Triggers | 3 Isolated Schemas   │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │ Ctypes Interop
┌───────────────────────────────────┴────────────────────────────────────┘
│                     NATIVE CRYPTOGRAPHIC ENGINE                        │
│             Compiled C Shared Library (hasher.so) via ctypes           │
└────────────────────────────────────────────────────────────────────────┘
```

The system is built on a Database-First Philosophy to guarantee ACID compliance, immutability, and transactional data integrity at the storage layer, while offloading high-speed aggregations to an in-memory execution pipeline.


# **📁 Repository Structure**
```
donut_shop/
├── README.md
├── data_for_analysis/              # Generated CSV datasets for benchmarking & dashboarding
├── database/                       # Relational Storage Engine
│   ├── plan.md                     # Schema blueprints and structural constraints
│   ├── tests.sql                   # Unit test scripts for procedures and triggers
│   ├── schemas/
│   │   └── create_schemas.sql      # Custom domain types and namespace boundaries
│   ├── inventory/                  # Tables, procedures, and triggers for stock control
│   ├── hr/                         # Employee profiles, shifts, and payroll audit logs
│   └── sales/                      # Orders, payments, discounts, and analytical views
│
├── dashboard/                      # Real-time Streamlit & Polars Analytical System
│   ├── main.py                     # Entry point for multi-page dashboard execution
│   ├── src/                        # Data processing & aggregation logic
│   │   ├── sales_revenue_ana.py    # Analytical transformations for sales and discounts
│   │   ├── inv_manage_waste.py     # Supply chain, stock thresholds, and waste metrics
│   │   └── hr_analysis.py          # Workforce demographics, shifts, and salary trends
│   └── pages/                      # User Interface & Plotly Visualization Layer
│       ├── sales_revenue_page.py   # Sales & Revenue dashboard view
│       ├── inv_manage_waste_page.py# Inventory & Waste Management view
│       ├── hr_status_page.py       # HR & Employee Analytics view
│       ├── user_guide_page.py      # Dynamic markdown documentation renderer
│       └── USER_GUIDE.md           # User documentation source
│
└── src/                            # Python Application & Service Integration Layer
    ├── plan.md                     # Application layer execution pipeline specs
    ├── process_sale.py             # Transactional point-of-sale workflow simulator
    ├── simple_report.py            # CLI-based operational BI report runner
    ├── hasher_src/                 # Low-level native C security module
    │   └── hash.c                  # Native C code for fast, memory-safe hashing
    └── services/                   # Modular Python service package
        ├── __init__.py             # API gateway exposing core services
        ├── dBconnect.py            # Thread-safe Psycopg connection pool manager
        ├── all_service.py          # Python wrappers invoking PostgreSQL procedures
        ├── hasher.so               # Compiled C shared object mapped via ctypes
        └── py_utils.py             # Regex validators and C function wrappers
```

# **⚡ Engineering & Compute Optimization Strategy**
This system is explicitly designed to minimize cloud compute costs, memory overhead, and network latencies:

### **1. Zero-Auto-Refresh Architecture (Cost & Compute Reduction)**
* Traditional Streamlit dashboards re-execute the entire Python script on every user interaction, causing continuous database polling and spiking server CPU/RAM usage.

* Controlled Execution: This dashboard rejects reactive auto-polling. Instead, data extraction is isolated behind an explicit Manual Data Refresh Button.

* On-Demand Processing: Queries execute and cache in memory only when requested, drastically cutting database connection costs and computing overhead.

### **2. Offloaded Query Processing (SQL + Polars Pipeline)**
* ConnectorX Engine: Data extraction utilizes connectorx, streaming PostgreSQL binary protocols directly into memory without Python object overhead.

* Database Offloading: Relational joins (JOIN ... USING) are executed on the database engine. 
Mathematical aggregations, conditional statements (pl.when().then()), and time-series group-bys are processed via Polars leveraging parallel Rust multi-threading.

### **3. Database-Level Business Invariants**
* Automated Stock Deduction: Server-side triggers (ingred_stock_update) instantly decrement raw ingredients upon transactional order insertion, eliminating concurrency race conditions.

* Audit-Proof Logs: Salary revisions, shift changes, and product price mutations append to immutable historical tracking tables.

### **4. Low-Level Native C Cryptographic Integration**
* Heavy hashing algorithms are compiled from hash.c to hasher.so. Python interfaces with the compiled binary through ctypes bindings, offloading cryptographic parsing from the Python interpreter to native machine instructions.


# **📊 Dashboard Modules & Feature Breakdown**
The analytical UI provides operational visibility across three core enterprise domains:

### **1. Sale & Revenue Analysis**
* KPI Summary: Total Quantity Sold, Total Net Profit, and Top Sold Donut.

* Comparative Pricing Metrics: Evaluates revenue performance per donut type under active discount promotions vs. standard retail pricing.

* Interactive Temporal Filtering: Isolates daily transaction logs and generated revenue by month.

* Visualizations: Line charts for monthly sales trends, Scatter Plots mapping total spending vs. unit profit, and Donut Charts analyzing category profit margins.

### **2. Inventory & Waste Management**
* KPI Summary: Aggregate Procurement Expenditure, Total Waste Volume, and Financial Loss Value.

* Supply Chain Tracking: Procurement history audit trails breaking down unit costs, total expenditure, and supplier distribution.

* Threshold Monitoring: Dual-color Bar Charts comparing live ingredient stock levels against safety inventory requirements.

* Waste Analytics: Monthly waste logs tracking discarded units and financial impact per product.

### **3. HR & Workforce Status**
* KPI Summary: Total Active Headcount, Aggregate Payroll Budget, and Average Employee Compensation.

* Workforce Audit: Profile listings with dynamic role-based filters and audit trails of recent payroll disbursements.

* Demographics & Distribution: Shift capacity bar charts, employee age distribution histograms, onboarding trends, and monthly salary disbursement metrics.




# **🛠️ Data Infrastructure & Generation Note**
* The dataset located in data_for_analysis/ was synthetically generated specifically for benchmarking this dashboard pipeline.

* Ingestion Strategy: During bulk dataset insertion, server-side transactional triggers and procedures were temporarily bypassed to populate raw schema structures cleanly for analytical stress-testing.

* Production Extensibility: In a live enterprise environment with continuous transactional volume, the pipeline easily scales to support auto-refresh streaming, heatmap analytical views, and deeper cohort analysis (daily/yearly temporal aggregation charts).

# **💡 Developer Notes & Customization**
* This project was developed as a comprehensive engineering exercise combining system programming, database design, and high-performance data analytics.

* If you are analyzing or adapting this codebase:

* Explore database/plan.md for full relational schema specs and procedure signatures.

* Review src/plan.md for application layer workflows and Python service mappings.

* Feel free to extend the Polars transformations or add advanced analytical visualizations (e.g., Correlation Heatmaps, Demand Forecasting) based on your operational requirements.



---

## 👤 Author & Background

**Jisan**  
*Data Science Student & Systems Programming Enthusiast*

* **Current Focus:** Learning Data Science and Systems Programming (C / Rust / Assembly) with a focus on building efficient, low-compute software pipelines.
* **Philosophy:** Studying C, Assembly, and CS fundamentals to understand hardware execution, memory management, and optimization. The goal is to apply these low-level insights toward building resource-friendly Machine Learning and Analytics systems in the future.
* **Technical Stack:** Python (Polars, Streamlit, Psycopg), PostgreSQL (PL/pgSQL), C, Rust, SQL, and Mathematics (Linear Algebra & Calculus).
