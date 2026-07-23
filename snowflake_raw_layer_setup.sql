------------------------------------------------------------
-- Purpose:
--   Prepare the Snowflake environment for the Triplens project.
--   This script creates the database, schemas, raw ingestion table,
--   external stage, and analyst access roles.
------------------------------------------------------------

------------------------------------------------------------
-- 1. Create Database and Schemas
------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS TRIPLENS_DB;
CREATE SCHEMA IF NOT EXISTS TRIPLENS_DB.RAW;
CREATE SCHEMA IF NOT EXISTS TRIPLENS_DB.MARTS;

USE DATABASE TRIPLENS_DB;

------------------------------------------------------------
-- 2. Create Raw Table for JSON Ingestion
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS TRIPLENS_DB.RAW.RAW_COUNTRIES (
    RAW_DATA VARIANT,
    INGESTED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

------------------------------------------------------------
-- 3. Create External Stage pointing to AWS S3
------------------------------------------------------------
CREATE OR REPLACE STAGE TRIPLENS_DB.RAW.TRIPLENS_S3_STAGE
  URL = 's3://triplens-raw-data/raw_travel_data/'
  CREDENTIALS = (
    AWS_KEY_ID = 'YOUR_AWS_ACCESS_KEY_ID',
    AWS_SECRET_KEY = 'YOUR_AWS_SECRET_ACCESS_KEY'
  )
  FILE_FORMAT = (TYPE = 'JSON');

------------------------------------------------------------
-- 4. Load Raw Data from S3 Stage into RAW Table
------------------------------------------------------------
COPY INTO TRIPLENS_DB.RAW.RAW_COUNTRIES (RAW_DATA)
FROM @TRIPLENS_DB.RAW.TRIPLENS_S3_STAGE
FILE_FORMAT = (TYPE = 'JSON')
ON_ERROR = 'CONTINUE';

------------------------------------------------------------
-- 5. Create Security Role for Data Analysts
------------------------------------------------------------
CREATE ROLE IF NOT EXISTS ANALYST_ROLE;

GRANT USAGE ON DATABASE TRIPLENS_DB TO ROLE ANALYST_ROLE;
GRANT USAGE ON SCHEMA TRIPLENS_DB.MARTS TO ROLE ANALYST_ROLE;

GRANT SELECT ON ALL TABLES IN SCHEMA TRIPLENS_DB.MARTS TO ROLE ANALYST_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA TRIPLENS_DB.MARTS TO ROLE ANALYST_ROLE;

GRANT SELECT ON ALL VIEWS IN SCHEMA TRIPLENS_DB.MARTS TO ROLE ANALYST_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA TRIPLENS_DB.MARTS TO ROLE ANALYST_ROLE;
