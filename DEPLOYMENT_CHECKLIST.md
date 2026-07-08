# Deployment Checklist

Follow these steps to deploy your salary data dashboard to GitHub Pages.

## Quick Setup (5 minutes)

### 1. Enable GitHub Pages

1. Go to your GitHub repo
2. Settings → Pages
3. Select:
   - **Source:** Deploy from a branch
   - **Branch:** `main`
   - **Folder:** `/docs`
4. Click **Save**

Wait ~1 minute for GitHub to build. Your site will be at:
```
https://vyuan.github.io/rbiotechsalary_etl/
```

### 2. Push Changes

```bash
git add .
git commit -m "Set up DuckDB Wasm dashboard on GitHub Pages"
git push
```

### 3. Trigger the Workflow (Optional)

The GitHub Action will run automatically **every Sunday at 2 AM UTC**. To deploy immediately:

1. Go to **Actions** tab on GitHub
2. Click **Export Parquet Marts**
3. Click **Run workflow**
4. Wait ~2 minutes for it to complete

### 4. Verify

Visit `https://vyuan.github.io/rbiotechsalary_etl/`

You should see:
- Title: "RBiotech Salary Data"
- Dropdown with table options (Salary Facts, Companies, Job Titles, Locations)
- Search and query controls

Select **Salary Facts** and click **Query** to test.

---

## What Was Set Up

### Files Created

| File | Purpose |
|------|---------|
| `docs/index.html` | Pure HTML dashboard (DuckDB Wasm) |
| `export_parquet.py` | Script to export DuckDB tables as Parquet |
| `.github/workflows/export-parquet.yml` | GitHub Action (runs weekly) |
| `SERVING_DATA.md` | Full documentation |
| `docs/data/` | Parquet exports (auto-generated, not in git) |

### How It Works

1. You push to `main` (or GitHub Action runs on schedule)
2. Action runs: `dbt build` → `python export_parquet.py` → deploy to `docs/`
3. Parquet files uploaded to GitHub Pages CDN
4. Users load `index.html` in browser
5. DuckDB Wasm reads `.parquet` files directly
6. Full SQL queries run client-side (no server needed)

---

## Testing Locally (Optional)

```bash
# Export Parquet files
python export_parquet.py

# Open in browser
open docs/index.html
```

Then:
- Select a table
- Click Query
- Results appear instantly

---

## Next Steps

**If tables don't appear in dropdown:**
1. Verify `dbt build` succeeded: `dbt test`
2. Verify tables exist: `duckdb dev.duckdb "SHOW TABLES;"`
3. Re-run export: `python export_parquet.py`

**To customize the dashboard:**
- Edit `docs/index.html` directly
- Change title, colors, add filters, etc.
- All changes sync to GitHub Pages on commit

**To change the update schedule:**
- Edit `.github/workflows/export-parquet.yml`
- Modify the `cron` line (see crontab.guru for syntax)
- Example: `'0 0 * * *'` = daily at midnight UTC

---

## Troubleshooting

**"Pages is not being published":**
- Check Settings → Pages
- Ensure branch is `main` and folder is `/docs`
- Wait 2 minutes for GitHub to rebuild

**Dashboard loads but no tables:**
- Go to Actions tab → Export Parquet Marts
- Check the latest run for errors
- If failed, click "Re-run failed jobs"

**Local test works but live site doesn't:**
- Clear browser cache (Ctrl+Shift+Del)
- Check GitHub Pages URL is correct
- Verify `docs/index.html` was pushed to `main`

---

Done! Your salary data is now live. 🚀
