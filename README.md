# Retail Sales & Customer Intelligence Engine

A production-grade PostgreSQL relational database design, data engineering pipeline, and business intelligence suite built to analyze high-velocity commercial retail transactions and customer behavior patterns. This engine processes dense transaction matrices, evaluates multi-month customer cohort retention metrics, optimizes query access layers using B-Tree indexing strategies, and exposes clean calculated aggregates to an interactive Power BI Management Dashboard.

---

## Project Architecture

```text
├── README.md                 <- Project overview, ecosystem setup, and execution paths
├── schema.sql                <- Pure DDL: Database catalogs, tables, types, and constraints
├── queries.sql               <- 46 distinct sequential data requests and window aggregations
├── insights.md               <- Strategic executive analytical observations and recommendations
└── screenshots/              <- Visual verification matrices and executive dashboard layouts
    ├── 05_verify_data.png    <- DBeaver data verification panel snapshot
    ├── 02_cohort_matrix.png  <- Cohort retention table result grid
    └── 03_dashboard.png      <- Interactive multi-year BI executive canvas
```

---

## Setting Up the Local Instance

### 1. Prerequisites
Ensure you have a local instance of PostgreSQL running alongside an SQL client interface such as DBeaver, pgAdmin, or command-line wrappers.

### 2. Initialize the Database Schema
Connect to your local database engine wrapper and create a fresh target database profile named `retail_sales`. Execute the contents of your `schema.sql` template script to safely construct your physical database tables, primary/foreign keys, and data validation check constraints:

```bash
psql -U postgres -d retail_sales -f schema.sql
```

### 3. Execute the Analytical Pipeline
Once the underlying baseline relational architecture is created and initialized, open up your SQL engine workspace client or run your core queries script directly through your console terminal to process everything sequentially from query 1 up through question 46:

```bash
psql -U postgres -d retail_sales -f queries.sql
```

---

## Business Intelligence Pipeline Integration
The analytics layout exposes a specialized, pre-calculated virtual tracking database view object named `monthly_sales_summary`. To mount the visualization framework and display the executive KPI dashboard canvas:
1. Fire up Power BI Desktop, go to the upper home ribbon panel, and choose Get Data -> PostgreSQL Database.
2. Specify Server address configurations as `localhost` and your Database label as `retail_sales`. Select your secure data import credentials.
3. Import the `monthly_sales_summary` database view asset exclusively to cleanly populate the charts, multi-year chronological trend lines, and filtering slicers without cluttering memory models.
