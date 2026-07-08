parse_accordion_items <- function(text) {
  if (is.null(text) || !nzchar(text)) return(list())
  lines <- strsplit(text, "\n", fixed = TRUE)[[1]]
  lines <- trimws(lines)
  lines <- lines[nzchar(lines)]
  if (!length(lines)) return(list())

  lapply(lines, function(line) {
    parts <- trimws(strsplit(line, "|", fixed = TRUE)[[1]])
    value <- parts[[1]]
    title <- if (length(parts) >= 2) parts[[2]] else parts[[1]]
    body <- if (length(parts) >= 3) parts[[3]] else "Panel content."
    list(value = value, title = title, body = body)
  })
}

register_accordion_showcase <- function(input, output, session) {
  accordion_state <- shiny::reactive({
    items <- parse_accordion_items(input$showcase_accordion_doc_items %||% "")
    if (!length(items)) {
      items <- list(
        list(value = "one", title = "Item one", body = "First panel body.")
      )
    }
    type <- input$showcase_accordion_doc_type %||% "single"
    values <- vapply(items, function(i) i$value, character(1))

    open_raw <- trimws(strsplit(input$showcase_accordion_doc_open %||% "", ",", fixed = TRUE)[[1]])
    open_raw <- unique(open_raw[nzchar(open_raw) & open_raw %in% values])
    open <- if (!length(open_raw)) {
      NULL
    } else if (identical(type, "single")) {
      open_raw[[1]]
    } else {
      open_raw
    }

    disabled_value <- if (isTRUE(input$showcase_accordion_doc_disabled)) {
      values[[length(values)]]
    } else {
      NULL
    }

    list(
      items = items,
      type = type,
      collapsible = isTRUE(input$showcase_accordion_doc_collapsible),
      open = open,
      icons = isTRUE(input$showcase_accordion_doc_icons),
      disabled_value = disabled_value,
      style = {
        style_val <- input$showcase_accordion_doc_style %||% ""
        if (nzchar(style_val)) style_val else NULL
      },
      class = if (isTRUE(input$showcase_accordion_doc_class)) {
        "showcase-accordion-preview-custom"
      } else {
        NULL
      }
    )
  })

  build_accordion_items <- function(state) {
    icon_pool <- c("help-circle", "package", "dollar-sign", "settings", "star")
    lapply(seq_along(state$items), function(i) {
      item <- state$items[[i]]
      block_accordion_item(
        value = item$value,
        title = item$title,
        htmltools::tags$p(style = "margin: 0; color: var(--muted-foreground);", item$body),
        icon = if (isTRUE(state$icons)) icon_pool[[((i - 1) %% length(icon_pool)) + 1]] else NULL,
        disabled = identical(item$value, state$disabled_value)
      )
    })
  }

  output$showcase_accordion_preview_ui <- shiny::renderUI({
    state <- accordion_state()
    do.call(
      block_accordion,
      c(
        build_accordion_items(state),
        list(
          id = "showcase_accordion_preview",
          type = state$type,
          collapsible = state$collapsible,
          open = state$open,
          style = state$style,
          class = state$class
        )
      )
    )
  })
  shiny::outputOptions(output, "showcase_accordion_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_accordion_preview_value <- showcase_render_code({
    value <- input$showcase_accordion_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (!length(value)) {
      "<EMPTY>"
    } else {
      paste(value, collapse = ", ")
    }
    paste0("input$showcase_accordion_preview = ", val_str)
  })
  shiny::outputOptions(output, "showcase_accordion_preview_value", suspendWhenHidden = FALSE)

  output$showcase_accordion_preview_code <- showcase_render_code({
    state <- accordion_state()

    item_lines <- vapply(state$items, function(item) {
      disabled <- if (identical(item$value, state$disabled_value)) ", disabled = TRUE" else ""
      sprintf(
        '  block_accordion_item("%s", "%s", "%s"%s)',
        item$value, item$title, item$body, disabled
      )
    }, character(1))

    args <- paste(item_lines, collapse = ",\n")
    tail <- c('  id = "showcase_accordion_preview"')
    if (!identical(state$type, "single")) {
      tail <- c(tail, sprintf('  type = "%s"', state$type))
    }
    if (identical(state$type, "single") && !isTRUE(state$collapsible)) {
      tail <- c(tail, "  collapsible = FALSE")
    }
    if (!is.null(state$open)) {
      open_text <- if (length(state$open) > 1) {
        paste0("c(", paste(sprintf('"%s"', state$open), collapse = ", "), ")")
      } else {
        sprintf('"%s"', state$open)
      }
      tail <- c(tail, paste0("  open = ", open_text))
    }
    if (!is.null(state$style)) tail <- c(tail, sprintf('  style = "%s"', state$style))
    if (!is.null(state$class)) {
      tail <- c(tail, '  class = "showcase-accordion-preview-custom"')
    }

    paste0(
      "block_accordion(\n",
      args, ",\n",
      paste(tail, collapse = ",\n"),
      "\n)"
    )
  })
  shiny::outputOptions(output, "showcase_accordion_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_accordion() code here."
  ))

  output$showcase_accordion_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(output, "showcase_accordion_reactive_code", suspendWhenHidden = FALSE)

  output$showcase_accordion_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c(
        "...", "id", "type", "collapsible", "open", "style", "class"
      ),
      Type = c(
        "block_accordion_item()", "character", "character", "logical",
        "character", "character", "character"
      ),
      Default = c(
        "required", "NULL", "\"single\"", "FALSE", "NULL", "NULL", "NULL"
      ),
      Description = c(
        "One or more block_accordion_item() sections.",
        "Input id. Reports the open value(s): a string/NULL (single) or a character vector (multiple).",
        "'single' (one open at a time) or 'multiple'. Create-only.",
        "Single mode: whether the open item can collapse to none. Create-only.",
        "Item value(s) open initially. Must match item values.",
        "Inline CSS styles applied to the accordion wrapper.",
        "Additional class merged onto the accordion wrapper."
      )
    ))
  })
  shiny::outputOptions(output, "showcase_accordion_api_table", suspendWhenHidden = FALSE)

  shiny::observeEvent(input$showcase_accordion_open_billing, {
    update_block_accordion(session, "showcase_accordion_preview", open = "billing")
    reactive_code(paste0(
      "update_block_accordion(\n",
      "  session = session,\n",
      "  input_id = \"showcase_accordion_preview\",\n",
      "  open = \"billing\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_accordion_open_all, {
    values <- vapply(accordion_state()$items, function(i) i$value, character(1))
    update_block_accordion(session, "showcase_accordion_preview", open = values)
    reactive_code(paste0(
      "update_block_accordion(\n",
      "  session = session,\n",
      "  input_id = \"showcase_accordion_preview\",\n",
      "  open = c(", paste(sprintf('"%s"', values), collapse = ", "), ")\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_accordion_close_all, {
    update_block_accordion(session, "showcase_accordion_preview", open = NULL)
    reactive_code(paste0(
      "update_block_accordion(\n",
      "  session = session,\n",
      "  input_id = \"showcase_accordion_preview\",\n",
      "  open = NULL\n",
      ")"
    ))
  })
}
