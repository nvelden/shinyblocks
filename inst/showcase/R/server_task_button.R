register_task_button_showcase <- function(input, output, session) {
  task_button_doc_icon <- function(icon_value) {
    if (is.null(icon_value) || identical(icon_value, "none")) {
      return(NULL)
    }
    icon_value
  }

  output$showcase_task_button_preview_ui <- shiny::renderUI({
    label <- input$showcase_task_button_doc_label %||% "Run analysis"
    if (!nzchar(label)) {
      label <- "Run analysis"
    }
    label_busy <- input$showcase_task_button_doc_label_busy %||% "Crunching..."
    if (!nzchar(label_busy)) {
      label_busy <- "Crunching..."
    }
    style <- input$showcase_task_button_doc_style %||% ""
    if (!nzchar(style)) {
      style <- NULL
    }
    block_task_button(
      input_id = "showcase_task_button_preview",
      label = label,
      label_busy = label_busy,
      variant = input$showcase_task_button_doc_variant %||% "default",
      size = input$showcase_task_button_doc_size %||% "default",
      icon = task_button_doc_icon(input$showcase_task_button_doc_icon),
      icon_busy = task_button_doc_icon(input$showcase_task_button_doc_icon_busy),
      icon_position = input$showcase_task_button_doc_icon_position %||% "inline-start",
      auto_reset = isTRUE(input$showcase_task_button_doc_auto_reset),
      disabled = isTRUE(input$showcase_task_button_doc_disabled),
      style = style,
      class = if (isTRUE(input$showcase_task_button_doc_class)) "border-dashed" else NULL
    )
  })
  shiny::outputOptions(
    output,
    "showcase_task_button_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_task_button_preview_value <- showcase_render_code({
    value <- input$showcase_task_button_preview
    val_str <- if (is.null(value)) "<NULL>" else as.character(value)
    paste0("input$showcase_task_button_preview = ", val_str)
  })
  shiny::outputOptions(
    output,
    "showcase_task_button_preview_value",
    suspendWhenHidden = FALSE
  )

  output$showcase_task_button_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }
    label_val <- input$showcase_task_button_doc_label %||% "Run analysis"
    if (!nzchar(label_val)) {
      label_val <- "Run analysis"
    }
    label_busy_val <- input$showcase_task_button_doc_label_busy %||% "Crunching..."
    if (!nzchar(label_busy_val)) {
      label_busy_val <- "Crunching..."
    }
    variant_val <- input$showcase_task_button_doc_variant %||% "default"
    size_val <- input$showcase_task_button_doc_size %||% "default"
    icon_val <- task_button_doc_icon(input$showcase_task_button_doc_icon)
    icon_busy_val <- task_button_doc_icon(input$showcase_task_button_doc_icon_busy)
    icon_position_val <- input$showcase_task_button_doc_icon_position %||% "inline-start"
    auto_reset_val <- isTRUE(input$showcase_task_button_doc_auto_reset)
    disabled_val <- isTRUE(input$showcase_task_button_doc_disabled)
    style_val <- input$showcase_task_button_doc_style %||% ""
    class_val <- isTRUE(input$showcase_task_button_doc_class)

    args <- c(
      'input_id = "showcase_task_button_preview"',
      paste0("label = ", string_literal(label_val)),
      paste0("label_busy = ", string_literal(label_busy_val))
    )
    if (variant_val != "default") {
      args <- c(args, paste0('variant = "', variant_val, '"'))
    }
    if (size_val != "default") {
      args <- c(args, paste0('size = "', size_val, '"'))
    }
    if (!is.null(icon_val)) {
      args <- c(args, paste0('icon = "', icon_val, '"'))
    }
    if (!is.null(icon_busy_val)) {
      args <- c(args, paste0('icon_busy = "', icon_busy_val, '"'))
    }
    if ((!is.null(icon_val) || !is.null(icon_busy_val)) && icon_position_val != "inline-start") {
      args <- c(args, paste0('icon_position = "', icon_position_val, '"'))
    }
    if (!auto_reset_val) {
      args <- c(args, "auto_reset = FALSE")
    }
    if (disabled_val) {
      args <- c(args, "disabled = TRUE")
    }
    if (nzchar(style_val)) {
      args <- c(args, paste0("style = ", string_literal(style_val)))
    }
    if (class_val) {
      args <- c(args, 'class = "border-dashed"')
    }
    paste0("block_task_button(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_task_button_preview_code",
    suspendWhenHidden = FALSE
  )

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_task_button() code here."
  ))
  output$showcase_task_button_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(
    output,
    "showcase_task_button_reactive_code",
    suspendWhenHidden = FALSE
  )

  show_update <- function(...) {
    args <- c(...)
    reactive_code(paste0(
      "update_block_task_button(\n",
      "  session = session,\n",
      "  input_id = \"showcase_task_button_preview\",\n",
      "  ", paste(args, collapse = ",\n  "), "\n",
      ")"
    ))
  }

  # Simulated work so the busy state is actually visible. The click locks the
  # button on the client; Shiny holds the outgoing ready-reset message until this
  # observer's reactive flush finishes, so the button stays busy for the duration
  # of the work. With auto_reset = TRUE it then clears itself; with
  # auto_reset = FALSE it stays busy until "Set ready". Without simulated work a
  # synchronous handler returns instantly and the busy state only flashes.
  task_result <- shiny::reactiveVal(NULL)

  shiny::observeEvent(input$showcase_task_button_preview, {
    Sys.sleep(1.5)
    task_result(sprintf(
      "Run #%d complete at %s",
      input$showcase_task_button_preview,
      format(Sys.time(), "%H:%M:%S")
    ))
  }, ignoreInit = TRUE)

  output$showcase_task_button_result <- showcase_render_code({
    res <- task_result()
    if (is.null(res)) "# Click the button to run a (simulated) 1.5s task." else res
  })
  shiny::outputOptions(
    output,
    "showcase_task_button_result",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_task_button_set_busy, {
    update_block_task_button(session, "showcase_task_button_preview", state = "busy")
    show_update('state = "busy"')
  })

  shiny::observeEvent(input$showcase_task_button_set_ready, {
    update_block_task_button(session, "showcase_task_button_preview", state = "ready")
    show_update('state = "ready"')
  })

  shiny::observeEvent(input$showcase_task_button_disable, {
    update_block_task_button(session, "showcase_task_button_preview", disabled = TRUE)
    show_update("disabled = TRUE")
  })

  shiny::observeEvent(input$showcase_task_button_enable, {
    update_block_task_button(session, "showcase_task_button_preview", disabled = FALSE)
    show_update("disabled = FALSE")
  })

  output$showcase_task_button_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("input_id", "label", "label_busy", "variant", "size", "icon", "icon_busy", "icon_position", "auto_reset", "...", "class"),
      Type = c("character", "character | tag", "character", "character", "character", "character | tag", "character | tag", "character", "logical", "named attributes", "character"),
      Default = c("required", "required", "\"Processing...\"", "\"default\"", "\"default\"", "NULL", "NULL", "\"inline-start\"", "TRUE", "none", "NULL"),
      Description = c(
        "Required input id. Read input$<id> as a click count (a shinyActionButtonValue).",
        "Ready-state label.",
        "Accessible and visible label shown while busy.",
        "Visual variant. One of default, secondary, outline, ghost, destructive, or link.",
        "Button size. One of default, sm, lg, or icon.",
        "Optional ready-state icon name or tag.",
        "Optional busy-state icon name or tag. Defaults to a spinner.",
        "Controls icon placement when an icon is present.",
        "When TRUE, return to ready after the click's reactive flush unless under manual control.",
        "Additional button attributes (e.g. disabled = TRUE).",
        "Additional class merged onto the runtime button element."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_task_button_api_table",
    suspendWhenHidden = FALSE
  )
}
