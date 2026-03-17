# Live Setup TODO

This checklist is for making the `color_demo` actually live for a presentation:

- Audience submits from a public Shiny URL.
- Audience app writes to Supabase.
- Presenter app runs either locally or from a short-lived hosted Shiny URL and reads live results from Supabase.
- Raw -> SDTM -> ADAM -> TFL can be rerun during the talk.

## 1. Supabase Project

- [ ] Create or choose a Supabase project.
- [ ] In Supabase SQL Editor, run [sql/create_raw_color_votes.sql](C:/Users/zhuze/OneDrive%20-%20ATorus/Documents/PHUSE_gsm_pharmaverse/color_demo/sql/create_raw_color_votes.sql).
- [ ] Confirm the table exists as `public.raw_color_votes`.
- [ ] Confirm Row Level Security is enabled on that table.
- [ ] Confirm the `anon` role has `insert` but not `select`.

## 2. Supabase Keys And Connection Details

- [ ] Open your Supabase project in the dashboard.
- [ ] Get the API URL for the audience app.
  Do this:
  - Click `Connect` near the top of the project page, or open `Project Settings` -> `API Keys`.
  - Find the project URL or API URL.
  - Copy that full value, which should look like `https://<project-ref>.supabase.co`.
  - Put that value into `SUPABASE_URL`.
- [ ] Get the public API key for the audience app.
  Do this:
  - In the same `Connect` dialog or `Project Settings` -> `API Keys`, find the public client key.
  - If your project shows a `Publishable key`, copy that.
  - If your project only shows legacy keys, copy the legacy `anon` key.
  - Do not use the `service_role` key here.
  - Put the public key value into `SUPABASE_ANON_KEY`.
  Important:
  - The variable name in this repo is still `SUPABASE_ANON_KEY`.
  - That variable can hold either a new publishable key or the legacy anon key, as long as it is the public client-facing key.
- [ ] Get the presenter app database connection values.
  Recommendation:
  - If you are not sure whether your laptop/network supports IPv6, use the `Session pooler` / `Supavisor session mode` connection, not the direct connection.
  - For this presenter app, `Session pooler` is the safest default.
  Do this:
  - Click `Connect` in the Supabase dashboard.
  - Look for connection strings.
  - Choose `Session pooler`.
  - Copy the full connection string or view the individual fields.
  - It should look similar to:

```text
postgresql://postgres.<project-ref>:<password>@aws-0-<region>.pooler.supabase.com:5432/postgres
```

- [ ] Break the session-pooler connection string into the variables this app expects.
  Map it like this:
  - `SUPABASE_DB_HOST`
    Use the hostname after `@` and before `:5432`.
    Example: `aws-0-us-east-1.pooler.supabase.com`
  - `SUPABASE_DB_PORT`
    Use `5432` for session pooler.
  - `SUPABASE_DB_NAME`
    Usually `postgres` unless you intentionally changed it.
  - `SUPABASE_DB_USER`
    Use the full username from the connection string.
    Important: for session pooler this is usually `postgres.<project-ref>`, not just `postgres`.
  - `SUPABASE_DB_PASSWORD`
    Use your database password.
    If you do not know it, reset it in `Database Settings` before continuing.
  - `SUPABASE_DB_SSLMODE`
    Set this to `require`.
- [ ] If you intentionally choose the direct connection instead of session pooler, map it differently.
  Direct connection example:

```text
postgresql://postgres:<password>@db.<project-ref>.supabase.co:5432/postgres
```

  Direct mapping:
  - `SUPABASE_DB_HOST=db.<project-ref>.supabase.co`
  - `SUPABASE_DB_PORT=5432`
  - `SUPABASE_DB_NAME=postgres`
  - `SUPABASE_DB_USER=postgres`
  - `SUPABASE_DB_PASSWORD=<your database password>`
  - `SUPABASE_DB_SSLMODE=require`
