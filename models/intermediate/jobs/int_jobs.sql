with
    -- first we apply distinc to columns of interest
    distinct_jobs as (
        select distinct
            raw_job_title,
            lower(trim(raw_job_title)) as title_lower,  -- to join on
            raw_department
        from {{ ref('stg_responses') }}
    ),

    -- map original titles to harmonized titles and job hierarchies
    job_titles_mapping as (select * from {{ ref("job_titles") }}),
    standard_titles as (
        select
            l.raw_job_title,
            l.raw_department,
            nullif(r.clean_job_title, 'Unknown') as title,

            -- Remove commas and slashes to help the fuzzy join match words
            regexp_replace(
                nullif(r.clean_job_title, 'Unknown'), '[,/]', ' '
            ) as title_to_match_on

        from distinct_jobs as l
        left join job_titles_mapping as r on l.title_lower = r.raw_job_title
    ),

    removed_nulls as (
        select * from standard_titles where raw_job_title is not null and title != '-'
    ),

    -- map job hierarchy and job level
    job_levels as (select * from {{ ref("job_hierarchy") }}),

    -- USE A FUZZY JOIN, THE RAW KEYWORD IS A PATTERN TO JOIN ON
    job_hierarchy_mapped as (
        select
            l.raw_job_title,
            l.raw_department,
            l.title,
            r.standardized_title,
            r.hierarchy,
            r.priority,
            -- we need to capture all the matches and rank them by priority
            row_number() over (
                partition by l.raw_job_title
                order by r.priority asc, length(r.keyword) desc  -- if matches have same priority, take the one with the longest keyword (most specific match)
            ) as match_rank
        from removed_nulls as l
        left join
            job_levels as r
            on (
                -- try really to match the title.
                trim(lower(l.title_to_match_on)) = trim(lower(r.keyword))
                or trim(lower(l.title_to_match_on)) like trim(lower(r.keyword)) || ' %'
                or trim(lower(l.title_to_match_on)) like '% ' || trim(lower(r.keyword))
                or trim(lower(l.title_to_match_on))
                like '% ' || trim(lower(r.keyword)) || ' %'
            )
    ),
    -- take the highest rank (1) 
    job_hierarchy_distinct as (select * from job_hierarchy_mapped where match_rank = 1)

select raw_job_title, raw_department, title, standardized_title, hierarchy, priority
from job_hierarchy_distinct
