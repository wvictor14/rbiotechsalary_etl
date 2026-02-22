{% macro clean_numeric(column_name) %}
    try_cast(
        regexp_replace(cast({{ column_name }} as string), '[^0-9.\\-]', '') as double
    )
{% endmacro %}
