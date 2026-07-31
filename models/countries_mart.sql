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
    NULL AS government_type,
    NULL AS population,
    stg.region AS region,
    stg.subregion AS subregion,
    
    -- Attributes
    NULL AS continent,
    NULL AS independent,
    stg.area_sq_km AS kilometers,
    NULL AS miles,
    NULL AS landlocked,
    FALSE AS un_member,
    FALSE AS eu_member,
    FALSE AS arab_league_member,
    FALSE AS african_union_member,

    NULL AS timezone,
    NULL AS start_of_week,

    -- Visuals & Identifiers
    NULL AS flag_png,
    NULL AS flag_svg,
    NULL AS flag_alt,
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