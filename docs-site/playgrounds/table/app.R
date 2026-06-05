if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)

  mounted <- FALSE
  for (path in c("../../library.data.gz", "../library.data.gz")) {
    tryCatch({
      webr::mount("/packages", path)
      if ("shinyblocks" %in% installed.packages(lib.loc = "/packages")[, "Package"]) {
        mounted <- TRUE
        break
      }
    }, error = function(e) {
      # Try the next path; Shinylive resolves mount URLs differently by host.
    })
  }

  if (!mounted) {
    tryCatch({
      webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
    }, error = function(e) {
      stop("Failed to mount shinyblocks WASM package library: ", e$message)
    })
  }

  .libPaths(c("/packages", .libPaths()))
}

library(shiny)
do.call(library, list("shinyblocks", character.only = TRUE))

`%||%` <- function(a, b) if (is.null(a)) b else a

showcase_render_code <- function(expr, env = parent.frame()) {
  quoted <- substitute(expr)
  force(env)
  renderUI({
    value <- eval(quoted, envir = env)
    if (is.null(value) || !length(value)) value <- ""
    block_code(
      code = paste(as.character(value), collapse = "\n"),
      language = "r",
      copyable = TRUE,
      line_numbers = TRUE
    )
  })
}

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

table_demo_data <- function(key) {
  switch(
    key %||% "metrics",
    releases = data.frame(
      package = c("shinyblocks", "runtime", "docs-site", "showcase"),
      status = c("ready", "review", "queued", "ready"),
      owner = c("UI", "Runtime", "Docs", "QA"),
      stringsAsFactors = FALSE
    ),
    empty = data.frame(
      metric = character(),
      value = numeric(),
      delta = character(),
      stringsAsFactors = FALSE
    ),
    data.frame(
      metric = c("Revenue", "Orders", "Conversion", "Refunds"),
      value = c(42000, 128, 0.048, NA),
      delta = c("+12%", "+8%", "+0.6 pts", NA),
      stringsAsFactors = FALSE
    )
  )
}

table_demo_columns <- function(key, align) {
  if (identical(key, "releases")) {
    return(list(
      status = table_column(label = "Status", align = align),
      owner = table_column(label = "Owner")
    ))
  }

  list(
    metric = table_column(label = "Metric"),
    value = table_column(
      label = "Value",
      align = align,
      format = function(value) {
        ifelse(
          is.na(value),
          NA_character_,
          ifelse(value < 1, sprintf("%.1f%%", value * 100), format(value, big.mark = ",", trim = TRUE))
        )
      }
    ),
    delta = table_column(label = "Delta", align = align)
  )
}

