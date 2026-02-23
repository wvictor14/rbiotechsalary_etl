select
    response_id,

    title,
    standardized_title,
    department,
    hierarchy,

    location_name,
    country,
    subdivision,
    city,

    company_name,
    company_size,
    sector,
    company_is_private_or_public

from {{ ref("int_responses_enriched") }}
