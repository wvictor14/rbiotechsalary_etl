{% docs modelling_strategy_overview %}

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

### Grains

- `fact_orders`: one survey response

---

## Final Tables

### Fact Tables

`fact_submissions`

One row per submitted survey response.

Key fields:
- `submission_id`
- `timestamp`
- `salary_amount`
- `years_experience`
- `company_id`
- `location_id`
- `job_id`

---

### Dimension Tables

#### `dim_companies`
Descriptive attributes for companies.  
See [{{ doc('companies') }}](models/companies.md) for detailed company modeling and consolidation logic.

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

#### `dim_jobs`

Job-related attributes associated with submissions.

Key fields:
- `job_id`
- `job_title`
- `department`
- `work_modality` (remote / hybrid / on-site)

---

## Usage Guidance

- Prefer querying **fact + dimension** models for analysis
- All business logic and consolidation should be assumed correct and complete
  only in mart models

{% enddocs %}