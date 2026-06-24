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

table_demo_data <- function() {
  data.frame(
    metric = c("Revenue", "Orders", "Refunds", "Forecast"),
    value = c(42000, 128, -1500, NA),
    delta = c("+12%", "+8%", "-3%", NA),
    stringsAsFactors = FALSE
  )
}

table_demo_columns <- function(align, styling = list()) {
  cell_intent <- if (isTRUE(styling$cell)) {
    function(v) ifelse(is.na(v), NA, ifelse(v < 0, "destructive", "success"))
  } else {
    NULL
  }
  # Two ways to give the header a filled background:
  #  1. Built-in intent (theme-safe, no CSS needed): header_intent + emphasis "solid".
  #  2. Escape hatch: a custom class (.showcase-table-head-accent, injected in the
  #     block_page theme <style>). Token-driven so it still tracks the theme.
  header_intent <- if (isTRUE(styling$header_intent)) "primary" else NULL
  header_emphasis <- if (isTRUE(styling$header_intent)) "solid" else "text"
  header_class <- if (isTRUE(styling$header_class)) "showcase-table-head-accent" else NULL

  list(
    metric = table_column(label = "Metric"),
    value = table_column(
      label = "Value",
      align = align,
      format = function(value) format(value, big.mark = ",", trim = TRUE),
      header_intent = header_intent,
      header_emphasis = header_emphasis,
      header_class = header_class,
      cell_intent = cell_intent
    ),
    delta = table_column(label = "Delta", align = align)
  )
}

