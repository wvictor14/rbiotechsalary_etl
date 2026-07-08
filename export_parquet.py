#!/usr/bin/env python3
"""Export dbt marts from DuckDB to Parquet files for GitHub Pages."""

import duckdb
import os
from pathlib import Path

DB_PATH = "dev.duckdb"
OUTPUT_DIR = "docs/data"

def export_marts():
    """Export all tables from the main schema as Parquet files."""
    con = duckdb.connect(DB_PATH, read_only=True)

    Path(OUTPUT_DIR).mkdir(exist_ok=True)

    # Get all tables in main schema (excluding internal tables)
    tables = con.execute(
        "SELECT table_name FROM information_schema.tables WHERE table_schema = 'main'"
    ).fetchall()

    for (table_name,) in tables:
        try:
            output_file = f"{OUTPUT_DIR}/{table_name}.parquet"
            con.execute(f"COPY {table_name} TO '{output_file}' (FORMAT PARQUET);")
            size_mb = os.path.getsize(output_file) / 1024 / 1024
            print(f"✓ {table_name} → {output_file} ({size_mb:.1f} MB)")
        except Exception as e:
            print(f"⚠ {table_name} → skipped ({str(e)[:50]}...)")

    con.close()
    print(f"\nExported to {OUTPUT_DIR}/")

if __name__ == "__main__":
    export_marts()
