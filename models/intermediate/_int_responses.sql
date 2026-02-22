select
    timestamp,
    email_address,

    -- joining to int_jobs on raw_job_title and raw_department
    raw_job_title,
    raw_department,

    -- joining on location
    country,
    city,

    -- joining on company
    company_name
from {{ ref("stg_responses") }}
