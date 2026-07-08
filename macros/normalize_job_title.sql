{% macro normalize_job_title(column_name) %}
    {#- Normalize a raw job title for matching against the job_titles seed.
        Collapses systematic spelling variants onto the seed's conventions so
        that "Sr. Scientist 2" resolves to the same key as "senior scientist ii"
        without needing a dedicated seed row per variant. Order matters: expand
        abbreviations first, convert trailing level digit to a roman numeral,
        then collapse whitespace. The digit->roman steps only fire on a level
        at the END of the string to avoid mangling things like "24/7". -#}
    trim(
    regexp_replace(
    regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(
    regexp_replace(regexp_replace(regexp_replace(regexp_replace(
        lower(trim({{ column_name }})),
        '\bsr\.?\s', 'senior '),          {#- sr / sr. -> senior -#}
        '\bjr\.?\s', 'junior '),          {#- jr / jr. -> junior -#}
        '\bmgr\.?(\s|$)', 'manager\1'),   {#- mgr -> manager -#}
        '\bassoc\.?\s', 'associate '),    {#- assoc -> associate -#}
        '\s1$', ' i'),                    {#- trailing arabic level -> roman -#}
        '\s2$', ' ii'),
        '\s3$', ' iii'),
        '\s4$', ' iv'),
        '\s5$', ' v'),
        '\s+', ' ')                       {#- collapse whitespace -#}
    )
{% endmacro %}
