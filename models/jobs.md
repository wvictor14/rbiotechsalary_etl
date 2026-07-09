{% docs jobs %}

## Final tables

- `dim_job_titles`
- `dim_jobs`

## Final Columns

### `dim_job_titles`

- `title_id` (pk)
- `title`

### `dim_jobs`

- `job_id` (pk)
- `title_id` (fk)
- `job_function`
- `seniority`
- `seniority_rank`
- `track`
- `title_status`
- `department`

## Modelling Strategy

### `dim_job_titles`

The `dim_job_titles` table captures the distinct job titles that appear in the survey responses. Each unique job title is assigned a `title_id` using a hash function based on the job title text.

This table allows us to easily track the different job titles that exist in the data and answer questions like:

- What are the most common job titles?
- How many distinct job titles are there?

### `dim_jobs`

The `dim_jobs` table takes the job title information from `dim_job_titles` and combines it with a **two-axis classification model**:
- **Job Function**: Primary role (Data Scientist, Engineer, Analyst, etc.)
- **Seniority**: Level and career track (Senior/Mid, IC/Management/Executive/Training)

The grain of this table is one row per unique combination of `title_id`, `job_function`, `seniority`, `track`, and `title_status`. This allows granular analysis:

- How do salaries vary by job_function and seniority_rank?
- What job_function/seniority combinations are most common?
- How many unmatched vs. matched job titles do we have?

The motivation for this two-axis model is to separate **what people do** (function) from **how senior they are** (seniority), enabling independent analysis of both dimensions.

{% enddocs %}