with
    dim_job_titles as (select * from {{ ref('dim_job_titles') }}),
    int_jobs as (select * from {{ ref('int_jobs') }}),
    
    -- First get distinct combinations of all job attributes
    distinct_job_combos as (
        select distinct 
            job_title,
            job_level,
            job_group,
            job_hierarchy
        from int_jobs
    ),
    
    final as (
        select 
            -- Generate a surrogate key for the job based on all relevant attributes
            {{ dbt_utils.generate_surrogate_key(['l.job_title_id', 'r.job_level', 'r.job_group', 'r.job_hierarchy']) }} as job_id,
            l.job_title_id,
            l.job_title,
            r.job_level,
            r.job_group,
            r.job_hierarchy
        from dim_job_titles as l
        left join distinct_job_combos as r
            on l.job_title = r.job_title
    )

select *
from final
order by job_hierarchy, job_title, job_level, job_group
;
