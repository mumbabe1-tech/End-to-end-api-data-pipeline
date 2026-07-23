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


An automated ELT data pipeline built with Python, AWS S3, Snowflake, dbt, and GitHub Actions.
The pipeline extracts country data from the REST Countries API, stores raw JSON in S3, and transforms it inside Snowflake using dbt models.

Architecture Overview
The pipeline runs in three main steps:

Extract  
A Python script downloads country data from the REST Countries API and uploads the raw JSON files to AWS S3.

Load  
Snowflake loads the raw JSON from S3 into the RAW schema.

Transform  
dbt converts the raw JSON into a clean staging table and then builds a final analytics table for reporting.

All steps run automatically every morning using GitHub Actions.

Structure: 
triplens-countries-explorer/
├── .github/workflows/pipeline.yml          # GitHub Actions workflow (08:30 CET)
├── dbt_project/
│   ├── models/
│   │   ├── staging/
│   │   │   └── stage_raw_countries.sql     # Staging model (clean raw JSON)
│   │   ├── marts/
│   │   │   └── countries_mart.sql          # Final analytics table
│   │   └── countries_schema.yml            # dbt tests + documentation
│   ├── dbt_project.yml                     # dbt project configuration
│   └── profiles.yml (optional copy)        # Only used if running with --profiles-dir
├── extract_country_data.py                 # Python extractor (API → S3)
├── Makefile                                # Local pipeline commands
├── requirements.txt                         # Python dependencies
└──snowflake_raw_layer_setup.sql           # One-time Snowflake setup script

Quickstart (Local Development)
Prerequisites
Python 3.10+
uv installed (curl -LsSf https://astral.sh/uv/install.sh | sh)
Snowflake & AWS Account credentials configured in .env

Setup Environment: make setup

Run Pipeline Locally:
# Run Python extraction to AWS S3
make extract

# Run dbt transformations in Snowflake
make dbt-run

# Run data quality tests
make dbt-test

CI/CD & Security
GitHub Actions handles automated daily execution at 07:30 AM UTC. Production secrets (AWS_ACCESS_KEY_ID, DBT_SNOWFLAKE_PASSWORD, etc.) are securely stored in GitHub Repo Settings -> Secrets and Variables -> Actions.