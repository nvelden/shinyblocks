register_select_showcase <- function(input, output, session) {
  select_doc_choices <- function(key) {
    switch(
      key %||% "plans",
      frameworks = c(React = "react", Vue = "vue", Svelte = "svelte", Angular = "angular"),
      fruits = c(Apple = "apple", Banana = "banana", Blueberry = "blueberry", Grapes = "grapes"),
      c(Free = "free", Pro = "pro", Team = "team")
    )
  }

  select_doc_max_items <- function(key) {
    key <- key %||% "none"
    if (identical(key, "none")) NULL else as.integer(key)
  }

  # `multiple` is mount-time identity, so single and multiple modes render the
  # `selected` control under distinct input ids (forcing a real remount when the
  # checkbox flips). This reader returns whichever id is currently active.
  select_doc_selected <- function() {
    if (isTRUE(input$showcase_select_doc_multiple)) {
      input$showcase_select_doc_selected_multi
    } else {
      input$showcase_select_doc_selected_single
    }
  }

  output$showcase_select_preview_value <- showcase_render_code({
    value <- input$showcase_select_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (length(value) == 0) {
      "character(0)"
    } else if (length(value) == 1 && identical(value, "")) {
      "<EMPTY>"
    } else if (length(value) == 1) {
      paste0('"', value, '"')
    } else {
      paste0("c(", paste0('"', value, '"', collapse = ", "), ")")
    }
    paste0("input$showcase_select_preview = ", val_str)
  })
  shiny::outputOptions(
    output,
    "showcase_select_preview_value",
    suspendWhenHidden = FALSE
  )

  # The `selected` control mirrors the `multiple` checkbox: single mode renders a
  # single-value select, multiple mode renders a chip multi-select. `multiple` is
  # mount-time identity (not updatable), so re-render the control whenever the
  # checkbox or the choices change. Defaults to the first choice in both modes so
  # the preview is never empty.
  output$showcase_select_doc_selected_ui <- shiny::renderUI({
    choices <- select_doc_choices(input$showcase_select_doc_choices)
    multiple <- isTRUE(input$showcase_select_doc_multiple)
    block_select(
      if (multiple) "showcase_select_doc_selected_multi" else "showcase_select_doc_selected_single",
      choices = choices,
      selected = unname(choices[[1]]),
      multiple = multiple,
      placeholder = if (multiple) "Select default value(s)" else NULL
    )
  })
  shiny::outputOptions(
    output,
    "showcase_select_doc_selected_ui",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_select_doc_class, {
    update_block_select(
      session,
      "showcase_select_preview",
      class = if (isTRUE(input$showcase_select_doc_class)) {
        "showcase-select-preview-custom"
      } else {
        NULL
      }
    )
  }, ignoreInit = TRUE)

  output$showcase_select_preview_ui <- shiny::renderUI({
    choices <- select_doc_choices(input$showcase_select_doc_choices)
    multiple <- isTRUE(input$showcase_select_doc_multiple)
    max_items <- select_doc_max_items(input$showcase_select_doc_max_items)

    # The `selected` control is itself a multi-select, so it always reports a
    # (possibly empty) vector; keep only values that exist in the current
    # choices. Multiple mode passes the whole vector; single mode takes the
    # first, falling back to the first choice so the preview is never empty.
    chosen <- select_doc_selected()
    chosen <- chosen[chosen %in% unname(choices)]
    if (multiple) {
      selected <- chosen
      if (!is.null(max_items) && length(selected) > max_items) {
        selected <- selected[seq_len(max_items)]
      }
    } else {
      selected <- if (length(chosen)) chosen[[1]] else unname(choices[[1]])
    }

    placeholder <- input$showcase_select_doc_placeholder %||% ""
    if (!nzchar(placeholder)) {
      placeholder <- NULL
    }

    width <- input$showcase_select_doc_width %||% "100%"
    if (!nzchar(width)) {
      width <- "100%"
    }

    style <- input$showcase_select_doc_style %||% ""
    if (!nzchar(style)) {
      style <- NULL
    }

    block_select(
      input_id = "showcase_select_preview",
      choices = choices,
      selected = selected,
      placeholder = placeholder,
      disabled = isTRUE(input$showcase_select_doc_disabled),
      width = width,
      style = style,
      class = if (isTRUE(input$showcase_select_doc_class)) {
        "showcase-select-preview-custom"
      } else {
        NULL
      },
      size = input$showcase_select_doc_size %||% "default",
      invalid = isTRUE(input$showcase_select_doc_invalid),
      multiple = multiple,
      max_items = if (multiple) max_items else NULL
    )
  })
  shiny::outputOptions(
    output,
    "showcase_select_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_select_preview_code <- showcase_render_code({
    choices_val <- input$showcase_select_doc_choices %||% "plans"
    choices_str <- switch(
      choices_val,
      frameworks = 'c(React = "react", Vue = "vue", Svelte = "svelte", Angular = "angular")',
      fruits = 'c(Apple = "apple", Banana = "banana", Blueberry = "blueberry", Grapes = "grapes")',
      'c(Free = "free", Pro = "pro", Team = "team")'
    )

    choices <- select_doc_choices(choices_val)
    multiple_val <- isTRUE(input$showcase_select_doc_multiple)
    max_items_val <- select_doc_max_items(input$showcase_select_doc_max_items)
    selected_val <- select_doc_selected()
    selected_val <- selected_val[selected_val %in% unname(choices)]
    placeholder_val <- input$showcase_select_doc_placeholder
    width_val <- input$showcase_select_doc_width
    style_val <- input$showcase_select_doc_style
    class_val <- input$showcase_select_doc_class
    size_val <- input$showcase_select_doc_size
    disabled_val <- input$showcase_select_doc_disabled
    invalid_val <- input$showcase_select_doc_invalid

    args <- c(
      'input_id = "showcase_select_preview"',
      paste0("choices = ", choices_str)
    )

    if (multiple_val) {
      sel <- selected_val
      if (!is.null(max_items_val) && length(sel) > max_items_val) {
        sel <- sel[seq_len(max_items_val)]
      }
      if (length(sel)) {
        args <- c(args, paste0("selected = c(", paste0('"', sel, '"', collapse = ", "), ")"))
      }
    } else if (length(selected_val)) {
      args <- c(args, paste0('selected = "', selected_val[[1]], '"'))
    }
    if (!is.null(placeholder_val) && nzchar(placeholder_val)) {
      args <- c(args, paste0('placeholder = "', placeholder_val, '"'))
    }
    if (multiple_val) {
      args <- c(args, "multiple = TRUE")
      if (!is.null(max_items_val)) {
        args <- c(args, paste0("max_items = ", max_items_val))
      }
    }
    if (isTRUE(disabled_val)) {
      args <- c(args, "disabled = TRUE")
    }
    if (!is.null(width_val) && nzchar(width_val) && width_val != "100%") {
      args <- c(args, paste0('width = "', width_val, '"'))
    }
    if (!is.null(style_val) && nzchar(style_val)) {
      args <- c(args, paste0('style = "', style_val, '"'))
    }
    if (isTRUE(class_val)) {
      args <- c(args, 'class = "showcase-select-preview-custom"')
    }
    if (!is.null(size_val) && size_val != "default") {
      args <- c(args, paste0('size = "', size_val, '"'))
    }
    if (isTRUE(invalid_val)) {
      args <- c(args, "invalid = TRUE")
    }

    paste0("block_select(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_select_preview_code",
    suspendWhenHidden = FALSE
  )

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_select() code here."
  ))

  output$showcase_select_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(
    output,
    "showcase_select_reactive_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_select_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("choices", "selected", "multiple", "max_items", "placeholder", "disabled", "width", "class", "size", "style", "invalid"),
      Type = c("character | list", "character", "logical", "integer", "character", "logical", "character", "character", "character", "character", "logical"),
      Default = c("required", "NULL", "FALSE", "NULL", "NULL", "FALSE", "NULL", "NULL", "\"default\"", "NULL", "FALSE"),
      Description = c(
        "The labels and values available in the select.",
        "Initial selected value(s). A single value normally, or a character vector when multiple = TRUE.",
        "Allow selecting several values. input$<id> becomes a character vector and selections render as removable chips.",
        "Optional cap on the number of selected values in multiple mode; unselected rows disable once the cap is reached.",
        "Optional empty-value prompt.",
        "Disables browser interaction while server updates remain possible.",
        "CSS width applied to the runtime select wrapper.",
        "Additional class merged onto the runtime select wrapper.",
        "Control size. One of default, sm, or lg.",
        "Inline CSS styles applied to the runtime select wrapper.",
        "Applies aria-invalid and destructive border/ring styling."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_select_api_table",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_select_set_pro, {
    update_block_select(
      session,
      "showcase_select_preview",
      selected = "pro"
    )
    reactive_code(paste0(
      "update_block_select(\n",
      "  session = session,\n",
      "  input_id = \"showcase_select_preview\",\n",
      "  selected = \"pro\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_select_set_two, {
    update_block_select(
      session,
      "showcase_select_preview",
      selected = c("free", "pro")
    )
    reactive_code(paste0(
      "update_block_select(\n",
      "  session = session,\n",
      "  input_id = \"showcase_select_preview\",\n",
      "  selected = c(\"free\", \"pro\")\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_select_clear, {
    update_block_select(
      session,
      "showcase_select_preview",
      selected = NULL
    )
    reactive_code(paste0(
      "update_block_select(\n",
      "  session = session,\n",
      "  input_id = \"showcase_select_preview\",\n",
      "  selected = NULL\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_select_disable, {
    update_block_select(session, "showcase_select_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_select(\n",
      "  session = session,\n",
      "  input_id = \"showcase_select_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_select_enable, {
    update_block_select(session, "showcase_select_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_select(\n",
      "  session = session,\n",
      "  input_id = \"showcase_select_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_select_replace_choices, {
    update_block_select(
      session,
      "showcase_select_preview",
      choices = c(Starter = "starter", Growth = "growth", Scale = "scale"),
      selected = "growth",
      placeholder = "Choose a package",
      disabled = FALSE
    )
    reactive_code(paste0(
      "update_block_select(\n",
      "  session = session,\n",
      "  input_id = \"showcase_select_preview\",\n",
      "  choices = c(Starter = \"starter\", Growth = \"growth\", Scale = \"scale\"),\n",
      "  selected = \"growth\",\n",
      "  placeholder = \"Choose a package\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })
}
