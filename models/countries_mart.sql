
-- Purpose:
--   To create a curated countries table for analytics.
--   This model transforms staging data into a clean,
--   analysis-ready structure for the Triplens project.
------------------------------------------------------------

WITH staging_countries AS (
    SELECT *
    FROM {{ ref('stage_raw_countries') }}
)

SELECT
    country_code,
    country_name,
    capital_city,
    region,
    subregion,
    population,
    total_area_square_kilometers,
    is_un_member,

    -- Calculate population density safely
    ROUND(
        population / NULLIF(total_area_square_kilometers, 0),
        2
    ) AS population_density_per_square_kilometer,

    -- Metadata
    INGESTED_AT AS last_updated_at
FROM staging_countries;
