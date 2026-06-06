showcase_table_data <- function() {
  data.frame(
    metric = c("Revenue", "Orders", "Refunds", "Forecast"),
    value = c(42000, 128, -1500, NA),
    delta = c("+12%", "+8%", "-3%", NA),
    stringsAsFactors = FALSE
  )
}

# Theme-safe styling demo: color a value by sign (negative -> destructive,
# positive -> success). cell_intent is a vectorized callback over the whole
# `value` column; emphasis stays the default "text" (colored numbers).
showcase_table_value_intent <- function() {
  function(v) ifelse(is.na(v), NA, ifelse(v < 0, "destructive", "success"))
}

showcase_table_columns <- function(align, styling = list()) {
  cell_intent <- if (isTRUE(styling$cell)) showcase_table_value_intent() else NULL
  # Two ways to give the header a filled background:
  #  1. Built-in intent (theme-safe, no CSS needed): header_intent + emphasis "solid".
  #  2. Escape hatch: a custom class (.showcase-table-head-accent in showcase.css).
  header_intent <- if (isTRUE(styling$header_intent)) "primary" else NULL
  header_emphasis <- if (isTRUE(styling$header_intent)) "solid" else "text"
  header_class <- if (isTRUE(styling$header_class)) "showcase-table-head-accent" else NULL

  list(
    metric = table_column(label = "Metric"),
    value = table_column(
      label = "Value",
      align = align,
      header_intent = header_intent,
      header_emphasis = header_emphasis,
      header_class = header_class,
      cell_intent = cell_intent
    ),
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

  # Shows the update_block_table() call behind the most recent server action,
  # mirroring the select playground's "Server Action" panel.
  reactive_code <- shiny::reactiveVal(paste0(
    "# Click a server action button to see\n",
    "# the update_block_table() code here."
  ))

  reactive_action <- function(arg_line) {
    paste0(
      "update_block_table(\n",
      "  session = session,\n",
      "  id = \"showcase_table_live\",\n",
      "  ", arg_line, "\n",
      ")"
    )
  }

  shiny::observeEvent(input$showcase_table_act_loading, {
    rv_loading(!rv_loading())
    reactive_code(reactive_action(paste0("loading = ", if (rv_loading()) "TRUE" else "FALSE")))
  }, ignoreInit = TRUE)
  shiny::observeEvent(input$showcase_table_act_filter, {
    rv_filtered(!rv_filtered())
    reactive_code(reactive_action(
      if (rv_filtered()) "data = head(latest_data(), 2)" else "data = latest_data()"
    ))
  }, ignoreInit = TRUE)
  shiny::observeEvent(input$showcase_table_act_striped, {
    rv_striped(!rv_striped())
    reactive_code(reactive_action(paste0(
      "data = latest_data(),\n  striped = ", if (rv_striped()) "TRUE" else "FALSE"
    )))
  }, ignoreInit = TRUE)
  shiny::observeEvent(input$showcase_table_act_bordered, {
    rv_bordered(!rv_bordered())
    reactive_code(reactive_action(paste0(
      "data = latest_data(),\n  bordered = ", if (rv_bordered()) "TRUE" else "FALSE"
    )))
  }, ignoreInit = TRUE)

  # Receive-only (output-style) table: the runtime binding forwards payloads to
  # the DOM but exposes no input value, so input$showcase_table_live is NULL.
  output$showcase_table_preview_value <- showcase_render_code({
    value <- input$showcase_table_live
    val_str <- if (is.null(value)) "<NULL>" else paste0('"', value, '"')
    paste0(
      "input$showcase_table_live = ", val_str, "\n",
      "# Tables are receive-only; they render server\n",
      "# pushes but report no input value."
    )
  })
  shiny::outputOptions(
    output,
    "showcase_table_preview_value",
    suspendWhenHidden = FALSE
  )

  output$showcase_table_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(
    output,
    "showcase_table_reactive_code",
    suspendWhenHidden = FALSE
  )

  # Single source of truth for the data + formatting payload. Drives both the
  # one-time mount (block_table) and every server push (update_block_table), so
  # the playground dogfoods the same pipeline an app author would use.
  table_spec <- shiny::reactive({
    align <- input$showcase_table_doc_align %||% "right"
    max_rows_value <- input$showcase_table_doc_max_rows %||% "all"
    digits_value <- input$showcase_table_doc_digits %||% "default"
    caption <- input$showcase_table_doc_caption %||% ""

    data <- showcase_table_data()
    if (isTRUE(rv_filtered())) {
      data <- utils::head(data, 2)
    }

    styling <- list(
      cell = isTRUE(input$showcase_table_doc_cellintent),
      header_intent = isTRUE(input$showcase_table_doc_headerintent),
      header_class = isTRUE(input$showcase_table_doc_headerclass)
    )

    list(
      data = data,
      columns = showcase_table_columns(align, styling),
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

    # Table-level classes are mount-time only; combine the toggles that target the
    # whole table (custom border, whole header row, tinted background).
    classes <- c(
      if (isTRUE(input$showcase_table_doc_class)) "showcase-table-preview-custom",
      if (isTRUE(input$showcase_table_doc_headrow)) "showcase-table-headrow",
      if (isTRUE(input$showcase_table_doc_tablebg)) "showcase-table-tinted"
    )

    # `loading` is an update_block_table()-only arg; block_table() does not take
    # it. The reactive observe below re-applies the loading state after mount.
    mount_spec <- shiny::isolate(table_spec())
    mount_spec$loading <- NULL

    do.call(
      block_table,
      c(
        list(
          id = "showcase_table_live",
          class = if (length(classes)) paste(classes, collapse = " ") else NULL,
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

    align <- input$showcase_table_doc_align %||% "right"
    max_rows_value <- input$showcase_table_doc_max_rows %||% "all"
    digits_value <- input$showcase_table_doc_digits %||% "default"
    caption <- input$showcase_table_doc_caption %||% ""
    na_value <- input$showcase_table_doc_na %||% ""
    use_rownames <- isTRUE(input$showcase_table_doc_rownames)
    use_rowformat <- isTRUE(input$showcase_table_doc_rowformat)
    style <- input$showcase_table_doc_style %||% ""
    use_class <- isTRUE(input$showcase_table_doc_class)
    use_cellintent <- isTRUE(input$showcase_table_doc_cellintent)
    use_headerintent <- isTRUE(input$showcase_table_doc_headerintent)
    use_headerclass <- isTRUE(input$showcase_table_doc_headerclass)
    use_headrow <- isTRUE(input$showcase_table_doc_headrow)
    use_tablebg <- isTRUE(input$showcase_table_doc_tablebg)

    data_expr <- 'data.frame(metric = c("Revenue", "Orders", "Refunds", "Forecast"), value = c(42000, 128, -1500, NA), delta = c("+12%", "+8%", "-3%", NA))'

    header_arg <- paste0(
      if (use_headerintent) ", header_intent = \"primary\", header_emphasis = \"solid\"" else "",
      if (use_headerclass) ", header_class = \"showcase-table-head-accent\"" else ""
    )
    cell_arg <- if (use_cellintent) {
      ",\n      cell_intent = function(v) ifelse(is.na(v), NA, ifelse(v < 0, \"destructive\", \"success\"))"
    } else {
      ""
    }

    columns_expr <- paste0(
      "list(\n",
      "    metric = table_column(label = \"Metric\"),\n",
      "    value = table_column(label = \"Value\", align = \"", align, "\"",
      header_arg, cell_arg, "),\n",
      "    delta = table_column(label = \"Delta\", align = \"", align, "\")\n",
      "  )"
    )

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
    table_classes <- c(
      if (use_class) "showcase-table-preview-custom",
      if (use_headrow) "showcase-table-headrow",
      if (use_tablebg) "showcase-table-tinted"
    )
    if (length(table_classes)) {
      args <- c(args, paste0("class = ", string_literal(paste(table_classes, collapse = " "))))
    }
    if (nzchar(style)) {
      args <- c(args, paste0("style = ", string_literal(style)))
    }

    # The class-based options (header_class / whole header row / table tint) are
    # escape hatches: the class only does something if the app also ships matching
    # CSS, so emit that CSS alongside the snippet.
    css_rules <- c(
      if (use_headerclass) paste0(
        "  .sb-table-head.showcase-table-head-accent {\n",
        "    background-color: color-mix(in oklch, var(--primary) 14%, transparent);\n",
        "    color: var(--primary); text-transform: uppercase;\n",
        "    letter-spacing: 0.08em; border-bottom: 2px solid var(--primary);\n",
        "  }"
      ),
      if (use_headrow) paste0(
        "  .showcase-table-headrow .sb-table-head {\n",
        "    background-color: var(--primary); color: var(--primary-foreground);\n",
        "  }"
      ),
      if (use_tablebg) paste0(
        "  .showcase-table-tinted .sb-table-element {\n",
        "    background-color: color-mix(in oklch, var(--primary) 8%, var(--card));\n",
        "  }"
      )
    )
    css_block <- if (length(css_rules)) {
      paste0(
        "# These classes need matching CSS in your app (any rule works):\n",
        "tags$style(HTML('\n",
        paste(css_rules, collapse = "\n"),
        "\n'))\n\n"
      )
    } else {
      ""
    }

    paste0(
      css_block,
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
        "table_column(width)", "table_column(intent)", "table_column(emphasis)",
        "table_column(class / style)", "table_column(header_intent)",
        "table_column(header_emphasis)", "table_column(header_class / header_style)",
        "table_column(cell_intent)", "table_column(cell_emphasis)",
        "table_column(cell_class / cell_style)"
      ),
      Type = c(
        "data.frame", "named list", "character", "integer", "character",
        "integer", "logical", "function", "logical", "logical", "logical",
        "character", "character", "character | named list", "function",
        "character", "character", "function", "integer", "character", "character",
        "character", "character", "character | named list", "character",
        "character", "character | named list", "function", "function", "function"
      ),
      Default = c(
        "required", "NULL", "NULL", "NULL", "\"\"", "NULL", "FALSE", "NULL",
        "FALSE", "TRUE", "FALSE", "NULL", "NULL", "NULL", "-", "NULL",
        "\"left\"", "NULL", "NULL", "NULL", "NULL", "NULL", "\"text\"", "NULL",
        "NULL", "\"text\"", "NULL", "NULL", "NULL", "NULL"
      ),
      Description = c(
        "Data frame or tibble to render. Cell values are formatted in R before runtime rendering.",
        "Optional named list of table_column() overrides. Names must match data columns.",
        "Optional caption rendered below the table.",
        "Optional non-negative row limit. Truncated tables render a footer note.",
        "String used to render missing values. Per-column overrides win.",
        "Decimal places for default numeric formatting. NULL keeps R's format().",
        "Render row.names(data) as a leading column.",
        "function(row, i) returning list(intent=, class=, style=) applied to that row's <tr>.",
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
        "Optional CSS width for the column.",
        "Token-backed styling intent for every cell in the column: muted, primary, secondary, destructive, success, warning, or accent. Theme-safe.",
        "How an intent renders: text (colored text), soft (tint), or solid (chip).",
        "Escape hatch: class / inline style on each <td>. You own theme-correctness.",
        "Styling intent applied to the column's <th> header cell.",
        "Emphasis for header_intent: text, soft, or solid.",
        "Escape-hatch class / style applied to the column's <th>.",
        "function(value) over the column vector returning a per-row intent (NA for none). Wins over the column intent.",
        "function(value) returning a per-row emphasis value.",
        "function(value) returning per-row class / style escape-hatch values."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_table_api_table",
    suspendWhenHidden = FALSE
  )
}
