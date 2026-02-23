with
    -- seeds
    countries as (select * from {{ ref("countries") }}),
    city_mapping as (select * from {{ ref("city_names") }}),

    raw_locations as (
        select
            response_id,
            raw_country,
            raw_city,
            trim(raw_country) as country,
            nullif(trim(raw_city), '') as city,
            nullif(trim(us_state), '') as us_state,
            nullif(trim(ca_province), '') as ca_province
        from {{ ref("stg_responses") }}
        where
            raw_country is not null
            and trim(raw_country) in (select country from countries)
    ),

    cleaned as (
        select
            r.response_id,
            r.raw_country,
            r.raw_city,
            country,
            nullif(coalesce(cm.clean_city, r.city), '') as city,
            us_state,
            ca_province,
            coalesce(us_state, ca_province) as subdivision
        from raw_locations r
        left join city_mapping cm on r.city = cm.raw_city
    ),

    final as (
        select
            response_id,
            raw_country,
            raw_city,
            {{ dbt_utils.generate_surrogate_key(["country", "city", "subdivision"]) }}
            as location_id,
            country,
            city,
            us_state,
            ca_province,
            subdivision
        from cleaned
    )

select
    response_id,
    raw_country,
    raw_city,
    location_id,
    concat_ws(', ', city, subdivision, country) as location_name,
    country,
    city,
    us_state,
    ca_province,
    subdivision
from final
;
