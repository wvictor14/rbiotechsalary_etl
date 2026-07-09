with
    source as (select * from {{ source("survey_results", "src_responses_2024") }}),

    -- 2022-2024 collected the annual target bonus in one free-form column
    -- that mixes units: decimal fractions (0.1 = 10%), percentages (15),
    -- and dollar amounts (10000). Split by magnitude:
    --   <= 1   -> fraction, convert to percent
    --   <= 100 -> already a percent
    --   > 100  -> dollar amount
    parsed as (
        select
            *,
            {{ parse_first_number("compensation_annual_target_bonus") }}
            as bonus_numeric
        from source
    ),

    renamed as (

        select
            {{ dbt_utils.generate_surrogate_key(["'2024'", "timestamp"]) }}
            as response_id,
            2024 as survey_year,
            cast(timestamp as timestamp) as submitted_at,
            cast(null as varchar) as email_address,

            -- jobs
            role_title_of_current_position as raw_job_title,
            cast(null as varchar) as raw_department,
            briefly_describe_your_position as position_description,
            cast(null as varchar) as work_arrangement,
            cast(null as varchar) as wfh_days_per_week,

            -- locations: 2024 switched mid-survey from city/country questions
            -- to multi-state region buckets (where_are_you_located)
            what_country_do_you_work_in as raw_country,
            where_is_the_closest_major_city_or_hub as raw_city,
            where_are_you_located as raw_region,
            cast(null as varchar) as us_state,
            cast(null as varchar) as ca_province,

            -- companies
            company_or_institution_name as raw_company_name,
            company_details_publicprivatestartup_subsidiary_of
            as company_is_private_or_public,
            biotech_sub_industry as sector,
            company_detail_approximate_company_size as company_size,
            company_review,
            work_life_balance_on_average_how_many_hours_do_you_work_per_week
            as hours_worked_per_week,

            -- education and experience
            what_degrees_do_you_have as degrees,
            cast(null as varchar) as highest_education,
            cast(null as varchar) as postdoc_years,
            cast(null as varchar) as did_postdoc,
            list_other_relevant_and_recognized_certifications as certifications,
            years_of_experience,
            cast(null as varchar) as years_at_current_position,

            -- compensation
            cast(null as varchar) as currency,
            cast(null as varchar) as salaried_or_hourly,
            cast(null as varchar) as hourly_hours_per_week,
            compensation_annual_base_salarypay as annual_base_salary,
            compensation_overtime_pay as overtime_pay,
            case
                when bonus_numeric <= 1
                then cast(bonus_numeric * 100 as varchar)
                when bonus_numeric <= 100
                then cast(bonus_numeric as varchar)
            end as annual_target_bonus_in_percentage,
            case
                when bonus_numeric > 100 then cast(bonus_numeric as varchar)
            end as annual_target_bonus_amount,
            cast(null as varchar) as other_annual_bonus,
            cast(null as varchar) as bonus_received_last_cycle,
            cast(null as varchar) as commission,
            compensation_annual_equitystock_option as annual_equity,
            compensation_most_recent_annual_yearly_raise
            as most_recent_annual_yearly_raise,
            compensation_sign_on_bonus_value as signon_bonus_value,
            compensation_sign_on_stockequity_options as signon_stock_options,
            sign_on_relocation_assistance_total_value
            as relocation_assistance_value,
            compensation_retirement_benefits as retirement_benefits,
            compensation_retirement_percent_match as retirement_percent_match,
            compensation_healthcare_benefits as healthcare_benefits,

            survey_feedback

        from parsed

    )

select *
from renamed
