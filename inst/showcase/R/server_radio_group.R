parse_radio_choices <- function(text) {
  if (is.null(text) || !nzchar(text)) return(list())
  lines <- strsplit(text, "\n", fixed = TRUE)[[1]]
  lines <- trimws(lines)
  lines <- lines[nzchar(lines)]
  if (!length(lines)) return(list())

  parts <- strsplit(lines, "|", fixed = TRUE)
  labels <- vapply(parts, function(p) trimws(p[[1]]), character(1))
  values <- vapply(parts, function(p) {
    if (length(p) >= 2) trimws(p[[2]]) else trimws(p[[1]])
  }, character(1))
  setNames(values, labels)
}

register_radio_group_showcase <- function(input, output, session) {
  output$showcase_radio_group_preview_ui <- shiny::renderUI({
    label <- input$showcase_radio_group_doc_label %||% "Notification preference"
    if (!nzchar(label)) label <- "Notification preference"

    choices <- parse_radio_choices(input$showcase_radio_group_doc_choices %||% "")
    if (!length(choices)) choices <- c(All = "all", Mentions = "mentions", None = "none")

    selected <- input$showcase_radio_group_doc_selected %||% NULL
    if (is.null(selected) || !nzchar(selected) || !selected %in% as.character(choices)) {
      selected <- as.character(choices)[[1]]
    }

    orientation <- input$showcase_radio_group_doc_orientation %||% "vertical"
    disabled <- isTRUE(input$showcase_radio_group_doc_disabled)
    invalid <- isTRUE(input$showcase_radio_group_doc_invalid)
    style_val <- input$showcase_radio_group_doc_style %||% ""
    if (!nzchar(style_val)) style_val <- NULL
    class_val <- if (isTRUE(input$showcase_radio_group_doc_class)) {
      "showcase-radio-group-preview-custom"
    } else {
      NULL
    }

    block_field(
      block_field_label(label, `for` = "showcase_radio_group_preview"),
      block_radio_group(
        "showcase_radio_group_preview",
        choices = choices,
        selected = selected,
        orientation = orientation,
        disabled = disabled,
        invalid = invalid,
        style = style_val,
        class = class_val
      )
    )
  })
  shiny::outputOptions(output, "showcase_radio_group_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_radio_group_preview_value <- showcase_render_code({
    value <- input$showcase_radio_group_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (!nzchar(value)) {
      "<EMPTY>"
    } else {
      value
    }
    paste0("input$showcase_radio_group_preview = ", val_str)
  })
  shiny::outputOptions(output, "showcase_radio_group_preview_value", suspendWhenHidden = FALSE)

  output$showcase_radio_group_preview_code <- showcase_render_code({
    choices <- parse_radio_choices(input$showcase_radio_group_doc_choices %||% "")
    if (!length(choices)) choices <- c(All = "all", Mentions = "mentions", None = "none")
    selected <- input$showcase_radio_group_doc_selected %||% as.character(choices)[[1]]
    orientation <- input$showcase_radio_group_doc_orientation %||% "vertical"
    disabled <- isTRUE(input$showcase_radio_group_doc_disabled)
    invalid <- isTRUE(input$showcase_radio_group_doc_invalid)
    style_val <- input$showcase_radio_group_doc_style %||% ""
    custom_class <- isTRUE(input$showcase_radio_group_doc_class)

    choices_text <- paste(
      sprintf('"%s" = "%s"', names(choices), as.character(choices)),
      collapse = ", "
    )

    args <- c(
      'input_id = "showcase_radio_group_preview"',
      paste0("choices = c(", choices_text, ")"),
      paste0('selected = "', selected, '"'),
      paste0('orientation = "', orientation, '"')
    )
    if (disabled) args <- c(args, "disabled = TRUE")
    if (invalid) args <- c(args, "invalid = TRUE")
    if (nzchar(style_val)) args <- c(args, paste0('style = "', style_val, '"'))
    if (custom_class) args <- c(args, 'class = "showcase-radio-group-preview-custom"')

    paste0(
      "block_radio_group(\n  ",
      paste(args, collapse = ",\n  "),
      "\n)"
    )
  })
  shiny::outputOptions(output, "showcase_radio_group_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_radio_group() code here."
  ))

  output$showcase_radio_group_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(output, "showcase_radio_group_reactive_code", suspendWhenHidden = FALSE)

  output$showcase_radio_group_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("input_id", "choices", "selected", "disabled", "invalid", "orientation", "style", "class"),
      Type = c("character", "named character | list", "character", "logical", "logical", "character", "character | list", "character"),
      Default = c("required", "required", "first choice", "FALSE", "FALSE", "\"vertical\"", "NULL", "NULL"),
      Description = c(
        "Input id for the radio group value.",
        "Choice labels and values.",
        "Initial selected value (must be one of choices).",
        "Disables the entire group while preserving server updates.",
        "Sets aria-invalid='true' to surface destructive styling.",
        "Layout orientation: 'vertical' (default) or 'horizontal'.",
        "Inline CSS styles applied to the radio-group wrapper.",
        "Additional class merged onto the runtime radio-group wrapper."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(output, "showcase_radio_group_api_table", suspendWhenHidden = FALSE)

  shiny::observeEvent(input$showcase_radio_group_select_mentions, {
    update_block_radio_group(session, "showcase_radio_group_preview", selected = "mentions")
    reactive_code(paste0(
      "update_block_radio_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_radio_group_preview\",\n",
      "  selected = \"mentions\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_radio_group_clear, {
    selected <- input$showcase_radio_group_doc_selected %||% "all"
    update_block_radio_group(session, "showcase_radio_group_preview", selected = selected)
    reactive_code(paste0(
      "update_block_radio_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_radio_group_preview\",\n",
      "  selected = \"", selected, "\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_radio_group_disable, {
    update_block_radio_group(session, "showcase_radio_group_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_radio_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_radio_group_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_radio_group_enable, {
    update_block_radio_group(session, "showcase_radio_group_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_radio_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_radio_group_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_radio_group_swap_choices, {
    new_choices <- c(Daily = "daily", Weekly = "weekly", Monthly = "monthly")
    update_block_radio_group(
      session,
      "showcase_radio_group_preview",
      choices = new_choices,
      selected = "weekly"
    )
    reactive_code(paste0(
      "update_block_radio_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_radio_group_preview\",\n",
      "  choices = c(Daily = \"daily\", Weekly = \"weekly\", Monthly = \"monthly\"),\n",
      "  selected = \"weekly\"\n",
      ")"
    ))
  })
}
