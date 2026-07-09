{% docs responses %}
One response per row, with all relevant dimensions (company, job, location) and facts (salaries, bonuses, stock options)
joined into a single wide table. This model is the canonical analytical source for survey responses and is intended
to be the main entry point for downstream marts and analysis.

Key responsibilities:
- Normalize and clean incoming headers and fields from the raw `responses` staging table.
- Standardize job titles and map them to job_function and seniority using two-axis classification.
- Attach company and location harmonization fields for downstream joins.
- Surface flags for low-confidence job/title mappings and unmapped cases for review.

Maintenance notes:
- Update `seeds/job_titles.csv` to refine title harmonization.
- Update `seeds/job_functions.csv` and `seeds/seniority_levels.csv` to refine function and seniority matching.
- Review cases with title_status='unmatched' periodically and adjust seed priorities or add specific keywords.
- Keep transformations deterministic and auditable; prefer seed/CSV-based rules where possible.

Examples:
- "senior scientist ii, process development" -> job_function=Data Scientist / seniority=Senior / "Senior Data Scientist"
- "associate director, program management" -> job_function=Program Management / seniority=Associate / track=Management / "Associate Director"
{% enddocs %}
