-- Purpose: Create a curated, analysis-ready countries table
------------------------------------------------------------
{{
    config(
        materialized='table'
    )
}}

SELECT
    stg.country AS country_name,
    stg.official_name AS official_name,
    stg.capital_city AS capital_city,
    stg.country_code AS country_code,
    NULL AS government_type,
    stg.population AS population,
    stg.region AS region,
    stg.subregion AS subregion,
    
    -- Attributes
    NULL AS continent,
    stg.independent AS independent,
    stg.area_kilometers AS kilometers,
    stg.area_miles AS miles,
    stg.landlocked AS landlocked,
    FALSE AS un_member,
    FALSE AS eu_member,
    FALSE AS arab_league_member,
    FALSE AS african_union_member,

    stg.timezone AS timezone,
    stg.start_of_week AS start_of_week,

    -- Visuals & Identifiers
    stg.flag_png AS flag_png,
    stg.flag_svg AS flag_svg,
    stg.flag_alt AS flag_alt,
    NULL AS coat_of_arms_png,
    NULL AS coat_of_arms_svg,
    NULL AS postal_code_format,
    NULL AS postal_code_regex,
    
    -- Dynamic placeholders
    NULL AS currency_code,
    NULL AS currency_name,
    NULL AS currency_symbol,
    NULL AS language_code,
    NULL AS language_name,
    NULL AS top_level_domain,
    NULL AS border_country_code

FROM {{ ref('stage_raw_countries') }} AS stg