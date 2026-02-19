with
    int_jobs as (select distinct job_title from {{ ref('int_jobs') }}),
    final as (
        select

            ({{ dbt_utils.generate_surrogate_key(['job_title']) }}) as job_id, job_title
        from int_jobs
    )
select *
from final
order by job_title

;
