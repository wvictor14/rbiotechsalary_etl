with
    stg as (select * from {{ ref("stg_responses") }}),

    jobs as (select * from {{ ref("int_jobs") }}),

    locations as (select * from {{ ref("int_locations") }}),

    companies_h as (select * from {{ ref("int_companies_harmonized_names") }}),

    companies as (select * from {{ ref("int_companies_consolidated") }}),

    salaries as (select * from {{ ref("int_salaries_computed") }}),

    joined as (
        select
            s.timestamp,
            s.email_address,

            s.raw_job_title,
            j.title as job_title,
            j.standardized_title,
            j.hierarchy as job_hierarchy,
            s.raw_department,

            s.raw_company_name,
            coalesce(ch.company_name, trim(s.raw_company_name)) as company_name,
            c.company_size,
            c.sector,
            c.company_is_private_or_public,

            s.raw_country,
            s.raw_city,
            l.country,
            l.city,
            l.us_state,
            l.ca_province,

            sal.base_salary,
            sal.bonus_pct,
            sal.bonus_amount,
            sal.total_compensation

        from stg s
        left join jobs j on s.raw_job_title = j.raw_job_title
        left join
            locations l
            on s.raw_country = l.raw_country
            and (coalesce(s.raw_city, '') = coalesce(l.raw_city, ''))
        left join companies_h ch on trim(s.raw_company_name) = ch.raw_company_name
        left join
            companies c
            on coalesce(ch.company_name, trim(s.raw_company_name)) = c.company_name
        left join salaries sal on s.timestamp = sal.timestamp
    )

select *
from joined
;
