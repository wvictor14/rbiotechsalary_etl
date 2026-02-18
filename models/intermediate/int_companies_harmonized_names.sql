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
    )
select *
from company_names_harmonized
;
