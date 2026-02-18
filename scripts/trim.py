""" Trims whitespace from seed company_names mapping"""

from pathlib import Path
import polars as pl
def trim_whitespace(df):
  df = (
    df
      .with_columns(pl.all().str.strip_chars())
      .unique()
      .sort('harmonized_company_name')
  )
  return df  

file = Path('seeds') / 'company_names.csv'
file_out = Path('seeds') / 'company_names.csv'

company_names = pl.read_csv(file)
company_names_cleaned = trim_whitespace(company_names)

company_names_cleaned.write_csv(file_out)