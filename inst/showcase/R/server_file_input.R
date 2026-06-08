register_file_input_showcase <- function(input, output, session) {
  file_input_args <- shiny::reactive({
    accept_value <- input$showcase_file_input_doc_accept %||% ".csv,text/csv"
    accept <- trimws(strsplit(accept_value, ",", fixed = TRUE)[[1]])
    accept <- accept[nzchar(accept)]
    if (!length(accept)) accept <- NULL

    style_val <- input$showcase_file_input_doc_style %||% ""
    if (!nzchar(style_val)) style_val <- NULL

    class_val <- if (isTRUE(input$showcase_file_input_doc_class)) {
      "border-dashed"
    } else {
      NULL
    }

    list(
      button_label = input$showcase_file_input_doc_button_label %||% "Browse",
      placeholder = input$showcase_file_input_doc_placeholder %||% "No file selected",
      accept = accept,
      multiple = isTRUE(input$showcase_file_input_doc_multiple),
      width = input$showcase_file_input_doc_width %||% "100%",
      disabled = isTRUE(input$showcase_file_input_doc_disabled),
      invalid = isTRUE(input$showcase_file_input_doc_invalid),
      style = style_val,
      class = class_val
    )
  })

  output$showcase_file_input_preview_ui <- shiny::renderUI({
    args <- file_input_args()

    block_field(
      block_field_label("Upload data", `for` = "showcase_file_input_preview"),
      block_file_input(
        "showcase_file_input_preview",
        multiple = args$multiple,
        accept = args$accept,
        button_label = args$button_label,
        placeholder = args$placeholder,
        width = args$width,
        disabled = args$disabled,
        invalid = args$invalid,
        style = args$style,
        class = args$class
      ),
      block_field_description("Server value uses Shiny's native fileInput() data frame.")
    )
  })
  shiny::outputOptions(output, "showcase_file_input_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_file_input_preview_value <- showcase_render_code({
    value <- input$showcase_file_input_preview
    if (is.null(value)) {
      "input$showcase_file_input_preview = <NULL>"
    } else {
      paste(c(
        "input$showcase_file_input_preview =",
        capture.output(print(value[, c("name", "size", "type", "datapath")], row.names = FALSE))
      ), collapse = "\n")
    }
  })
  shiny::outputOptions(output, "showcase_file_input_preview_value", suspendWhenHidden = FALSE)

  output$showcase_file_input_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }
    args <- file_input_args()
    code_args <- c('input_id = "showcase_file_input_preview"')
    if (args$multiple) code_args <- c(code_args, "multiple = TRUE")
    if (!is.null(args$accept)) {
      quoted <- paste(vapply(args$accept, string_literal, character(1)), collapse = ", ")
      code_args <- c(code_args, paste0("accept = c(", quoted, ")"))
    }
    if (!identical(args$button_label, "Browse")) {
      code_args <- c(code_args, paste0("button_label = ", string_literal(args$button_label)))
    }
    if (!identical(args$placeholder, "No file selected")) {
      code_args <- c(code_args, paste0("placeholder = ", string_literal(args$placeholder)))
    }
    if (!is.null(args$width) && nzchar(args$width) && !identical(args$width, "100%")) {
      code_args <- c(code_args, paste0("width = ", string_literal(args$width)))
    }
    if (args$disabled) code_args <- c(code_args, "disabled = TRUE")
    if (args$invalid) code_args <- c(code_args, "invalid = TRUE")
    if (!is.null(args$style)) code_args <- c(code_args, paste0("style = ", string_literal(args$style)))
    if (!is.null(args$class)) code_args <- c(code_args, paste0("class = ", string_literal(args$class)))

    paste0("block_file_input(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(output, "showcase_file_input_preview_code", suspendWhenHidden = FALSE)

  output$showcase_file_input_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("input_id", "multiple", "accept", "button_label", "placeholder", "width", "disabled", "invalid", "style", "class"),
      Type = c("character", "logical", "character", "character", "character", "character", "logical", "logical", "character | list", "character"),
      Default = c("required", "FALSE", "NULL", "\"Browse\"", "\"No file selected\"", "NULL", "FALSE", "FALSE", "NULL", "NULL"),
      Description = c(
        "Input id for the native Shiny file upload value.",
        "Allow selecting more than one file.",
        "Accepted MIME types or extensions, comma-joined for the native accept attribute.",
        "Text rendered inside the visible picker button.",
        "Text shown before a file is selected.",
        "Optional CSS width applied to the wrapper.",
        "Disables the visible picker and native file input.",
        "Sets aria-invalid='true' to surface destructive styling.",
        "Inline CSS styles applied to the visible control.",
        "Additional class merged onto the visible control."
      )
    ))
  })
  shiny::outputOptions(output, "showcase_file_input_api_table", suspendWhenHidden = FALSE)

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_file_input() code here."
  ))

  output$showcase_file_input_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(output, "showcase_file_input_reactive_code", suspendWhenHidden = FALSE)

  shiny::observeEvent(input$showcase_file_input_relabel, {
    update_block_file_input(session, "showcase_file_input_preview", button_label = "Pick a file")
    reactive_code(paste0(
      "update_block_file_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_file_input_preview\",\n",
      "  button_label = \"Pick a file\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_file_input_disable, {
    update_block_file_input(session, "showcase_file_input_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_file_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_file_input_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_file_input_enable, {
    update_block_file_input(session, "showcase_file_input_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_file_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_file_input_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_file_input_mark_invalid, {
    update_block_file_input(session, "showcase_file_input_preview", invalid = TRUE)
    reactive_code(paste0(
      "update_block_file_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_file_input_preview\",\n",
      "  invalid = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_file_input_clear_invalid, {
    update_block_file_input(session, "showcase_file_input_preview", invalid = FALSE)
    reactive_code(paste0(
      "update_block_file_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_file_input_preview\",\n",
      "  invalid = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_file_input_reset, {
    update_block_file_input(session, "showcase_file_input_preview", reset = TRUE)
    reactive_code(paste0(
      "update_block_file_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_file_input_preview\",\n",
      "  reset = TRUE\n",
      ")"
    ))
  })
}
