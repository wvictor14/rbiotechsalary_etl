select
    response_id,
    job_title,
    raw_department,
    country,
    city,
    us_state,
    ca_province,
    company_name
from {{ ref("int_responses") }}
