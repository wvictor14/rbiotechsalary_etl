select *
from
    read_csv_auto(
        {{ source("survey_results", "responses") }},
        normalize_names = true,
        sample_size = 100,  -- Scan the WHOLE file to figure out the structure
        max_line_size = 2097152,
        strict_mode = false
    ) as src
