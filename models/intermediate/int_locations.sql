with
    -- seed
    countries as (select * from {{ ref('countries') }}),

    raw_locations as (
        select
            trim(country) as country,
            nullif(trim(city), '') as city,
            nullif(trim(us_state), '') as us_state,
            nullif(trim(ca_province), '') as ca_province
        from {{ ref('stg_responses') }}
        where country is not null and country in (select country from countries)
    ),

    final as (
        select distinct
            country,
            city,
            us_state,
            ca_province,
            coalesce(us_state, ca_province) as subdivision,
            concat_ws(', ', city, subdivision, country) as location_name
        from raw_locations
    )

select *
from final
;
