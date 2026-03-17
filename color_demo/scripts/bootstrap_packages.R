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

repo_url <- "https://cloud.r-project.org"

cran_packages <- c(
  "admiral",
  "bslib",
  "config",
  "DBI",
  "DT",
  "dplyr",
  "gt",
  "gtsummary",
  "here",
  "httr2",
  "remotes",
  "RPostgres",
  "rmarkdown",
  "rlang",
  "rsconnect",
  "sdtm.oak",
  "shiny",
  "yaml"
)

installed <- rownames(utils::installed.packages())
missing_cran <- setdiff(cran_packages, installed)
failed_packages <- character()

if ("remotes" %in% missing_cran) {
  install.packages("remotes", repos = repo_url, lib = local_library, dependencies = TRUE)
  missing_cran <- setdiff(missing_cran, "remotes")
}

for (package_name in missing_cran) {
  if (requireNamespace(package_name, quietly = TRUE)) {
    next
  }

  message(sprintf("Installing %s...", package_name))

  tryCatch(
    {
      install.packages(package_name, repos = repo_url, lib = local_library, dependencies = TRUE)
    },
    error = function(err) {
      failed_packages <<- c(failed_packages, package_name)
      message(sprintf("Installation failed for %s: %s", package_name, conditionMessage(err)))
    }
  )

  if (!requireNamespace(package_name, quietly = TRUE)) {
    failed_packages <- c(failed_packages, package_name)
    message(sprintf("Package %s is still not loadable after installation.", package_name))
  }
}

if (!requireNamespace("gsm.core", quietly = TRUE)) {
  if (!requireNamespace("remotes", quietly = TRUE)) {
    failed_packages <- c(failed_packages, "remotes", "gsm.core")
  } else {
    tryCatch(
      {
        remotes::install_github("Gilead-BioStats/gsm.core", lib = local_library, upgrade = "never")
      },
      error = function(err) {
        failed_packages <<- c(failed_packages, "gsm.core")
        message(sprintf("Installation failed for gsm.core: %s", conditionMessage(err)))
      }
    )

    if (!requireNamespace("gsm.core", quietly = TRUE)) {
      failed_packages <- c(failed_packages, "gsm.core")
      message("Package gsm.core is still not loadable after installation.")
    }
  }
}

message(sprintf("Bootstrap complete. Packages are available in %s", local_library))

if (length(failed_packages) > 0L) {
  warning(sprintf("Some packages still need attention: %s", paste(unique(failed_packages), collapse = ", ")))
}
