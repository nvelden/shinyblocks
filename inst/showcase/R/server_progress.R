register_progress_showcase <- function(input, output, session) {
  # Parse a control's text into a finite number, falling back when blank/invalid
  # so a half-typed value never errors the live preview.
  num_or <- function(x, fallback) {
    if (is.null(x)) return(fallback)
    n <- suppressWarnings(as.numeric(x))
    if (length(n) != 1 || !is.finite(n)) fallback else n
  }

  blank_to_null <- function(x) {
    if (is.null(x) || !nzchar(trimws(x))) NULL else x
  }

  # Resolved, validated control state shared by the preview and the code block.
  progress_state <- shiny::reactive({
    min <- num_or(input$showcase_progress_doc_min, 0)
    max <- num_or(input$showcase_progress_doc_max, 1)
    if (!(min < max)) {
      min <- 0
      max <- 1
    }
    list(
      value = num_or(input$showcase_progress_doc_value, min),
      min = min,
      max = max,
      label = blank_to_null(input$showcase_progress_doc_label),
      message = blank_to_null(input$showcase_progress_doc_message),
      detail = blank_to_null(input$showcase_progress_doc_detail),
      show_value = isTRUE(input$showcase_progress_doc_show_value),
      indeterminate = isTRUE(input$showcase_progress_doc_indeterminate),
      variant = input$showcase_progress_doc_variant %||% "default",
      width = blank_to_null(input$showcase_progress_doc_width),
      style = blank_to_null(input$showcase_progress_doc_style),
      use_class = isTRUE(input$showcase_progress_doc_class)
    )
  })

  output$showcase_progress_preview_ui <- shiny::renderUI({
    s <- progress_state()
    block_progress(
      id = "showcase_progress_preview",
      value = s$value,
      min = s$min,
      max = s$max,
      message = s$message,
      detail = s$detail,
      label = s$label,
      show_value = s$show_value,
      indeterminate = s$indeterminate,
      variant = s$variant,
      width = s$width,
      style = s$style,
      class = if (s$use_class) "showcase-progress-preview-custom" else NULL
    )
  })
  shiny::outputOptions(
    output,
    "showcase_progress_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_progress_preview_code <- showcase_render_code({
    s <- progress_state()
    args <- c('id = "showcase_progress_preview"')
    if (s$value != 0) args <- c(args, paste0("value = ", s$value))
    if (s$min != 0) args <- c(args, paste0("min = ", s$min))
    if (s$max != 1) args <- c(args, paste0("max = ", s$max))
    if (!is.null(s$label)) args <- c(args, paste0('label = "', s$label, '"'))
    if (!is.null(s$message)) args <- c(args, paste0('message = "', s$message, '"'))
    if (!is.null(s$detail)) args <- c(args, paste0('detail = "', s$detail, '"'))
    if (isTRUE(s$show_value)) args <- c(args, "show_value = TRUE")
    if (isTRUE(s$indeterminate)) args <- c(args, "indeterminate = TRUE")
    if (!identical(s$variant, "default")) args <- c(args, paste0('variant = "', s$variant, '"'))
    if (!is.null(s$width)) args <- c(args, paste0('width = "', s$width, '"'))
    if (!is.null(s$style)) args <- c(args, paste0('style = "', s$style, '"'))
    if (isTRUE(s$use_class)) args <- c(args, 'class = "showcase-progress-preview-custom"')
    paste0("block_progress(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_progress_preview_code",
    suspendWhenHidden = FALSE
  )

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see the\n",
    "# update_block_progress() / inc_block_progress() call here."
  ))

  output$showcase_progress_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(
    output,
    "showcase_progress_reactive_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_progress_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c(
        "id", "value", "min", "max", "message", "detail", "label",
        "show_value", "indeterminate", "variant", "width", "class", "style"
      ),
      Type = c(
        "character", "numeric", "numeric", "numeric", "character", "character",
        "character", "logical", "logical", "character", "character", "character",
        "character | list"
      ),
      Default = c(
        "required", "0", "0", "1", "NULL", "NULL", "NULL",
        "FALSE", "FALSE", "\"default\"", "NULL", "NULL", "NULL"
      ),
      Description = c(
        "Component id used to address the bar from the server. Not a form control: there is no input$<id> value.",
        "Current progress value, clamped into [min, max].",
        "Lower bound. Must be finite and less than max.",
        "Upper bound. Must be finite and greater than min.",
        "Dynamic status line; renders header-left, or as a muted second line when label is also set.",
        "Secondary muted text below the track.",
        "Static description of what is progressing; takes header-left when set.",
        "Render the clamped percent at header-right. Suppressed when indeterminate.",
        "Show an unknown-progress sweep instead of a determinate fill.",
        "Indicator color: default, success, warning, info, or destructive.",
        "CSS width for the component (NULL fills the container).",
        "Additional classes merged onto the runtime mount.",
        "Inline styles applied to the runtime mount."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_progress_api_table",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_progress_set_25, {
    update_block_progress(session, "showcase_progress_preview", value = 0.25, indeterminate = FALSE)
    reactive_code(paste0(
      "update_block_progress(\n",
      "  session = session,\n",
      "  id = \"showcase_progress_preview\",\n",
      "  value = 0.25\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_progress_set_75, {
    update_block_progress(session, "showcase_progress_preview", value = 0.75, indeterminate = FALSE)
    reactive_code(paste0(
      "update_block_progress(\n",
      "  session = session,\n",
      "  id = \"showcase_progress_preview\",\n",
      "  value = 0.75\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_progress_inc, {
    inc_block_progress(session, "showcase_progress_preview", amount = 0.1)
    reactive_code(paste0(
      "inc_block_progress(\n",
      "  session = session,\n",
      "  id = \"showcase_progress_preview\",\n",
      "  amount = 0.1\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_progress_reset, {
    update_block_progress(session, "showcase_progress_preview", value = 0, indeterminate = FALSE)
    reactive_code(paste0(
      "update_block_progress(\n",
      "  session = session,\n",
      "  id = \"showcase_progress_preview\",\n",
      "  value = 0  # reset to min\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_progress_toggle_indeterminate, {
    update_block_progress(session, "showcase_progress_preview", indeterminate = TRUE)
    reactive_code(paste0(
      "update_block_progress(\n",
      "  session = session,\n",
      "  id = \"showcase_progress_preview\",\n",
      "  indeterminate = TRUE\n",
      ")"
    ))
  })
}
