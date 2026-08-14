# Walmart DataNexxus
## End-to-End Walmart Data Engineering Platform

An end-to-end Data Engineering project that demonstrates how data from PostgreSQL and Amazon S3 can be ingested, orchestrated, transformed, tested, and delivered into curated analytical datasets using Apache Airflow, Databricks, dbt, and modern data engineering practices.

The project focuses on building a production-style data pipeline with CDC/incremental ingestion, layered transformations, data quality validation, dimensional modeling, lineage, orchestration, and pipeline monitoring.

---

## Project Overview

The goal of this project is to build a reliable data platform for Walmart retail data.

The pipeline integrates data from:

* Neon PostgreSQL
* Amazon S3

The data is then processed through an orchestrated workflow using Apache Airflow and Databricks.

dbt is used for SQL-based transformation, incremental processing, testing, documentation, and lineage.

The final datasets are organized into analytical Fact and Dimension models.

### High-Level Flow

<img width="1234" height="545" alt="Architecture" src="https://github.com/user-attachments/assets/7b0634d1-a80e-42d6-9006-587dceb3e14a" />


```text
                    ┌─────────────────────┐
                    │   Neon PostgreSQL   │
                    │                     │
                    │  Operational Data   │
                    └──────────┬──────────┘
                               │
                              CDC
                               │
                               ▼
┌──────────────┐       ┌─────────────────────┐
│              │       │                     │
│ Amazon S3    ├──────►│      Databricks     │
│ File Sources │       │                     │
│              │       │                     │
└──────────────┘       └──────────┬──────────┘
                                   │
                                   ▼
                         ┌──────────────────┐
                         │     Bronze       │
                         │  Raw / Staging   │
                         └────────┬─────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │      Silver      │
                         │ Enriched / Clean │
                         └────────┬─────────┘
                                  │
                           dbt Transformations
                                  │
                                  ▼
                         ┌──────────────────┐
                         │       Gold       │
                         │ Facts & Dimensions│
                         └──────────────────┘

              Apache Airflow
        Orchestration & Scheduling
```

---

# Architecture

The project follows a layered data engineering architecture.

```text
Source Systems
     │
     ├── Neon PostgreSQL
     │       └── CDC
     │
     └── Amazon S3
             └── File Ingestion
                    │
                    ▼
              Bronze / Raw
                    │
                    ▼
              Silver Layer
                    │
             ┌──────┴──────┐
             │             │
       Technical       Business
       Transformations Transformations
             │             │
             └──────┬──────┘
                    │
              Data Quality
                    │
                    ▼
               Gold Layer
             ┌──────┴──────┐
             │             │
           Facts       Dimensions
```

Apache Airflow controls the execution flow across the pipeline.

dbt manages SQL transformations, incremental models, testing, documentation, and lineage.

Databricks provides the processing and data platform environment.

---

# Technologies Used

| Technology                | Purpose                                |
| ------------------------- | -------------------------------------- |
| Python                    | Pipeline and orchestration logic       |
| SQL                       | Data transformation and modeling       |
| PostgreSQL / Neon         | Source operational database            |
| Amazon S3                 | File-based data source                 |
| Apache Airflow            | Workflow orchestration                 |
| Databricks                | Data processing and pipeline execution |
| dbt                       | Transformation, testing and lineage    |
| Delta / Databricks Tables | Data storage and processing            |
| Git / GitHub              | Version control                        |
| Jinja                     | Dynamic dbt SQL                        |
| CDC                       | Incremental source ingestion           |

---

# Data Sources

## 1. Neon PostgreSQL

Neon PostgreSQL acts as one of the operational data sources.

The project uses CDC-based ingestion to capture changes from the source system rather than repeatedly processing the entire dataset.

Example source entities include:

```text
customers
employees
orders
order_items
products
stores
```

---

## 2. Amazon S3

Amazon S3 is used as a file-based data source.

