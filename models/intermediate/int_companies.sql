with
    -- first we apply distinc to columns of interest
    distinct_companies as (
        select distinct company_name, company_size, sector, company_is_private_or_public
        from {{ ref('stg_responses') }}
    ),
    -- then we compute a hash based on name, size, and sector
    company_with_ids as (
        select
            {{ dbt_utils.generate_surrogate_key(['company_name', 'company_size', 'sector', 'company_is_private_or_public']) }}
            as company_id,
            *
        from distinct_companies
        order by company_is_private_or_public desc, company_name asc
    )
select *
from company_with_ids
;
