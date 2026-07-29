-- Purpose: Create a curated, analysis-ready countries table
------------------------------------------------------------
{{
    config(
        materialized='table'
    )
}}

WITH staging AS (
    SELECT * FROM {{ ref('stage_raw_countries') }}
)

SELECT
    country_code,
    country_name,
    official_name,
    capital_city,
    region,
    subregion,
    population,
    area_sq_km,
    ROUND(population / NULLIF(area_sq_km, 0), 2) AS population_density_per_sq_km,
    currency_code,
    currency_name,
    currency_symbol,
    ingested_at AS last_updated_at
FROM staging