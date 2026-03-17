color_demo_resolve_repo_root <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)

  if (length(file_arg) > 0L) {
    script_file <- normalizePath(sub("^--file=", "", file_arg[[1L]]), winslash = "/", mustWork = TRUE)
    return(normalizePath(file.path(dirname(script_file), "..", ".."), winslash = "/", mustWork = TRUE))
  }

  frame_files <- unique(Filter(
    nzchar,
    vapply(
      sys.frames(),
      function(frame) {
        if (is.null(frame$ofile)) {
          ""
        } else {
          frame$ofile
        }
      },
      character(1)
    )
  ))

  if (length(frame_files) > 0L) {
    script_file <- normalizePath(frame_files[[length(frame_files)]], winslash = "/", mustWork = TRUE)
    return(normalizePath(file.path(dirname(script_file), "..", ".."), winslash = "/", mustWork = TRUE))
  }

  current_wd <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)

  if (dir.exists(file.path(current_wd, "color_demo"))) {
    return(current_wd)
  }

  if (basename(current_wd) == "color_demo" && dir.exists(file.path(current_wd, "scripts"))) {
    return(normalizePath(file.path(current_wd, ".."), winslash = "/", mustWork = TRUE))
  }

  stop(
    "Could not determine the repo root. Run the script with Rscript.exe or source() it from the repo root.",
    call. = FALSE
  )
}

repo_root <- color_demo_resolve_repo_root()
setwd(repo_root)
project_renviron <- file.path(repo_root, "color_demo", ".Renviron")

if (file.exists(project_renviron)) {
  readRenviron(project_renviron)
}

local_library <- file.path(repo_root, "color_demo", ".r_libs")
dir.create(local_library, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(local_library, .libPaths()))

source(file.path("color_demo", "R", "color_demo_utils.R"), local = TRUE)
color_demo_assert_packages(c("rsconnect"))

presenter_config <- color_demo_config_file_value(
  section = "supabase_db",
  required_fields = c("host", "port", "dbname", "user", "password", "sslmode"),
  placeholder_values = list(
    host = "aws-0-your-region.pooler.supabase.com",
    user = "postgres.your-project-ref",
    password = "your-database-password"
  ),
  config_file = file.path("color_demo", "apps", "presenter_hosted", "config.yml")
)

if (is.null(presenter_config)) {
  stop(
    paste(
      "Update color_demo/apps/presenter_hosted/config.yml with real Supabase database values",
      "before deploying the hosted presenter app."
    ),
    call. = FALSE
  )
}

deploy_env <- color_demo_assert_env(c("SHINYAPPS_NAME", "SHINYAPPS_TOKEN", "SHINYAPPS_SECRET"))
app_name <- Sys.getenv("COLOR_DEMO_PRESENTER_SHINYAPPS_APP_NAME", unset = "color-demo-presenter")

rsconnect::setAccountInfo(
  name = deploy_env$SHINYAPPS_NAME,
  token = deploy_env$SHINYAPPS_TOKEN,
  secret = deploy_env$SHINYAPPS_SECRET
)

rsconnect::deployApp(
  appDir = file.path("color_demo", "apps", "presenter_hosted"),
  appName = app_name,
  appTitle = "Color Demo Presenter",
  forceUpdate = TRUE
)

message(
  paste(
    "Deployment requested. Confirm color_demo/apps/presenter_hosted/config.yml contains the",
    "Supabase database connection values you want bundled with the hosted presenter app.",
    "Because this app reads the database directly, shut the app down and rotate the database",
    "password after the demo."
  )
)
