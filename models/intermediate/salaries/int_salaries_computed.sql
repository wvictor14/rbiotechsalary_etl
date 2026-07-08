-- bonus_amount: prefer computing from the target percent; fall back to the
-- dollar amount reported directly in the 2022-2024 surveys
select
    response_id,
    survey_year,
    base_salary,
    bonus_pct,
    coalesce(base_salary * bonus_pct / 100, bonus_amount_reported) as bonus_amount,
    base_salary
    + coalesce(base_salary * bonus_pct / 100, bonus_amount_reported, 0)
    as total_compensation
from {{ ref("int_salaries_cleaned") }}
