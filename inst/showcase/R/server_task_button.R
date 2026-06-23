register_task_button_showcase <- function(input, output, session) {
  variant_choices <- c(
    "default",
    "secondary",
    "outline",
    "ghost",
    "destructive",
    "link"
  )

  output$showcase_task_button_preview_ui <- shiny::renderUI({
    label <- input$showcase_task_button_doc_label %||% "Run analysis"
    if (!nzchar(label)) {
      label <- "Run analysis"
    }
    label_busy <- input$showcase_task_button_doc_label_busy %||% "Crunching…"
    if (!nzchar(label_busy)) {
      label_busy <- "Crunching…"
    }
    block_task_button(
      input_id = "showcase_task_button_preview",
      label = label,
      label_busy = label_busy,
      variant = input$showcase_task_button_doc_variant %||% "default",
      auto_reset = isTRUE(input$showcase_task_button_doc_auto_reset),
      disabled = isTRUE(input$showcase_task_button_doc_disabled)
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
    label_busy_val <- input$showcase_task_button_doc_label_busy %||% "Crunching…"
    if (!nzchar(label_busy_val)) {
      label_busy_val <- "Crunching…"
    }
    variant_val <- input$showcase_task_button_doc_variant %||% "default"
    auto_reset_val <- isTRUE(input$showcase_task_button_doc_auto_reset)
    disabled_val <- isTRUE(input$showcase_task_button_doc_disabled)

    args <- c(
      'input_id = "showcase_task_button_preview"',
      paste0("label = ", string_literal(label_val)),
      paste0("label_busy = ", string_literal(label_busy_val))
    )
    if (variant_val != "default") {
      args <- c(args, paste0('variant = "', variant_val, '"'))
    }
    if (!auto_reset_val) {
      args <- c(args, "auto_reset = FALSE")
    }
    if (disabled_val) {
      args <- c(args, "disabled = TRUE")
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

  shiny::observeEvent(input$showcase_task_button_set_busy, {
    update_block_task_button(session, "showcase_task_button_preview", state = "busy")
    reactive_code(paste0(
      "update_block_task_button(\n",
      "  session = session,\n",
      "  input_id = \"showcase_task_button_preview\",\n",
      "  state = \"busy\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_task_button_set_ready, {
    update_block_task_button(session, "showcase_task_button_preview", state = "ready")
    reactive_code(paste0(
      "update_block_task_button(\n",
      "  session = session,\n",
      "  input_id = \"showcase_task_button_preview\",\n",
      "  state = \"ready\"\n",
      ")"
    ))
  })

  output$showcase_task_button_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("input_id", "label", "label_busy", "variant", "size", "icon", "icon_busy", "icon_position", "auto_reset", "...", "class"),
      Type = c("character", "character | tag", "character", "character", "character", "character | tag", "character | tag", "character", "logical", "named attributes", "character"),
      Default = c("required", "required", "\"Processing…\"", "\"default\"", "\"default\"", "NULL", "NULL", "\"inline-start\"", "TRUE", "none", "NULL"),
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
