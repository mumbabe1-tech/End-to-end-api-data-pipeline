-- Purpose: Create a curated, analysis-ready countries table
------------------------------------------------------------

SELECT
    country_code,
    country_name,
    capital_city,
    region,
    subregion,
    population,
    total_area_square_kilometers,

    -- Calculate population density safely
    ROUND(
        population / NULLIF(total_area_square_kilometers, 0),
        2
    ) AS population_density_per_sq_km,

    -- Metadata
    ingested_at AS last_updated_at

FROM {{ ref('stage_raw_countries') }}