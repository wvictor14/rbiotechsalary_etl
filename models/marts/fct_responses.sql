select
    timestamp,

    -- joining to int_jobs on raw_job_title and raw_department
    raw_job_title,
    raw_department,

    -- joining on location
    raw_country,
    raw_city,

    -- joining on company
    raw_company_name
from {{ ref("int_salaries_cleaned") }}
