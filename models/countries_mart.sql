-- Purpose: Create a curated, analysis-ready countries table
------------------------------------------------------------
{{
    config(
        materialized='table'
    )
}}

SELECT
    stg.country_name AS country_name,
    stg.official_name AS official_name,
    stg.capital_city AS capital_city,
    stg.country_code AS country_code,
    stg.region AS region,
    stg.subregion AS subregion,
    stg.area_sq_km AS kilometers,
    
    -- Analytics & Demographics
    stg.payload:population::number AS population,
    stg.payload:independent::boolean AS independent,
    stg.payload:unMember::boolean AS un_member,
    stg.payload:landlocked::boolean AS landlocked,
    stg.payload:continents[0]::string AS continent,
    stg.payload:startOfWeek::string AS start_of_week,

    -- Extracting Flags & Maps
    stg.payload:flags:png::string AS flag_png,
    stg.payload:flags:svg::string AS flag_svg,
    stg.payload:flags:alt::string AS flag_alt,

    -- Extracting Languages (grabs the first spoken language object or string depending on API structure)
    -- This flattens or extracts the language names cleanly for reporting
    (SELECT VALUE FROM LATERAL FLATTEN(input => OBJECT_KEYS(stg.payload:languages)))[0]::string AS primary_language_code,
    
    -- Extracting Currencies (grabs the currency key/code)
    (SELECT VALUE FROM LATERAL FLATTEN(input => OBJECT_KEYS(stg.payload:currencies)))[0]::string AS primary_currency_code

FROM {{ ref('stage_raw_countries') }} AS stg