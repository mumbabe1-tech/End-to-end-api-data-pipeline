-- Purpose: Clean raw country JSON into structured columns
------------------------------------------------------------

SELECT
    -- Country Identifiers
    src:cca3::STRING AS country_code,
    src:name::STRING AS country_name,

    -- Geographic & Demographic Info
    src:capital[0]::STRING AS capital_city,
    src:region::STRING AS region,
    src:subregion::STRING AS subregion,
    src:population::INTEGER AS population,
    src:area::FLOAT AS total_area_square_kilometers,

    -- Metadata
    loaded_at AS ingested_at

FROM TRIPLENS_DB.RAW.RAW_COUNTRIES
WHERE src:cca3 IS NOT NULL