# Color Demo

This demo adds a Supabase-backed favorite-color workflow to mimic a simple Raw -> SDTM -> ADAM -> TFL pipeline with YAML orchestration.

## What is included

- `apps/audience_entry/app.R`: public Shiny eCRF-style app for audience submissions
- `apps/presenter_pipeline/app.R`: local Shiny app with Raw -> SDTM, SDTM -> ADAM, and ADAM -> TFL tabs
- `apps/presenter_hosted/app.R`: self-contained shinyapps.io-ready presenter app bundle
- `workflows/`: YAML workflow stages named `DM.yaml`, `ADSL.yaml`, and `WorkProduct1.yaml`
- `report_templates/WorkProduct1.Rmd`: `gtsummary` HTML output
- `sql/create_raw_color_votes.sql`: Supabase schema and RLS setup
- `scripts/`: package bootstrap, launchers, and shinyapps.io deployment helper

## Environment variables and app config

Copy `color_demo/.Renviron.example` to `color_demo/.Renviron` or set the variables in your shell before running the apps.

The launcher scripts in `color_demo/scripts/` explicitly load `color_demo/.Renviron`, so you do not need to put these values in the repo root or your global home `.Renviron` unless you prefer to. The audience entry app now prefers `color_demo/apps/audience_entry/config.yml` when that file is present.

Audience app:

- `apps/audience_entry/config.yml`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Presenter app:

- `SUPABASE_DB_HOST`
- `SUPABASE_DB_PORT`
- `SUPABASE_DB_NAME`
- `SUPABASE_DB_USER`
- `SUPABASE_DB_PASSWORD`
- `SUPABASE_DB_SSLMODE` defaults to `require` if omitted

Hosted presenter app:

- `apps/presenter_hosted/config.yml`
- `COLOR_DEMO_PRESENTER_SHINYAPPS_APP_NAME`

Deployment helper:

- `SHINYAPPS_NAME`
- `SHINYAPPS_TOKEN`
- `SHINYAPPS_SECRET`
- `COLOR_DEMO_SHINYAPPS_APP_NAME`

## Setup

1. Run `color_demo/sql/create_raw_color_votes.sql` in Supabase SQL Editor.
2. Install packages with:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' 'C:\Users\zhuze\OneDrive - ATorus\Documents\PHUSE_gsm_pharmaverse\color_demo\scripts\bootstrap_packages.R'
```

3. Edit `color_demo/apps/audience_entry/config.yml` and replace the placeholder Supabase URL and public key.

4. Start the audience app with:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' 'C:\Users\zhuze\OneDrive - ATorus\Documents\PHUSE_gsm_pharmaverse\color_demo\scripts\run_audience_app.R'
```

5. Start the presenter app with:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' 'C:\Users\zhuze\OneDrive - ATorus\Documents\PHUSE_gsm_pharmaverse\color_demo\scripts\run_presenter_app.R'
```

6. Deploy the audience app when you are ready with:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' 'C:\Users\zhuze\OneDrive - ATorus\Documents\PHUSE_gsm_pharmaverse\color_demo\scripts\deploy_audience_app.R'
```

7. If you want the presenter app hosted too, edit `color_demo/apps/presenter_hosted/config.yml` with the Supabase database credentials, test it locally with:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' 'C:\Users\zhuze\OneDrive - ATorus\Documents\PHUSE_gsm_pharmaverse\color_demo\scripts\run_presenter_hosted_app.R'
```

8. Deploy the hosted presenter app when you are ready with:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' 'C:\Users\zhuze\OneDrive - ATorus\Documents\PHUSE_gsm_pharmaverse\color_demo\scripts\deploy_presenter_hosted.R'
```

## Notes

- The presenter app queries Supabase directly through Postgres, so it does not depend on local peer-to-peer networking.
- The audience app posts through the Supabase REST endpoint using the public Supabase key defined in `apps/audience_entry/config.yml` and does not expose read access.
- Cached `.rds` outputs land in `color_demo/data/cache/`.
- Rendered HTML output lands in `color_demo/TFLS/WorkProduct1.html`.
- Package installs from the bootstrap script land in `color_demo/.r_libs/` so you do not need write access to the system R library.
- The hosted presenter app writes cache files and rendered HTML into a temp runtime directory on shinyapps.io, so rerun the tabs after each restart.
- Because the hosted presenter app bundles database credentials in `apps/presenter_hosted/config.yml`, it is best treated as a short-lived demo deployment. Shut it down and rotate the database password afterward.
