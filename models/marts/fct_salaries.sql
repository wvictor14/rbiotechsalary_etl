select
    response_id,
    submitted_at,
    date_part('year', submitted_at) as year,
    date_part('month', submitted_at) as month,
    date_part('day', submitted_at) as day,

    company_id,
    job_id,
    location_id,

    base_salary,
    bonus_pct,
    bonus_amount,
    total_compensation,
    currency_code,
    currency_source
from {{ ref("int_responses_enriched") }}
