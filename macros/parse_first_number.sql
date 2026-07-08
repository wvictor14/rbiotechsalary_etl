{% macro parse_first_number(column_name) %}
    {#- Extract the first numeric token from free-text survey answers.
        Handles "$10,000", "10%", "0.15", and range answers like
        "8,000 - 16,000" (takes the lower bound). Stripping ALL non-digits
        instead would concatenate ranges into garbage (8000016000). -#}
    try_cast(
        replace(regexp_extract({{ column_name }}, '[0-9][0-9,]*\.?[0-9]*'), ',', '')
        as double
    )
{% endmacro %}
