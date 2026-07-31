-- Purpose: Clean raw country JSON into structured columns
------------------------------------------------------------

WITH countries AS (
  SELECT
    -- Pass the raw JSON object through for downstream flattening in marts
    raw.SRC AS payload,

    -- Identifiers & Names
    raw.SRC:alpha3Code::STRING AS country_code,
    raw.SRC:name::STRING AS country_name,
    raw.SRC:nativeName::STRING AS official_name,

    -- Geography & Demographics
    raw.SRC:capital::STRING AS capital_city,
    raw.SRC:region::STRING AS region,
    raw.SRC:subregion::STRING AS subregion,
    raw.SRC:area::NUMBER AS area_sq_km,
    raw.SRC:population::NUMBER AS population,
    raw.SRC:demonym::STRING AS demonym,
    raw.SRC:independent::BOOLEAN AS is_sovereign,

    -- Codes & Time
    raw.SRC:callingCodes[0]::STRING AS calling_code,
    raw.SRC:timezones[0]::STRING AS timezone,
    raw.SRC:topLevelDomain[0]::STRING AS top_level_domain,

    -- Ingestion Tracking
    raw.loaded_at AS ingested_at

  FROM {{ source('raw_country_data', 'RAW_COUNTRIES') }} AS raw
  WHERE raw.SRC:name::STRING IS NOT NULL
)

SELECT DISTINCT * FROM countries