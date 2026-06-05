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
    value = table_column(label = "Value", align = align),
    delta = table_column(label = "Delta", align = align)
  )
}

# row_format demo: highlight rows whose numeric `value` exceeds a threshold.
showcase_table_row_format <- function() {
  function(row, i) {
    value <- row[["value"]]
    if (is.null(value) || length(value) != 1 || is.na(value) || !is.numeric(value)) {
      return(NULL)
    }
    if (value > 100) {
      return(list(style = "font-weight: 600; color: var(--primary);"))
    }
    NULL
  }
}

register_table_showcase <- function(input, output, session) {
  # Server-action state pushed through update_block_table().
  rv_loading <- shiny::reactiveVal(FALSE)
  rv_filtered <- shiny::reactiveVal(FALSE)
  rv_striped <- shiny::reactiveVal(FALSE)
  rv_bordered <- shiny::reactiveVal(FALSE)

  shiny::observeEvent(input$showcase_table_act_loading, {
    rv_loading(!rv_loading())
  }, ignoreInit = TRUE)
  shiny::observeEvent(input$showcase_table_act_filter, {
    rv_filtered(!rv_filtered())
  }, ignoreInit = TRUE)
  shiny::observeEvent(input$showcase_table_act_striped, {
    rv_striped(!rv_striped())
  }, ignoreInit = TRUE)
  shiny::observeEvent(input$showcase_table_act_bordered, {
    rv_bordered(!rv_bordered())
  }, ignoreInit = TRUE)

  # Single source of truth for the data + formatting payload. Drives both the
  # one-time mount (block_table) and every server push (update_block_table), so
  # the playground dogfoods the same pipeline an app author would use.
  table_spec <- shiny::reactive({
    dataset <- input$showcase_table_doc_dataset %||% "revenue"
    align <- input$showcase_table_doc_align %||% "right"
    max_rows_value <- input$showcase_table_doc_max_rows %||% "all"
    digits_value <- input$showcase_table_doc_digits %||% "default"
    caption <- input$showcase_table_doc_caption %||% ""

    data <- showcase_table_data(dataset)
    if (isTRUE(rv_filtered())) {
      data <- utils::head(data, 2)
    }

    list(
      data = data,
      columns = showcase_table_columns(dataset, align),
      caption = if (nzchar(caption)) caption else NULL,
      max_rows = if (identical(max_rows_value, "all")) NULL else as.integer(max_rows_value),
      na = input$showcase_table_doc_na %||% "",
      digits = if (identical(digits_value, "default")) NULL else as.integer(digits_value),
      rownames = isTRUE(input$showcase_table_doc_rownames),
      row_format = if (isTRUE(input$showcase_table_doc_rowformat)) showcase_table_row_format() else NULL,
      striped = isTRUE(rv_striped()),
      bordered = isTRUE(rv_bordered()),
      loading = isTRUE(rv_loading())
    )
  })

  # Mount-time-only props (class/style) cannot be pushed by update_block_table(),
  # so a change to them remounts the table; everything else updates in place.
  output$showcase_table_preview_ui <- shiny::renderUI({
    style <- input$showcase_table_doc_style %||% ""
    use_class <- isTRUE(input$showcase_table_doc_class)

    # `loading` is an update_block_table()-only arg; block_table() does not take
    # it. The reactive observe below re-applies the loading state after mount.
    mount_spec <- shiny::isolate(table_spec())
    mount_spec$loading <- NULL

    do.call(
      block_table,
      c(
        list(
          id = "showcase_table_live",
          class = if (use_class) "showcase-table-preview-custom" else NULL,
          style = if (nzchar(style)) style else NULL
        ),
        mount_spec
      )
    )
  })
  shiny::outputOptions(
    output,
    "showcase_table_preview_ui",
    suspendWhenHidden = FALSE
  )

  # Reactive refresh: push a fresh payload whenever the data/formatting spec
  # changes. The mount above is created once; this keeps it in sync.
  shiny::observe({
    do.call(
      update_block_table,
      c(list(session = session, id = "showcase_table_live"), table_spec())
    )
  })

  output$showcase_table_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    dataset <- input$showcase_table_doc_dataset %||% "revenue"
    align <- input$showcase_table_doc_align %||% "right"
    max_rows_value <- input$showcase_table_doc_max_rows %||% "all"
    digits_value <- input$showcase_table_doc_digits %||% "default"
    caption <- input$showcase_table_doc_caption %||% ""
    na_value <- input$showcase_table_doc_na %||% ""
    use_rownames <- isTRUE(input$showcase_table_doc_rownames)
    use_rowformat <- isTRUE(input$showcase_table_doc_rowformat)
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
        "    value = table_column(label = \"Value\", align = \"", align, "\"),\n",
        "    delta = table_column(label = \"Delta\", align = \"", align, "\")\n",
        "  )"
      )
    }

    args <- c(
      'id = "tbl"',
      paste0("data = ", data_expr),
      paste0("columns = ", columns_expr)
    )
    if (nzchar(caption)) {
      args <- c(args, paste0("caption = ", string_literal(caption)))
    }
    if (!identical(max_rows_value, "all")) {
      args <- c(args, paste0("max_rows = ", max_rows_value))
    }
    if (nzchar(na_value)) {
      args <- c(args, paste0("na = ", string_literal(na_value)))
    }
    if (!identical(digits_value, "default")) {
      args <- c(args, paste0("digits = ", digits_value))
    }
    if (use_rownames) {
      args <- c(args, "rownames = TRUE")
    }
    if (use_rowformat) {
      args <- c(
        args,
        "row_format = function(row, i) if (is.numeric(row$value) && !is.na(row$value) && row$value > 100) list(style = \"font-weight: 600; color: var(--primary);\")"
      )
    }
    if (use_class) {
      args <- c(args, 'class = "showcase-table-preview-custom"')
    }
    if (nzchar(style)) {
      args <- c(args, paste0("style = ", string_literal(style)))
    }

    paste0(
      "block_table(\n  ", paste(args, collapse = ",\n  "), "\n)\n\n",
      "# Push a reactive refresh from the server:\n",
      "observeEvent(input$reload, {\n",
      "  update_block_table(session, \"tbl\", data = latest_data(), loading = FALSE)\n",
      "})"
    )
  })
  shiny::outputOptions(
    output,
    "showcase_table_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_table_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c(
        "data", "columns", "caption", "max_rows", "na", "digits", "rownames",
        "row_format", "striped", "hover", "bordered", "id", "class", "style",
        "update_block_table()", "table_column(label)", "table_column(align)",
        "table_column(format)", "table_column(digits)", "table_column(na)",
        "table_column(width)"
      ),
      Type = c(
        "data.frame", "named list", "character", "integer", "character",
        "integer", "logical", "function", "logical", "logical", "logical",
        "character", "character", "character | named list", "function",
        "character", "character", "function", "integer", "character", "character"
      ),
      Default = c(
        "required", "NULL", "NULL", "NULL", "\"\"", "NULL", "FALSE", "NULL",
        "FALSE", "TRUE", "FALSE", "NULL", "NULL", "NULL", "-", "NULL",
        "\"left\"", "NULL", "NULL", "NULL", "NULL"
      ),
      Description = c(
        "Data frame or tibble to render. Cell values are formatted in R before runtime rendering.",
        "Optional named list of table_column() overrides. Names must match data columns.",
        "Optional caption rendered below the table.",
        "Optional non-negative row limit. Truncated tables render a footer note.",
        "String used to render missing values. Per-column overrides win.",
        "Decimal places for default numeric formatting. NULL keeps R's format().",
        "Render row.names(data) as a leading column.",
        "function(row, i) returning list(class=, style=) applied to that row's <tr>.",
        "Zebra-stripe body rows.",
        "Highlight rows on hover (shadcn base behavior).",
        "Draw cell borders.",
        "Optional input id. Required only to update the table from the server.",
        "Additional CSS class merged into the runtime table container.",
        "Optional inline styles applied to the runtime mount and table container.",
        "Re-render an id-bound table from the server with a freshly formatted payload.",
        "Optional display label for a column header.",
        "Column text alignment. One of left, center, or right.",
        "Optional function applied to the full column vector; must return one value per row.",
        "Per-column decimal places, overriding the table-level digits.",
        "Per-column missing-value string, overriding the table-level na.",
        "Optional CSS width for the column."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_table_api_table",
    suspendWhenHidden = FALSE
  )
}