ui <- block_page(
  title = "shinyblocks - Table playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::tags$div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      class = "showcase-playground",
      style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
      block_card(
        title = "Controls",
        class = "showcase-playground__controls",
        style = "flex: 1; min-width: 280px; max-width: 320px;",
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Content"
          ),
          block_field(
            block_field_label("dataset", `for` = "showcase_table_doc_dataset"),
            block_select(
              "showcase_table_doc_dataset",
              choices = c(
                "Metrics" = "metrics",
                "Release queue" = "releases",
                "Zero rows" = "empty"
              ),
              selected = "metrics",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("caption", `for` = "showcase_table_doc_caption"),
            block_textarea(
              "showcase_table_doc_caption",
              value = "Monthly operating metrics.",
              rows = 2,
              resize = "none"
            )
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "State"
          ),
          block_field(
            block_field_label("max_rows", `for` = "showcase_table_doc_max_rows"),
            block_select(
              "showcase_table_doc_max_rows",
              choices = c("All rows" = "all", "2 rows" = "2", "3 rows" = "3"),
              selected = "all",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("numeric alignment", `for` = "showcase_table_doc_align"),
            block_select(
              "showcase_table_doc_align",
              choices = c("left", "center", "right"),
              selected = "right",
              size = "sm"
            )
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Styling"
          ),
          block_field(
            block_field_label("style", `for` = "showcase_table_doc_style"),
            block_textarea(
              "showcase_table_doc_style",
              value = "",
              rows = 1,
              placeholder = "e.g., max-width: 520px;",
              resize = "none"
            )
          ),
          block_field(
            block_field_label("class", `for` = "showcase_table_doc_class"),
            block_checkbox(
              "showcase_table_doc_class",
              "Use custom dashed-border class",
              value = FALSE
            )
          )
        )
      ),
      htmltools::div(
        class = "showcase-playground__main",
        style = "flex: 2; min-width: 320px; display: flex; flex-direction: column; gap: 1.25rem;",
        htmltools::tags$div(
          style = "display: flex; flex-direction: column; gap: 0.5rem;",
          htmltools::tags$div(
            style = "font-size: 0.875rem; font-weight: 600; color: var(--foreground);",
            "Preview"
          ),
          htmltools::tags$div(
            style = paste(
              "position: relative; padding: 1.5rem; background: var(--card);",
              "border: 1px dashed var(--border); border-radius: 0.75rem;",
              "min-height: 260px; box-sizing: border-box; overflow-x: auto;"
            ),
            uiOutput("showcase_table_preview_ui")
          )
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("showcase_table_preview_code")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    dataset <- input$showcase_table_doc_dataset %||% "metrics"
    align <- input$showcase_table_doc_align %||% "right"
    max_rows_value <- input$showcase_table_doc_max_rows %||% "all"
    caption <- input$showcase_table_doc_caption %||% ""
    style <- input$showcase_table_doc_style %||% ""

    list(
      dataset = dataset,
      align = align,
      max_rows_value = max_rows_value,
      max_rows = if (identical(max_rows_value, "all")) NULL else as.integer(max_rows_value),
      caption = if (nzchar(caption)) caption else NULL,
      style = if (nzchar(style)) style else NULL,
      class = if (isTRUE(input$showcase_table_doc_class)) "showcase-table-preview-custom" else NULL
    )
  })

  output$showcase_table_preview_ui <- renderUI({
    args <- preview_args()
    block_table(
      table_demo_data(args$dataset),
      columns = table_demo_columns(args$dataset, args$align),
      caption = args$caption,
      max_rows = args$max_rows,
      class = args$class,
      style = args$style
    )
  })
  outputOptions(output, "showcase_table_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_table_preview_code <- showcase_render_code({
    args <- preview_args()
    data_expr <- switch(
      args$dataset,
      releases = 'data.frame(package = c("shinyblocks", "runtime", "docs-site", "showcase"), status = c("ready", "review", "queued", "ready"), owner = c("UI", "Runtime", "Docs", "QA"))',
      empty = 'data.frame(metric = character(), value = numeric(), delta = character())',
      'data.frame(metric = c("Revenue", "Orders", "Conversion", "Refunds"), value = c(42000, 128, 0.048, NA), delta = c("+12%", "+8%", "+0.6 pts", NA))'
    )
    columns_expr <- if (identical(args$dataset, "releases")) {
      paste0(
        "list(\n",
        "    status = table_column(label = \"Status\", align = \"", args$align, "\"),\n",
        "    owner = table_column(label = \"Owner\")\n",
        "  )"
      )
    } else {
      paste0(
        "list(\n",
        "    metric = table_column(label = \"Metric\"),\n",
        "    value = table_column(label = \"Value\", align = \"", args$align, "\"),\n",
        "    delta = table_column(label = \"Delta\", align = \"", args$align, "\")\n",
        "  )"
      )
    }

    code_args <- c(
      paste0("data = ", data_expr),
      paste0("columns = ", columns_expr)
    )
    if (!is.null(args$caption)) {
      code_args <- c(code_args, paste0("caption = ", string_literal(args$caption)))
    }
    if (!is.null(args$max_rows)) {
      code_args <- c(code_args, paste0("max_rows = ", args$max_rows))
    }
    if (!is.null(args$class)) {
      code_args <- c(code_args, paste0("class = ", string_literal(args$class)))
    }
    if (!is.null(args$style)) {
      code_args <- c(code_args, paste0("style = ", string_literal(args$style)))
    }

    paste0("block_table(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "showcase_table_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
