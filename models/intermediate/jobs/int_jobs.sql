with
    -- first we apply distinc to columns of interest
    distinct_jobs as (
        select distinct lower(trim(job_title)) as job_title, job_group
        from {{ ref('stg_responses') }}
    ),
    job_titles_mapping as (select * from {{ ref("job_titles") }}),
    joined as (
        select
            l.job_title as job_title_original,
            r.standardized_job_title as job_title,
            job_group

        from distinct_jobs as l
        left join job_titles_mapping as r on l.job_title = r.raw_job_title
    ),
    with_job_levels as (
        select
            *,
            -- Extract specific job level from job_title
            case
                -- Look for roman numerals or numbers after job titles
                when job_title like '% I' or job_title like '% 1'
                then replace(job_title, ' I', '')
                when job_title like '% II' or job_title like '% 2'
                then replace(replace(job_title, ' II', ''), ' 2', '')
                when job_title like '% III' or job_title like '% 3'
                then replace(replace(job_title, ' III', ''), ' 3', '')
                when job_title like '% IV' or job_title like '% 4'
                then replace(replace(job_title, ' IV', ''), ' 4', '')
                when job_title like '% V' or job_title like '% 5'
                then replace(replace(job_title, ' V', ''), ' 5', '')
                else job_title
            end as job_title_base,

            case
                when job_title like '% I' or job_title like '% 1'
                then 'I'
                when job_title like '% II' or job_title like '% 2'
                then 'II'
                when job_title like '% III' or job_title like '% 3'
                then 'III'
                when job_title like '% IV' or job_title like '% 4'
                then 'IV'
                when job_title like '% V' or job_title like '% 5'
                then 'V'
                else null
            end as job_level,

            -- Group jobs into broader hierarchical categories
            case
                -- C-Suite/Executive
                when
                    lower(job_title) like '%cso%'
                    or lower(job_title) like '%chief scientific officer%'
                then 'C-Suite/Executive'
                when
                    lower(job_title) like '%cto%'
                    or lower(job_title) like '%chief technology officer%'
                then 'C-Suite/Executive'
                when
                    lower(job_title) like '%cmo%'
                    or lower(job_title) like '%chief medical officer%'
                then 'C-Suite/Executive'
                when lower(job_title) like '%general counsel%'
                then 'C-Suite/Executive'
                when
                    lower(job_title) like '%vp%'
                    or lower(job_title) like '%vice president%'
                then 'C-Suite/Executive'
                when lower(job_title) like '%executive director%'
                then 'C-Suite/Executive'

                -- Senior Management
                when
                    lower(job_title) like '%senior director%'
                    or lower(job_title) like '%sr. director%'
                    or lower(job_title) like '%sr director%'
                then 'Senior Management'
                when lower(job_title) like '%director%'
                then 'Senior Management'
                when
                    lower(job_title) like '%associate director%'
                    or lower(job_title) like '%assoc director%'
                    or lower(job_title) like '%assoc. director%'
                then 'Senior Management'

                -- Middle Management
                when
                    lower(job_title) like '%senior manager%'
                    or lower(job_title) like '%sr. manager%'
                    or lower(job_title) like '%sr manager%'
                then 'Middle Management'
                when lower(job_title) like '%manager%'
                then 'Middle Management'
                when
                    lower(job_title) like '%associate manager%'
                    or lower(job_title) like '%assoc manager%'
                    or lower(job_title) like '%assoc. manager%'
                then 'Middle Management'
                when
                    lower(job_title) like '%team lead%'
                    or lower(job_title) like '%supervisor%'
                then 'Middle Management'

                -- Senior Individual Contributors
                when lower(job_title) like '%principal%'
                then 'Senior Individual Contributor'
                when
                    lower(job_title) like '%senior principal%'
                    or lower(job_title) like '%sr. principal%'
                    or lower(job_title) like '%sr principal%'
                then 'Senior Individual Contributor'
                when lower(job_title) like '%staff%'
                then 'Senior Individual Contributor'

                -- Scientific/Technical Professionals
                when
                    lower(job_title) like '%senior scientist%'
                    or lower(job_title) like '%sr. scientist%'
                    or lower(job_title) like '%sr scientist%'
                then 'Scientific/Technical Professional'
                when
                    lower(job_title) like '%senior engineer%'
                    or lower(job_title) like '%sr. engineer%'
                    or lower(job_title) like '%sr engineer%'
                then 'Scientific/Technical Professional'
                when
                    (
                        lower(job_title) like '%scientist%'
                        and not lower(job_title) like '%associate%'
                        and not lower(job_title) like '%assistant%'
                    )
                then 'Scientific/Technical Professional'
                when
                    (
                        lower(job_title) like '%engineer%'
                        and not lower(job_title) like '%associate%'
                        and not lower(job_title) like '%assistant%'
                    )
                then 'Scientific/Technical Professional'

                -- Associates/Assistants
                when lower(job_title) like '%associate%'
                then 'Associate/Assistant'
                when lower(job_title) like '%assistant%'
                then 'Associate/Assistant'
                when lower(job_title) like '%research associate%'
                then 'Associate/Assistant'
                when
                    lower(job_title) like '%lab technician%'
                    or lower(job_title) like '%specialist%'
                then 'Associate/Assistant'

                -- Entry Level/Training
                when lower(job_title) like '%intern%'
                then 'Entry Level/Training'
                when lower(job_title) like '%graduate%'
                then 'Entry Level/Training'
                when lower(job_title) like '%trainee%'
                then 'Entry Level/Training'
                when
                    lower(job_title) like '%postdoc%'
                    or lower(job_title) like '%post-doc%'
                then 'Entry Level/Training'

                -- Other specialized roles
                when
                    lower(job_title) like '%msl%'
                    or lower(job_title) like '%medical science liaison%'
                then 'Specialized Role'
                when
                    lower(job_title) like '%cra%'
                    or lower(job_title) like '%clinical research associate%'
                then 'Specialized Role'
                when lower(job_title) like '%consultant%'
                then 'Specialized Role'

                else 'Other'
            end as job_hierarchy
        from joined
    ),
    filtered_out_nulls as (
        select job_title_original, job_title, job_group, job_level, job_hierarchy
        from with_job_levels
        where job_title_original is not null and job_title != '-'
        order by job_title, job_group
    )

select *
from filtered_out_nulls
;
