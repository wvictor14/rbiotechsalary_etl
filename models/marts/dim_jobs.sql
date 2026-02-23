select distinct
    job_id, title_id, title, standardized_title, department, hierarchy, priority
from {{ ref("int_jobs") }}