- [ ] Paste the final values into your local env file.
  Recommended target:
  - [color_demo/.Renviron](C:/Users/zhuze/OneDrive%20-%20ATorus/Documents/PHUSE_gsm_pharmaverse/color_demo/.Renviron), based on [color_demo/.Renviron.example](C:/Users/zhuze/OneDrive%20-%20ATorus/Documents/PHUSE_gsm_pharmaverse/color_demo/.Renviron.example)
  Note:
  - the scripts in `color_demo/scripts/` explicitly load `color_demo/.Renviron`, so this folder-level file is the intended local setup for this demo
  Example using session pooler:

```text
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=sb_publishable_xxxxx
SUPABASE_DB_HOST=aws-0-us-east-1.pooler.supabase.com
SUPABASE_DB_PORT=5432
SUPABASE_DB_NAME=postgres
SUPABASE_DB_USER=postgres.yourprojectref
SUPABASE_DB_PASSWORD=your-database-password
SUPABASE_DB_SSLMODE=require
```
- [ ] Sanity check before moving on.
  Confirm:
  - `SUPABASE_URL` starts with `https://`
  - `SUPABASE_ANON_KEY` is the public key, not `service_role`
  - `SUPABASE_DB_USER` matches the connection type you chose
  - `SUPABASE_DB_PASSWORD` is the database password, not your Supabase login password
  - `SUPABASE_DB_SSLMODE` is exactly `require`

## 3. Local Env Files

- [ ] Copy [color_demo/.Renviron.example](C:/Users/zhuze/OneDrive%20-%20ATorus/Documents/PHUSE_gsm_pharmaverse/color_demo/.Renviron.example) to [color_demo/.Renviron](C:/Users/zhuze/OneDrive%20-%20ATorus/Documents/PHUSE_gsm_pharmaverse/color_demo/.Renviron) for local use.
- [ ] Fill in the Supabase database values for the presenter app.
- [ ] Fill in `SHINYAPPS_NAME`, `SHINYAPPS_TOKEN`, and `SHINYAPPS_SECRET` for deployment.
- [ ] Set `COLOR_DEMO_SHINYAPPS_APP_NAME` to the public app name you want.
- [ ] If you are hosting the presenter app too, set `COLOR_DEMO_PRESENTER_SHINYAPPS_APP_NAME` to the app name you want.

## 4. Install And Verify R Packages

- [ ] Run the package bootstrap in your RStudio terminal:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' 'C:\Users\zhuze\OneDrive - ATorus\Documents\PHUSE_gsm_pharmaverse\color_demo\scripts\bootstrap_packages.R'
```
- [ ] Do not treat the contents of `color_demo/.r_libs/` by itself as the pass/fail check.
  Note:
  - `bootstrap_packages.R` installs only packages that are missing from your currently available R libraries.
  - If some packages are already installed globally on your machine, they may not appear inside `color_demo/.r_libs/`, and that is fine.
- [ ] Run a quick package smoke test:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' -e "local_library <- file.path(getwd(), 'color_demo', '.r_libs'); .libPaths(c(local_library, .libPaths())); pkgs <- c('shiny','bslib','config','DBI','DT','dplyr','here','httr2','RPostgres','rmarkdown','rlang','rsconnect','yaml','gt','gtsummary','admiral','sdtm.oak','gsm.core'); print(vapply(pkgs, requireNamespace, logical(1), quietly = TRUE))"
```

- [ ] If any package still returns `FALSE`, install/fix it before demo day.

## 5. Smoke Test Supabase Insert Security

- [ ] From PowerShell, verify the public key can insert:

```powershell
$headers = @{
  apikey = $env:SUPABASE_ANON_KEY
  Authorization = "Bearer $($env:SUPABASE_ANON_KEY)"
  Prefer = "return=minimal"
  "Content-Type" = "application/json"
}

Invoke-WebRequest `
  -Method Post `
  -Uri "$($env:SUPABASE_URL)/rest/v1/raw_color_votes" `
  -Headers $headers `
  -Body '{"favorite_color":"red","submission_source":"smoke_test"}'
```

- [ ] Verify a `select` with the same public key is blocked or not exposed as intended.
- [ ] Confirm the presenter database credentials can still read the table.

## 6. Local Presenter App

