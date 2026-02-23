with
    companies as (
        select * from {{ ref("int_companies_harmonized_names") }} order by company_name
    ),
    -- pivot so that we can count by company_name, var_name, var_value
    unpivoted as (
        select company_name, var_name, var_value
        from
            companies unpivot (
                var_value for var_name
                in (company_size, sector, company_is_private_or_public)
            )
    ),
    -- count by company_name, var_name, var_values
    counted as (
        select
            *,
            count(*) as n,
            row_number() over (
                partition by company_name, var_name order by count(*) desc
            ) as rank
        from unpivoted
        group by company_name, var_name, var_value
        order by company_name, var_name, rank
    ),
    -- for each company take the top
    top_ranked as (
        select company_name, var_name, var_value from counted where rank = 1
    ),
    pivoted as (
        select company_name, company_size, sector, company_is_private_or_public
        from
            top_ranked pivot (
                max(var_value)  -- just take the only value
                for var_name
                in ('company_size', 'sector', 'company_is_private_or_public')
            )
    )
select *
from pivoted
;
