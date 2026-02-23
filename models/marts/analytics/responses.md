{% docs responses %}
One response per row, with all relevant dimensions (company, job, location) and facts (salaries, bonuses, stock options)
joined into a single wide table. This model is the canonical analytical source for survey responses and is intended
to be the main entry point for downstream marts and analysis.

Key responsibilities:
- Normalize and clean incoming headers and fields from the raw `responses` staging table.
- Standardize job titles and map them to the job hierarchy and department seeds.
- Attach company and location harmonization fields for downstream joins.
- Surface flags for low-confidence job/title mappings and unmapped cases for review.

Maintenance notes:
- Update `seeds/job_titles.csv` and the job hierarchy seed to refine title canonicalization.
- Review low-confidence cases periodically and adjust seed priorities or add specific keywords.
- Keep transformations deterministic and auditable; prefer seed/CSV-based rules where possible.

Examples:
- "senior scientist ii, process development" -> Professional / Research / "Senior Scientist II"
- "associate director, program management" -> Management / Operations / "Associate Director"
{% enddocs %}