ui <- block_page(
  title = "shinyblocks - Table playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    # Custom header background used by table_column(header_class = ). Token-driven
    # so it still tracks the active theme even though it is an escape hatch.
    htmltools::tags$style(htmltools::HTML(paste(
      ".sb-table-head.showcase-table-head-accent { background-color: color-mix(in oklch, var(--primary) 14%, transparent); color: var(--primary) !important; text-transform: uppercase; letter-spacing: 0.08em; border-bottom: 2px solid var(--primary); }",
      ".showcase-table-headrow .sb-table-head { background-color: var(--primary); color: var(--primary-foreground) !important; }",
      ".showcase-table-tinted .sb-table-element { background-color: color-mix(in oklch, var(--primary) 8%, var(--card)); }",
      sep = "\n"
    )))
  ),
  htmltools::tags$div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      class = "showcase-playground",
    block_cluster(
      gap = "lg",
      align = "start",
      class = "showcase-playground__split",
      block_card(
        title = "Controls",
        class = "showcase-playground__controls",
        block_stack(
          gap = "sm",
          class = "showcase-controls-group showcase-controls-group--first",
          htmltools::tags$h4(
            class = "showcase-controls-group__title",
            "Content"
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
        block_stack(
          gap = "sm",
          class = "showcase-controls-group",
          htmltools::tags$h4(
            class = "showcase-controls-group__title",
            "State"
          ),
          block_field(
            block_field_label("selection", `for` = "showcase_table_doc_selection"),
            block_select(
              "showcase_table_doc_selection",
              choices = c("none", "single", "multiple"),
              selected = "none",
              size = "sm"
            )
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
        block_stack(
          gap = "sm",
          class = "showcase-controls-group",
          htmltools::tags$h4(
            class = "showcase-controls-group__title",
            "Styling"
          ),
          block_field(
            block_checkbox(
              "showcase_table_doc_cellintent",
              "Color values by sign",
              value = FALSE
            )
          ),
          block_field(
            block_checkbox(
              "showcase_table_doc_headerintent",
              "Header background via intent",
              value = FALSE
            )
          ),
          block_field(
            block_checkbox(
              "showcase_table_doc_headerclass",
              "Header background via custom class",
              value = FALSE
            )
          ),
          block_field(
            block_checkbox(
              "showcase_table_doc_headrow",
              "Background on the whole header row",
              value = FALSE
            )
          ),
          block_field(
            block_checkbox(
              "showcase_table_doc_tablebg",
              "Tint the table background",
              value = FALSE
            )
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
        ),
        block_stack(
          gap = "sm",
          class = "showcase-controls-group",
          htmltools::tags$h4(
            class = "showcase-controls-group__title",
            "Server actions"
          ),
          block_button(
            "Toggle loading",
            id = "showcase_table_act_loading",
            variant = "outline",
            size = "sm"
          )
        )
      ),
      block_stack(
        gap = "lg",
        class = "showcase-playground__main",
        block_stack(
          gap = "sm",
          htmltools::tags$div(
            class = "showcase-playground__label",
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
        uiOutput("showcase_table_preview_value"),
        htmltools::tags$div(
          htmltools::tags$div(
            class = "showcase-playground__label showcase-playground__label--code",
            "Server Action"
          ),
          uiOutput("showcase_table_reactive_code")
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            class = "showcase-playground__label showcase-playground__label--code",
            "UI Definition"
          ),
          uiOutput("showcase_table_preview_code")
        )
      )
    )
  )
  )
)

server <- function(input, output, session) {
  rv_loading <- reactiveVal(FALSE)
  reactive_code <- reactiveVal(paste0(
    "# Click a server action button to see\n",
    "# the update_block_table() code here."
  ))

  observeEvent(input$showcase_table_act_loading, {
    rv_loading(!rv_loading())
    reactive_code(paste0(
      "update_block_table(\n",
      "  session = session,\n",
      "  id = \"showcase_table_live\",\n",
      "  loading = ", if (rv_loading()) "TRUE" else "FALSE", "\n",
      ")"
    ))
  }, ignoreInit = TRUE)

  output$showcase_table_preview_value <- showcase_render_code({
    fmt <- function(v) {
      if (is.null(v) || length(v) == 0) {
        return("integer(0)")
      }
      paste0("c(", paste(v, collapse = ", "), ")")
    }
    selection <- input$showcase_table_doc_selection %||% "none"
    if (identical(selection, "none")) {
      return(paste0(
        "input$showcase_table_live = <NULL>\n",
        "# selection = \"none\": the table is receive-only\n",
        "# and reports no input value. Switch selection\n",
        "# to \"single\" or \"multiple\" to make it reactive."
      ))
    }
    cell <- input$showcase_table_live_cell_clicked
    cell_str <- if (is.null(cell)) {
      "NULL"
    } else {
      sprintf("list(row = %s, col = %s, value = \"%s\")", cell$row, cell$col, cell$value)
    }
    paste0(
      "input$showcase_table_live = ", fmt(input$showcase_table_live), "\n",
      "input$showcase_table_live_rows_selected = ", fmt(input$showcase_table_live_rows_selected), "\n",
      "input$showcase_table_live_row_last_clicked = ",
      input$showcase_table_live_row_last_clicked %||% "NULL", "\n",
      "input$showcase_table_live_cell_clicked = ", cell_str
    )
  })
  outputOptions(output, "showcase_table_preview_value", suspendWhenHidden = FALSE)

  output$showcase_table_reactive_code <- showcase_render_code({
    reactive_code()
  })
  outputOptions(output, "showcase_table_reactive_code", suspendWhenHidden = FALSE)

  # Shared data + formatting spec. Feeds both the one-time block_table() mount
  # and every update_block_table() push, so the playground dogfoods the reactive
  # refresh path an app author would use.
  table_spec <- reactive({
    align <- input$showcase_table_doc_align %||% "right"
    max_rows_value <- input$showcase_table_doc_max_rows %||% "all"
    caption <- input$showcase_table_doc_caption %||% ""

    styling <- list(
      cell = isTRUE(input$showcase_table_doc_cellintent),
      header_intent = isTRUE(input$showcase_table_doc_headerintent),
      header_class = isTRUE(input$showcase_table_doc_headerclass)
    )

    list(
      data = table_demo_data(),
      columns = table_demo_columns(align, styling),
      caption = if (nzchar(caption)) caption else NULL,
      max_rows = if (identical(max_rows_value, "all")) NULL else as.integer(max_rows_value),
      selection = input$showcase_table_doc_selection %||% "none",
      loading = isTRUE(rv_loading())
    )
  })

  # class/style are mount-time only and cannot be pushed by update_block_table(),
  # so a change to them remounts the table; everything else updates in place.
  output$showcase_table_preview_ui <- renderUI({
    style <- input$showcase_table_doc_style %||% ""

    classes <- c(
      if (isTRUE(input$showcase_table_doc_class)) "showcase-table-preview-custom",
      if (isTRUE(input$showcase_table_doc_headrow)) "showcase-table-headrow",
      if (isTRUE(input$showcase_table_doc_tablebg)) "showcase-table-tinted"
    )

    mount_spec <- isolate(table_spec())
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
  outputOptions(output, "showcase_table_preview_ui", suspendWhenHidden = FALSE)

  observe({
    do.call(
      update_block_table,
      c(list(session = session, id = "showcase_table_live"), table_spec())
    )
  })

  output$showcase_table_preview_code <- showcase_render_code({
    align <- input$showcase_table_doc_align %||% "right"
    max_rows_value <- input$showcase_table_doc_max_rows %||% "all"
    selection_value <- input$showcase_table_doc_selection %||% "none"
    caption <- input$showcase_table_doc_caption %||% ""
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

    code_args <- c(
      'id = "tbl"',
      paste0("data = ", data_expr),
      paste0("columns = ", columns_expr)
    )
    if (nzchar(caption)) {
      code_args <- c(code_args, paste0("caption = ", string_literal(caption)))
    }
    if (!identical(max_rows_value, "all")) {
      code_args <- c(code_args, paste0("max_rows = ", max_rows_value))
    }
    if (!identical(selection_value, "none")) {
      code_args <- c(code_args, paste0("selection = ", string_literal(selection_value)))
    }
    table_classes <- c(
      if (use_class) "showcase-table-preview-custom",
      if (use_headrow) "showcase-table-headrow",
      if (use_tablebg) "showcase-table-tinted"
    )
    if (length(table_classes)) {
      code_args <- c(code_args, paste0("class = ", string_literal(paste(table_classes, collapse = " "))))
    }
    if (nzchar(style)) {
      code_args <- c(code_args, paste0("style = ", string_literal(style)))
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
      "block_table(\n  ", paste(code_args, collapse = ",\n  "), "\n)\n\n",
      "# Refresh reactively from the server:\n",
      "observeEvent(input$reload, {\n",
      "  update_block_table(session, \"tbl\", data = latest_data(), loading = FALSE)\n",
      "})"
    )
  })
  outputOptions(output, "showcase_table_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
