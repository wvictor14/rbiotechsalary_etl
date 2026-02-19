with
    -- first we apply distinc to columns of interest
    distinct_jobs as (
        select distinct lower(trim(job_title)) as job_title, job_group
        from {{ ref('stg_responses') }}
    ),

    -- map original titles to harmonized titles and job hierarchies
    job_titles_mapping as (select * from {{ ref("job_titles") }}),
    joined as (
        select
            l.job_title as job_title_original,
            r.standardized_job_title as job_title,
            r.job_level,
            r.job_hierarchy,
            job_group

        from distinct_jobs as l
        left join job_titles_mapping as r on l.job_title = r.raw_job_title
    ),

    -- unknowns should be converted to explicit nulls 
    filtered_out_nulls as (
        select
            job_title_original,
            nullif(job_title, 'Unknown') as job_title,
            job_level,
            job_hierarchy,
            job_group
        from joined
        where job_title_original is not null and job_title != '-'
        order by job_title, job_group
    )

select *
from filtered_out_nulls
;
