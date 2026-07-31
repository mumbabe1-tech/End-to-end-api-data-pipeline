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
    stg.alpha2_code AS alpha2_code,
    stg.numeric_code AS numeric_code,
    stg.region AS region,
    stg.subregion AS subregion,
    stg.area_sq_km AS kilometers,
    
    -- Demographics & Codes
    stg.population AS population,
    stg.demonym AS demonym,
    stg.is_sovereign AS independent,
    stg.calling_code AS calling_code,
    stg.timezone AS timezone,
    stg.top_level_domain AS top_level_domain,

    -- Languages, Currencies, Borders & Metadata
    stg.languages_raw[0]:name::string AS primary_language,
    stg.currencies_raw[0]:name::string AS currency_name,
    stg.currencies_raw[0]:code::string AS currency_code,
    stg.borders_raw AS neighboring_countries,
    stg.alt_spellings_raw[0]::string AS alternate_spelling,

    -- Extracting Flags & Maps with fallback
    stg.payload:flags:png::string AS flag_png,
    stg.payload:flags:svg::string AS flag_svg,
    COALESCE(stg.payload:flags:alt::string, 'Not available') AS flag_alt

FROM {{ ref('stage_raw_countries') }} AS stg