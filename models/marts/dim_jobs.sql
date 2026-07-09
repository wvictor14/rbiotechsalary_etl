select distinct
    job_id, title_id, title, standardized_title, department, job_function, seniority, seniority_rank, track, title_status
from {{ ref("int_jobs") }}