The pipeline reads source files from S3 and loads them into the processing layer for downstream transformation.

This demonstrates handling multiple source types within the same data platform.

---

# Data Ingestion

The ingestion layer supports two major patterns.

### CDC Ingestion

CDC is used for changes coming from the PostgreSQL source.

Instead of processing all historical records every time, the pipeline can identify and process changed records.

Conceptually:

```text
Source Database
      │
      │ CDC
      ▼
Changed Records
      │
      ▼
Target / Bronze
```

### File Ingestion

Files arriving through Amazon S3 are processed as part of the ingestion workflow.

```text
Amazon S3
    │
    ▼
Raw / Staging
    │
    ▼
Transformation
```

---

# Apache Airflow Orchestration

Apache Airflow is used as the orchestration layer.

The DAG coordinates ingestion, validation, transformation, testing, and Gold-layer processing.

The workflow is structured approximately as:

```text
ingest_cdc
     │
     ▼
clean_target
     │
     ▼
source_freshness
     │
     ├───────────────┐
     ▼               ▼
silver_technical  silver_business
     │               │
     ▼               ▼
technical_tests   business_tests
     │               │
     └───────┬───────┘
             ▼
      ┌──────┴─────────┐
      ▼                ▼
 gold_facts      gold_dimensions
             │
             ▼
       gold_ephemeral
```

The DAG also provides visibility into task-level execution and failures.

---

# Data Freshness

A source freshness validation step is included before downstream processing.

The purpose is to prevent transformations from running against stale source data.

Conceptually:

```text
Source
  │
  ▼
Freshness Check
  │
  ├── Fresh → Continue
  │
  └── Stale → Stop / Alert
```

This is an important reliability feature in production data pipelines.

---

# dbt Transformation Layer

dbt is used to manage the SQL transformation layer.

The project separates models into different stages.

```text
models/
│
├── raw/
│
├── enriched_tech/
│
├── enriched_business/
│
└── curated/
```

The exact folder structure may vary depending on the implementation, but the design separates raw, enriched, and curated datasets.

---

# Incremental Models

Incremental processing is used to avoid rebuilding the complete target table for every execution.

A simplified example:

```sql
{{ config(
    unique_key='product_id'
) }}

SELECT
    *,
    current_timestamp() AS processed_at

FROM {{ ref('products_raw') }}

{% if is_incremental() %}

WHERE updated_timestamp >
(
    SELECT
        COALESCE(
            MAX(updated_timestamp),
            '1900-01-01'
        )
    FROM {{ this }}
)

{% endif %}
```

During the first execution, the model processes the available source data.

During subsequent executions, only records newer than the latest processed timestamp are considered.

This reduces unnecessary processing and makes the pipeline more efficient.

---

# Data Quality

Data quality checks are incorporated into the transformation workflow.

Examples include:

* Unique key validation
* Not-null validation
* Relationship validation
* Source freshness validation
* Business-rule validation
* Transformation-level tests

Example dbt test configuration:

```yaml
version: 2

models:

  - name: enriched_products

    columns:

      - name: product_id
        tests:
          - unique
          - not_null

      - name: category_id
        tests:
          - not_null
```

The Airflow workflow executes downstream Gold processing only after the required validation steps complete successfully.

---

# Dimensional Modeling

The Gold layer contains analytical datasets based on Fact and Dimension modeling.

Example structure:

```text
                 ┌────────────────┐
                 │  dim_customers  │
                 └───────┬────────┘
                         │
                         │
┌──────────────┐         ▼
│ dim_products │ ───► fact_sales ◄─── dim_stores
└──────────────┘         ▲
                         │
                         │
                  ┌──────┴───────┐
                  │ dim_orders   │
                  └──────────────┘
```

The objective is to provide a model that is easier for downstream analytics and reporting workloads to consume.

---

# Slowly Changing Dimensions

