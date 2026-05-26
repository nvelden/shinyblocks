register_button_showcase <- function(input, output, session) {
  button_doc_icon <- function(icon_value) {
    if (is.null(icon_value) || identical(icon_value, "none")) {
      return(NULL)
    }
    icon_value
  }

  variant_choices <- c(
    "default",
    "secondary",
    "outline",
    "ghost",
    "destructive",
    "link"
  )

  output$showcase_button_preview_ui <- shiny::renderUI({
    label <- input$showcase_button_doc_label %||% "Continue"
    if (!nzchar(label)) {
      label <- "Continue"
    }
    variant <- input$showcase_button_doc_variant %||% "default"
    size <- input$showcase_button_doc_size %||% "default"
    icon <- button_doc_icon(input$showcase_button_doc_icon)
    icon_position <- input$showcase_button_doc_icon_position %||% "inline-start"
    style <- input$showcase_button_doc_style %||% ""
    if (!nzchar(style)) {
      style <- NULL
    }
    if (identical(size, "icon")) {
      if (is.null(icon)) {
        icon <- "search"
      }
      label <- NULL
    }

    block_button(
      label = label,
      id = "showcase_button_preview",
      variant = variant,
      size = size,
      icon = icon,
      icon_position = icon_position,
      disabled = isTRUE(input$showcase_button_doc_disabled),
      style = style,
      class = if (isTRUE(input$showcase_button_doc_class)) {
        "showcase-button-preview-custom"
      } else {
        NULL
      }
    )
  })
  shiny::outputOptions(
    output,
    "showcase_button_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_button_preview_value <- showcase_render_code({
    value <- input$showcase_button_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else {
      as.character(value)
    }
    paste0("input$showcase_button_preview = ", val_str)
  })
  shiny::outputOptions(
    output,
    "showcase_button_preview_value",
    suspendWhenHidden = FALSE
  )

  output$showcase_button_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    label_val <- input$showcase_button_doc_label %||% "Continue"
    if (!nzchar(label_val)) {
      label_val <- "Continue"
    }
    variant_val <- input$showcase_button_doc_variant %||% "default"
    size_val <- input$showcase_button_doc_size %||% "default"
    icon_val <- button_doc_icon(input$showcase_button_doc_icon)
    icon_position_val <- input$showcase_button_doc_icon_position %||% "inline-start"
    disabled_val <- isTRUE(input$showcase_button_doc_disabled)
    style_val <- input$showcase_button_doc_style %||% ""
    class_val <- isTRUE(input$showcase_button_doc_class)
    if (identical(size_val, "icon")) {
      if (is.null(icon_val)) {
        icon_val <- "search"
      }
      label_val <- ""
    }

    args <- c(
      paste0("label = ", string_literal(label_val)),
      'id = "showcase_button_preview"'
    )

    if (variant_val != "default") {
      args <- c(args, paste0('variant = "', variant_val, '"'))
    }
    if (size_val != "default") {
      args <- c(args, paste0('size = "', size_val, '"'))
    }
    if (!is.null(icon_val)) {
      args <- c(args, paste0('icon = "', icon_val, '"'))
      if (icon_position_val != "inline-start") {
        args <- c(args, paste0('icon_position = "', icon_position_val, '"'))
      }
    }
    if (disabled_val) {
      args <- c(args, "disabled = TRUE")
    }
    if (nzchar(style_val)) {
      args <- c(args, paste0("style = ", string_literal(style_val)))
    }
    if (class_val) {
      args <- c(args, 'class = "showcase-button-preview-custom"')
    }

    paste0("block_button(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_button_preview_code",
    suspendWhenHidden = FALSE
  )

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_button() code here."
  ))

  output$showcase_button_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(
    output,
    "showcase_button_reactive_code",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_button_set_label, {
    update_block_button(session, "showcase_button_preview", label = "Saved!")
    reactive_code(paste0(
      "update_block_button(\n",
      "  session = session,\n",
      "  input_id = \"showcase_button_preview\",\n",
      "  label = \"Saved!\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_button_cycle_variant, {
    current <- input$showcase_button_doc_variant %||% "default"
    idx <- match(current, variant_choices, nomatch = 0L)
    next_variant <- variant_choices[(idx %% length(variant_choices)) + 1L]
    update_block_button(session, "showcase_button_preview", variant = next_variant)
    reactive_code(paste0(
      "update_block_button(\n",
      "  session = session,\n",
      "  input_id = \"showcase_button_preview\",\n",
      "  variant = \"", next_variant, "\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_button_disable, {
    update_block_button(session, "showcase_button_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_button(\n",
      "  session = session,\n",
      "  input_id = \"showcase_button_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_button_enable, {
    update_block_button(session, "showcase_button_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_button(\n",
      "  session = session,\n",
      "  input_id = \"showcase_button_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_button_set_icon, {
    update_block_button(session, "showcase_button_preview", icon = "check")
    reactive_code(paste0(
      "update_block_button(\n",
      "  session = session,\n",
      "  input_id = \"showcase_button_preview\",\n",
      "  icon = \"check\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_button_clear_icon, {
    update_block_button(session, "showcase_button_preview", icon = NULL)
    reactive_code(paste0(
      "update_block_button(\n",
      "  session = session,\n",
      "  input_id = \"showcase_button_preview\",\n",
      "  icon = NULL\n",
      ")"
    ))
  })

  output$showcase_button_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("label", "variant", "size", "icon", "icon_position", "...", "class"),
      Type = c("character | tag", "character", "character", "character | tag", "character", "named attributes", "character"),
      Default = c("required", "\"default\"", "\"default\"", "NULL", "\"inline-start\"", "none", "NULL"),
      Description = c(
        "Content rendered inside the button.",
        "Visual variant. One of default, secondary, outline, ghost, destructive, or link.",
        "Button size. One of default, sm, lg, or icon.",
        "Optional leading/trailing icon name or tag.",
        "Controls icon placement when an icon is present.",
        "Additional button attributes. Pass id = \"...\" to expose input$<id> as a click count and address the button from update_block_button().",
        "Additional class merged onto the runtime button element."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_button_api_table",
    suspendWhenHidden = FALSE
  )
}
