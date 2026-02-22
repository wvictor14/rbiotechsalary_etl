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

- One-to-one with source tables
- Minimal transformations
- Renaming and type casting only

**Intermediate models (`int_*`)**

- Resolve many-to-many relationships
- Cleaning and transforms
- Apply business logic
- Not intended for direct consumption

**Mart models**

- `dim_*`: descriptive entities
- `fact_*`: event-based or transactional data
- Star-schema aligned where possible

---

## Final Tables

### Fact Tables

`fct_responses`

One row per submitted survey response.

Key fields:
- `response_id`
- `company_id`
- `job_id`
- `timestamp`
- `salary_amount`
- `years_experience`
- `location_id`

### Grains 

- **`fact_submissions`**: One row per survey response
- **`dim_companies`**: One row per unique company
- **`dim_locations`**: One row per unique location
- **`dim_jobs`**: One row per unique job profile

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
- `state_province`
- `country`

#### `dim_job_titles`

1 row per title

Key fields:

- `job_title_id` A hash based on job_title
- `job_title` e.g. Director of Commercial Operations, "Scientist"

What did people call their job?

How many distinct titles exist?

#### `dim_jobs`

Grain is one row per job_title * job_group * job_level

- `job_id` A hash based on job_title_id, job_group, and job_level
- `job_title_id`
- `job_level` e.g. RA / Scientist / Manager / Director / VP
- `job_group` e.g. Research / Operations / Commercial


How many Scientists?

How do RAs from different groups differ in salary?

---

## Usage Guidance

- Prefer querying **fact + dimension** models for analysis
- All business logic and consolidation should be assumed correct and complete
  only in mart models

{% enddocs %}