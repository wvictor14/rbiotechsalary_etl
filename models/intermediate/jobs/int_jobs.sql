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

    -- map original titles to harmonized titles.
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

    -- Map to job functions using fuzzy matching on keyword patterns
    job_functions_seed as (select * from {{ ref("job_functions") }}),
    job_function_mapped as (
        select
            l.response_id,
            l.title_to_match_on,
            r.job_function,
            r.priority,
            row_number() over (
                partition by l.response_id
                order by r.priority asc, length(r.keyword) desc, r.keyword
            ) as match_rank
        from standard_titles as l
        left join
            job_functions_seed as r
            on (
                trim(lower(l.title_to_match_on)) = trim(lower(r.keyword))
                or trim(lower(l.title_to_match_on)) like trim(lower(r.keyword)) || ' %'
                or trim(lower(l.title_to_match_on)) like '% ' || trim(lower(r.keyword))
                or trim(lower(l.title_to_match_on))
                like '% ' || trim(lower(r.keyword)) || ' %'
            )
    ),
    job_function_best as (
        select response_id, job_function
        from job_function_mapped
        where match_rank = 1
    ),

    -- Map to seniority levels using fuzzy matching on keyword patterns
    seniority_levels_seed as (select * from {{ ref("seniority_levels") }}),
    seniority_mapped as (
        select
            l.response_id,
            l.title_to_match_on,
            r.seniority,
            r.track,
            r.seniority_rank,
            r.priority,
            row_number() over (
                partition by l.response_id
                order by r.priority asc, length(r.keyword) desc, r.keyword
            ) as match_rank
        from standard_titles as l
        left join
            seniority_levels_seed as r
            on (
                trim(lower(l.title_to_match_on)) = trim(lower(r.keyword))
                or trim(lower(l.title_to_match_on)) like trim(lower(r.keyword)) || ' %'
                or trim(lower(l.title_to_match_on)) like '% ' || trim(lower(r.keyword))
                or trim(lower(l.title_to_match_on))
                like '% ' || trim(lower(r.keyword)) || ' %'
            )
    ),
    seniority_best as (
        select response_id, seniority, track, seniority_rank
        from seniority_mapped
        where match_rank = 1
    ),

    -- Combine both axes at response grain
    combined as (
        select
            st.response_id,
            st.raw_job_title,
            st.raw_department,
            st.title,
            st.title_to_match_on,
            fn.job_function,
            sen.seniority as sen_seniority,
            coalesce(sen.seniority, case when fn.job_function is not null then 'Mid' end) as seniority,
            coalesce(sen.seniority_rank, case when fn.job_function is not null then 5 end) as seniority_rank,
            coalesce(sen.track, case when fn.job_function is not null then 'IC' end) as track
        from standard_titles as st
        left join job_function_best as fn on st.response_id = fn.response_id
        left join seniority_best as sen on st.response_id = sen.response_id
    ),

    -- Derive standardized_title and title_status
    derived as (
        select
            response_id,
            raw_job_title,
            raw_department,
            title,
            job_function,
            seniority,
            seniority_rank,
            track,
            case
                when title is null then null
                when track in ('Management', 'Executive', 'Training') then seniority
                when job_function is null then seniority
                when seniority = 'Mid' then job_function
                when lower(job_function) like '%' || lower(seniority) || '%' then job_function
                else seniority || ' ' || job_function
            end as standardized_title,
            case
                when raw_job_title is null or trim(raw_job_title) = '' then 'missing'
                when job_function is null and sen_seniority is null then 'unmatched'
                else 'matched'
            end as title_status
        from combined
    ),

    -- Generate title_id
    with_title_ids as (
        select
            ({{ dbt_utils.generate_surrogate_key(["title"]) }}) as title_id,
            *
        from derived
    ),

    -- Final output
    final as (
        select
            response_id,
            raw_job_title,
            raw_department,
            (
                {{
                    dbt_utils.generate_surrogate_key(
                        [
                            "title_id",
                            "raw_department",
                            "job_function",
                            "seniority",
                            "track",
                            "title_status",
                        ]
                    )
                }}
            ) as job_id,
            title_id,
            title,
            standardized_title,
            raw_department as department,
            job_function,
            seniority,
            seniority_rank,
            track,
            title_status
        from with_title_ids
    )

select *
from final
