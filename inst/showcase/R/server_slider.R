parse_slider_value <- function(text, fallback = 50) {
  if (is.null(text) || !nzchar(text)) return(fallback)
  parts <- trimws(strsplit(text, ",", fixed = TRUE)[[1]])
  values <- suppressWarnings(as.numeric(parts[nzchar(parts)]))
  values <- values[!is.na(values)]
  if (!length(values)) return(fallback)
  if (length(values) > 2) values <- values[1:2]
  values
}

slider_number <- function(value, fallback) {
  parsed <- suppressWarnings(as.numeric(value))
  if (length(parsed) != 1 || is.na(parsed)) fallback else parsed
}

slider_code_value <- function(value) {
  if (length(value) == 1) return(as.character(value))
  paste0("c(", paste(value, collapse = ", "), ")")
}

register_slider_showcase <- function(input, output, session) {
  output$showcase_slider_preview_ui <- shiny::renderUI({
    min_val <- slider_number(input$showcase_slider_doc_min, 0)
    max_val <- slider_number(input$showcase_slider_doc_max, 100)
    if (min_val >= max_val) {
      min_val <- 0
      max_val <- 100
    }
    value <- parse_slider_value(input$showcase_slider_doc_value, 50)
    value <- pmin(max_val, pmax(min_val, value))
    if (length(value) == 2 && value[[1]] > value[[2]]) value <- sort(value)
    step_val <- slider_number(input$showcase_slider_doc_step, 1)
    if (step_val <= 0) step_val <- 1
    disabled <- isTRUE(input$showcase_slider_doc_disabled)
    invalid <- isTRUE(input$showcase_slider_doc_invalid)
    width_val <- input$showcase_slider_doc_width %||% "100%"
    if (!nzchar(width_val)) width_val <- NULL
    style_val <- input$showcase_slider_doc_style %||% ""
    if (!nzchar(style_val)) style_val <- NULL
    class_val <- if (isTRUE(input$showcase_slider_doc_class)) {
      "showcase-slider-preview-custom"
    } else {
      NULL
    }

    block_field(
      block_field_label("Volume", `for` = "showcase_slider_preview"),
      block_slider(
        "showcase_slider_preview",
        value = value,
        min = min_val,
        max = max_val,
        step = step_val,
        width = width_val,
        disabled = disabled,
        invalid = invalid,
        style = style_val,
        class = class_val
      )
    )
  })
  shiny::outputOptions(output, "showcase_slider_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_slider_preview_value <- shiny::renderText({
    value <- input$showcase_slider_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (length(value) > 1) {
      paste(value, collapse = ", ")
    } else {
      as.character(value)
    }
    paste0("input$showcase_slider_preview = ", val_str)
  })
  shiny::outputOptions(output, "showcase_slider_preview_value", suspendWhenHidden = FALSE)

  output$showcase_slider_preview_code <- shiny::renderText({
    min_val <- slider_number(input$showcase_slider_doc_min, 0)
    max_val <- slider_number(input$showcase_slider_doc_max, 100)
    value <- parse_slider_value(input$showcase_slider_doc_value, 50)
    step_val <- slider_number(input$showcase_slider_doc_step, 1)
    disabled <- isTRUE(input$showcase_slider_doc_disabled)
    invalid <- isTRUE(input$showcase_slider_doc_invalid)
    width_val <- input$showcase_slider_doc_width %||% "100%"
    style_val <- input$showcase_slider_doc_style %||% ""
    custom_class <- isTRUE(input$showcase_slider_doc_class)

    args <- c(
      'input_id = "showcase_slider_preview"',
      paste0("value = ", slider_code_value(value)),
      paste0("min = ", min_val),
      paste0("max = ", max_val),
      paste0("step = ", step_val)
    )
    if (nzchar(width_val)) args <- c(args, paste0('width = "', width_val, '"'))
    if (disabled) args <- c(args, "disabled = TRUE")
    if (invalid) args <- c(args, "invalid = TRUE")
    if (nzchar(style_val)) args <- c(args, paste0('style = "', style_val, '"'))
    if (custom_class) args <- c(args, 'class = "showcase-slider-preview-custom"')

    paste0(
      "block_slider(\n  ",
      paste(args, collapse = ",\n  "),
      "\n)"
    )
  })
  shiny::outputOptions(output, "showcase_slider_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_slider() code here."
  ))

  output$showcase_slider_reactive_code <- shiny::renderText({
    reactive_code()
  })
  shiny::outputOptions(output, "showcase_slider_reactive_code", suspendWhenHidden = FALSE)

  output$showcase_slider_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("input_id", "value", "min", "max", "step", "ticks", "width", "disabled", "invalid", "style", "class"),
      Type = c("character", "numeric", "numeric", "numeric", "numeric | NULL", "logical", "character", "logical", "logical", "character | list", "character"),
      Default = c("required", "required", "required", "required", "NULL", "FALSE", "NULL", "FALSE", "FALSE", "NULL", "NULL"),
      Description = c(
        "Input id for the slider value.",
        "Initial slider value. Use one number for a single thumb or two numbers for a range.",
        "Minimum slider value.",
        "Maximum slider value.",
        "Optional step size for pointer and keyboard updates.",
        "Accepted for API compatibility; tick labels are not rendered yet.",
        "Optional CSS width applied to the wrapper.",
        "Disables user interaction while preserving server updates.",
        "Sets aria-invalid='true' to surface destructive styling.",
        "Inline CSS styles applied to the slider element.",
        "Additional class merged onto the runtime slider wrapper."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(output, "showcase_slider_api_table", suspendWhenHidden = FALSE)

  shiny::observeEvent(input$showcase_slider_set_low, {
    update_block_slider(session, "showcase_slider_preview", value = 25)
    reactive_code(paste0(
      "update_block_slider(\n",
      "  session = session,\n",
      "  input_id = \"showcase_slider_preview\",\n",
      "  value = 25\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_slider_set_range, {
    update_block_slider(session, "showcase_slider_preview", value = c(25, 75))
    reactive_code(paste0(
      "update_block_slider(\n",
      "  session = session,\n",
      "  input_id = \"showcase_slider_preview\",\n",
      "  value = c(25, 75)\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_slider_disable, {
    update_block_slider(session, "showcase_slider_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_slider(\n",
      "  session = session,\n",
      "  input_id = \"showcase_slider_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_slider_enable, {
    update_block_slider(session, "showcase_slider_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_slider(\n",
      "  session = session,\n",
      "  input_id = \"showcase_slider_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_slider_resize, {
    update_block_slider(
      session,
      "showcase_slider_preview",
      min = -50,
      max = 150,
      value = 40,
      step = 5
    )
    reactive_code(paste0(
      "update_block_slider(\n",
      "  session = session,\n",
      "  input_id = \"showcase_slider_preview\",\n",
      "  min = -50,\n",
      "  max = 150,\n",
      "  value = 40,\n",
      "  step = 5\n",
      ")"
    ))
  })
}
