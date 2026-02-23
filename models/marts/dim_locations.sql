select distinct
    -- Generate a surrogate key for the job based on all relevant attributes
    location_id, country, subdivision, city, location_name
from {{ ref("int_locations") }}
