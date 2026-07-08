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

    Path(OUTPUT_DIR).mkdir(parents=True, exist_ok=True)

    # Only publish marts; staging/intermediate tables contain raw responses
    tables = con.execute(
        """
        SELECT table_name FROM information_schema.tables
        WHERE table_schema = 'main'
          AND (table_name LIKE 'dim_%' OR table_name LIKE 'fct_%')
        """
    ).fetchall()

    exported = 0
    for (table_name,) in tables:
        try:
            output_file = f"{OUTPUT_DIR}/{table_name}.parquet"
            con.execute(f"COPY {table_name} TO '{output_file}' (FORMAT PARQUET);")
            size_kb = os.path.getsize(output_file) / 1024
            print(f"OK {table_name} -> {output_file} ({size_kb:.1f} KB)")
            exported += 1
        except Exception as e:
            print(f"SKIP {table_name} ({str(e)[:60]})")

    con.close()
    print(f"\nExported {exported}/{len(tables)} tables to {OUTPUT_DIR}/")

if __name__ == "__main__":
    export_marts()
