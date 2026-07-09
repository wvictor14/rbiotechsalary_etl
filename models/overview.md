{% docs __overview__ %}

## Overview

This schema contains the final analytical ready tables and describe the strategy for modelling, organization, and documentation. 

### Documentation

Strategies and tools leveraged for documentation:

- `dbt-codegen` to scaffold yaml templates, facilite sync'ing with column renames, and deletes. Basically copy pasting and then using git diff to stage/revert.
- dbt doc blocks 
- AI to auto generate, clarify, and improve documentation

### Modeling strategy

Models are organized according to *stage*: 

source/raw -> staging -> intermediate -> marts

**Source**
    
- Loaded into data warehouse from raw source data
- Untouched except headers are sanitized (lowercase, stripped of special characters  and spaces) in order to comply with warehouse limitations

**Staging models (`stg_*`)**

- `timestamp` is the unique identifier for each survey response, and serves as the primary key for all models, there we create a copy of it called `response_id`.
- One-to-one with source tables
- Minimal transformations
- Renaming and type casting only

**Intermediate models (`int_*`)**

- Cleaning and transforms
- Apply business logic
- Develop primary keys for dims and facts
- Resolve many-to-many relationships
- Not intended for direct consumption

**Mart models**

- `dim_*`: descriptive entities
- `fact_*`: event-based or transactional data
- Star-schema aligned where possible

---

## Final Tables

### Fact Tables

`fct_salaries`

One row per submitted survey response + salaries. 

Key fields:
- `timestamp`
- `salary_amount`
- `years_experience`
- `location_id`

### Grains 

- **`fct_salaries`**: One row per survey response
- **`dim_companies`**: One row per unique company
- **`dim_locations`**: One row per unique location
- **`dim_jobs`**: One row per unique job profile
- **`dim_job_titles`**: One row per unique job title

---

### Dimension Tables

#### `dim_companies`

Descriptive attributes for companies.  
See `models/companies.md` for detailed company modeling and consolidation logic.

Key fields:
- `company_id`
- `company_name`
- `company_size`
- `sector`
- `company_type`

#### `dim_locations`

Geographic attributes associated with submissions.

Key fields:
- `location_id`
- `city`
- `subdivision` State, province, or a country subregion
- `country`

#### `dim_job_titles`

1 row per title

Key fields:

- `title_id` A hash based on `title`
- `title` A cleaned up version of respondent's input: "Director of Commercial Operations", "Bioinformatics Scientist"

What did people call their job?

How many distinct titles exist?

#### `dim_jobs`

Grain is one row per job_title * job_function * seniority * track * status

- `job_id` A hash based on job_title_id, job_function, seniority, track, and title_status
- `title_id` (fk to `dim_job_titles`)
- `title`
- `standardized_title` A derived title combining job_function and seniority
- `job_function` Primary role (e.g., Data Scientist, Engineer, Analyst)
- `seniority` Level (Senior, Mid, Junior, etc.) within the career track
- `seniority_rank` Numeric rank (1-14) for ordering by seniority
- `track` Career track (IC, Management, Executive, Training)
- `title_status` Mapping success (missing, unmatched, matched)
- `department` Raw department from source

Title and department are derived from respondent input; job_function and seniority are standardized via fuzzy keyword matching on the job_functions and seniority_levels seeds. See `models/jobs.md` for detailed job modeling and consolidation logic.

Questions that can be answered with this model

- How many distinct job function/seniority combinations exist?
- How do salaries vary by job_function, independent of seniority?
- How do salaries vary by seniority_rank, independent of job_function?
- What is the distribution of unmatched vs. matched titles?

---

## Usage Guidance

- Prefer querying **fact + dimension** models for analysis
- All business logic and consolidation should be assumed correct and complete
  only in mart models

{% enddocs %}