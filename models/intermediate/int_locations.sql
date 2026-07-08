with
    -- seeds
    countries as (select * from {{ ref("countries") }}),
    city_mapping as (select * from {{ ref("city_names") }}),
    subdivisions as (select * from {{ ref("subdivisions") }}),

    country_mapping as (select * from {{ ref("country_names") }}),

    -- normalize country name variants (USA, US, England, ...) before the
    -- countries filter, so those responses aren't dropped
    normalized_country as (
        select
            s.*,
            coalesce(cn.clean_country, trim(s.raw_country)) as country_clean
        from {{ ref("stg_responses") }} as s
        left join country_mapping as cn
            on lower(trim(s.raw_country)) = cn.raw_country
    ),

    raw_locations as (
        select
            response_id,
            raw_country,
            raw_city,
            country_clean as country,
            nullif(trim(raw_city), '') as city,
            nullif(trim(us_state), '') as us_state,
            nullif(trim(ca_province), '') as ca_province
        from normalized_country
        where
            raw_country is not null
            and country_clean in (select country from countries)
    ),

    cleaned_city as (
        select
            r.response_id,
            r.raw_country,
            r.raw_city,
            country,
            nullif(coalesce(cm.clean_city, r.city), '') as city,
            us_state,
            ca_province
        from raw_locations r
        left join city_mapping cm on r.city = cm.raw_city
    ),

    -- older surveys put state/province names in the city-or-hub question;
    -- reclassify them so "California" is a subdivision regardless of year
    cleaned as (
        select
            response_id,
            raw_country,
            raw_city,
            country,
            case
                when city in (select subdivision from subdivisions) then null
                else city
            end as city,
            us_state,
            ca_province,
            coalesce(
                us_state,
                ca_province,
                case
                    when city in (select subdivision from subdivisions) then city
                end
            ) as subdivision
        from cleaned_city
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
    trim(concat_ws(', ', city, subdivision, country)) as location_name,
    country,
    city,
    us_state,
    ca_province,
    subdivision
from final
