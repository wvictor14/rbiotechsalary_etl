select
    {{ dbt_utils.generate_surrogate_key(['company_name']) }} as company_id,
    company_name,
    company_size,
    sector,
    company_is_private_or_public
from {{ ref('int_companies_consolidated') }}
