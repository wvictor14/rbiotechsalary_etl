with
    -- first we apply distinc to columns of interest
    distinct_companies as (
        select distinct company_name, company_size, sector, company_is_private_or_public
        from {{ ref('stg_responses') }}
    ),
    -- then join on company names mapping seed to get harmonized company names
    company_names_harmonized as (
        select
            r.harmonized_company_name as company_name,
            l.company_name as company_name_original,
            l.company_size,
            l.sector,
            l.company_is_private_or_public
        from distinct_companies as l
        left join {{ ref('company_names') }} as r on l.company_name = r.raw_company_name
    ),
    -- then for each company with duplicates we need to decide what metadata is correct
    -- use the "most selected" and "most recent" tie-breakers
    -- then we compute a hash based on name, size, and sector
    company_with_ids as (
        select
            {{ dbt_utils.generate_surrogate_key(['company_name', 'company_size', 'sector', 'company_is_private_or_public']) }}
            as company_id,
            *
        from company_names_harmonized
        order by company_is_private_or_public desc, company_name asc
    )
select *
from company_names_harmonized
;
