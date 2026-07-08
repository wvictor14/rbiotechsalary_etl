with
    source as (select * from {{ source("survey_results", "src_responses_2026") }}),

    renamed as (

        select
            {{ dbt_utils.generate_surrogate_key(["'2026'", "timestamp"]) }}
            as response_id,
            2026 as survey_year,
            timestamp,
            -- 2026 survey no longer collects email
            cast(null as varchar) as email_address,

            -- jobs
            what_is_your_official_job_title as raw_job_title,
            which_department_best_describes_your_role_if_you_cant_find_one_that_fits_your_specific_role_select_other_and_describe
            as raw_department,
            briefly_describe_your_position_and_responsibilities
            as position_description,
            do_you_work_inperson_remote_or_hybrid as work_arrangement,
            how_many_days_on_average_per_week_do_you_work_from_home
            as wfh_days_per_week,

            -- locations
            which_country_do_you_work_in as raw_country,
            what_city_do_you_work_in as raw_city,
            cast(null as varchar) as raw_region,
            which_us_state_do_you_work_in as us_state,
            which_canadian_province_do_you_work_in as ca_province,

            -- companies
            company_or_institution_name as raw_company_name,
            which_of_the_following_best_describes_your_company
            as company_is_private_or_public,
            biotech_sub_industry as sector,
            company_detail_approximate_company_size as company_size,
            provide_a_review_and_rate_your_companyinstitution_and_experience
            as company_review,
            work_life_balance_on_average_how_many_hours_do_you_work_per_week
            as hours_worked_per_week,

            -- education and experience (2026 dropped the multi-select degrees
            -- question, keeping only highest relevant education)
            cast(null as varchar) as degrees,
            select_the_highest_level_of_education_that_you_have_thats_relevant_to_your_occupation_if_you_have_multiple_please_select_other_and_describe
            as highest_education,
            how_many_total_years_of_experience_in_postdocs_do_you_have
            as postdoc_years,
            cast(null as varchar) as did_postdoc,
            list_other_relevant_and_recognized_certifications as certifications,
            please_enter_your_total_years_of_experience_in_the_field
            as years_of_experience,
            how_many_years_have_you_been_working_at_this_current_position
            as years_at_current_position,

            -- compensation
            what_currency_will_you_be_answering_these_quesitons_in as currency,
            are_you_a_salaried_or_hourly_employee as salaried_or_hourly,
            if_you_are_an_hourly_employee_how_many_hours_per_week_do_you_work
            as hourly_hours_per_week,
            annual_base_salary,
            overtime_pay,
            annual_target_bonus_in_percentage,
            cast(null as varchar) as annual_target_bonus_amount,
            any_other_type_of_annual_bonus_please_describe as other_annual_bonus,
            how_much_of_your_bonus_did_you_receive_in_the_last_cycle
            as bonus_received_last_cycle,
            commission,
            annual_equitystock_option as annual_equity,
            most_recent_annual_yearly_raise,
            bonus_value as signon_bonus_value,
            stockequity_options as signon_stock_options,
            relocation_assistance_total_value as relocation_assistance_value,
            retirement_benefits,
            cast(null as varchar) as retirement_percent_match,
            healthcare_benefits,

            survey_feedback

        from source

    )

select *
from renamed
