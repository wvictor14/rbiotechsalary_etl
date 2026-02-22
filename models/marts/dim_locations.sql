select
    -- Generate a surrogate key for the job based on all relevant attributes
    {{ dbt_utils.generate_surrogate_key(['country', 'city', 'us_state', 'ca_province']) }}
    as location_id,
    country,
    city,
    us_state,
    ca_province,
    location_name
from {{ ref('int_locations') }}