- [ ] Start the presenter app from your RStudio terminal:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' 'C:\Users\zhuze\OneDrive - ATorus\Documents\PHUSE_gsm_pharmaverse\color_demo\scripts\run_presenter_app.R'
```
- [ ] Confirm the default SQL query returns rows from Supabase.
- [ ] Confirm `Run Raw -> SDTM` creates `color_demo/data/cache/SDTM_DM.rds`.
- [ ] Confirm `Run SDTM -> ADAM` creates `color_demo/data/cache/ADAM_ADSL.rds`.
- [ ] Confirm `Run ADAM -> TFL` creates [TFLS/WorkProduct1.html](C:/Users/zhuze/OneDrive%20-%20ATorus/Documents/PHUSE_gsm_pharmaverse/color_demo/TFLS/WorkProduct1.html).
- [ ] Confirm the third tab embeds the rendered HTML successfully.

## 7. Audience App Deployment Strategy

- [ ] Edit [color_demo/apps/audience_entry/config.yml](C:/Users/zhuze/OneDrive%20-%20ATorus/Documents/PHUSE_gsm_pharmaverse/color_demo/apps/audience_entry/config.yml) before deploying.
- [ ] Replace the placeholder values in the `default` section:

```yaml
default:
  supabase:
    url: "https://<your-project>.supabase.co"
    anon_key: "<your-publishable-or-legacy-anon-key>"
```

- [ ] Leave `local` and `shinyapps` inheriting from `default` unless you intentionally want different values.
- [ ] Do not put database passwords or `service_role` keys in the hosted audience app config.
- [ ] Because this app uses only public Supabase values, bundling them in `config.yml` is acceptable for this demo.

## 8. Publish To shinyapps.io

- [ ] Create or log into your `shinyapps.io` account.
- [ ] In the shinyapps.io dashboard, create/retrieve your token and secret.
- [ ] Put those values into local env vars or [color_demo/.Renviron](C:/Users/zhuze/OneDrive%20-%20ATorus/Documents/PHUSE_gsm_pharmaverse/color_demo/.Renviron).
- [ ] Confirm [color_demo/apps/audience_entry/config.yml](C:/Users/zhuze/OneDrive%20-%20ATorus/Documents/PHUSE_gsm_pharmaverse/color_demo/apps/audience_entry/config.yml) contains the correct Supabase URL and public key before deploying.
- [ ] Run the deployment command from your RStudio terminal:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' 'C:\Users\zhuze\OneDrive - ATorus\Documents\PHUSE_gsm_pharmaverse\color_demo\scripts\deploy_audience_app.R'
```
- [ ] Open the deployed app URL and submit a test vote from a browser that is not relying on localhost.
- [ ] Check shinyapps.io logs if the app fails to start.

## 9. Capacity And Reliability Checks

- [ ] Decide whether the shinyapps.io Free plan is enough.
  Note: the official docs say Free and Starter plans allow only 1 application instance.
- [ ] If you expect many simultaneous audience submissions, consider a paid plan or rehearse with realistic traffic.
- [ ] Warm the app shortly before the talk so the first attendee does not hit a cold start.
- [ ] If you host the presenter app, remember it carries live database credentials in its bundled config and should be treated as temporary.

## 10. Hosted Presenter App

- [ ] Edit [color_demo/apps/presenter_hosted/config.yml](C:/Users/zhuze/OneDrive%20-%20ATorus/Documents/PHUSE_gsm_pharmaverse/color_demo/apps/presenter_hosted/config.yml) before deploying.
- [ ] Replace the placeholder values in the `default` section:

```yaml
default:
  supabase_db:
    host: "aws-0-your-region.pooler.supabase.com"
    port: 5432
    dbname: "postgres"
    user: "postgres.your-project-ref"
    password: "your-database-password"
    sslmode: "require"
```

