with
    int_jobs as (select distinct title from {{ ref('int_jobs') }}),
    final as (
        select ({{ dbt_utils.generate_surrogate_key(['title']) }}) as title_id, title
        from int_jobs
    )
select *
from final
order by title
;
