{% docs locations %}

## Locations modelling strategy

Geographic attributes associated with survey responses.

Location data is extracted from four raw survey columns: `country`, `city`,
`us_state`, and `ca_province`. Because the data is free-text, it contains
typos, inconsistent casing, diacritics, and embedded info (e.g.
"Pune, Maharashtra", "Basel (greater Area)").

### Cleaning approach

1. **Country validation** — only rows whose `country` value appears in the
   `countries` seed are kept, filtering out junk rows (e.g. job descriptions,
   education info that ended up in the country column).
2. **City standardization** — a `city_names` seed maps raw city values to
   cleaned names, handling typos ("Mancester" → "Manchester"), casing
   ("zurich" → "Zurich"), diacritics ("Zürich" → "Zurich"), embedded info
   ("Pune, Maharashtra" → "Pune"), and non-city values ("Remote" → null).
3. **Deduplication** — `select distinct` produces one row per unique
   combination of country, city, us_state, and ca_province.

### Key fields

- `location_id` — surrogate key generated from `country`, `city`, and
  `subdivision`
- `country` — validated country name
- `city` — cleaned city name (null for US/Canada state-only entries)
- `subdivision` — coalesced from `us_state` or `ca_province`
- `location_name` — human-readable label (e.g. "Boston, Massachusetts, United States")

{% enddocs %}