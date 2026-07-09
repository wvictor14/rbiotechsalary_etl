select
    response_id,
    submitted_at,
    date_part('year', submitted_at) as year,
    date_part('month', submitted_at) as month,
    date_part('day', submitted_at) as day,

    base_salary,
    bonus_pct,
    bonus_amount,
    total_compensation,
    currency_code,
    currency_source,

    title,
    standardized_title,
    department,
    job_function,
    seniority,
    seniority_rank,
    track,
    title_status,

    location_name,
    country,
    subdivision,
    city,

    company_name,
    company_size,
    sector,
    company_is_private_or_public

from {{ ref("int_responses_enriched") }}
