-- Purpose: Clean raw country JSON into structured columns
------------------------------------------------------------

WITH raw_data AS (
    SELECT
        SRC AS payload,
        loaded_at AS ingested_at
    FROM {{ source('raw_country_data', 'RAW_COUNTRIES') }}
),

countries AS (
    SELECT
        -- Identifiers & Names
        payload:alpha3Code::STRING AS country_code,
        payload:name::STRING AS country_name,
        payload:nativeName::STRING AS official_name,

        -- Geography & Demographics
        payload:capital::STRING AS capital_city,
        payload:region::STRING AS region,
        payload:subregion::STRING AS subregion,
        payload:area::NUMBER AS area_sq_km,
        payload:population::NUMBER AS population,
        payload:demonym::STRING AS demonym,
        payload:independent::BOOLEAN AS is_sovereign,

        -- Arrays / Lists (grabbing first element)
        payload:callingCodes[0]::STRING AS calling_code,
        payload:timezones[0]::STRING AS timezone,
        payload:topLevelDomain[0]::STRING AS top_level_domain,

        -- Primary Currency Fields (grabbing first currency safely without FLATTEN)
        payload:currencies[0].code::STRING AS currency_code,
        payload:currencies[0].name::STRING AS currency_name,
        payload:currencies[0].symbol::STRING AS currency_symbol,

        -- Metadata
        ingested_at

    FROM raw_data
)

SELECT * FROM countries