select
    response_id,
    survey_year,

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
