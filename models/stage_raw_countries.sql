-- Purpose: Clean raw country JSON into structured columns
------------------------------------------------------------

WITH countries AS (
  SELECT
    -- Identifiers & Names
    country.value:cca3::STRING AS country_code,
    country.value:names.common::STRING AS country_name,
    country.value:names.official::STRING AS official_name,

    -- Geography & Demographics
    country.value:capitals[0]:name::STRING AS capital_city,
    country.value:region::STRING AS region,
    country.value:subregion::STRING AS subregion,
    country.value:continents[0]::STRING AS continent,
    country.value:population::NUMBER AS population,
    country.value:area.kilometers::NUMBER AS area_sq_km,
    country.value:area.miles::NUMBER AS area_sq_miles,
    country.value:landlocked::STRING AS is_landlocked,

    -- Governance & Memberships
    country.value:government_type::STRING AS government_type,
    country.value:classification.sovereign::STRING AS is_sovereign,
    country.value:memberships.un::BOOLEAN AS is_un_member,
    country.value:memberships.eu::BOOLEAN AS is_eu_member,
    country.value:memberships.arab_league::BOOLEAN AS is_arab_league_member,
    country.value:memberships.african_union::BOOLEAN AS is_african_union_member,

    -- Codes & Time
    country.value:calling_codes[0]::STRING AS calling_code,
    country.value:date.start_of_week::STRING AS start_of_week,
    country.value:timezones[0]::STRING AS timezone,

    -- Dynamic Currency Fields
    currency.value:code::STRING AS currency_code,
    currency.value:name::STRING AS currency_name,
    currency.value:symbol::STRING AS currency_symbol,

    -- Ingestion Tracking
    raw.loaded_at AS ingested_at

  FROM {{ source('raw_country_data', 'RAW_COUNTRIES') }} AS raw
    JOIN LATERAL FLATTEN(input => raw.SRC) country
    LEFT JOIN LATERAL FLATTEN(input => country.value:currencies) currency
)

SELECT * FROM countries