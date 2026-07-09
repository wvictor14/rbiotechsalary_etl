with
    int_responses as (
        select
            response_id,
            submitted_at,
            company_name,
            job_id,
            location_id,
            base_salary,
            bonus_pct,
            bonus_amount,
            total_compensation,
            currency_code,
            currency_source,
            survey_feedback
        from {{ ref("int_responses") }}
    ),
    jobs as (select * from {{ ref("dim_jobs") }}),
    locations as (select * from {{ ref("dim_locations") }}),
    companies as (select * from {{ ref("dim_companies") }}),
    final as (
        select
            r.response_id,
            r.submitted_at,
            r.company_name,
            c.company_id,
            c.company_size,
            c.sector,
            c.company_is_private_or_public,

            r.job_id,
            j.title_id,
            j.title,
            j.standardized_title,
            j.department,
            j.job_function,
            j.seniority,
            j.seniority_rank,
            j.track,
            j.title_status,

            r.base_salary,
            r.bonus_pct,
            r.bonus_amount,
            r.total_compensation,
            r.currency_code,
            r.currency_source,

            r.survey_feedback,

            r.location_id,
            l.location_name,
            l.country,
            l.subdivision,
            l.city

        from int_responses as r
        left join companies as c on r.company_name = c.company_name
        left join jobs as j on r.job_id = j.job_id
        left join locations as l on r.location_id = l.location_id
    )
select *
from final
