register_select_showcase <- function(input, output, session) {
  select_doc_choices <- function(key) {
    switch(
      key %||% "plans",
      frameworks = c(React = "react", Vue = "vue", Svelte = "svelte", Angular = "angular"),
      fruits = c(Apple = "apple", Banana = "banana", Blueberry = "blueberry", Grapes = "grapes"),
      c(Free = "free", Pro = "pro", Team = "team")
    )
  }

  output$showcase_select_preview_value <- shiny::renderText({
    value <- input$showcase_select_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (identical(value, "")) {
      "<EMPTY>"
    } else {
      paste0('"', value, '"')
    }
    paste0("input$showcase_select_preview = ", val_str)
  })
  shiny::outputOptions(
    output,
    "showcase_select_preview_value",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_select_doc_choices, {
    choices <- select_doc_choices(input$showcase_select_doc_choices)
    update_block_select(
      session,
      "showcase_select_doc_selected",
      choices = choices,
      selected = unname(choices[[1]])
    )
  }, ignoreInit = TRUE)

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
    selected <- input$showcase_select_doc_selected
    if (identical(selected, "")) {
      selected <- NULL
    } else if (is.null(selected) || !selected %in% unname(choices)) {
      selected <- unname(choices[[1]])
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
      invalid = isTRUE(input$showcase_select_doc_invalid)
    )
  })
  shiny::outputOptions(
    output,
    "showcase_select_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_select_preview_code <- shiny::renderText({
    choices_val <- input$showcase_select_doc_choices %||% "plans"
    choices_str <- switch(
      choices_val,
      frameworks = 'c(React = "react", Vue = "vue", Svelte = "svelte", Angular = "angular")',
      fruits = 'c(Apple = "apple", Banana = "banana", Blueberry = "blueberry", Grapes = "grapes")',
      'c(Free = "free", Pro = "pro", Team = "team")'
    )

    selected_val <- input$showcase_select_doc_selected
    placeholder_val <- input$showcase_select_doc_placeholder
    width_val <- input$showcase_select_doc_width
    style_val <- input$showcase_select_doc_style
    class_val <- input$showcase_select_doc_class
    size_val <- input$showcase_select_doc_size
    disabled_val <- input$showcase_select_doc_disabled
    invalid_val <- input$showcase_select_doc_invalid

    args <- c(
      'input_id = "showcase_select_preview"',
      paste0('choices = ', choices_str)
    )

    if (!is.null(selected_val) && selected_val != "") {
      args <- c(args, paste0('selected = "', selected_val, '"'))
    }
    if (!is.null(placeholder_val) && nzchar(placeholder_val)) {
      args <- c(args, paste0('placeholder = "', placeholder_val, '"'))
    }
    if (isTRUE(disabled_val)) {
      args <- c(args, 'disabled = TRUE')
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
      args <- c(args, 'invalid = TRUE')
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

  output$showcase_select_reactive_code <- shiny::renderText({
    reactive_code()
  })
  shiny::outputOptions(
    output,
    "showcase_select_reactive_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_select_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("choices", "selected", "placeholder", "disabled", "width", "class", "size", "style", "invalid"),
      Type = c("character | list", "character", "character", "logical", "character", "character", "character", "character", "logical"),
      Default = c("required", "NULL", "NULL", "FALSE", "NULL", "NULL", "\"default\"", "NULL", "FALSE"),
      Description = c(
        "The labels and values available in the select.",
        "Initial selected value. It must match one of the current choices.",
        "Optional empty-value prompt.",
        "Disables browser interaction while server updates remain possible.",
        "CSS width applied to the runtime select wrapper.",
        "Additional class merged onto the runtime select wrapper.",
        "Control size. One of default, sm, or lg.",
        "Inline CSS styles applied to the runtime select wrapper.",
        "Applies aria-invalid and destructive border/ring styling."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
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
