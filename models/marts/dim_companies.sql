with
    distinct_companies as (
        select distinct company_name, company_size, sector, company_is_private_or_public
        from {{ ref('stg_responses') }}
    )
select
    {{ dbt_utils.generate_surrogate_key(['company_name', 'company_size', 'sector', 'company_is_private_or_public']) }}
    as company_id,
    *
from distinct_companies
;
