with
    raw_data as (
        select
            response_id,
            survey_year,
            annual_base_salary,
            annual_target_bonus_in_percentage,
            annual_target_bonus_amount
        from {{ ref("stg_responses") }}
        where annual_base_salary is not null
    ),

    -- parse_first_number takes the first numeric token, so range answers
    -- like "110,000 - 120,000" become the lower bound instead of garbage
    parsed as (
        select
            response_id,
            survey_year,
            {{ parse_first_number("annual_base_salary") }} as base_salary,
            {{ parse_first_number("annual_target_bonus_in_percentage") }}
            as bonus_pct_raw,
            {{ parse_first_number("annual_target_bonus_amount") }}
            as bonus_amount_raw
        from raw_data
    ),

    -- null out implausible bonus values instead of dropping the response:
    -- the base salary is still usable
    validated as (
        select
            response_id,
            survey_year,
            base_salary,
            case when bonus_pct_raw <= 100 then bonus_pct_raw end as bonus_pct,
            case
                when bonus_amount_raw <= base_salary then bonus_amount_raw
            end as bonus_amount_reported
        from parsed
        where base_salary >= 15000
    )

select *
from validated
