COLOR_DEMO_ALLOWED_COLORS <- c("red", "blue", "yellow", "green", "orange", "purple")

color_demo_dependency_refs <- function() {
  invisible(list(
    admiral::derive_vars_computed,
    DBI::dbConnect,
    dplyr::mutate,
    gsm.core::MakeWorkflowList,
    gt::gt,
    gtsummary::tbl_summary,
    here::here,
    httr2::request,
    rmarkdown::render,
    sdtm.oak::hardcode_ct,
    yaml::yaml.load
  ))
}

color_demo_set_root <- function(path) {
  options(color_demo.root = normalizePath(path, winslash = "/", mustWork = TRUE))
  invisible(getOption("color_demo.root"))
}

color_demo_set_runtime_dir <- function(path) {
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  options(color_demo.runtime_dir = normalizePath(path, winslash = "/", mustWork = FALSE))
  invisible(getOption("color_demo.runtime_dir"))
}

color_demo_root <- function() {
  configured_root <- getOption("color_demo.root", default = NULL)

  if (is.character(configured_root) && nzchar(configured_root) && dir.exists(configured_root)) {
    return(normalizePath(configured_root, winslash = "/", mustWork = TRUE))
  }

  env_root <- Sys.getenv("COLOR_DEMO_ROOT", unset = "")

  if (nzchar(env_root) && dir.exists(env_root)) {
    return(normalizePath(env_root, winslash = "/", mustWork = TRUE))
  }

  here_root <- tryCatch(here::here("color_demo"), error = function(...) "")

  if (nzchar(here_root) && dir.exists(here_root)) {
    return(normalizePath(here_root, winslash = "/", mustWork = TRUE))
  }

  current_wd <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)

  if (dir.exists(file.path(current_wd, "workflows")) && dir.exists(file.path(current_wd, "report_templates"))) {
    return(current_wd)
  }

  if (dir.exists(file.path(current_wd, "color_demo", "workflows"))) {
    return(normalizePath(file.path(current_wd, "color_demo"), winslash = "/", mustWork = TRUE))
  }

  stop("Could not determine the color_demo root directory.", call. = FALSE)
}

color_demo_runtime_root <- function() {
  configured_runtime <- getOption("color_demo.runtime_dir", default = NULL)

  if (is.character(configured_runtime) && nzchar(configured_runtime)) {
    dir.create(configured_runtime, recursive = TRUE, showWarnings = FALSE)
    return(normalizePath(configured_runtime, winslash = "/", mustWork = FALSE))
  }

  env_runtime <- Sys.getenv("COLOR_DEMO_RUNTIME_DIR", unset = "")

  if (nzchar(env_runtime)) {
    dir.create(env_runtime, recursive = TRUE, showWarnings = FALSE)
    return(normalizePath(env_runtime, winslash = "/", mustWork = FALSE))
  }

  color_demo_root()
}

color_demo_path <- function(...) {
  normalizePath(file.path(color_demo_root(), ...), winslash = "/", mustWork = FALSE)
}

color_demo_runtime_path <- function(...) {
  normalizePath(file.path(color_demo_runtime_root(), ...), winslash = "/", mustWork = FALSE)
}

color_demo_register_yaml_helpers <- function(target_env = globalenv()) {
  helper_names <- c("color_demo_path", "color_demo_runtime_path", "color_demo_tfl_path")

  for (helper_name in helper_names) {
    assign(helper_name, get(helper_name, mode = "function"), envir = target_env)
  }

  invisible(target_env)
}

color_demo_required_packages <- function() {
  c(
    "admiral",
    "bslib",
    "config",
    "DBI",
    "DT",
    "dplyr",
    "gsm.core",
    "gt",
    "gtsummary",
    "here",
    "httr2",
    "RPostgres",
    "rmarkdown",
    "rlang",
    "rsconnect",
    "sdtm.oak",
    "shiny",
    "yaml"
  )
}

color_demo_missing_packages <- function(packages = color_demo_required_packages()) {
  packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
}

