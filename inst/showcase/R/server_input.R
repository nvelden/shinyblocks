register_input_showcase <- function(input, output, session) {
  # min/max/step controls are number inputs, so they report numeric (NA while
  # empty). Only forward a real bound, and only when the preview is a number.
  number_arg <- function(value, type_val) {
    if (type_val != "number" || is.null(value) || is.na(value)) NULL else value
  }

  output$showcase_input_preview_ui <- shiny::renderUI({
    label <- input$showcase_input_doc_label %||% "Email"
    if (!nzchar(label)) label <- "Email"

    placeholder <- input$showcase_input_doc_placeholder %||% "name@example.com"
    initial_value <- input$showcase_input_doc_value %||% ""
    type_val <- input$showcase_input_doc_type %||% "text"

    disabled <- isTRUE(input$showcase_input_doc_disabled)
    invalid <- isTRUE(input$showcase_input_doc_invalid)
    style_val <- input$showcase_input_doc_style %||% ""
    if (!nzchar(style_val)) style_val <- NULL
    class_val <- if (isTRUE(input$showcase_input_doc_class)) {
      "border-dashed"
    } else {
      NULL
    }
    min_val <- number_arg(input$showcase_input_doc_min, type_val)
    max_val <- number_arg(input$showcase_input_doc_max, type_val)
    step_val <- number_arg(input$showcase_input_doc_step, type_val)
    if (!is.null(step_val) && step_val <= 0) step_val <- NULL
    if (!is.null(min_val) && !is.null(max_val) && min_val >= max_val) {
      max_val <- NULL
    }

    block_field(
      block_field_label(label, `for` = "showcase_input_preview"),
      block_input(
        "showcase_input_preview",
        value = initial_value,
        placeholder = placeholder,
        type = type_val,
        min = min_val,
        max = max_val,
        step = step_val,
        disabled = disabled,
        invalid = invalid,
        style = style_val,
        class = class_val
      )
    )
  })
  shiny::outputOptions(output, "showcase_input_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_input_preview_value <- showcase_render_code({
    value <- input$showcase_input_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (is.numeric(value)) {
      # number type reports numeric (NA while empty/unparseable)
      if (is.na(value)) "NA (numeric)" else paste0(format(value), " (numeric)")
    } else if (!nzchar(value)) {
      "<EMPTY>"
    } else {
      value
    }
    paste0("input$showcase_input_preview = ", val_str)
  })
  shiny::outputOptions(output, "showcase_input_preview_value", suspendWhenHidden = FALSE)

  output$showcase_input_preview_code <- showcase_render_code({
    placeholder <- input$showcase_input_doc_placeholder %||% "name@example.com"
    initial_value <- input$showcase_input_doc_value %||% ""
    type_val <- input$showcase_input_doc_type %||% "text"

    disabled <- isTRUE(input$showcase_input_doc_disabled)
    invalid <- isTRUE(input$showcase_input_doc_invalid)
    style_val <- input$showcase_input_doc_style %||% ""
    custom_class <- isTRUE(input$showcase_input_doc_class)

    min_val <- number_arg(input$showcase_input_doc_min, type_val)
    max_val <- number_arg(input$showcase_input_doc_max, type_val)
    step_val <- number_arg(input$showcase_input_doc_step, type_val)
    if (!is.null(step_val) && step_val <= 0) step_val <- NULL
    if (!is.null(min_val) && !is.null(max_val) && min_val >= max_val) {
      max_val <- NULL
    }

    args <- c(
      'input_id = "showcase_input_preview"',
      paste0('value = "', initial_value, '"'),
      paste0('placeholder = "', placeholder, '"'),
      paste0('type = "', type_val, '"')
    )
    if (!is.null(min_val)) args <- c(args, paste0("min = ", format(min_val)))
    if (!is.null(max_val)) args <- c(args, paste0("max = ", format(max_val)))
    if (!is.null(step_val)) args <- c(args, paste0("step = ", format(step_val)))
    if (disabled) args <- c(args, "disabled = TRUE")
    if (invalid) args <- c(args, "invalid = TRUE")
    if (nzchar(style_val)) args <- c(args, paste0('style = "', style_val, '"'))
    if (custom_class) args <- c(args, 'class = "border-dashed"')

    paste0(
      "block_input(\n  ",
      paste(args, collapse = ",\n  "),
      "\n)"
    )
  })
  shiny::outputOptions(output, "showcase_input_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_input() code here."
  ))

  output$showcase_input_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(output, "showcase_input_reactive_code", suspendWhenHidden = FALSE)

  output$showcase_input_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c(
        "input_id", "value", "placeholder", "type", "min", "max", "step",
        "width", "disabled", "invalid", "style", "class"
      ),
      Type = c(
        "character", "character", "character", "character", "numeric",
        "numeric", "numeric", "character", "logical", "logical",
        "character | list", "character"
      ),
      Default = c(
        "required", "\"\"", "NULL", "\"text\"", "NULL", "NULL", "NULL",
        "NULL", "FALSE", "FALSE", "NULL", "NULL"
      ),
      Description = c(
        "Input id for the input value. type = 'number' reports a numeric value (NA while empty); other types report a character string.",
        "Initial input value.",
        "Optional placeholder text shown when the input is empty.",
        "HTML input type — one of text, password, email, url, tel, search, or number. The number type renders stepper buttons.",
        "Optional lower bound (number type only).",
        "Optional upper bound (number type only).",
        "Optional positive step for the stepper buttons and arrow keys (number type only, browser default 1).",
        "Optional CSS width applied to the wrapper.",
        "Disables user interaction while preserving server updates.",
        "Sets aria-invalid='true' to surface destructive styling.",
        "Inline CSS styles applied to the input element.",
        "Additional class merged onto the runtime input wrapper."
      )
    ))
  })
  shiny::outputOptions(output, "showcase_input_api_table", suspendWhenHidden = FALSE)

  shiny::observeEvent(input$showcase_input_set_value, {
    update_block_input(
      session,
      "showcase_input_preview",
      value = "shipped@shinyblocks.dev"
    )
    reactive_code(paste0(
      "update_block_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_input_preview\",\n",
      "  value = \"shipped@shinyblocks.dev\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_input_clear, {
    initial_value <- input$showcase_input_doc_value %||% ""
    type_val <- input$showcase_input_doc_type %||% "text"

    update_block_input(
      session,
      "showcase_input_preview",
      value = initial_value,
      type = type_val
    )
    reactive_code(paste0(
      "update_block_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_input_preview\",\n",
      "  value = \"", initial_value, "\",\n",
      "  type = \"", type_val, "\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_input_disable, {
    update_block_input(session, "showcase_input_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_input_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_input_enable, {
    update_block_input(session, "showcase_input_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_input_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_input_number_bounds, {
    update_block_input(
      session,
      "showcase_input_preview",
      min = 0,
      max = 10,
      step = 2
    )
    reactive_code(paste0(
      "# Only affects type = \"number\" inputs\n",
      "update_block_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_input_preview\",\n",
      "  min = 0,\n",
      "  max = 10,\n",
      "  step = 2\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_input_to_password, {
    update_block_input(session, "showcase_input_preview", type = "password")
    reactive_code(paste0(
      "update_block_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_input_preview\",\n",
      "  type = \"password\"\n",
      ")"
    ))
  })
}
