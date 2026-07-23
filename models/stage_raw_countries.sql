-- Purpose:
--   Convert raw JSON country data into a clean staging table
--   for downstream transformations in the Triplens project.
------------------------------------------------------------

WITH raw_country_data AS (
    SELECT 
        RAW_DATA,
        INGESTED_AT
    FROM TRIPLENS_DB.RAW.RAW_COUNTRIES
)

SELECT
    -- Country identifiers
    RAW_DATA:alpha3Code::STRING AS country_code,
    RAW_DATA:name::STRING AS country_name,

    -- Geographic information
    RAW_DATA:capital::STRING AS capital_city,
    RAW_DATA:region::STRING AS region,
    RAW_DATA:subregion::STRING AS subregion,

    -- Demographic information
    RAW_DATA:population::INTEGER AS population,
    RAW_DATA:area::FLOAT AS total_area_square_kilometers,

    -- Membership information
    RAW_DATA:independent::BOOLEAN AS is_un_member,

    -- Metadata
    INGESTED_AT
FROM raw_country_data
WHERE RAW_DATA:alpha3Code IS NOT NULL