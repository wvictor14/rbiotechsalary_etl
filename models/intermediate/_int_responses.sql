select
    timestamp,
    email_address,
    raw_job_title,
    raw_department,
    country,
    city,
    us_state,
    ca_province,
    company_name
from {{ ref('stg_responses') }}
