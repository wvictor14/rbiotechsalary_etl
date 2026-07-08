-- Resolve a currency for every response. Only the 2025+ surveys asked which
-- currency answers were in; for older years we infer it from geography.
-- Precedence: reported answer > country's currency > 2024 region bucket's
-- currency > assume USD (validated against 2025 data, where reported currency
-- matches the country's currency almost perfectly).
with
    responses as (
        select response_id, currency, raw_country, raw_region
        from {{ ref("stg_responses") }}
    ),

    currency_mapping as (select * from {{ ref("currency_names") }}),
    country_mapping as (select * from {{ ref("country_names") }}),
    countries as (select * from {{ ref("countries") }}),
    country_currencies as (select * from {{ ref("country_currencies") }}),
    region_mapping as (select * from {{ ref("region_countries") }}),

    normalized as (
        select
            r.response_id,
            cm.currency_code as reported_currency,
            coalesce(
                cnm.clean_country,
                case
                    when trim(r.raw_country) in (select country from countries)
                    then trim(r.raw_country)
                end
            ) as country,
            rm.currency_code as region_currency
        from responses as r
        left join currency_mapping as cm on lower(trim(r.currency)) = cm.raw_currency
        left join country_mapping as cnm on lower(trim(r.raw_country)) = cnm.raw_country
        left join region_mapping as rm on lower(trim(r.raw_region)) = rm.raw_region
    ),

    resolved as (
        select
            n.response_id,
            coalesce(
                n.reported_currency, cc.currency_code, n.region_currency, 'USD'
            ) as currency_code,
            case
                when n.reported_currency is not null
                then 'reported'
                when cc.currency_code is not null
                then 'inferred_from_country'
                when n.region_currency is not null
                then 'inferred_from_region'
                else 'assumed_usd'
            end as currency_source
        from normalized as n
        left join country_currencies as cc on n.country = cc.country
    )

select *
from resolved