- [ ] Leave `local` and `shinyapps` inheriting from `default` unless you intentionally want different database targets.
- [ ] Local smoke test the hosted bundle in RStudio before publishing:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' 'C:\Users\zhuze\OneDrive - ATorus\Documents\PHUSE_gsm_pharmaverse\color_demo\scripts\run_presenter_hosted_app.R'
```

- [ ] Confirm the hosted bundle can:
  - query Supabase from the first tab
  - regenerate SDTM_DM
  - regenerate ADAM_ADSL
  - render the HTML work product
- [ ] Deploy the hosted presenter app when ready:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' 'C:\Users\zhuze\OneDrive - ATorus\Documents\PHUSE_gsm_pharmaverse\color_demo\scripts\deploy_presenter_hosted.R'
```

- [ ] Open the hosted presenter URL from a second browser to confirm it works away from your local R session.
- [ ] Expect the hosted presenter app to lose cached `.rds` and HTML artifacts on restart because shinyapps.io storage is ephemeral.

## 11. Final Rehearsal

- [ ] Submit at least one primary color and one secondary color through the hosted audience app.
- [ ] In the presenter app, confirm the SQL tab shows the new rows.
- [ ] Run all three buttons in order:
  - `Run Raw -> SDTM`
  - `Run SDTM -> ADAM`
  - `Run ADAM -> TFL`
- [ ] Confirm the mappings are:
  - `RED -> R`
  - `BLUE -> B`
  - `YELLOW -> Y`
  - `GREEN -> G`
  - `ORANGE -> O`
  - `PURPLE -> P`
- [ ] Confirm `R/B/Y` classify to `Primary`.
- [ ] Confirm `G/O/P` classify to `Secondary`.
- [ ] Save the final presenter URL, shinyapps URL, and Supabase dashboard URL somewhere easy to reach during the presentation.

## 12. Day-Of Checklist

- [ ] Start the presenter app you plan to use before the session.
- [ ] If you are using the local presenter app, start it with:

```powershell
& 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' 'C:\Users\zhuze\OneDrive - ATorus\Documents\PHUSE_gsm_pharmaverse\color_demo\scripts\run_presenter_app.R'
```
- [ ] If you are using the hosted presenter app, open its shinyapps.io URL and run one quick smoke test in the browser.
- [ ] Open the hosted audience app and QR code on a slide.
- [ ] Open the presenter app tabs you will demo.
- [ ] Keep Supabase SQL Editor or Table Editor open in another browser tab as a fallback proof of ingestion.
- [ ] Pre-run one vote yourself before the audience joins.
- [ ] If the hosted audience app fails, enter a few votes manually through the Supabase SQL Editor so the pipeline demo can continue.
- [ ] If the hosted presenter app fails, fall back to the local presenter app if available, or keep Supabase SQL Editor open as a backup proof of the live ingestion.

## 13. Post-Demo Cleanup

- [ ] Stop or delete the hosted presenter app on shinyapps.io when the talk is over.
- [ ] Stop or delete the hosted audience app if you no longer need it.
- [ ] Rotate the Supabase database password used by the hosted presenter app.
- [ ] Remove or reset the real values from [color_demo/apps/presenter_hosted/config.yml](C:/Users/zhuze/OneDrive%20-%20ATorus/Documents/PHUSE_gsm_pharmaverse/color_demo/apps/presenter_hosted/config.yml) if you plan to keep the repo around.

## Official References

- Supabase API keys: [Understanding API keys](https://supabase.com/docs/guides/api/api-keys)
- Supabase Postgres connection options: [Connect to your database](https://supabase.com/docs/guides/database/connecting-to-postgres)
- Supabase RLS: [Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
- shinyapps.io account setup and `rsconnect::deployApp()`: [shinyapps.io Getting Started](https://docs.posit.co/shinyapps.io/guide/getting_started/)
- shinyapps.io application settings and instance limits: [shinyapps.io Applications](https://docs.posit.co/shinyapps.io/guide/applications/)
- shinyapps.io persistent storage guidance: [Security and Compliance](https://docs.posit.co/shinyapps.io/guide/security_and_compliance/index.html)

## Notes On Interpretation

- Supabase docs treat publishable and legacy `anon` keys as appropriate for public-facing components. This is why using the public key in the hosted audience app is acceptable here.
- For shinyapps.io, `config.yml` is the supported app-configuration pattern, and deployed apps typically run with the `shinyapps` config active.
