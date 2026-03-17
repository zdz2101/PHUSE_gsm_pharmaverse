entry_allowed_colors <- c("red", "blue", "yellow", "green", "orange", "purple")

read_entry_config <- function() {
  if (file.exists("config.yml")) {
    cfg <- config::get(file = "config.yml")
    cfg_url <- cfg[["supabase"]][["url"]]
    cfg_key <- cfg[["supabase"]][["anon_key"]]

    if (nzchar(cfg_url) && nzchar(cfg_key) &&
        !identical(cfg_url, "https://your-project.supabase.co") &&
        !identical(cfg_key, "your-public-publishable-or-anon-key")) {
      return(list(SUPABASE_URL = cfg_url, SUPABASE_ANON_KEY = cfg_key))
    }
  }

  values <- Sys.getenv(c("SUPABASE_URL", "SUPABASE_ANON_KEY"), unset = NA_character_)
  missing_vars <- c("SUPABASE_URL", "SUPABASE_ANON_KEY")[is.na(values) | !nzchar(values)]

  if (length(missing_vars) > 0) {
    stop(
      sprintf(
        "Missing required Supabase configuration: %s. Update config.yml in the app directory or set environment variables.",
        paste(missing_vars, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  stats::setNames(as.list(unname(values)), c("SUPABASE_URL", "SUPABASE_ANON_KEY"))
}

assert_entry_env <- function(var_names) {
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

post_vote_to_supabase <- function(favorite_color, submission_source = "shiny_entry") {
  favorite_color <- tolower(trimws(favorite_color))

  if (!(favorite_color %in% entry_allowed_colors)) {
    stop(
      sprintf("Unsupported color '%s'. Allowed values: %s", favorite_color, paste(entry_allowed_colors, collapse = ", ")),
      call. = FALSE
    )
  }

  app_cfg <- read_entry_config()
  rest_url <- sprintf("%s/rest/v1/raw_color_votes", sub("/$", "", app_cfg$SUPABASE_URL))

  httr2::request(rest_url) |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      apikey = app_cfg$SUPABASE_ANON_KEY,
      Authorization = paste("Bearer", app_cfg$SUPABASE_ANON_KEY),
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

entry_palette <- c(
  red = "#d1495b",
  blue = "#2b59c3",
  yellow = "#edae49",
  green = "#4f772d",
  orange = "#f4a261",
  purple = "#6c5ce7"
)

entry_choices <- Map(
  f = function(color_name, color_hex) {
    shiny::tags$span(
      class = "color-option",
      shiny::tags$span(class = "color-swatch", style = sprintf("background:%s;", color_hex)),
      tools::toTitleCase(color_name)
    )
  },
  color_name = entry_allowed_colors,
  color_hex = unname(entry_palette[entry_allowed_colors])
)

entry_theme <- bslib::bs_theme(
  version = 5,
  bg = "#f7f3eb",
  fg = "#17324d",
  primary = "#bc4b09",
  secondary = "#355070",
  success = "#386641",
  base_font = bslib::font_google("Source Sans 3"),
  heading_font = bslib::font_google("Libre Baskerville")
)

ui <- bslib::page_fillable(
  title = "Color Demo Entry",
  theme = entry_theme,
  shiny::tags$head(
    shiny::tags$style(
      shiny::HTML(
        "
        body {
          background:
            radial-gradient(circle at top left, rgba(237, 174, 73, 0.22), transparent 34%),
            radial-gradient(circle at top right, rgba(43, 89, 195, 0.18), transparent 28%),
            linear-gradient(180deg, #f7f3eb 0%, #f2ede2 100%);
        }
        .entry-shell {
          max-width: 760px;
          margin: auto;
          padding: 2.5rem 1.25rem 3rem;
        }
        .entry-chip {
          display: inline-block;
          margin-bottom: 1rem;
          padding: 0.45rem 0.8rem;
          border-radius: 999px;
          background: rgba(23, 50, 77, 0.08);
          color: #17324d;
          font-size: 0.9rem;
          letter-spacing: 0.03em;
          text-transform: uppercase;
        }
        .entry-card {
          background: rgba(255, 255, 255, 0.9);
          border: 1px solid rgba(23, 50, 77, 0.08);
          border-radius: 1.25rem;
          box-shadow: 0 24px 60px rgba(23, 50, 77, 0.08);
          padding: 1.5rem;
        }
        .entry-lead {
          max-width: 48rem;
          color: rgba(23, 50, 77, 0.82);
          font-size: 1.1rem;
        }
        .color-option {
          display: inline-flex;
          align-items: center;
          gap: 0.7rem;
          font-size: 1.05rem;
        }
        .color-swatch {
          width: 1rem;
          height: 1rem;
          border-radius: 999px;
          border: 1px solid rgba(0, 0, 0, 0.15);
          box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.32);
        }
        .radio {
          padding: 0.35rem 0;
        }
        .action-row {
          margin-top: 1rem;
          display: flex;
          gap: 0.75rem;
          align-items: center;
          flex-wrap: wrap;
        }
        .btn-primary {
          border-radius: 999px;
          padding-inline: 1.3rem;
          font-weight: 600;
        }
        .feedback-card {
          margin-top: 1rem;
          padding: 1rem 1.1rem;
          border-radius: 1rem;
          background: rgba(56, 102, 65, 0.08);
          border: 1px solid rgba(56, 102, 65, 0.16);
        }
        .feedback-card h4 {
          margin-bottom: 0.35rem;
        }
        "
      )
    )
  ),
  shiny::div(
    class = "entry-shell",
    shiny::div(class = "entry-chip", "COLORDEMO audience vote"),
    shiny::h1("Favorite Color eCRF"),
    shiny::p(
      class = "entry-lead",
      "Choose the color you like best, then submit your response. The vote is stored in Supabase and will feed the live Raw -> SDTM -> ADAM -> TFL demo."
    ),
    shiny::div(
      class = "entry-card",
      shiny::radioButtons(
        inputId = "favorite_color",
        label = shiny::tags$strong("What is your favorite color?"),
        choiceNames = unname(entry_choices),
        choiceValues = unname(entry_allowed_colors),
        selected = NULL
      ),
      shiny::div(
        class = "action-row",
        shiny::actionButton("submit_vote", "Submit response", class = "btn-primary btn-lg")
      ),
      shiny::uiOutput("vote_feedback")
    )
  )
)

server <- function(input, output, session) {
  submitted_color <- shiny::reactiveVal(NULL)

  output$vote_feedback <- shiny::renderUI({
    current_color <- submitted_color()

    if (is.null(current_color)) {
      return(
        shiny::p(
          class = "text-muted mb-0 mt-3",
          "Your response is write-only in this app. The presenter will review the aggregated results in a separate workflow app."
        )
      )
    }

    shiny::div(
      class = "feedback-card",
      shiny::h4("Response recorded"),
      shiny::p(sprintf("You submitted: %s.", tools::toTitleCase(current_color))),
      shiny::p(
        class = "mb-0",
        "You can leave this page open or change your answer and submit again if prompted."
      )
    )
  })

  shiny::observeEvent(input$favorite_color, {
    submitted_color(NULL)
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$submit_vote, {
    if (!nzchar(input$favorite_color)) {
      shiny::showNotification("Please choose a color before submitting.", type = "warning")
      return()
    }

    shiny::showNotification(
      "Submitting response...",
      id = "vote-submit",
      type = "message",
      duration = NULL,
      closeButton = FALSE
    )

    tryCatch(
      {
        post_vote_to_supabase(input$favorite_color)
        shiny::removeNotification("vote-submit")
        submitted_color(input$favorite_color)
        shiny::showNotification("Thanks, your vote was saved.", type = "message", duration = 4)
      },
      error = function(err) {
        shiny::removeNotification("vote-submit")
        shiny::showNotification(conditionMessage(err), type = "error", duration = NULL)
      }
    )
  })
}

shiny::shinyApp(ui = ui, server = server)
