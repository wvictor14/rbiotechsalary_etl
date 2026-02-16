{% docs companies %}

## Final tables

- `dim_companies`

## Final Columns

- company_id (pk)
- company_name
- company_size
- sector
- company_type

## Modelling Strategy

### Company names

All reported company names are taken and used to generate company name mapping file. We leverage AI here to make smarter decisions about harmonization. This is helpful for example when some companies have abbreviated versions, or end in "pharmaceuticals", "therapeutics" or something generic.

`company_names.csv`:

```
Original,Harmonized,
"BioMarin","BioMarin"
"BioMarin Pharmaceutical ","BioMarin"
```

If unknown or unidentifiable, company_name is set to "Unknown". However, "Unknown" responses may still contain relevant company_size, sector, etc. information that respondent was willing to share. This information is stored.

### Size, sector, public/private

Companies can have disparate information because each respondent can give different answers for company size, sector, etc.

How do we consolidate information for each company?

Decision Tree:

1. We select the most frequently reported.
2. If ties, use most recent (not implemented yet)

Exceptions:

1. *(not implemented yet)* Public / private should be weighted more highly towards more recently reported "public"  (private companies will beecome public, but not vice versa)

{% enddocs %}