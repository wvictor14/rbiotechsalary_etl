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

### No response or Unidentifiable

Some survey respondents don't provide a company name but still share useful information like company size, sector, or whether it's public/private.

If company name is unknown or unidentifiable, company_name is set to "Unknown". And then `fct_submissions` will take the response data directly for `company_size` `sector` and other relevant company information.

### Size, sector, public/private

Companies can have disparate information because each respondent can give different answers for company size, sector, etc.

How do we consolidate information for each company?

Decision Tree:

1. We select the most frequently reported.
2. If ties, use most recent (not implemented yet)

Exceptions:

1. *(not implemented yet)* Public / private should be weighted more highly towards more recently reported "public"  (private companies will beecome public, but not vice versa)

{% enddocs %}

{% docs company_name %}

Company name source is free-form response. Gets harmonized early with an LLM.



{% enddocs %}