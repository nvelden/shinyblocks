register_textarea_showcase <- function(input, output, session) {
  output$showcase_textarea_preview_ui <- shiny::renderUI({
    label <- input$showcase_textarea_doc_label %||% "Notes"
    if (!nzchar(label)) label <- "Notes"

    placeholder <- input$showcase_textarea_doc_placeholder %||% "Add release notes here…"
    initial_value <- input$showcase_textarea_doc_value %||% ""
    rows_text <- input$showcase_textarea_doc_rows %||% "3"
    rows_val <- suppressWarnings(as.integer(rows_text))
    if (is.na(rows_val) || rows_val < 1) rows_val <- 3L

    disabled <- isTRUE(input$showcase_textarea_doc_disabled)
    invalid <- isTRUE(input$showcase_textarea_doc_invalid)
    style_val <- input$showcase_textarea_doc_style %||% ""
    if (!nzchar(style_val)) style_val <- NULL
    class_val <- if (isTRUE(input$showcase_textarea_doc_class)) {
      "showcase-textarea-preview-custom"
    } else {
      NULL
    }

    block_field(
      block_field_label(label, `for` = "showcase_textarea_preview"),
      block_textarea(
        "showcase_textarea_preview",
        value = initial_value,
        placeholder = placeholder,
        rows = rows_val,
        disabled = disabled,
        invalid = invalid,
        style = style_val,
        class = class_val
      )
    )
  })
  shiny::outputOptions(output, "showcase_textarea_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_textarea_preview_value <- shiny::renderText({
    value <- input$showcase_textarea_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (!nzchar(value)) {
      "<EMPTY>"
    } else {
      value
    }
    paste0("input$showcase_textarea_preview = ", val_str)
  })
  shiny::outputOptions(output, "showcase_textarea_preview_value", suspendWhenHidden = FALSE)

  output$showcase_textarea_preview_code <- shiny::renderText({
    placeholder <- input$showcase_textarea_doc_placeholder %||% "Add release notes here…"
    initial_value <- input$showcase_textarea_doc_value %||% ""
    rows_text <- input$showcase_textarea_doc_rows %||% "3"
    rows_val <- suppressWarnings(as.integer(rows_text))
    if (is.na(rows_val) || rows_val < 1) rows_val <- 3L

    disabled <- isTRUE(input$showcase_textarea_doc_disabled)
    invalid <- isTRUE(input$showcase_textarea_doc_invalid)
    style_val <- input$showcase_textarea_doc_style %||% ""
    custom_class <- isTRUE(input$showcase_textarea_doc_class)

    args <- c(
      'input_id = "showcase_textarea_preview"',
      paste0('value = "', initial_value, '"'),
      paste0('placeholder = "', placeholder, '"'),
      paste0('rows = ', rows_val)
    )
    if (disabled) args <- c(args, "disabled = TRUE")
    if (invalid) args <- c(args, "invalid = TRUE")
    if (nzchar(style_val)) args <- c(args, paste0('style = "', style_val, '"'))
    if (custom_class) args <- c(args, 'class = "showcase-textarea-preview-custom"')

    paste0(
      "block_textarea(\n  ",
      paste(args, collapse = ",\n  "),
      "\n)"
    )
  })
  shiny::outputOptions(output, "showcase_textarea_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_textarea() code here."
  ))

  output$showcase_textarea_reactive_code <- shiny::renderText({
    reactive_code()
  })
  shiny::outputOptions(output, "showcase_textarea_reactive_code", suspendWhenHidden = FALSE)

  output$showcase_textarea_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("input_id", "value", "placeholder", "rows", "width", "disabled", "invalid", "style", "class"),
      Type = c("character", "character", "character", "integer", "character", "logical", "logical", "character | list", "character"),
      Default = c("required", "\"\"", "NULL", "3", "NULL", "FALSE", "FALSE", "NULL", "NULL"),
      Description = c(
        "Input id for the textarea value.",
        "Initial textarea value.",
        "Optional placeholder text shown when the textarea is empty.",
        "Number of visible rows.",
        "Optional CSS width applied to the wrapper.",
        "Disables user interaction while preserving server updates.",
        "Sets aria-invalid='true' to surface destructive styling.",
        "Inline CSS styles applied to the textarea element.",
        "Additional class merged onto the runtime textarea wrapper."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(output, "showcase_textarea_api_table", suspendWhenHidden = FALSE)

  shiny::observeEvent(input$showcase_textarea_set_value, {
    update_block_textarea(
      session,
      "showcase_textarea_preview",
      value = "Shipped! Phase 5.7 textarea runtime migration is live."
    )
    reactive_code(paste0(
      "update_block_textarea(\n",
      "  session = session,\n",
      "  input_id = \"showcase_textarea_preview\",\n",
      "  value = \"Shipped! Phase 5.7 textarea runtime migration is live.\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_textarea_clear, {
    update_block_textarea(
      session,
      "showcase_textarea_preview",
      value = "",
      rows = 3
    )
    reactive_code(paste0(
      "update_block_textarea(\n",
      "  session = session,\n",
      "  input_id = \"showcase_textarea_preview\",\n",
      "  value = \"\",\n",
      "  rows = 3\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_textarea_disable, {
    update_block_textarea(session, "showcase_textarea_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_textarea(\n",
      "  session = session,\n",
      "  input_id = \"showcase_textarea_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_textarea_enable, {
    update_block_textarea(session, "showcase_textarea_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_textarea(\n",
      "  session = session,\n",
      "  input_id = \"showcase_textarea_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_textarea_grow, {
    update_block_textarea(session, "showcase_textarea_preview", rows = 6)
    reactive_code(paste0(
      "update_block_textarea(\n",
      "  session = session,\n",
      "  input_id = \"showcase_textarea_preview\",\n",
      "  rows = 6\n",
      ")"
    ))
  })
}
