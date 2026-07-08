select
    s.response_id,
    s.survey_year,
    s.base_salary,
    s.bonus_pct,
    s.bonus_amount,
    s.total_compensation,
    c.currency_code,
    c.currency_source
from {{ ref("int_salaries_computed") }} as s
left join {{ ref("int_currencies") }} as c on s.response_id = c.response_id
