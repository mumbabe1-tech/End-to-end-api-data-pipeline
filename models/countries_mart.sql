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

    -- Extracting Flags & Maps with fallback
    stg.payload:flags:png::string AS flag_png,
    stg.payload:flags:svg::string AS flag_svg,
    COALESCE(stg.payload:flags:alt::string, 'Not available') AS flag_alt

FROM {{ ref('stage_raw_countries') }} AS stg