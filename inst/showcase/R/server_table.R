showcase_table_data <- function(key) {
  switch(
    key %||% "revenue",
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

showcase_table_columns <- function(key, align) {
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

register_table_showcase <- function(input, output, session) {
  output$showcase_table_preview_ui <- shiny::renderUI({
    dataset <- input$showcase_table_doc_dataset %||% "revenue"
    align <- input$showcase_table_doc_align %||% "right"
    max_rows_value <- input$showcase_table_doc_max_rows %||% "all"
    max_rows <- if (identical(max_rows_value, "all")) NULL else as.integer(max_rows_value)
    caption <- input$showcase_table_doc_caption %||% ""
    if (!nzchar(caption)) {
      caption <- NULL
    }
    style <- input$showcase_table_doc_style %||% ""
    if (!nzchar(style)) {
      style <- NULL
    }

    block_table(
      showcase_table_data(dataset),
      columns = showcase_table_columns(dataset, align),
      caption = caption,
      max_rows = max_rows,
      class = if (isTRUE(input$showcase_table_doc_class)) "showcase-table-preview-custom" else NULL,
      style = style
    )
  })
  shiny::outputOptions(
    output,
    "showcase_table_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_table_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    dataset <- input$showcase_table_doc_dataset %||% "revenue"
    align <- input$showcase_table_doc_align %||% "right"
    max_rows_value <- input$showcase_table_doc_max_rows %||% "all"
    caption <- input$showcase_table_doc_caption %||% ""
    style <- input$showcase_table_doc_style %||% ""
    use_class <- isTRUE(input$showcase_table_doc_class)

    data_expr <- switch(
      dataset,
      releases = 'data.frame(package = c("shinyblocks", "runtime", "docs-site", "showcase"), status = c("ready", "review", "queued", "ready"), owner = c("UI", "Runtime", "Docs", "QA"))',
      empty = 'data.frame(metric = character(), value = numeric(), delta = character())',
      'data.frame(metric = c("Revenue", "Orders", "Conversion", "Refunds"), value = c(42000, 128, 0.048, NA), delta = c("+12%", "+8%", "+0.6 pts", NA))'
    )

    columns_expr <- if (identical(dataset, "releases")) {
      paste0(
        "list(\n",
        "    status = table_column(label = \"Status\", align = \"", align, "\"),\n",
        "    owner = table_column(label = \"Owner\")\n",
        "  )"
      )
    } else {
      paste0(
        "list(\n",
        "    metric = table_column(label = \"Metric\"),\n",
        "    value = table_column(\n",
        "      label = \"Value\",\n",
        "      align = \"", align, "\",\n",
        "      format = function(x) ifelse(is.na(x), NA_character_, ifelse(x < 1, sprintf(\"%.1f%%\", x * 100), format(x, big.mark = \",\", trim = TRUE)))\n",
        "    ),\n",
        "    delta = table_column(label = \"Delta\", align = \"", align, "\")\n",
        "  )"
      )
    }

    args <- c(
      paste0("data = ", data_expr),
      paste0("columns = ", columns_expr)
    )
    if (nzchar(caption)) {
      args <- c(args, paste0("caption = ", string_literal(caption)))
    }
    if (!identical(max_rows_value, "all")) {
      args <- c(args, paste0("max_rows = ", max_rows_value))
    }
    if (use_class) {
      args <- c(args, 'class = "showcase-table-preview-custom"')
    }
    if (nzchar(style)) {
      args <- c(args, paste0("style = ", string_literal(style)))
    }

    paste0("block_table(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_table_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_table_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("data", "columns", "caption", "max_rows", "class", "style", "table_column(label)", "table_column(align)", "table_column(format)", "table_column(width)"),
      Type = c("data.frame", "named list", "character", "integer", "character", "character | named list", "character", "character", "function", "character"),
      Default = c("required", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "\"left\"", "NULL", "NULL"),
      Description = c(
        "Data frame or tibble to render. Cell values are formatted in R before runtime rendering.",
        "Optional named list of table_column() overrides. Names must match data columns.",
        "Optional caption rendered below the table.",
        "Optional non-negative row limit. Truncated tables render a footer note.",
        "Additional CSS class merged into the runtime table container.",
        "Optional inline styles applied to the runtime mount and table container.",
        "Optional display label for a column header.",
        "Column text alignment. One of left, center, or right.",
        "Optional function applied to the full column vector; must return one value per row.",
        "Optional CSS width for the column."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_table_api_table",
    suspendWhenHidden = FALSE
  )
}
