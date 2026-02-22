with
    raw_data as (
        select timestamp, annual_base_salary, annual_target_bonus_in_percentage
        from {{ ref("stg_responses") }}
        -- Critical: Filter out the "Process results" junk rows immediately
        where timestamp is not null and annual_base_salary is not null
    ),

    scrubbed as (
        select
            *,
            -- Step 1: Just remove everything that isn't a digit or decimal
            regexp_replace(
                cast(annual_base_salary as string), '[^0-9.]', ''
            ) as base_str,
            regexp_replace(
                cast(annual_target_bonus_in_percentage as string), '[^0-9.]', ''
            ) as bonus_pct_str
        from raw_data
    ),
    final_numeric as (
        select
            timestamp,
            -- Step 2: Safe cast to double (Spark's version of float)
            cast(nullif(base_str, '') as double) as base_salary,
            cast(nullif(bonus_pct_str, '') as double) as bonus_pct
        from scrubbed
    ),

    filtered as (
        select * from final_numeric where base_salary >= 15000 and bonus_pct <= 100
    )

select *
from filtered
