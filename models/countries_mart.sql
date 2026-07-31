-- Purpose: Create a curated, analysis-ready countries table
------------------------------------------------------------
{{
    config(
        materialized='table'
    )
}}

with countries as (
  SELECT
    -- Top level keys
    country.value:names.common::STRING AS country_name,
    country.value:names.official::STRING AS official_name,
    country.value:capitals[0]:name::STRING AS capital_city,
    country.value:calling_codes[0]::STRING AS calling_codes,
    country.value:government_type::STRING AS government_type,
    country.value:population::NUMBER AS population,
    country.value:region::STRING AS region,
    country.value:subregion::STRING AS subregion,
    
    -- Array keys & attributes
    country.value:continents[0]::STRING AS continent,
    country.value:classification.sovereign::STRING AS independent,
    country.value:area.kilometers::NUMBER AS kilometers,
    country.value:area.miles::NUMBER AS miles,
    country.value:landlocked::STRING AS landlocked,
    country.value:memberships.un::BOOLEAN AS un_member,
    country.value:memberships.eu::BOOLEAN AS eu_member,
    country.value:memberships.arab_league::BOOLEAN AS arab_league_member,
    country.value:memberships.african_union::BOOLEAN AS african_union_member,

    country.value:date.start_of_week::STRING AS start_of_week,
    country.value:timezones[0]::STRING AS timezone,

    -- Visuals & Identifiers (Flags, Coat of Arms, Postal Codes)
    country.value:flags.png::STRING AS flag_png,
    country.value:flags.svg::STRING AS flag_svg,
    country.value:flags.alt::STRING AS flag_alt,
    country.value:coat_of_arms.png::STRING AS coat_of_arms_png,
    country.value:coat_of_arms.svg::STRING AS coat_of_arms_svg,
    country.value:postal_code.format::STRING AS postal_code_format,
    country.value:postal_code.regex::STRING AS postal_code_regex,
    
    -- Dynamic Currency keys
    currency.value:code::STRING AS currency_code,
    currency.value:name::STRING AS currency_name,
    currency.value:symbol::STRING AS currency_symbol,

    -- Dynamic Language keys
    language.key::STRING AS language_code,
    language.value::STRING AS language_name,

    -- Additional keys (Top-level domain & Borders)
    tld.value::STRING AS top_level_domain,
    border.value::STRING AS border_country_code

  FROM {{ ref('stage_raw_countries') }} AS stg
    JOIN LATERAL FLATTEN(input => stg.PAYLOAD) country
    JOIN LATERAL FLATTEN(input => country.value:currencies) currency
    JOIN LATERAL FLATTEN(input => country.value:languages) language
    -- Left joins prevent dropping rows if a country is missing tld or borders
    LEFT JOIN LATERAL FLATTEN(input => country.value:tld) tld
    LEFT JOIN LATERAL FLATTEN(input => country.value:borders) border
)

select * from countries