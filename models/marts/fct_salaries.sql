select response_id, base_salary, bonus_pct, bonus_amount, total_compensation
from {{ ref("int_salaries_computed") }}
