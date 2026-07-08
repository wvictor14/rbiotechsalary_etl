with
    -- select and basic trim
    jobs as (
        select
            response_id,
            raw_job_title,
            -- normalized key: collapses systematic variants (sr->senior,
            -- arabic->roman levels) onto seed conventions before matching
            {{ normalize_job_title("raw_job_title") }} as title_key,
            raw_department
        from {{ ref("stg_responses") }}
    ),

    -- map original titles to harmonized titles and job hierarchies.
    -- Normalize the seed key the SAME way so "sr analyst" (seed) and
    -- "Sr. Analyst" (response) both collapse to "senior analyst" and match.
    job_titles_mapping as (
        select title_key, clean_job_title
        from (
            select
                {{ normalize_job_title("raw_job_title") }} as title_key,
                clean_job_title,
                -- if two seed rows collapse to the same key, keep one
                -- deterministically (prefer non-Unknown, then alphabetical)
                row_number() over (
                    partition by {{ normalize_job_title("raw_job_title") }}
                    order by (clean_job_title = 'Unknown'), clean_job_title
                ) as rn
            from {{ ref("job_titles") }}
        )
        where rn = 1
    ),
    standard_titles as (
        select
            l.response_id,
            l.raw_job_title,
            l.raw_department,
            nullif(r.clean_job_title, 'Unknown') as title,

            -- Remove commas and slashes to help the fuzzy join match words
            regexp_replace(
                nullif(r.clean_job_title, 'Unknown'), '[,/]', ' '
            ) as title_to_match_on

        from jobs as l
        left join job_titles_mapping as r on l.title_key = r.title_key
    ),

    removed_nulls as (
        select * from standard_titles where raw_job_title is not null and title != '-'
    ),

    -- map job hierarchy and job level
    job_levels as (select * from {{ ref("job_hierarchy") }}),

    -- USE A FUZZY JOIN, THE RAW KEYWORD IS A PATTERN TO JOIN ON
    job_hierarchy_mapped as (
        select
            l.response_id,
            l.raw_job_title,
            l.raw_department,
            l.title,
            r.standardized_title,
            r.hierarchy,
            r.priority,
            -- we need to capture all the matches and rank them by priority
            -- one best match per RESPONSE (partitioning by title would keep one
            -- arbitrary response per title and drop the rest)
            row_number() over (
                partition by l.response_id
                order by r.priority asc, length(r.keyword) desc, r.keyword  -- prefer priority, then most specific (longest) keyword; keyword as deterministic tiebreak
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
    job_hierarchy_distinct as (select * from job_hierarchy_mapped where match_rank = 1),

    with_title_ids as (
        select
            -- Generate a surrogate key for the job based on all relevant attributes
            ({{ dbt_utils.generate_surrogate_key(["title"]) }}) as title_id, *
        from job_hierarchy_distinct

    ),
    final as (
        select
            response_id,
            raw_job_title,
            raw_department,
            -- Generate a surrogate key for the job based on all relevant attributes
            (
                {{
                    dbt_utils.generate_surrogate_key(
                        [
                            "title_id",
                            "raw_department",
                            "hierarchy",
                            "priority",
                        ]
                    )
                }}
            ) as job_id,
            title_id,
            title,
            standardized_title,
            raw_department as department,
            hierarchy,
            priority
        from with_title_ids
    )

select *
from final
