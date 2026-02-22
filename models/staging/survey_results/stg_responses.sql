with
    source as (select * from {{ source('survey_results', 'src_responses') }}),

    renamed as (

        select
            timestamp,
            email_address,

            -- jobs
            what_is_your_official_job_title as raw_job_title,
            which_department_best_describes_your_role_if_you_cant_find_one_that_fits_your_specific_role_select_other_and_describe
            as raw_department,

            how_many_days_on_average_per_week_do_you_work_from_home,
            briefly_describe_your_position_and_responsibilities,
            do_you_work_inperson_remote_or_hybrid,

            which_country_do_you_work_in as country,
            what_city_do_you_work_in as city,
            which_us_state_do_you_work_in as us_state,
            which_canadian_province_do_you_work_in as ca_province,

            -- companies
            company_or_institution_name as company_name,
            which_of_the_following_best_describes_your_company
            as company_is_private_or_public,
            biotech_sub_industry as sector,
            company_detail_approximate_company_size as company_size,
            provide_a_review_and_rate_your_companyinstitution_and_experience,
            work_life_balance_on_average_how_many_hours_do_you_work_per_week,

            -- education
            what_degrees_do_you_have,
            how_many_total_years_of_experience_in_postdocs_do_you_have,
            list_other_relevant_and_recognized_certifications,
            please_enter_your_total_years_of_experience_in_the_field,
            what_currency_will_you_be_answering_these_questions_in,
            are_you_a_salaried_or_hourly_employee,
            if_you_are_an_hourly_employee_how_many_hours_per_week_do_you_work,
            annual_base_salary,
            overtime_pay,
            annual_target_bonus_in_percentage,
            commission,
            annual_equitystock_option,
            most_recent_annual_yearly_raise,
            bonus_value,
            stockequity_options,
            relocation_assistance_total_value,
            retirement_benefits,
            healthcare_benefits,
            select_the_highest_level_of_education_that_you_have_thats_relevant_to_your_occupation_if_you_have_multiple_please_select_other_and_describe,
            how_many_years_have_you_been_working_at_this_current_position,
            what_currency_will_you_be_answering_these_quesitons_in,
            survey_feedback,
            any_other_type_of_annual_bonus_please_describe,
            how_much_of_your_bonus_did_you_receive_in_the_last_cycle

        from source

    )

select *
from renamed
