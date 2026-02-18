with
    -- first we apply distinc to columns of interest
    distinct_jobs as (
        select distinct job_title, job_group from {{ ref('stg_responses') }}
    )

select *
from distinct_jobs
;
