register_switch_showcase <- function(input, output, session) {
  preview_label <- shiny::reactiveVal("Send incident alerts")

  output$showcase_switch_preview_ui <- shiny::renderUI({
    label <- input$showcase_switch_doc_label %||% preview_label()
    if (!nzchar(label)) label <- preview_label()
    preview_label(label)

    value <- isTRUE(input$showcase_switch_doc_value)
    disabled <- isTRUE(input$showcase_switch_doc_disabled)
    style_val <- input$showcase_switch_doc_style %||% ""
    if (!nzchar(style_val)) style_val <- NULL
    class_val <- if (isTRUE(input$showcase_switch_doc_class)) {
      "showcase-switch-preview-custom"
    } else {
      NULL
    }

    block_field(
      block_switch(
        "showcase_switch_preview",
        label,
        value = value,
        disabled = disabled,
        style = style_val,
        class = class_val
      )
    )
  })
  shiny::outputOptions(output, "showcase_switch_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_switch_preview_value <- shiny::renderText({
    value <- input$showcase_switch_preview
    val_str <- if (is.null(value)) "<NULL>" else as.character(isTRUE(value))
    paste0("input$showcase_switch_preview = ", val_str)
  })
  shiny::outputOptions(output, "showcase_switch_preview_value", suspendWhenHidden = FALSE)

  output$showcase_switch_preview_code <- shiny::renderText({
    label <- input$showcase_switch_doc_label %||% preview_label()
    value <- isTRUE(input$showcase_switch_doc_value)
    disabled <- isTRUE(input$showcase_switch_doc_disabled)
    style_val <- input$showcase_switch_doc_style %||% ""
    custom_class <- isTRUE(input$showcase_switch_doc_class)

    args <- c(
      'input_id = "showcase_switch_preview"',
      paste0('label = "', label, '"')
    )
    if (value) args <- c(args, "value = TRUE")
    if (disabled) args <- c(args, "disabled = TRUE")
    if (nzchar(style_val)) args <- c(args, paste0('style = "', style_val, '"'))
    if (custom_class) args <- c(args, 'class = "showcase-switch-preview-custom"')

    paste0(
      "block_switch(\n  ",
      paste(args, collapse = ",\n  "),
      "\n)"
    )
  })
  shiny::outputOptions(output, "showcase_switch_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_switch() code here."
  ))

  output$showcase_switch_reactive_code <- shiny::renderText({
    reactive_code()
  })
  shiny::outputOptions(output, "showcase_switch_reactive_code", suspendWhenHidden = FALSE)

  output$showcase_switch_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("input_id", "label", "value", "disabled", "style", "class"),
      Type = c("character", "character", "logical", "logical", "character | list", "character"),
      Default = c("required", "required", "FALSE", "FALSE", "NULL", "NULL"),
      Description = c(
        "Input id reported back to Shiny as input$<id>.",
        "Visible label rendered next to the toggle.",
        "Initial checked state (TRUE/FALSE).",
        "Disables the switch while preserving server updates.",
        "Inline CSS styles applied to the switch wrapper.",
        "Additional class merged onto the runtime switch wrapper."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(output, "showcase_switch_api_table", suspendWhenHidden = FALSE)

  shiny::observeEvent(input$showcase_switch_turn_on, {
    update_block_switch(session, "showcase_switch_preview", checked = TRUE)
    reactive_code(paste0(
      "update_block_switch(\n",
      "  session = session,\n",
      "  input_id = \"showcase_switch_preview\",\n",
      "  checked = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_switch_turn_off, {
    update_block_switch(session, "showcase_switch_preview", checked = FALSE)
    reactive_code(paste0(
      "update_block_switch(\n",
      "  session = session,\n",
      "  input_id = \"showcase_switch_preview\",\n",
      "  checked = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_switch_disable, {
    update_block_switch(session, "showcase_switch_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_switch(\n",
      "  session = session,\n",
      "  input_id = \"showcase_switch_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_switch_enable, {
    update_block_switch(session, "showcase_switch_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_switch(\n",
      "  session = session,\n",
      "  input_id = \"showcase_switch_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_switch_rename, {
    new_label <- "Auto-resolve pages"
    shiny::updateTextInput(session, "showcase_switch_doc_label", value = new_label)
    reactive_code(paste0(
      "# `label` is a constructor arg, not an update_block_switch() arg.\n",
      "# Re-render with the new label via the constructor's `label`.\n",
      "block_switch(\"showcase_switch_preview\",\n",
      "  label = \"", new_label, "\", ...)"
    ))
  })
}
