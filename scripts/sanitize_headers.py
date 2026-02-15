import polars as pl
import re
from pathlib import Path

def clean_name(name):
    # 1. Kill everything after the first newline (strips the long instructions)
    name = str(name).split('\n')[0]
    # 2. Kill everything inside parentheses/brackets
    name = re.sub(r'[\(\[].*?[\)\]]', '', name)
    # 3. Remove special characters and punctuation
    name = re.sub(r'[^a-zA-Z0-9\s]', '', name)
    # 4. Collapse spaces into single underscores and lowercase
    name = name.strip().lower()
    name = re.sub(r'\s+', '_', name)
    return name

def sanitize_headers(file_input, file_output):
    # Use infer_schema_length=0 to keep it as strings during the header swap
    df = pl.read_csv(file_input, infer_schema_length=0)
    
    # Rename columns using our strict logic
    df.columns = [clean_name(col) for col in df.columns]
    
    # IMPORTANT: Drop the first few rows if they contain "leftover" header text
    # We look for rows where 'timestamp' doesn't start with a number
    df = df.filter(pl.col("timestamp").str.contains(r"^\d"))
    
    df.write_csv(file_output)
    print(f"✅ Success! Cleaned file saved to {file_output}")

# Correct path handling for your setup
input_path = "data/r_biotech salary and company survey - 2025.csv"
output_path = Path("data") / "sanitized.csv"

sanitize_headers(input_path, output_path)