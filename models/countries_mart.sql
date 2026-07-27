-- Purpose: Create a curated, analysis-ready countries table
------------------------------------------------------------
SELECT
    country_name,
    capital,
    region,
    population,
    area_sq_km,

    -- Calculate population density safely
    ROUND(
        population / NULLIF(area_sq_km, 0),
        2
    ) AS population_density_per_sq_km,

    -- Metadata
    ingested_at AS last_updated_at

FROM {{ ref('stage_raw_countries') }}