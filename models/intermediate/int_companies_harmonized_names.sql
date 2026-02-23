with

    -- filter missing and basic trim
    companies_raw as (
        select
            response_id,
            raw_company_name,
            trim(raw_company_name) as company_name,
            company_size,
            sector,
            company_is_private_or_public
        from {{ ref("stg_responses") }}
        -- remove no names
        where
            lower(trim(raw_company_name)) != 'unknown' and raw_company_name is not null
    ),
    -- then join on company names mapping seed to get harmonized company names
    company_names_harmonized as (
        select
            l.response_id,
            l.raw_company_name,
            r.harmonized_company_name as company_name,
            l.company_size,
            l.sector,
            l.company_is_private_or_public
        from companies_raw as l
        left join {{ ref("company_names") }} as r on l.company_name = r.raw_company_name
    )
select *
from company_names_harmonized
;
