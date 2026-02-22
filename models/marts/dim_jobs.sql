with
    dim_job_titles as (select * from {{ ref('dim_job_titles') }}),

    -- First get distinct combinations of all job attributes
    distinct_job_combos as (
        select distinct
            raw_job_title,
            raw_department,
            title,
            standardized_title,
            hierarchy,
            priority
        from {{ ref('int_jobs') }}
    ),

    final as (
        select

            r.raw_job_title,
            r.raw_department,

            -- Generate a surrogate key for the job based on all relevant attributes
            {{ dbt_utils.generate_surrogate_key(['l.title_id', 'r.raw_department', 'r.hierarchy', 'r.priority']) }}
            as job_id,
            l.title_id,
            l.title,
            r.standardized_title,
            r.hierarchy,
            r.priority
        from dim_job_titles as l
        left join distinct_job_combos as r on l.title = r.title
    )

select *
from final
order by hierarchy, title, raw_department
;
