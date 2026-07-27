-- Purpose: Create a curated, analysis-ready countries table
------------------------------------------------------------
SELECT
    country_code,
    country_name,
    official_name,
    capital_city,
    region,
    subregion,
    continent,
    population,
    area_sq_km,

    -- Calculate population density safely
    ROUND(
        population / NULLIF(area_sq_km, 0),
        2
    ) AS population_density_per_sq_km,

    currency_code,
    currency_name,

    -- Metadata
    ingested_at AS last_updated_at

FROM {{ ref('stage_raw_countries') }}