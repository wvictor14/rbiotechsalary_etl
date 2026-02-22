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
- `hierarchy`
- `department`

## Modelling Strategy

### `dim_job_titles`

The `dim_job_titles` table captures the distinct job titles that appear in the survey responses. Each unique job title is assigned a `title_id` using a hash function based on the job title text.

This table allows us to easily track the different job titles that exist in the data and answer questions like:

- What are the most common job titles?
- How many distinct job titles are there?

### `dim_jobs`

The `dim_jobs` table takes the job title information from `dim_job_titles` and combines it with additional attributes like `hierarchy` and `department`. 

The grain of this table is one row per unique combination of `title_id`, `hierarchy`, and `department`. This allows us to analyze the data at a more granular level, answering questions like:

- How many people have the "Scientist" job title, and how do their salaries vary by hierarchy and department?
- What are the most common title + hierarchy + department combinations in the data?

The motivation for splitting job information into these two tables is to have a central reference for unique job titles, while also allowing more detailed analysis of jobs based on the additional attributes.

{% enddocs %}