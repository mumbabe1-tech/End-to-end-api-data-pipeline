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
    country.value:name:common::STRING AS country_name,
    country.value:name:official::STRING AS official_name,
    country.value:capital[0]::STRING AS capital_city,
    country.value:callingCodes[0]::STRING AS calling_codes,
    country.value:unMember::BOOLEAN AS government_type,
    country.value:population::NUMBER AS population,
    country.value:region::STRING AS region,
    country.value:subregion::STRING AS subregion,
    
    -- Array keys & attributes
    country.value:continents[0]::STRING AS continent,
    country.value:independent::STRING AS independent,
    country.value:area::NUMBER AS kilometers,
    country.value:area::NUMBER AS miles,
    country.value:landlocked::STRING AS landlocked,
    country.value:unMember::BOOLEAN AS un_member,
    country.value:independent::BOOLEAN AS eu_member,
    FALSE AS arab_league_member,
    FALSE AS african_union_member,

    country.value:startOfWeek::STRING AS start_of_week,
    country.value:timezones[0]::STRING AS timezone,

    -- Visuals & Identifiers (Flags, Coat of Arms, Postal Codes)
    country.value:flags:png::STRING AS flag_png,
    country.value:flags:svg::STRING AS flag_svg,
    country.value:flags:alt::STRING AS flag_alt,
    country.value:coatOfArms:png::STRING AS coat_of_arms_png,
    country.value:coatOfArms:svg::STRING AS coat_of_arms_svg,
    country.value:postalCode:format::STRING AS postal_code_format,
    country.value:postalCode:regex::STRING AS postal_code_regex,
    
    -- Dynamic Currency keys
    currency.key::STRING AS currency_code,
    currency.value:name::STRING AS currency_name,
    currency.value:symbol::STRING AS currency_symbol,

    -- Dynamic Language keys
    language.key::STRING AS language_code,
    language.value::STRING AS language_name,

    -- Additional keys (Top-level domain & Borders)
    tld.value::STRING AS top_level_domain,
    border.value::STRING AS border_country_code

  FROM {{ ref('stage_raw_countries') }} AS stg
    CROSS JOIN LATERAL FLATTEN(input => PARSE_JSON(stg.payload)) country
    LEFT JOIN LATERAL FLATTEN(input => country.value:currencies) currency
    LEFT JOIN LATERAL FLATTEN(input => country.value:languages) language
    -- Left joins prevent dropping rows if a country is missing tld, borders, currencies, or languages
    LEFT JOIN LATERAL FLATTEN(input => country.value:tld) tld
    LEFT JOIN LATERAL FLATTEN(input => country.value:borders) border
)

select * from countries