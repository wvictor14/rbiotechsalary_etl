with
    stg as (select * from {{ ref("stg_responses") }}),

    jobs as (select * from {{ ref("int_jobs") }}),

    locations as (select * from {{ ref("int_locations") }}),

    companies as (select * from {{ ref("int_companies_harmonized_names") }}),

    salaries as (select * from {{ ref("int_salaries_computed") }}),

    -- join the foreign keys from other int tables
    joined as (
        select s.response_id, c.company_name, j.job_id, l.location_id
        from stg as s
        left join companies as c on s.response_id = c.response_id
        left join jobs as j on s.response_id = j.response_id
        left join locations as l on s.response_id = l.response_id
    )

select *
from joined
;
