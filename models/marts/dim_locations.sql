select
    -- Generate a surrogate key for the job based on all relevant attributes
    {{ dbt_utils.generate_surrogate_key(['country', 'city', 'subdivision']) }}
    as location_id,
    country,
    subdivision,
    city,
    location_name
from {{ ref('int_locations') }}