The project also demonstrates Slowly Changing Dimension concepts for maintaining historical dimension information.

The idea is to preserve changes to dimension attributes rather than simply overwriting the previous value.

Conceptually:

```text
Customer ID
     │
     ├── Version 1
     │     Address = Chennai
     │
     └── Version 2
           Address = Bangalore
```

This allows historical analysis to remain possible when dimension attributes change.

---

# dbt Ephemeral Models

Ephemeral models are used where intermediate transformation logic does not need to be materialized as a persistent database table.

Conceptually:

```text
Source
  │
  ▼
Intermediate Logic
  │
  ▼
Final Model
```

This helps keep the physical database layer cleaner while still allowing reusable transformation logic inside dbt.

---

# Data Lineage

dbt lineage provides visibility into model dependencies.

The project tracks the flow:

```text
Source
  │
  ▼
Raw
  │
  ▼
Enriched
  │
  ▼
Curated
  │
  ├── Dimensions
  │
  └── Facts
```

This makes it easier to understand:

* Where a dataset originated
* Which transformations were applied
* Which downstream models depend on it
* What could be affected by a source change

---

# Databricks

Databricks is used as the main data processing platform.

The project uses Databricks for:

* Data processing
* Table management
* Pipeline execution
* Job execution
* Pipeline monitoring
* Data lineage visibility

The pipeline follows a Bronze/Silver/Gold style architecture.

```text
Bronze
  │
  │ Raw / minimally transformed
  ▼
Silver
  │
  │ Cleaned + enriched
  ▼
Gold
  │
  │ Business-ready
  ▼
Analytics
```

---

# Databricks Jobs

Databricks Jobs are used to execute and monitor the data workloads.

The job interface provides visibility into:

* Run history
* Execution duration
* Run status
* Scheduling
* Successful and failed executions

This gives the project a production-style execution and monitoring workflow.

---

# Databricks Pipelines

Databricks Pipelines are also used to process the Walmart datasets.

The pipeline provides visibility into individual tables and their execution status.

Example datasets include:

```text
walmart_bronze_customers_staging
walmart_bronze_employees_staging
walmart_bronze_order_items_staging
walmart_bronze_orders_staging
walmart_bronze_products_staging
walmart_bronze_stores_staging
```

---

# Project Structure

A simplified repository structure:

```text
walmart-data-engineering/
│
├── airflow/
│   ├── dags/
│   │   └── walmart_dag.py
│   │
│   └── README.md
│
├── dbt/
│   └── walmart_dbt_project/
│       │
│       ├── analyses/
│       ├── macros/
│       ├── models/
│       │   ├── raw/
│       │   ├── enriched_tech/
│       │   ├── enriched_business/
│       │   └── curated/
│       │
│       ├── seeds/
│       ├── snapshots/
│       ├── tests/
│       ├── dbt_project.yml
│       ├── profiles.yml
│       └── README.md
│
├── databricks/
│   ├── notebooks/
│   ├── jobs/
│   └── pipelines/
│
├── sql/
│   ├── staging/
│   ├── transformations/
│   └── marts/
│
├── docs/
│   ├── architecture.png
│   ├── airflow-dag.png
│   └── lineage.png
│
├── .gitignore
└── README.md
```

---

# dbt Commands

Install dbt according to the adapter used by the project.

Typical commands:

```bash
dbt debug
```

Validate the dbt configuration and connection.

```bash
dbt deps
```

Install project dependencies.

```bash
dbt seed
```

Load seed data when applicable.

```bash
dbt run
```

Build the transformation models.

```bash
dbt test
```

Execute data quality tests.

```bash
dbt source freshness
```

Check configured source freshness.

```bash
dbt build
```

Run models and associated tests together.

```bash
dbt docs generate
```

Generate dbt documentation.

```bash
dbt docs serve
```

Serve the generated documentation locally.

---

# Airflow Workflow

The Airflow DAG is responsible for coordinating the overall workflow.

