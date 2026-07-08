parse_toggle_group_choices <- function(text) {
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

parse_toggle_group_selected <- function(text, choices, type) {
  values <- as.character(choices)
  if (is.null(text) || !nzchar(text)) return(NULL)
  selected <- trimws(strsplit(text, ",", fixed = TRUE)[[1]])
  selected <- unique(selected[nzchar(selected) & selected %in% values])
  if (!length(selected)) return(NULL)
  if (identical(type, "single")) selected <- selected[[1]]
  selected
}

toggle_group_showcase_icons <- function(choices) {
  values <- as.character(choices)
  icon_pool <- c("layout-list", "layout-grid", "grid", "list")
  icons <- as.list(icon_pool[seq_len(min(length(values), length(icon_pool)))])
  names(icons) <- values[seq_along(icons)]
  icons
}

register_toggle_group_showcase <- function(input, output, session) {
  toggle_group_state <- shiny::reactive({
    choices <- parse_toggle_group_choices(input$showcase_toggle_group_doc_choices %||% "")
    if (!length(choices)) choices <- c(List = "list", Grid = "grid", Board = "board")
    type <- input$showcase_toggle_group_doc_type %||% "single"
    use_icons <- isTRUE(input$showcase_toggle_group_doc_icons)
    icon_only <- isTRUE(input$showcase_toggle_group_doc_icon_only) && use_icons

    disabled <- if (isTRUE(input$showcase_toggle_group_doc_disabled)) {
      TRUE
    } else if (isTRUE(input$showcase_toggle_group_doc_disabled_item)) {
      as.character(choices)[[length(choices)]]
    } else {
      FALSE
    }

    list(
      choices = choices,
      selected = parse_toggle_group_selected(
        input$showcase_toggle_group_doc_selected %||% "",
        choices,
        type
      ),
      type = type,
      variant = input$showcase_toggle_group_doc_variant %||% "default",
      size = input$showcase_toggle_group_doc_size %||% "default",
      icons = if (use_icons) toggle_group_showcase_icons(choices) else NULL,
      icon_only = icon_only,
      disabled = disabled,
      style = {
        style_val <- input$showcase_toggle_group_doc_style %||% ""
        if (nzchar(style_val)) style_val else NULL
      },
      class = if (isTRUE(input$showcase_toggle_group_doc_class)) {
        "showcase-toggle-group-preview-custom"
      } else {
        NULL
      }
    )
  })

  output$showcase_toggle_group_preview_ui <- shiny::renderUI({
    state <- toggle_group_state()
    label <- input$showcase_toggle_group_doc_label %||% "View"
    if (!nzchar(label)) label <- "View"

    block_field(
      block_field_label(label, `for` = "showcase_toggle_group_preview"),
      block_toggle_group(
        "showcase_toggle_group_preview",
        choices = state$choices,
        selected = state$selected,
        type = state$type,
        variant = state$variant,
        size = state$size,
        icons = state$icons,
        icon_only = state$icon_only,
        disabled = state$disabled,
        style = state$style,
        class = state$class
      )
    )
  })
  shiny::outputOptions(output, "showcase_toggle_group_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_toggle_group_preview_value <- showcase_render_code({
    value <- input$showcase_toggle_group_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (!length(value)) {
      "<EMPTY>"
    } else {
      paste(value, collapse = ", ")
    }
    paste0("input$showcase_toggle_group_preview = ", val_str)
  })
  shiny::outputOptions(output, "showcase_toggle_group_preview_value", suspendWhenHidden = FALSE)

  output$showcase_toggle_group_preview_code <- showcase_render_code({
    state <- toggle_group_state()

    choices_text <- paste(
      sprintf('"%s" = "%s"', names(state$choices), as.character(state$choices)),
      collapse = ", "
    )

    args <- c(
      'input_id = "showcase_toggle_group_preview"',
      paste0("choices = c(", choices_text, ")")
    )
    if (!is.null(state$selected)) {
      selected_text <- if (length(state$selected) > 1) {
        paste0("c(", paste(sprintf('"%s"', state$selected), collapse = ", "), ")")
      } else {
        sprintf('"%s"', state$selected)
      }
      args <- c(args, paste0("selected = ", selected_text))
    }
    if (!identical(state$type, "single")) {
      args <- c(args, paste0('type = "', state$type, '"'))
    }
    if (!identical(state$variant, "default")) {
      args <- c(args, paste0('variant = "', state$variant, '"'))
    }
    if (!identical(state$size, "default")) {
      args <- c(args, paste0('size = "', state$size, '"'))
    }
    if (!is.null(state$icons)) {
      icons_text <- paste(
        sprintf('%s = "%s"', names(state$icons), unlist(state$icons)),
        collapse = ", "
      )
      args <- c(args, paste0("icons = list(", icons_text, ")"))
    }
    if (isTRUE(state$icon_only)) args <- c(args, "icon_only = TRUE")
    if (isTRUE(state$disabled)) {
      args <- c(args, "disabled = TRUE")
    } else if (is.character(state$disabled)) {
      args <- c(args, sprintf('disabled = "%s"', state$disabled))
    }
    if (!is.null(state$style)) args <- c(args, paste0('style = "', state$style, '"'))
    if (!is.null(state$class)) {
      args <- c(args, 'class = "showcase-toggle-group-preview-custom"')
    }

    paste0(
      "block_toggle_group(\n  ",
      paste(args, collapse = ",\n  "),
      "\n)"
    )
  })
  shiny::outputOptions(output, "showcase_toggle_group_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_toggle_group() code here."
  ))

  output$showcase_toggle_group_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(output, "showcase_toggle_group_reactive_code", suspendWhenHidden = FALSE)

  output$showcase_toggle_group_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c(
        "input_id", "choices", "selected", "type", "variant", "size",
        "icons", "icon_only", "disabled", "style", "class"
      ),
      Type = c(
        "character", "named character | list", "character", "character",
        "character", "character", "named list", "logical",
        "logical | character", "character | list", "character"
      ),
      Default = c(
        "required", "required", "NULL", "\"single\"", "\"default\"",
        "\"default\"", "NULL", "FALSE", "FALSE", "NULL", "NULL"
      ),
      Description = c(
        "Input id. Reports a string (single) or character vector (multiple).",
        "Choice labels and values.",
        "Initial pressed value(s); NULL starts with nothing pressed.",
        "'single' (radio-like, pressing again releases) or 'multiple'. Create-only.",
        "Visual variant: 'default' (borderless) or 'outline'.",
        "Item size: 'default', 'sm', or 'lg'.",
        "Named list mapping choice values to vendored icon names or shiny.tag icons.",
        "Hide labels visually; labels become the accessible name. Requires icons.",
        "TRUE/FALSE for the whole group, or choice values to disable per item.",
        "Inline CSS styles applied to the toggle-group wrapper.",
        "Additional class merged onto the runtime toggle-group wrapper."
      )
    ))
  })
  shiny::outputOptions(output, "showcase_toggle_group_api_table", suspendWhenHidden = FALSE)

  shiny::observeEvent(input$showcase_toggle_group_select_grid, {
    update_block_toggle_group(session, "showcase_toggle_group_preview", selected = "grid")
    reactive_code(paste0(
      "update_block_toggle_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_toggle_group_preview\",\n",
      "  selected = \"grid\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_toggle_group_clear, {
    update_block_toggle_group(session, "showcase_toggle_group_preview", selected = NULL)
    reactive_code(paste0(
      "update_block_toggle_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_toggle_group_preview\",\n",
      "  selected = NULL\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_toggle_group_disable, {
    update_block_toggle_group(session, "showcase_toggle_group_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_toggle_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_toggle_group_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_toggle_group_enable, {
    update_block_toggle_group(session, "showcase_toggle_group_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_toggle_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_toggle_group_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_toggle_group_swap_choices, {
    update_block_toggle_group(
      session,
      "showcase_toggle_group_preview",
      choices = c(Day = "day", Week = "week", Month = "month"),
      selected = "week"
    )
    reactive_code(paste0(
      "update_block_toggle_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_toggle_group_preview\",\n",
      "  choices = c(Day = \"day\", Week = \"week\", Month = \"month\"),\n",
      "  selected = \"week\"\n",
      ")"
    ))
  })
}
