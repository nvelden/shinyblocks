register_popover_showcase <- function(input, output, session) {
  swapped_body <- shiny::reactiveVal(FALSE)
  open_state <- shiny::reactiveVal(FALSE)

  shiny::observeEvent(
    input$showcase_popover_doc_open,
    {
      open_state(isTRUE(input$showcase_popover_doc_open))
    },
    ignoreNULL = FALSE
  )

  output$showcase_popover_preview_ui <- shiny::renderUI({
    trigger <- input$showcase_popover_doc_trigger %||% "Open popover"
    if (!nzchar(trigger)) trigger <- "Open popover"
    body <- if (isTRUE(swapped_body())) {
      "Body updated from the server."
    } else {
      input$showcase_popover_doc_body %||% ""
    }
    side <- input$showcase_popover_doc_side %||% "bottom"
    align <- input$showcase_popover_doc_align %||% "center"
    is_open <- isTRUE(open_state())

    style_val <- input$showcase_popover_doc_style %||% ""
    if (!nzchar(style_val)) style_val <- NULL

    class_val <- if (isTRUE(input$showcase_popover_doc_class)) {
      "showcase-popover-preview-custom"
    } else {
      NULL
    }

    block_popover(
      id = "showcase_popover_preview",
      trigger = trigger,
      side = side,
      align = align,
      open = is_open,
      style = style_val,
      class = class_val,
      htmltools::tags$p(body)
    )
  })
  shiny::outputOptions(
    output,
    "showcase_popover_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_popover_preview_value <- showcase_render_code({
    value <- input$showcase_popover_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (isTRUE(value)) {
      "TRUE"
    } else {
      "FALSE"
    }
    paste0("input$showcase_popover_preview = ", val_str)
  })
  shiny::outputOptions(
    output,
    "showcase_popover_preview_value",
    suspendWhenHidden = FALSE
  )

  output$showcase_popover_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    trigger <- input$showcase_popover_doc_trigger %||% "Open popover"
    body <- if (isTRUE(swapped_body())) {
      "Body updated from the server."
    } else {
      input$showcase_popover_doc_body %||% ""
    }
    side <- input$showcase_popover_doc_side %||% "bottom"
    align <- input$showcase_popover_doc_align %||% "center"
    is_open <- isTRUE(open_state())

    args <- c(
      'id = "showcase_popover_preview"',
      paste0("trigger = ", string_literal(trigger))
    )
    if (nzchar(body)) {
      args <- c(args, paste0("htmltools::tags$p(", string_literal(body), ")"))
    }
    if (!identical(side, "bottom")) {
      args <- c(args, paste0("side = ", string_literal(side)))
    }
    if (!identical(align, "center")) {
      args <- c(args, paste0("align = ", string_literal(align)))
    }
    if (is_open) {
      args <- c(args, "open = TRUE")
    }
    style_val <- input$showcase_popover_doc_style %||% ""
    if (nzchar(style_val)) {
      args <- c(args, paste0("style = ", string_literal(style_val)))
    }
    if (isTRUE(input$showcase_popover_doc_class)) {
      args <- c(args, 'class = "showcase-popover-preview-custom"')
    }

    paste0("block_popover(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_popover_preview_code",
    suspendWhenHidden = FALSE
  )

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_popover() code here."
  ))

  output$showcase_popover_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(
    output,
    "showcase_popover_reactive_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_popover_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("trigger", "...", "id", "side", "align", "open", "style", "class"),
      Type = c("character", "tag | tagList", "character", "character", "character", "logical", "character | list", "character"),
      Default = c("required", "NULL", "NULL", "\"bottom\"", "\"center\"", "FALSE", "NULL", "NULL"),
      Description = c(
        "Trigger button label. Renders a default-variant block_button that toggles the popover.",
        "Popover body content. Serialized to HTML.",
        "Optional input id. input$<id> reports open state when supplied.",
        "Side of the trigger to anchor on. One of bottom, top, left, right.",
        "Alignment along the anchored side. One of center, start, end.",
        "Initial open state.",
        "Optional inline CSS applied to the popover content container.",
        "Additional class merged onto the popover content container."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_popover_api_table",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_popover_open, {
    swapped_body(FALSE)
    open_state(TRUE)
    update_block_popover(session, "showcase_popover_preview", open = TRUE)
    reactive_code(paste0(
      "update_block_popover(\n",
      "  session = session,\n",
      "  input_id = \"showcase_popover_preview\",\n",
      "  open = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_popover_close, {
    swapped_body(FALSE)
    open_state(FALSE)
    update_block_popover(session, "showcase_popover_preview", open = FALSE)
    reactive_code(paste0(
      "update_block_popover(\n",
      "  session = session,\n",
      "  input_id = \"showcase_popover_preview\",\n",
      "  open = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_popover_reposition, {
    swapped_body(FALSE)
    open_state(TRUE)
    update_block_select(session, "showcase_popover_doc_side", selected = "top")
    update_block_select(session, "showcase_popover_doc_align", selected = "end")
    update_block_popover(
      session,
      "showcase_popover_preview",
      open = TRUE,
      side = "top",
      align = "end"
    )
    reactive_code(paste0(
      "update_block_popover(\n",
      "  session = session,\n",
      "  input_id = \"showcase_popover_preview\",\n",
      "  open = TRUE,\n",
      "  side = \"top\",\n",
      "  align = \"end\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_popover_swap_body, {
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    open_state(TRUE)
    swapped_body(!isTRUE(swapped_body()))
    next_body <- if (isTRUE(swapped_body())) {
      "Body updated from the server."
    } else {
      input$showcase_popover_doc_body %||% ""
    }
    update_block_popover(
      session,
      "showcase_popover_preview",
      open = TRUE,
      body = htmltools::tags$p(next_body)
    )
    reactive_code(paste0(
      "update_block_popover(\n",
      "  session = session,\n",
      "  input_id = \"showcase_popover_preview\",\n",
      "  open = TRUE,\n",
      "  body = htmltools::tags$p(",
      string_literal(next_body),
      ")\n",
      ")"
    ))
  })
}
