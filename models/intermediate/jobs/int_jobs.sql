with
    -- first we apply distinc to columns of interest
    distinct_jobs as (
        select distinct lower(trim(job_title)) as raw_title, job_group as department
        from {{ ref('stg_responses') }}
    ),

    -- map original titles to harmonized titles and job hierarchies
    job_titles_mapping as (select * from {{ ref("job_titles") }}),
    standard_titles as (
        select l.raw_title, nullif(r.clean_job_title, 'Unknown') as title, department

        from distinct_jobs as l
        left join job_titles_mapping as r on l.raw_title = r.raw_job_title
    ),

    removed_nulls as (
        select * from standard_titles where raw_title is not null and title != '-'
    ),

    -- map job hierarchy and job level
    job_levels as (select * from {{ ref("job_hierarchy") }}),

    -- USE A FUZZY JOIN, THE RAW KEYWORD IS A PATTERN TO JOIN ON
    job_hierarchy_mapped as (
        select
            l.raw_title,
            l.title,
            r.standardized_title,
            l.department,
            r.hierarchy,
            r.priority,

            -- we need to capture all the matches and rank them by priority
            row_number() over (
                partition by l.title order by r.priority asc
            ) as match_rank
        from removed_nulls as l
        left join job_levels as r on lower(l.title) like "%" || r.keyword || "%"
    ),
    -- take the highest rank (1) 
    job_hierarchy_distinct as (select * from job_hierarchy_mapped where match_rank = 1)

select raw_title, title, standardized_title, hierarchy, department
from job_hierarchy_distinct
;
