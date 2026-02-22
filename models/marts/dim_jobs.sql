with
    dim_job_titles as (select * from {{ ref('dim_job_titles') }}),
    int_jobs as (select * from {{ ref('int_jobs') }}),

    -- First get distinct combinations of all job attributes
    distinct_job_combos as (
        select distinct title, standardized_title, hierarchy, department, priority
        from int_jobs
    ),

    final as (
        select
            -- Generate a surrogate key for the job based on all relevant attributes
            {{ dbt_utils.generate_surrogate_key(['l.title_id', 'r.department', 'r.hierarchy', 'r.priority']) }}
            as job_id,
            l.title_id,
            l.title,
            r.standardized_title,
            r.department,
            r.hierarchy,
            r.priority
        from dim_job_titles as l
        left join distinct_job_combos as r on l.title = r.title
    )

select *
from final
order by hierarchy, title, department
;
