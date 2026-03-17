source(file.path("..", "..", "R", "color_demo_utils.R"), local = TRUE)
color_demo_assert_packages(c("bslib", "DBI", "DT", "here", "RPostgres", "rlang", "shiny"))

presenter_theme <- bslib::bs_theme(
  version = 5,
  bg = "#f8f6f1",
  fg = "#213547",
  primary = "#1d7874",
  secondary = "#bc6c25",
  success = "#386641",
  base_font = bslib::font_google("Source Sans 3"),
  heading_font = bslib::font_google("Libre Baskerville")
)

ui <- bslib::page_navbar(
  title = "Color Demo Pipeline",
  theme = presenter_theme,
  header = shiny::tags$head(
    shiny::tags$style(
      shiny::HTML(
        "
        body {
          background:
            radial-gradient(circle at top left, rgba(29, 120, 116, 0.12), transparent 30%),
            radial-gradient(circle at top right, rgba(188, 108, 37, 0.14), transparent 28%),
            linear-gradient(180deg, #f8f6f1 0%, #f1ede4 100%);
        }
        .stage-card {
          border-radius: 1.1rem;
          border: 1px solid rgba(33, 53, 71, 0.08);
          box-shadow: 0 18px 44px rgba(33, 53, 71, 0.08);
        }
        .status-text {
          min-height: 3rem;
          padding: 0.85rem 1rem;
          border-radius: 0.9rem;
          background: rgba(29, 120, 116, 0.08);
          color: #21455c;
          white-space: pre-wrap;
        }
        .table-fill {
          min-height: 0;
          height: 100%;
          overflow: auto;
        }
        .table-fill .html-widget,
        .table-fill .datatables,
        .table-fill .dataTables_wrapper {
          width: 100%;
        }
        .yaml-preview {
          min-height: 0;
        }
        .code-area textarea {
          font-family: Consolas, 'Courier New', monospace;
          min-height: 16rem;
        }
        .action-row {
          display: flex;
          gap: 0.75rem;
          flex-wrap: wrap;
          align-items: center;
        }
        .yaml-note {
          color: rgba(33, 53, 71, 0.72);
          font-size: 0.95rem;
        }
        .file-label {
          color: rgba(33, 53, 71, 0.62);
          font-size: 0.85rem;
          margin-bottom: 0.6rem;
        }
        .yaml-preview {
          max-height: 28rem;
          overflow: auto;
          border-radius: 0.9rem;
          border: 1px solid rgba(33, 53, 71, 0.08);
          background: rgba(255, 255, 255, 0.78);
        }
        .source-preview {
          max-height: 16rem;
          margin-bottom: 1rem;
        }
        .yaml-preview pre {
          margin: 0;
          padding: 1rem;
          white-space: pre-wrap;
          word-break: break-word;
          font-family: Consolas, 'Courier New', monospace;
          font-size: 0.88rem;
          line-height: 1.45;
          color: #213547;
          background: transparent;
        }
        .compact-code-area textarea {
          min-height: 14rem;
        }
        .tfl-frame {
          width: 100%;
          min-height: 760px;
          border: 1px solid rgba(33, 53, 71, 0.1);
          border-radius: 0.8rem;
          background: white;
        }
        "
      )
    )
  ),
  bslib::nav_panel(
    "Raw -> SDTM",
    bslib::layout_columns(
      col_widths = c(4, 4, 4),
      bslib::card(
        class = "stage-card raw-top-card",
        style = "height: 32rem;",
        full_screen = TRUE,
        bslib::card_header("Supabase SQL"),
        shiny::div(
          class = "code-area compact-code-area",
          shiny::textAreaInput("raw_sql", NULL, value = color_demo_default_sql(), width = "100%", resize = "vertical")
        ),
        shiny::div(
          class = "action-row",
          shiny::actionButton("run_sql", "Run SQL", class = "btn-primary")
        ),
        shiny::div(class = "status-text", shiny::textOutput("sql_status"))
      ),
      bslib::card(
        class = "stage-card raw-top-card",
        style = "height: 32rem;",
        full_screen = TRUE,
        bslib::card_header("Controlled Terminology Preview"),
        shiny::div(class = "table-fill", DT::DTOutput("ct_preview"))
      ),
      bslib::card(
        class = "stage-card raw-top-card",
        style = "height: 32rem;",
        full_screen = TRUE,
        bslib::card_header("Raw Preview"),
        shiny::div(class = "table-fill", DT::DTOutput("raw_preview"))
      )
    ),
    bslib::layout_columns(
      col_widths = c(4, 4, 4),
      bslib::card(
        class = "stage-card raw-bottom-card",
        style = "height: 27rem;",
        bslib::card_header("DM.yaml"),
        shiny::div(
          class = "action-row",
          shiny::actionButton("run_sdtm", "Run Raw -> SDTM", class = "btn-primary")
        ),
        shiny::div(class = "status-text", shiny::textOutput("sdtm_status"))
      ),
      bslib::card(
        class = "stage-card raw-bottom-card",
        style = "height: 27rem;",
        full_screen = TRUE,
        bslib::card_header("DM.yaml Preview"),
        shiny::div(
          class = "yaml-preview",
          shiny::verbatimTextOutput("dm_yaml_preview")
        )
      ),
      bslib::card(
        class = "stage-card raw-bottom-card",
        style = "height: 27rem;",
        full_screen = TRUE,
        bslib::card_header("SDTM_DM Preview"),
        shiny::div(class = "table-fill", DT::DTOutput("sdtm_preview"))
      )
    )
  ),
  bslib::nav_panel(
    "SDTM -> ADAM",
    bslib::layout_columns(
      col_widths = c(4, 4, 4),
      bslib::card(
        class = "stage-card",
        bslib::card_header("ADSL.yaml"),
        shiny::div(
          class = "action-row",
          shiny::actionButton("run_adam", "Run SDTM -> ADAM", class = "btn-primary")
        ),
        shiny::div(class = "status-text", shiny::textOutput("adam_status"))
      ),
      bslib::card(
        class = "stage-card",
        full_screen = TRUE,
        bslib::card_header("ADSL.yaml Preview"),
        shiny::div(
          class = "yaml-preview",
          shiny::verbatimTextOutput("adsl_yaml_preview")
        )
      ),
      bslib::card(
        class = "stage-card",
        full_screen = TRUE,
        bslib::card_header("ADAM_ADSL Preview"),
        DT::DTOutput("adam_preview")
      )
    )
  ),
  bslib::nav_panel(
    "ADAM -> TFL",
    bslib::layout_columns(
      col_widths = c(4, 4, 4),
      bslib::card(
        class = "stage-card",
        bslib::card_header("WorkProduct1.yaml"),
        shiny::div(
          class = "action-row",
          shiny::actionButton("run_tfl", "Run ADAM -> TFL", class = "btn-primary")
        ),
        shiny::div(class = "status-text", shiny::textOutput("tfl_status"))
      ),
      bslib::card(
        class = "stage-card",
        full_screen = TRUE,
        bslib::card_header("R Markdown Sources"),
        shiny::div(
          class = "yaml-preview source-preview",
          shiny::verbatimTextOutput("tfl_parent_rmd_preview")
        ),
        shiny::div(
          class = "yaml-preview source-preview",
          shiny::verbatimTextOutput("tfl_child_rmd_preview")
        )
      ),
      bslib::card(
        class = "stage-card",
        full_screen = TRUE,
        bslib::card_header("Rendered Work Product"),
        shiny::uiOutput("tfl_preview")
      )
    )
  )
)

server <- function(input, output, session) {
  stamp_message <- function(message_text) {
    sprintf("[%s] %s", format(Sys.time(), "%H:%M:%S"), message_text)
  }

  initial_sdtm_data <- color_demo_read_cache_rds("SDTM_DM.rds")
  initial_adam_data <- color_demo_read_cache_rds("ADAM_ADSL.rds")
  existing_tfl_path <- color_demo_tfl_path()
  initial_tfl_path <- if (file.exists(existing_tfl_path)) existing_tfl_path else NULL

  raw_data <- shiny::reactiveVal(NULL)
  raw_preview_data <- shiny::reactiveVal(NULL)
  sdtm_data <- shiny::reactiveVal(initial_sdtm_data)
  sdtm_preview_data <- shiny::reactiveVal(NULL)
  adam_data <- shiny::reactiveVal(initial_adam_data)
  tfl_data <- shiny::reactiveVal(initial_tfl_path)

  sql_status <- shiny::reactiveVal("Run the default query to load raw votes from Supabase.")
  sdtm_status <- shiny::reactiveVal(
    if (is.null(initial_sdtm_data)) {
      "No cached SDTM_DM dataset found yet."
    } else {
      stamp_message(sprintf("Loaded %d cached SDTM row(s).", nrow(initial_sdtm_data)))
    }
  )
  adam_status <- shiny::reactiveVal(
    if (is.null(initial_adam_data)) {
      "No cached ADAM_ADSL dataset found yet."
    } else {
      stamp_message(sprintf("Loaded %d cached ADAM row(s).", nrow(initial_adam_data)))
    }
  )
  tfl_status <- shiny::reactiveVal(
    if (is.null(initial_tfl_path)) {
      "No cached WorkProduct1.html artifact found yet."
    } else {
      stamp_message(sprintf("Loaded existing TFL artifact from %s.", initial_tfl_path))
    }
  )

  update_status <- function(status_reactive, message_text) {
    status_reactive(stamp_message(message_text))
  }

  read_source_preview <- function(path, missing_message) {
    if (!file.exists(path)) {
      return(missing_message)
    }

    paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  }

  ensure_raw_data <- function() {
    current_raw <- raw_data()

    if (is.null(current_raw)) {
      current_raw <- color_demo_fetch_raw_votes()
      raw_data(current_raw)
    }

    current_raw
  }

  ensure_sdtm_data <- function() {
    current_sdtm <- sdtm_data()

    if (is.null(current_sdtm)) {
      current_sdtm <- color_demo_run_sdtm(ensure_raw_data())
      sdtm_data(current_sdtm)
      update_status(sdtm_status, sprintf("Generated %d SDTM DM row(s).", nrow(current_sdtm)))
    }

    current_sdtm
  }

  ensure_adam_data <- function() {
    current_adam <- adam_data()

    if (is.null(current_adam)) {
      current_adam <- color_demo_run_adam(ensure_sdtm_data())
      adam_data(current_adam)
      update_status(adam_status, sprintf("Generated %d ADAM row(s).", nrow(current_adam)))
    }

    current_adam
  }

  shiny::observeEvent(input$run_sql, {
    tryCatch(
      {
        queried_data <- color_demo_run_read_only_query(input$raw_sql)
        raw_data(queried_data)
        raw_preview_data(queried_data)
        update_status(sql_status, sprintf("Query returned %d row(s).", nrow(queried_data)))
      },
      error = function(err) {
        update_status(sql_status, conditionMessage(err))
        shiny::showNotification(conditionMessage(err), type = "error", duration = NULL)
      }
    )
  })

  shiny::observeEvent(input$run_sdtm, {
    shiny::withProgress(message = "Running Raw -> SDTM", value = 0, {
      tryCatch(
        {
          current_raw <- ensure_raw_data()
          shiny::incProgress(0.35, detail = "Raw data ready")
          current_sdtm <- color_demo_run_sdtm(current_raw)
          shiny::incProgress(0.85, detail = "DM.yaml complete")
          sdtm_data(current_sdtm)
          sdtm_preview_data(current_sdtm)
          update_status(sdtm_status, sprintf("Generated %d SDTM DM row(s).", nrow(current_sdtm)))
          shiny::showNotification("Raw -> SDTM complete.", type = "message", duration = 4)
        },
        error = function(err) {
          update_status(sdtm_status, conditionMessage(err))
          shiny::showNotification(conditionMessage(err), type = "error", duration = NULL)
        }
      )
    })
  })

  shiny::observeEvent(input$run_adam, {
    shiny::withProgress(message = "Running SDTM -> ADAM", value = 0, {
      tryCatch(
        {
          current_sdtm <- ensure_sdtm_data()
          shiny::incProgress(0.45, detail = "SDTM_DM ready")
          current_adam <- color_demo_run_adam(current_sdtm)
          shiny::incProgress(0.9, detail = "ADSL.yaml complete")
          adam_data(current_adam)
          update_status(adam_status, sprintf("Generated %d ADAM row(s).", nrow(current_adam)))
          shiny::showNotification("SDTM -> ADAM complete.", type = "message", duration = 4)
        },
        error = function(err) {
          update_status(adam_status, conditionMessage(err))
          shiny::showNotification(conditionMessage(err), type = "error", duration = NULL)
        }
      )
    })
  })

  shiny::observeEvent(input$run_tfl, {
    shiny::withProgress(message = "Running ADAM -> TFL", value = 0, {
      tryCatch(
        {
          current_adam <- ensure_adam_data()
          shiny::incProgress(0.45, detail = "ADAM_ADSL ready")
          rendered_path <- color_demo_run_tfl(current_adam)
          shiny::incProgress(0.95, detail = "WorkProduct1.yaml complete")
          tfl_data(rendered_path)
          update_status(tfl_status, sprintf("Rendered HTML artifact to %s.", rendered_path))
          shiny::showNotification("ADAM -> TFL complete.", type = "message", duration = 4)
        },
        error = function(err) {
          update_status(tfl_status, conditionMessage(err))
          shiny::showNotification(conditionMessage(err), type = "error", duration = NULL)
        }
      )
    })
  })

  output$sql_status <- shiny::renderText(sql_status())
  output$sdtm_status <- shiny::renderText(sdtm_status())
  output$adam_status <- shiny::renderText(adam_status())
  output$tfl_status <- shiny::renderText(tfl_status())

  output$raw_preview <- DT::renderDT({
    preview_data <- raw_preview_data()

    if (is.null(preview_data)) {
      return(
        DT::datatable(
          data.frame(Message = "Click Run SQL to preview raw rows from Supabase.", stringsAsFactors = FALSE),
          rownames = FALSE,
          options = list(dom = "t", paging = FALSE, searching = FALSE, info = FALSE)
        )
      )
    }

    DT::datatable(
      color_demo_preview(preview_data),
      rownames = FALSE,
      options = list(pageLength = 8, scrollX = TRUE, dom = "tip")
    )
  })

  output$ct_preview <- DT::renderDT({
    ct_data <- color_demo_study_ct()

    DT::datatable(
      ct_data,
      rownames = FALSE,
      options = list(pageLength = 6, scrollX = TRUE, dom = "tip")
    )
  })

  output$dm_yaml_preview <- shiny::renderText({
    read_source_preview(
      color_demo_path("workflows", "1_RAW_TO_SDTM", "DM.yaml"),
      "DM.yaml could not be found."
    )
  })

  output$sdtm_preview <- DT::renderDT({
    preview_data <- sdtm_preview_data()

    if (is.null(preview_data)) {
      return(
        DT::datatable(
          data.frame(Message = "Click Run Raw -> SDTM to preview SDTM_DM rows.", stringsAsFactors = FALSE),
          rownames = FALSE,
          options = list(dom = "t", paging = FALSE, searching = FALSE, info = FALSE)
        )
      )
    }

    DT::datatable(
      color_demo_preview(preview_data),
      rownames = FALSE,
      options = list(pageLength = 8, scrollX = TRUE, dom = "tip")
    )
  })

  output$adsl_yaml_preview <- shiny::renderText({
    read_source_preview(
      color_demo_path("workflows", "2_SDTM_TO_ADAM", "ADSL.yaml"),
      "ADSL.yaml could not be found."
    )
  })

  output$adam_preview <- DT::renderDT({
    DT::datatable(
      color_demo_preview(adam_data()),
      rownames = FALSE,
      options = list(pageLength = 8, scrollX = TRUE, dom = "tip")
    )
  })

  output$tfl_preview <- shiny::renderUI({
    rendered_path <- tfl_data()

    if (is.null(rendered_path) || !file.exists(rendered_path)) {
      return(shiny::p("Run the ADAM -> TFL step to render the HTML work product."))
    }

    html_text <- paste(readLines(rendered_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

    shiny::tags$iframe(srcdoc = html_text, class = "tfl-frame")
  })

  output$tfl_parent_rmd_preview <- shiny::renderText({
    read_source_preview(
      color_demo_path("report_templates", "WorkProduct1.Rmd"),
      "WorkProduct1.Rmd could not be found."
    )
  })

  output$tfl_child_rmd_preview <- shiny::renderText({
    read_source_preview(
      color_demo_path("report_templates", "WorkProduct1_child.Rmd"),
      "WorkProduct1_child.Rmd could not be found."
    )
  })

}

shiny::shinyApp(ui = ui, server = server)
