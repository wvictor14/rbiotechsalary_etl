select distinct
    -- Generate a surrogate key for the job based on all relevant attributes
    {{ dbt_utils.generate_surrogate_key(["country", "city", "subdivision"]) }}
    as location_id,
    country,
    subdivision,
    city,
    concat_ws(', ', city, subdivision, country) as location_name
from {{ ref("int_locations") }}
