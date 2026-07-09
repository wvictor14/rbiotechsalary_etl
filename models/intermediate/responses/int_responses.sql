with
    stg as (select * from {{ ref("stg_responses") }}),

    jobs as (select * from {{ ref("int_jobs") }}),

    locations as (select * from {{ ref("int_locations") }}),

    companies as (select * from {{ ref("int_companies_harmonized_names") }}),

    salaries as (select * from {{ ref("int_salaries_computed") }}),

    currencies as (select * from {{ ref("int_currencies") }}),

    -- join the foreign keys from other int tables
    joined as (
        select
            s.response_id,
            s.submitted_at,
            c.company_name,
            j.job_id,
            l.location_id,
            sa.base_salary,
            sa.bonus_pct,
            sa.bonus_amount,
            sa.total_compensation,
            cur.currency_code,
            cur.currency_source
        from stg as s
        left join companies as c on s.response_id = c.response_id
        left join jobs as j on s.response_id = j.response_id
        left join locations as l on s.response_id = l.response_id
        left join salaries as sa on s.response_id = sa.response_id
        left join currencies as cur on s.response_id = cur.response_id
    )

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
    currency_source
from joined