The main execution stages are:

```text
1. Ingest CDC
       ↓
2. Clean Target
       ↓
3. Validate Source Freshness
       ↓
4. Run Silver Technical Models
       ↓
5. Run Silver Business Models
       ↓
6. Execute Data Quality Tests
       ↓
7. Build Gold Facts
       ↓
8. Build Gold Dimensions
       ↓
9. Execute Gold Ephemeral Logic
```

This dependency structure ensures that downstream transformations are not executed before their upstream requirements are satisfied.

---

# Monitoring

Monitoring is implemented at multiple levels.

### Airflow

Used to monitor:

* DAG status
* Individual task status
* Execution time
* Dependencies
* Task failures

### Databricks

Used to monitor:

* Job runs
* Pipeline runs
* Table processing
* Execution history

### dbt

Used to monitor:

* Model execution
* Test results
* Source freshness
* Model lineage

---

# Key Engineering Concepts Demonstrated

This project demonstrates practical knowledge of:

### Data Engineering

* ETL / ELT
* Batch processing
* Incremental processing
* CDC
* Data ingestion
* Data validation
* Data quality

### Data Architecture

* Bronze / Silver / Gold architecture
* Layered data processing
* Fact and Dimension modeling
* Slowly Changing Dimensions

### Orchestration

* Apache Airflow
* DAGs
* Task dependencies
* Scheduling
* Pipeline monitoring

### Transformation

* dbt
* SQL
* Jinja
* Incremental models
* Ephemeral models
* dbt tests
* Source freshness
* Lineage

### Cloud / Data Platforms

* Amazon S3
* Databricks
* PostgreSQL
* Delta-based data processing

### Development

* Python
* Git
* GitHub
* VS Code

---

# What I Learned

Building this project helped me understand that a real-world data platform is more than simply moving data from one database to another.

The important part is designing the complete lifecycle:

```text
Ingest
  ↓
Validate
  ↓
Transform
  ↓
Test
  ↓
Model
  ↓
Orchestrate
  ↓
Monitor
  ↓
Serve
```

The project also helped me understand how different tools complement each other.

Airflow handles orchestration, Databricks provides the processing environment, dbt manages SQL transformations and data quality, while S3 and PostgreSQL represent different types of source systems.

---

# Future Improvements

Potential improvements for the project include:

* CI/CD for dbt and Airflow
* Automated deployment
* Centralized secrets management
* Alerting for failed DAG runs
* More comprehensive dbt tests
* Data observability
* Schema evolution handling
* Performance optimization
* Role-based access control
* Automated documentation generation
* Dashboarding using Power BI
* Additional CDC sources

---

# Screenshots

## Architecture

![Architecture](docs/architecture.png)

## Apache Airflow DAG

![Airflow DAG](docs/airflow-dag.png)

## dbt Lineage

![dbt Lineage](docs/dbt-lineage.png)

## Databricks Pipeline

![Databricks Pipeline](docs/databricks-pipeline.png)

## dbt Models

![dbt Models](docs/dbt-models.png)

---

# Conclusion

This project represents an end-to-end implementation of a modern data engineering workflow using multiple technologies.

The main focus was not on using as many tools as possible, but on understanding how the tools work together to build a reliable and maintainable data pipeline.

The final architecture combines:

```text
Neon PostgreSQL
       +
Amazon S3
       ↓
Apache Airflow
       ↓
Databricks
       ↓
Bronze
       ↓
Silver
       ↓
dbt Transformations
       ↓
Data Quality
       ↓
Gold Facts & Dimensions
       ↓
Analytics
```

---

## Author

**Arsath Mohamed**

Aspiring Data Engineer

Skills demonstrated in this project:

`Python` `SQL` `Apache Airflow` `Databricks` `dbt` `AWS S3` `PostgreSQL` `ETL/ELT` `Data Modeling` `CDC` `Git` `GitHub`
