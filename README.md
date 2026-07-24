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


A lightweight, automated ELT pipeline that integrates API ingestion, cloud storage, Snowflake warehousing, dbt transformations, and CI/CD orchestration through GitHub Actions. The system retrieves semi‑structured country data from the REST Countries API, stores raw JSON payloads in AWS S3, and processes them into analytics‑ready tables within Snowflake.

## Tech Stack & Tooling

* Extraction & Environment: Python 3.10+, uv package manager (pyproject.toml, uv.lock)
* Cloud Storage (Data Lake): AWS S3 (Raw JSON Bronze Landing Zone)
* Data Warehouse: Snowflake (Semi-structured VARIANT parsing)
* Transformation: dbt Core (dbt-snowflake adapter)
* Automation & CI/CD: GitHub Actions (Daily automatic runs)

---

## Why This Architecture is Simple & Efficient

While building an end-to-end cloud pipeline requires real technical effort, this system is designed to stay clean, practical, and cheap to run:

* No Always-On Servers: You do not need to pay for or manage servers running 24/7 (like Airflow).
* Temporary Cloud Runners: GitHub Actions creates a temporary computer only when it needs to run, finishes the pipeline steps in minutes, and deletes itself immediately.
* Decoupled Data Lake & Processing: AWS S3 serves as a cost-effective raw Data Lake to store historical API files, while Snowflake handles data processing only when needed.
* Easy to Maintain: The pipeline runs on its own every morning without needing daily check-ins or costly upkeep.

---

## Architecture & Detailed System Structure

The pipeline operates as a fully automated cloud system that runs every day at 08:37 AM CET (07:37 UTC):

[REST Countries API] 
       |
       v (Python / boto3 / uv)
[AWS S3 Raw Storage Bucket]  <-- DATA LAKE (Raw JSON Landing Zone)
       |
       v (Snowflake Auto-Ingest / COPY)
[Snowflake RAW Schema] 
       |
       v (dbt Transformation Views)
[Snowflake MARTS Schema]

### 1. Daily Extraction & AWS S3 Data Lake Ingestion
* Trigger: Runs automatically every day (37 7 * * *) or whenever new code is saved to main.
* Extraction Script: Executed via uv run extract_country_data.py.
* Data Lake Destination: 
  s3://triplens-landing-zone-ifeoma1/raw_travel_data/countries_YYYYMMDD_HHMMSS.json

### 2. Snowflake Database Structure
* Database: TRIPLENS_DB
* Setup Script: snowflake_raw_layer_setup.sql
* Schemas:
  * RAW: Holds raw JSON data directly from the S3 Data Lake using Snowflake's VARIANT column type.
    * Table: TRIPLENS_DB.RAW.RAW_COUNTRIES (src VARIANT, loaded_at TIMESTAMP)
  * MARTS: Holds clean, final views ready for analysis.
    * View: TRIPLENS_DB.RAW.countries_mart

### 3. dbt Transformation Layer
* Staging Model (models/stage_raw_countries.sql): Reads raw JSON from TRIPLENS_DB.RAW.RAW_COUNTRIES, extracts specific fields (like capital cities), fixes data formats, and renames columns clearly.
* Mart Model (models/countries_mart.sql): Reads from the staging model, calculates useful stats (like population density), and creates the final view for business reporting.
* Testing & Schema (models/countries_schema.yml): Contains automated data checks and descriptions.

### 4. GitHub Actions Automation Workspace
* Workflow File: .github/workflows/triplens_pipeline.yml
* Schedule: Set to run automatically at 07:37 UTC (08:37 AM CET) every morning.
* Security: Uses GitHub Repository Secrets to hide logins for AWS and Snowflake.

---

## Repository Structure

triplens-countries-explorer/
├── .github/
│   └── workflows/
│       └── triplens_pipeline.yml      # GitHub Actions automation file
├── models/
│   ├── stage_raw_countries.sql        # dbt model that parses raw JSON
│   ├── countries_mart.sql             # dbt model for final analysis tables
│   └── countries_schema.yml           # dbt data test rules and notes
├── .env                               # Local secret key file (not uploaded to GitHub)
├── .gitignore                         # Files Git should ignore
├── .python-version                    # Python version settings
├── dbt_project.yml                    # Main dbt configuration file
├── extract_country_data.py            # Python script to pull API data into AWS S3 Data Lake
├── main.py                            # Secondary script runner
├── Makefile                           # Development command shortcuts
├── profiles.yml                       # Snowflake connection setup for GitHub Actions
├── pyproject.toml                     # Python package configuration
├── README.md                          # Project overview document
├── requirements.txt                   # List of Python dependencies
├── snowflake_raw_layer_setup.sql      # Database setup queries for Snowflake
└── uv.lock                            # Exact version lockfile for Python packages

---

## What Was Learned & Technical Insights

Building this pipeline gave great hands-on practice with pulling API data, storing cloud files in a Data Lake, working in Snowflake, transforming data in dbt, and setting up automatic GitHub runs.

### 1. Matching Column Names Across Tools
* Challenge: Mismatches between raw column names and the SQL model queries caused dbt build errors.
* Insight: The dbt staging layer acts as the bridge. Making sure raw Snowflake column names match dbt queries prevents system errors.

### 2. Reading Nested JSON Data in Snowflake
* Challenge: Reading values out of complex, nested JSON fields sent by the REST API into the Data Lake.
* Insight: Learned how to use Snowflake's VARIANT format and array selectors (like src:capital[0]::STRING) to easily turn JSON into regular spreadsheet-style columns.

### 3. Writing Clean dbt SQL Code
* Challenge: Extra semicolons (;) at the end of dbt model files caused SQL errors because dbt builds its own SQL behind the scenes.
* Insight: Removing trailing semicolons in dbt files and cleaning up dbt_project.yml fixed all compilation errors, giving a 100% clean pipeline run.

### 4. Keeping Automated Workflows Fresh
* Challenge: Handling warning messages in GitHub Actions dependencies while using new Python tools like uv.
* Insight: Keeping GitHub Actions versions current (actions/checkout@v5 and actions/setup-python@v6) ensures the automated pipeline runs smoothly without stopping.