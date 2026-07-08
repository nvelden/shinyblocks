register_combobox_showcase <- function(input, output, session) {
  combobox_doc_choices <- function(key) {
    switch(
      key %||% "frameworks",
      countries = c(France = "fr", Germany = "de", Japan = "jp", Brazil = "br", Canada = "ca"),
      fruits = c(Apple = "apple", Banana = "banana", Blueberry = "blueberry", Grapes = "grapes"),
      c(React = "react", Vue = "vue", Svelte = "svelte", Angular = "angular", Solid = "solid")
    )
  }

  combobox_doc_max_items <- function(key) {
    key <- key %||% "none"
    if (identical(key, "none")) NULL else as.integer(key)
  }

  combobox_doc_selected <- function() {
    if (isTRUE(input$showcase_combobox_doc_multiple)) {
      input$showcase_combobox_doc_selected_multi
    } else {
      input$showcase_combobox_doc_selected_single
    }
  }

  output$showcase_combobox_preview_value <- showcase_render_code({
    value <- input$showcase_combobox_preview
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
    paste0("input$showcase_combobox_preview = ", val_str)
  })
  shiny::outputOptions(
    output,
    "showcase_combobox_preview_value",
    suspendWhenHidden = FALSE
  )

  output$showcase_combobox_doc_selected_ui <- shiny::renderUI({
    choices <- combobox_doc_choices(input$showcase_combobox_doc_choices)
    multiple <- isTRUE(input$showcase_combobox_doc_multiple)
    block_select(
      if (multiple) "showcase_combobox_doc_selected_multi" else "showcase_combobox_doc_selected_single",
      choices = choices,
      selected = unname(choices[[1]]),
      multiple = multiple,
      placeholder = if (multiple) "Select default value(s)" else NULL
    )
  })
  shiny::outputOptions(
    output,
    "showcase_combobox_doc_selected_ui",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_combobox_doc_class, {
    update_block_combobox(
      session,
      "showcase_combobox_preview",
      class = if (isTRUE(input$showcase_combobox_doc_class)) {
        "showcase-select-preview-custom"
      } else {
        NULL
      }
    )
  }, ignoreInit = TRUE)

  output$showcase_combobox_preview_ui <- shiny::renderUI({
    choices <- combobox_doc_choices(input$showcase_combobox_doc_choices)
    multiple <- isTRUE(input$showcase_combobox_doc_multiple)
    max_items <- combobox_doc_max_items(input$showcase_combobox_doc_max_items)

    chosen <- combobox_doc_selected()
    chosen <- chosen[chosen %in% unname(choices)]
    if (multiple) {
      selected <- chosen
      if (!is.null(max_items) && length(selected) > max_items) {
        selected <- selected[seq_len(max_items)]
      }
    } else {
      selected <- if (length(chosen)) chosen[[1]] else unname(choices[[1]])
    }

    placeholder <- input$showcase_combobox_doc_placeholder %||% ""
    if (!nzchar(placeholder)) {
      placeholder <- NULL
    }

    search_placeholder <- input$showcase_combobox_doc_search %||% ""
    if (!nzchar(search_placeholder)) {
      search_placeholder <- NULL
    }

    empty_message <- input$showcase_combobox_doc_empty %||% ""
    if (!nzchar(empty_message)) {
      empty_message <- NULL
    }

    width <- input$showcase_combobox_doc_width %||% "100%"
    if (!nzchar(width)) {
      width <- "100%"
    }

    style <- input$showcase_combobox_doc_style %||% ""
    if (!nzchar(style)) {
      style <- NULL
    }

    block_combobox(
      input_id = "showcase_combobox_preview",
      choices = choices,
      selected = selected,
      placeholder = placeholder,
      search_placeholder = search_placeholder,
      empty_message = empty_message,
      disabled = isTRUE(input$showcase_combobox_doc_disabled),
      width = width,
      style = style,
      class = if (isTRUE(input$showcase_combobox_doc_class)) {
        "showcase-select-preview-custom"
      } else {
        NULL
      },
      size = input$showcase_combobox_doc_size %||% "default",
      invalid = isTRUE(input$showcase_combobox_doc_invalid),
      multiple = multiple,
      max_items = if (multiple) max_items else NULL
    )
  })
  shiny::outputOptions(
    output,
    "showcase_combobox_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_combobox_preview_code <- showcase_render_code({
    choices_val <- input$showcase_combobox_doc_choices %||% "frameworks"
    choices_str <- switch(
      choices_val,
      countries = 'c(France = "fr", Germany = "de", Japan = "jp", Brazil = "br", Canada = "ca")',
      fruits = 'c(Apple = "apple", Banana = "banana", Blueberry = "blueberry", Grapes = "grapes")',
      'c(React = "react", Vue = "vue", Svelte = "svelte", Angular = "angular", Solid = "solid")'
    )

    choices <- combobox_doc_choices(choices_val)
    multiple_val <- isTRUE(input$showcase_combobox_doc_multiple)
    max_items_val <- combobox_doc_max_items(input$showcase_combobox_doc_max_items)
    selected_val <- combobox_doc_selected()
    selected_val <- selected_val[selected_val %in% unname(choices)]
    placeholder_val <- input$showcase_combobox_doc_placeholder
    search_val <- input$showcase_combobox_doc_search
    empty_val <- input$showcase_combobox_doc_empty
    width_val <- input$showcase_combobox_doc_width
    style_val <- input$showcase_combobox_doc_style
    class_val <- input$showcase_combobox_doc_class
    size_val <- input$showcase_combobox_doc_size
    disabled_val <- input$showcase_combobox_doc_disabled
    invalid_val <- input$showcase_combobox_doc_invalid

    args <- c(
      'input_id = "showcase_combobox_preview"',
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
    if (!is.null(search_val) && nzchar(search_val) && search_val != "Search...") {
      args <- c(args, paste0('search_placeholder = "', search_val, '"'))
    }
    if (!is.null(empty_val) && nzchar(empty_val) && empty_val != "No results found.") {
      args <- c(args, paste0('empty_message = "', empty_val, '"'))
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

    paste0("block_combobox(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_combobox_preview_code",
    suspendWhenHidden = FALSE
  )

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_combobox() code here."
  ))

  output$showcase_combobox_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(
    output,
    "showcase_combobox_reactive_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_combobox_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("choices", "selected", "multiple", "max_items", "placeholder", "search_placeholder", "empty_message", "disabled", "width", "class", "size", "style", "invalid"),
      Type = c("character | list", "character", "logical", "integer", "character", "character", "character", "logical", "character", "character", "character", "character", "logical"),
      Default = c("required", "NULL", "FALSE", "NULL", "NULL", "\"Search...\"", "\"No results found.\"", "FALSE", "NULL", "NULL", "\"default\"", "NULL", "FALSE"),
      Description = c(
        "The labels and values available in the combobox.",
        "Initial selected value(s). A single value normally, or a character vector when multiple = TRUE.",
        "Allow selecting several values. input$<id> becomes a character vector and selections render as removable chips.",
        "Optional cap on the number of selected values in multiple mode; unselected rows disable once the cap is reached.",
        "Optional empty-value prompt shown on the trigger.",
        "Placeholder shown in the type-to-filter search box.",
        "Message shown in the popup when the filter matches no choices.",
        "Disables browser interaction while server updates remain possible.",
        "CSS width applied to the runtime combobox wrapper.",
        "Additional class merged onto the runtime combobox wrapper.",
        "Control size. One of default, sm, or lg.",
        "Inline CSS styles applied to the runtime combobox wrapper.",
        "Applies aria-invalid and destructive border/ring styling."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_combobox_api_table",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_combobox_set_vue, {
    update_block_combobox(
      session,
      "showcase_combobox_preview",
      selected = "vue"
    )
    reactive_code(paste0(
      "update_block_combobox(\n",
      "  session = session,\n",
      "  input_id = \"showcase_combobox_preview\",\n",
      "  selected = \"vue\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_combobox_set_two, {
    update_block_combobox(
      session,
      "showcase_combobox_preview",
      selected = c("react", "vue")
    )
    reactive_code(paste0(
      "update_block_combobox(\n",
      "  session = session,\n",
      "  input_id = \"showcase_combobox_preview\",\n",
      "  selected = c(\"react\", \"vue\")\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_combobox_clear, {
    update_block_combobox(
      session,
      "showcase_combobox_preview",
      selected = NULL
    )
    reactive_code(paste0(
      "update_block_combobox(\n",
      "  session = session,\n",
      "  input_id = \"showcase_combobox_preview\",\n",
      "  selected = NULL\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_combobox_disable, {
    update_block_combobox(session, "showcase_combobox_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_combobox(\n",
      "  session = session,\n",
      "  input_id = \"showcase_combobox_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_combobox_enable, {
    update_block_combobox(session, "showcase_combobox_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_combobox(\n",
      "  session = session,\n",
      "  input_id = \"showcase_combobox_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_combobox_replace_choices, {
    update_block_combobox(
      session,
      "showcase_combobox_preview",
      choices = c(Python = "python", Rust = "rust", Go = "go"),
      selected = "rust",
      placeholder = "Choose a language",
      disabled = FALSE
    )
    reactive_code(paste0(
      "update_block_combobox(\n",
      "  session = session,\n",
      "  input_id = \"showcase_combobox_preview\",\n",
      "  choices = c(Python = \"python\", Rust = \"rust\", Go = \"go\"),\n",
      "  selected = \"rust\",\n",
      "  placeholder = \"Choose a language\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })
}
