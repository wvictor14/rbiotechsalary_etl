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

Grain is one row per job_title * job_group * job_level

- `job_id` A hash based on job_title_id, job_group, and job_level
- `title_id` (fk to `dim_job_titles`)
- `title`
- `standardized_title` A generic standard title e.g. RA / Scientist / Manager / Director / VP
- `department` e.g. Research / Operations / Commercial
- `hierarchy an organizaton by relative seniority

title and department are derived from respondent input, but then standardized and consolidated based on rules and heuristics. See `models/jobs.md` for detailed job modeling and consolidation logic.


Questions that can be answered with this model

- How many distinct jobs exist?
- How do jobs propagate across levels and departments? E.g. how many distinct job titles are there in research vs commercial? How many distinct job titles are there at each level of the hierarchy?

---

## Usage Guidance

- Prefer querying **fact + dimension** models for analysis
- All business logic and consolidation should be assumed correct and complete
  only in mart models

{% enddocs %}