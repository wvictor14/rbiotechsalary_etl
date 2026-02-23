select distinct title_id title
from {{ ref("int_jobs") }}
;
