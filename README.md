# Data refresh

Source of truth is the public Google Sheet (one tab per survey year, 2022-2026).

1. `uv run python scripts/extract.py` downloads the workbook and writes
   `data/raw/src_responses_<year>.csv` with sanitized headers
2. `dbt build` - sources read the CSVs directly via duckdb `read_csv`
   (`external_location` in `_src_survey_results.yml`), no manual load step

Survey questions changed across years; each `stg_responses_<year>` model maps
that year onto the canonical schema, and `stg_responses` unions them
(see `_stg_survey_results.yml` for which columns exist in which years).


# Primary Keys

- Company ID: uses `dbt_utils.generate_surrogate_key` macro on company name to create a unique id
- response_id: uses `dbt_utils.generate_surrogate_key` on timestamp column
- location_id: uses `dbt_utils.generate_surrogate_key` on City, Country


# Useful commands

```bash
dbt build # tests and run
dbt run # just run
dbt test # just test
dbt docs generate 
dbt docs serve
duckdb dev.db # explore
.tables 

# selective build
dbt build --select int_responses  # rebuild just this model and downstream
dbt build --select int_responses+ # include downstream dependents
dbt build --select +int_responses # include upstream sources
```

# Data limitations

Previous versions have imprecise question/answers that make them less useful and missing for certain fields that later survey versions contain:

Location 

- 2024's region buckets ("New England (MA, CT...)") land in a new raw_region column but aren't yet mapped into the location dimension - most 2024 rows have no country/city, so they're excluded from dim_locations.
- This is unfortunately limits location analysis from previous years

Compensation

- Previous years was not clear how to specify bonus so there is a mix of fractions (0.1), percent (10) and dollar amount (10000). The magnitude heuristic can't distinguish a $100 bonus from a 100% bonus (treated as percent); rare and documented in the yml.

Currency

- Only collected 2025+. Older years are resolved by `int_currencies` with
  precedence: reported answer > country's currency > 2024 region bucket's
  currency > assume USD. `currency_source` on `fct_salaries` / `responses`
  records which rule applied, so analyses can filter to reported-only.
- 2022 collected no country at all (only city/hub, overwhelmingly US), so all
  of 2022 is `assumed_usd`.
- Seeds: `currency_names` (free-text answer -> ISO code), `country_names`
  (USA/US/England -> standard name, also fixes dropped locations),
  `country_currencies`, `region_countries`.