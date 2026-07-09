{% docs jobs_hierarchy %}

## Job Hierarchy Mapping (Two-Axis Model)

### 1. Approach Overview

This model maps messy, free-text job titles to a **two-dimensional classification**:
- **Job Function**: Primary role category (e.g., Data Scientist, Engineer, Analyst, Manager)
- **Seniority**: Level and track (Senior/Mid/Junior, plus track: IC / Management / Executive / Training)

This replaces the single-axis hierarchy, allowing more nuanced analysis of job roles across two independent dimensions.

### 2. Logical Steps

1. **Normalization**: Raw titles are normalized and joined with the job_titles seed to produce a clean "title" for matching.

2. **Sanitization**: Commas and slashes in title_to_match_on are stripped to prevent punctuation from breaking word-boundary matches.

3. **Dual Fuzzy Joins**: Two parallel matches are performed:
   - **job_functions_seed**: Keywords matched against normalized title → job_function
   - **seniority_levels_seed**: Keywords matched against normalized title → seniority, track, seniority_rank

4. **Keyword Matching**: Both seeds use the same 4-point word-boundary check (exact, starts-with, ends-with, surrounded-by-spaces) to prevent false positives (e.g., "Analyst" won't match "Psychoanalyst").

5. **Conflict Resolution**: Both matches rank by priority (1 = highest), with longest keyword as tiebreaker. One best match per response_id.

6. **Defaults**:
   - If job_function matched but no seniority: seniority='Mid', seniority_rank=5, track='IC'

7. **Derivation**:
   - **standardized_title**: Combines job_function and seniority intelligently (avoids redundancy; e.g., "Research Associate" when seniority="Associate")
   - **title_status**: 'missing' (null raw_job_title) | 'unmatched' (no job_function AND no seniority) | 'matched' (at least one match)

### 3. Maintenance: Adding New Jobs

1. **To add a new job function**: Update `seeds/job_functions.csv` with a unique keyword and assign a job_function name and priority.

2. **To add a new seniority level**: Update `seeds/seniority_levels.csv` with a keyword, seniority, track, seniority_rank, and priority.

3. **Formatting Rules**:
   - Keywords must be lowercase and contain no punctuation.
   - Avoid trailing/leading spaces in CSV.
   - Priorities should be unique where roles are specific vs. generic (specific = lower number = higher priority).

{% enddocs %}