color_demo_assert_packages <- function(packages = color_demo_required_packages()) {
  missing_packages <- color_demo_missing_packages(packages)

  if (length(missing_packages) > 0) {
    stop(
      sprintf(
        "Missing required packages: %s. Run color_demo/scripts/bootstrap_packages.R first.",
        paste(missing_packages, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

color_demo_assert_env <- function(var_names) {
  values <- Sys.getenv(var_names, unset = NA_character_)
  missing_vars <- var_names[is.na(values) | !nzchar(values)]

  if (length(missing_vars) > 0) {
    stop(
      sprintf("Missing required environment variables: %s", paste(missing_vars, collapse = ", ")),
      call. = FALSE
    )
  }

  stats::setNames(as.list(unname(values)), var_names)
}

color_demo_supabase_rest_config <- function() {
  cfg <- color_demo_config_file_value(
    section = "supabase",
    required_fields = c("url", "anon_key"),
    placeholder_values = list(
      url = "https://your-project.supabase.co",
      anon_key = "your-public-publishable-or-anon-key"
    )
  )

  if (!is.null(cfg)) {
    return(
      list(
        url = sprintf("%s/rest/v1/raw_color_votes", sub("/$", "", cfg$url)),
        key = cfg$anon_key
      )
    )
  }

  env <- color_demo_assert_env(c("SUPABASE_URL", "SUPABASE_ANON_KEY"))

  list(
    url = sprintf("%s/rest/v1/raw_color_votes", sub("/$", "", env$SUPABASE_URL)),
    key = env$SUPABASE_ANON_KEY
  )
}

color_demo_read_app_config <- function(config_file = "config.yml") {
  if (!file.exists(config_file) || !requireNamespace("config", quietly = TRUE)) {
    return(NULL)
  }

  tryCatch(
    config::get(file = config_file),
    error = function(...) NULL
  )
}

color_demo_config_file_value <- function(section, required_fields, placeholder_values = list(), config_file = "config.yml") {
  cfg <- color_demo_read_app_config(config_file = config_file)

  if (is.null(cfg)) {
    return(NULL)
  }

  section_cfg <- cfg[[section]]

  if (!is.list(section_cfg)) {
    return(NULL)
  }

  section_values <- lapply(required_fields, function(field) section_cfg[[field]])
  names(section_values) <- required_fields

  has_invalid_value <- vapply(
    required_fields,
    function(field) {
      value <- section_values[[field]]

      if (is.null(value) || length(value) != 1L || !nzchar(as.character(value))) {
        return(TRUE)
      }

      placeholder <- placeholder_values[[field]]

      if (!is.null(placeholder) && identical(as.character(value), as.character(placeholder))) {
        return(TRUE)
      }

      FALSE
    },
    logical(1)
  )

  if (any(has_invalid_value)) {
    return(NULL)
  }

  section_values
}

color_demo_post_vote <- function(favorite_color, submission_source = "shiny_entry") {
  color_demo_assert_packages(c("httr2"))

  favorite_color <- tolower(trimws(favorite_color))

  if (!(favorite_color %in% COLOR_DEMO_ALLOWED_COLORS)) {
    stop(
      sprintf("Unsupported color '%s'. Allowed values: %s", favorite_color, paste(COLOR_DEMO_ALLOWED_COLORS, collapse = ", ")),
      call. = FALSE
    )
  }

  rest_cfg <- color_demo_supabase_rest_config()

  httr2::request(rest_cfg$url) |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      apikey = rest_cfg$key,
      Authorization = paste("Bearer", rest_cfg$key),
      Prefer = "return=minimal"
    ) |>
    httr2::req_body_json(
      list(
        favorite_color = favorite_color,
        submission_source = submission_source
      ),
      auto_unbox = TRUE
    ) |>
    httr2::req_perform()

  invisible(TRUE)
}

color_demo_db_config <- function() {
  cfg <- color_demo_config_file_value(
    section = "supabase_db",
    required_fields = c("host", "port", "dbname", "user", "password", "sslmode"),
    placeholder_values = list(
      host = "aws-0-your-region.pooler.supabase.com",
      user = "postgres.your-project-ref",
      password = "your-database-password"
    )
  )

  if (!is.null(cfg)) {
    return(
      list(
        host = cfg$host,
        port = as.integer(cfg$port),
        dbname = cfg$dbname,
        user = cfg$user,
        password = cfg$password,
        sslmode = cfg$sslmode
      )
    )
  }

  env <- color_demo_assert_env(
    c(
      "SUPABASE_DB_HOST",
      "SUPABASE_DB_PORT",
      "SUPABASE_DB_NAME",
      "SUPABASE_DB_USER",
      "SUPABASE_DB_PASSWORD"
    )
  )

  list(
    host = env$SUPABASE_DB_HOST,
    port = as.integer(env$SUPABASE_DB_PORT),
    dbname = env$SUPABASE_DB_NAME,
    user = env$SUPABASE_DB_USER,
    password = env$SUPABASE_DB_PASSWORD,
    sslmode = Sys.getenv("SUPABASE_DB_SSLMODE", unset = "require")
  )
}

color_demo_connect_db <- function() {
  color_demo_assert_packages(c("DBI", "RPostgres"))
  db_cfg <- color_demo_db_config()

  DBI::dbConnect(
    RPostgres::Postgres(),
    host = db_cfg$host,
    port = db_cfg$port,
    dbname = db_cfg$dbname,
    user = db_cfg$user,
    password = db_cfg$password,
    sslmode = db_cfg$sslmode
  )
}

color_demo_default_sql <- function() {
  paste(
    "select",
    "  record_id,",
    "  favorite_color,",
    "  submitted_at",
    "from public.raw_color_votes",
    "order by record_id",
    sep = "\n"
  )
}

color_demo_strip_sql_comments <- function(sql) {
  stripped_sql <- gsub("/\\*.*?\\*/", " ", sql, perl = TRUE)
  gsub("(?m)--.*$", " ", stripped_sql, perl = TRUE)
}

color_demo_validate_read_only_sql <- function(sql) {
  if (!is.character(sql) || length(sql) != 1L) {
    stop("SQL must be a single character string.", call. = FALSE)
  }

  normalized_sql <- trimws(color_demo_strip_sql_comments(sql))
  normalized_sql <- sub(";\\s*$", "", normalized_sql, perl = TRUE)

  if (!nzchar(normalized_sql)) {
    stop("SQL cannot be empty.", call. = FALSE)
  }

  if (grepl(";", normalized_sql, fixed = TRUE)) {
    stop("Only a single query is allowed.", call. = FALSE)
  }

  lowered_sql <- tolower(normalized_sql)

  if (!(startsWith(lowered_sql, "select") || startsWith(lowered_sql, "with"))) {
    stop("Only SELECT or WITH queries are allowed.", call. = FALSE)
  }

  blocked_keywords <- c(
    "alter",
    "call",
    "comment",
    "copy",
    "create",
    "delete",
    "do",
    "drop",
    "grant",
    "insert",
    "merge",
    "refresh",
    "revoke",
    "truncate",
    "update",
    "vacuum"
  )

  if (grepl(sprintf("\\b(%s)\\b", paste(blocked_keywords, collapse = "|")), lowered_sql, perl = TRUE)) {
    stop("Only read-only SQL is allowed in the presenter app.", call. = FALSE)
  }

  normalized_sql
}

color_demo_run_read_only_query <- function(sql = color_demo_default_sql()) {
  validated_sql <- color_demo_validate_read_only_sql(sql)
  conn <- color_demo_connect_db()
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  DBI::dbGetQuery(conn, validated_sql)
}

color_demo_fetch_raw_votes <- function() {
  color_demo_run_read_only_query(
    paste(
      "select",
      "  record_id,",
      "  favorite_color,",
      "  submitted_at,",
      "  submission_source",
      "from public.raw_color_votes",
      "order by record_id",
      sep = "\n"
    )
  )
}

color_demo_study_ct <- function() {
  utils::read.csv(
    color_demo_path("data", "ct", "color_terms.csv"),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

color_demo_cache_rds_path <- function(filename) {
  cache_dir <- color_demo_runtime_path("data", "cache")
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  normalizePath(file.path(cache_dir, filename), winslash = "/", mustWork = FALSE)
}

color_demo_write_cache_rds <- function(value, filename) {
  saveRDS(value, color_demo_cache_rds_path(filename))
  invisible(value)
}

color_demo_read_cache_rds <- function(filename) {
  cache_path <- color_demo_cache_rds_path(filename)

  if (!file.exists(cache_path)) {
    return(NULL)
  }

  readRDS(cache_path)
}

color_demo_tfl_path <- function() {
  tfl_dir <- color_demo_runtime_path("TFLS")
  dir.create(tfl_dir, recursive = TRUE, showWarnings = FALSE)
  normalizePath(file.path(tfl_dir, "WorkProduct1.html"), winslash = "/", mustWork = FALSE)
}

color_demo_extract_workflow_output <- function(outputs, preferred_name = NULL) {
  if (!is.list(outputs) || length(outputs) == 0L) {
    stop("Workflow execution did not return any outputs.", call. = FALSE)
  }

  if (!is.null(preferred_name) && preferred_name %in% names(outputs)) {
    return(outputs[[preferred_name]])
  }

  outputs[[1]]
}

color_demo_make_workflow_list <- function(workflow_name, workflow_path) {
  color_demo_assert_packages(c("gsm.core"))
  gsm.core::MakeWorkflowList(
    strNames = workflow_name,
    strPath = workflow_path,
    strPackage = NULL
  )
}

color_demo_run_sdtm <- function(raw_color_votes = NULL) {
  color_demo_assert_packages(c("dplyr", "gsm.core", "here", "rlang", "sdtm.oak", "yaml"))
  color_demo_register_yaml_helpers()
  options(yaml.eval.expr = TRUE)

  if (is.null(raw_color_votes)) {
    raw_color_votes <- color_demo_fetch_raw_votes()
  }

  workflows <- color_demo_make_workflow_list(
    workflow_name = "DM",
    workflow_path = color_demo_path("workflows", "1_RAW_TO_SDTM")
  )

  workflow_outputs <- gsm.core::RunWorkflows(
    lWorkflows = workflows,
    lData = list(
      raw_color_votes = raw_color_votes,
      study_ct = color_demo_study_ct()
    )
  )

  sdtm_dm <- color_demo_extract_workflow_output(workflow_outputs, "SDTM_DM")
  color_demo_write_cache_rds(sdtm_dm, "SDTM_DM.rds")
  sdtm_dm
}

color_demo_run_adam <- function(sdtm_dm = NULL) {
  color_demo_assert_packages(c("admiral", "dplyr", "gsm.core", "rlang", "yaml"))
  color_demo_register_yaml_helpers()
  options(yaml.eval.expr = TRUE)

  if (is.null(sdtm_dm)) {
    sdtm_dm <- color_demo_read_cache_rds("SDTM_DM.rds")
  }

  if (is.null(sdtm_dm)) {
    sdtm_dm <- color_demo_run_sdtm()
  }

  workflows <- color_demo_make_workflow_list(
    workflow_name = "ADSL",
    workflow_path = color_demo_path("workflows", "2_SDTM_TO_ADAM")
  )

  workflow_outputs <- gsm.core::RunWorkflows(
    lWorkflows = workflows,
    lData = list(SDTM_DM = sdtm_dm)
  )

  adam_adsl <- color_demo_extract_workflow_output(workflow_outputs, "ADAM_ADSL")
  color_demo_write_cache_rds(adam_adsl, "ADAM_ADSL.rds")
  adam_adsl
}

color_demo_run_tfl <- function(adam_adsl = NULL) {
  color_demo_assert_packages(c("dplyr", "gsm.core", "gtsummary", "here", "rmarkdown", "yaml"))
  color_demo_register_yaml_helpers()
  options(yaml.eval.expr = TRUE)

  if (is.null(adam_adsl)) {
    adam_adsl <- color_demo_read_cache_rds("ADAM_ADSL.rds")
  }

  if (is.null(adam_adsl)) {
    adam_adsl <- color_demo_run_adam()
  }

  workflows <- color_demo_make_workflow_list(
    workflow_name = "WorkProduct1",
    workflow_path = color_demo_path("workflows", "3_ADAM_TO_TFL")
  )

  invisible(
    gsm.core::RunWorkflows(
      lWorkflows = workflows,
      lData = list(ADSL = adam_adsl)
    )
  )

  output_path <- color_demo_tfl_path()

  if (!file.exists(output_path)) {
    stop(sprintf("Expected TFL output was not created at %s", output_path), call. = FALSE)
  }

  output_path
}

color_demo_preview <- function(data, n = 10L) {
  if (is.null(data)) {
    return(data.frame(Message = "No data available yet.", stringsAsFactors = FALSE))
  }

  utils::head(data, n = n)
}
