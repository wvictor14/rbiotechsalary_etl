-- All survey years unioned into one canonical response table.
-- Each stg_responses_<year> model maps that year's survey columns onto the
-- shared canonical schema; union all by name tolerates column-order drift.
{% set survey_years = [2022, 2023, 2024, 2025, 2026] %}

{% for year in survey_years %}
select *
from {{ ref("stg_responses_" ~ year) }}
{% if not loop.last %}
union all by name
{% endif %}
{% endfor %}
