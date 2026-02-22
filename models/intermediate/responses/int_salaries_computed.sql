select
    *,
    base_salary * bonus_pct as bonus_amount,
    base_salary + (base_salary * bonus_pct / 100) as total_compensation
from {{ ref("int_salaries_cleaned") }}
