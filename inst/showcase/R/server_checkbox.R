register_checkbox_showcase <- function(input, output, session) {
  output$showcase_checkbox_preview_ui <- shiny::renderUI({
    label <- input$showcase_checkbox_doc_label %||% "Email me product updates"
    if (!nzchar(label)) label <- "Email me product updates"

    description <- input$showcase_checkbox_doc_description %||%
      "Unchecked default checkbox state."
    invalid_message <- input$showcase_checkbox_doc_invalid_message %||%
      "You must confirm the rollout checklist before continuing."

    checked <- isTRUE(input$showcase_checkbox_doc_checked)
    disabled <- isTRUE(input$showcase_checkbox_doc_disabled)
    invalid <- isTRUE(input$showcase_checkbox_doc_invalid)
    style_val <- input$showcase_checkbox_doc_style %||% ""
    if (!nzchar(style_val)) style_val <- NULL
    class_val <- if (isTRUE(input$showcase_checkbox_doc_class)) {
      "showcase-checkbox-preview-custom"
    } else {
      NULL
    }

    preview_field <- block_field(
      block_checkbox(
        "showcase_checkbox_preview",
        label = label,
        value = checked,
        disabled = disabled,
        style = style_val,
        class = class_val
      ),
      block_field_description(description)
    )

    if (invalid) {
      block_field_invalid(preview_field, invalid_message)
    } else {
      preview_field
    }
  })
  shiny::outputOptions(
    output,
    "showcase_checkbox_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_checkbox_preview_value <- showcase_render_code({
    value <- input$showcase_checkbox_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (isTRUE(value)) {
      "TRUE"
    } else {
      "FALSE"
    }
    paste0("input$showcase_checkbox_preview = ", val_str)
  })
  shiny::outputOptions(
    output,
    "showcase_checkbox_preview_value",
    suspendWhenHidden = FALSE
  )

  output$showcase_checkbox_preview_code <- showcase_render_code({
    label <- input$showcase_checkbox_doc_label %||% "Email me product updates"
    description <- input$showcase_checkbox_doc_description %||%
      "Unchecked default checkbox state."
    invalid_message <- input$showcase_checkbox_doc_invalid_message %||%
      "You must confirm the rollout checklist before continuing."

    checked <- isTRUE(input$showcase_checkbox_doc_checked)
    disabled <- isTRUE(input$showcase_checkbox_doc_disabled)
    invalid <- isTRUE(input$showcase_checkbox_doc_invalid)
    style_val <- input$showcase_checkbox_doc_style %||% ""
    custom_class <- isTRUE(input$showcase_checkbox_doc_class)

    checkbox_args <- c(
      'input_id = "showcase_checkbox_preview"',
      paste0('label = "', label, '"')
    )
    if (checked) checkbox_args <- c(checkbox_args, "value = TRUE")
    if (disabled) checkbox_args <- c(checkbox_args, "disabled = TRUE")
    if (nzchar(style_val)) {
      checkbox_args <- c(checkbox_args, paste0('style = "', style_val, '"'))
    }
    if (custom_class) {
      checkbox_args <- c(
        checkbox_args,
        'class = "showcase-checkbox-preview-custom"'
      )
    }

    code <- paste0(
      "block_field(\n",
      "  block_checkbox(\n",
      "    ",
      paste(checkbox_args, collapse = ",\n    "),
      "\n",
      "  ),\n",
      "  block_field_description(\"",
      description,
      "\")\n",
      ")"
    )

    if (invalid) {
      code <- paste0(
        "block_field_invalid(\n",
        "  ",
        gsub("\n", "\n  ", code, fixed = TRUE),
        ",\n",
        "  \"",
        invalid_message,
        "\"\n",
        ")"
      )
    }

    code
  })
  shiny::outputOptions(
    output,
    "showcase_checkbox_preview_code",
    suspendWhenHidden = FALSE
  )

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_checkbox() code here."
  ))

  output$showcase_checkbox_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(
    output,
    "showcase_checkbox_reactive_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_checkbox_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("input_id", "label", "value", "disabled", "style", "class"),
      Type = c("character", "character", "logical", "logical", "character | list", "character"),
      Default = c("required", "required", "FALSE", "FALSE", "NULL", "NULL"),
      Description = c(
        "Input id for the checkbox value.",
        "Checkbox label text displayed next to the indicator.",
        "Initial checked state.",
        "Disables user interaction while preserving server updates.",
        "Inline CSS styles applied to the runtime checkbox wrapper.",
        "Additional class merged onto the runtime checkbox wrapper."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_checkbox_api_table",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_checkbox_set_checked, {
    update_block_checkbox(session, "showcase_checkbox_preview", checked = TRUE)
    reactive_code(paste0(
      "update_block_checkbox(\n",
      "  session = session,\n",
      "  input_id = \"showcase_checkbox_preview\",\n",
      "  checked = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_checkbox_clear, {
    update_block_checkbox(session, "showcase_checkbox_preview", checked = FALSE)
    reactive_code(paste0(
      "update_block_checkbox(\n",
      "  session = session,\n",
      "  input_id = \"showcase_checkbox_preview\",\n",
      "  checked = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_checkbox_disable, {
    update_block_checkbox(session, "showcase_checkbox_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_checkbox(\n",
      "  session = session,\n",
      "  input_id = \"showcase_checkbox_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_checkbox_enable, {
    update_block_checkbox(session, "showcase_checkbox_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_checkbox(\n",
      "  session = session,\n",
      "  input_id = \"showcase_checkbox_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })
}
