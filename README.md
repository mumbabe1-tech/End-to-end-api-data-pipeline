┌─────────────────────────────────────────────────────────┐
               │         GITHUB ACTIONS CLOUD ORCHESTRATOR               │
               │            (Runs daily at 07:30 AM UTC)                 │
               └────────────────────┬────────────────────────────────────┘
                                    │
                         1. Executes Python Extractor
                                    │
                                    ▼
                     ┌──────────────────────────────┐
                     │     REST Countries API       │
                     └──────────────┬───────────────┘
                                    │
                         Fetches Raw Country JSON
                                    │
                                    ▼
                     ┌──────────────────────────────┐
                     │        AWS S3 Bucket         │
                     │  (triplens-raw-data/...)     │
                     └──────────────┬───────────────┘
                                    │
                         2. Executes dbt Core
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                          SNOWFLAKE DATA WAREHOUSE                      │
│                                                                        │
│  ┌─────────────────────────┐              ┌──────────────────────────┐ │
│  │     TRIPLENS_DB.RAW     │              │    TRIPLENS_DB.MARTS     │ │
│  │ ─────────────────────── │              │ ──────────────────────── │ │
│  │  RAW_COUNTRIES          │ ─── dbt ───► │  DIM_COUNTRIES           │ │
│  │  (VARIANT JSON Staging) │  Transform   │  (Clean Structured Mart) │ │
│  └─────────────────────────┘              └────────────┬─────────────┘ │
└────────────────────────────────────────────────────────┼───────────────┘
                                                         │
                                               3. Serves Reports
                                                         │
                                                         ▼
                                            ┌──────────────────────────┐
                                            │   POWER BI / ANALYSTS    │
                                            │    (ANALYST_ROLE)        │
                                            └──────────────────────────┘


An automated ELT data pipeline built with Python, AWS S3, Snowflake, dbt, and GitHub Actions and CI/CD orchestration through GitHub Actions.
The pipeline retrieves semi‑structured country data from the REST Countries API, stores raw JSON payloads in AWS S3, and processes them into analytics‑ready tables within Snowflake using dbt.
 

Architecture Overview
The pipeline operates across three main stages:

1. Extract
A Python script retrieves country data from the REST Countries API and uploads raw JSON payloads to AWS S3.

2. Load
Snowflake ingests the raw JSON files from S3 into the RAW schema using Snowflake’s native semi‑structured data capabilities.

3. Transform
dbt converts the raw JSON into a structured staging model and then produces a final analytics model suitable for reporting and downstream consumption.

All steps are orchestrated automatically via GitHub Actions, enabling scheduled daily runs without requiring local compute resources.

Repository Structure


triplens-countries-explorer/
├── .github/workflows/pipeline.yml          # GitHub Actions workflow (automated daily pipeline)
├── dbt_project/
│   ├── models/
│   │   ├── staging/
│   │   │   └── stage_raw_countries.sql     # Staging model for parsing raw JSON
│   │   ├── marts/
│   │   │   └── countries_mart.sql          # Final analytics model for reporting
│   │   └── countries_schema.yml            # dbt tests and model documentation
│   ├── dbt_project.yml                     # dbt project configuration
│   └── profiles.yml (optional copy)        # Used only when running dbt with --profiles-dir
├── scripts/fetch_and_upload.py             # Python extractor (API → S3 ingestion)
├── Makefile                                # Local development and pipeline commands
├── requirements.txt                         # Python dependencies
└── snowflake_initial_setup.sql           # One-time Snowflake database and schema setup


Lessons Learned & Technical Insights
The development of this pipeline provided practical insights into modern data engineering workflows, including API ingestion, semi‑structured data handling, cloud warehousing, dbt modeling, and CI/CD automation.

1. Consistent Data Contracts and Naming Conventions
Challenge:  
Differences between raw ingestion column names and downstream SQL model references caused dbt compilation errors.

Insight:  
The dbt staging layer acts as a translation point between raw data structures and analytics‑ready models. Ensuring strict alignment between Snowflake table schemas and dbt model queries prevents invalid identifier errors and supports reliable transformations.

2. Parsing Semi‑Structured JSON in Snowflake
Challenge:  
The REST Countries API returns nested JSON objects and array‑based fields requiring careful extraction.

Insight:  
Snowflake’s VARIANT type and JSON path syntax (column:path::TYPE) enable reliable parsing of nested structures. Array indexing (e.g., RAW_DATA:capital[0]::STRING) is essential for converting semi‑structured API responses into clean relational columns.

3. dbt SQL Execution and Model Materialization
Challenge:  
Trailing semicolons in SQL models and unused folder paths in dbt_project.yml resulted in dbt compilation warnings and errors.

Insight:  
dbt wraps SQL models inside its own CREATE TABLE/VIEW AS (...) statements, meaning semicolons should not be used at the end of model files. Streamlining dbt_project.yml to include only active model directories produces cleaner builds and eliminates unnecessary warnings.

4. CI/CD Workflow Maintenance in GitHub Actions
Challenge:  
Deprecation warnings for GitHub Actions dependencies required updates to maintain pipeline stability.

Insight:  
Automated workflows benefit from regular dependency updates. Keeping GitHub Actions versions current ensures reliable execution, reduces runtime warnings, and supports long‑term maintainability of the pipeline.