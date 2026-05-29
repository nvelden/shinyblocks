register_dialog_showcase <- function(input, output, session) {
  dialog_size_max_width <- function(size) {
    switch(
      size %||% "default",
      sm = "24rem",
      lg = "48rem",
      xl = "64rem",
      "32rem"
    )
  }

  default_footer <- function() {
    htmltools::tagList(
      block_button("Cancel", variant = "outline"),
      block_button("Continue")
    )
  }

  custom_footer <- function() {
    htmltools::tagList(
      block_button("Discard", variant = "outline"),
      block_button("Save draft", variant = "secondary"),
      block_button("Publish")
    )
  }

  footer_kind <- shiny::reactiveVal("default")

  inline_dialog_preview <- function(title, description, footer_tags, size, hide_title, extra_style = NULL, extra_class = NULL) {
    title_style <- if (isTRUE(hide_title)) {
      "position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0,0,0,0); white-space: nowrap; border: 0;"
    } else {
      "margin: 0; font-size: 1.125rem; font-weight: 600; line-height: 1.2; letter-spacing: -0.01em;"
    }

    # Render the inline preview at the requested size and only clamp if the
    # canvas is too narrow. The previous `width: 100%; max-width: <size>`
    # collapsed `sm` and `default` to identical widths in narrow viewports.
    base_style <- sprintf(
      paste0(
        "position: relative; display: flex; flex-direction: column; gap: 1rem;",
        " width: min(%s, 100%%); max-width: 100%%; max-height: min(32rem, calc(100vh - 4rem));",
        " overflow: auto; margin: 0 auto; box-sizing: border-box;",
        " border: 1px solid var(--border);",
        " border-radius: calc(var(--radius) * 1.4); background-color: var(--background);",
        " color: var(--foreground); padding: 1.5rem;",
        " box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);"
      ),
      dialog_size_max_width(size)
    )
    if (!is.null(extra_style) && nzchar(extra_style)) {
      base_style <- paste0(base_style, " ", extra_style)
    }

    htmltools::tags$div(
      role = "dialog",
      "aria-modal" = "false",
      "data-slot" = "dialog-content",
      "data-size" = size,
      class = merge_classes("sb-dialog-content", extra_class),
      style = base_style,
      htmltools::tags$div(
        style = "display: flex; flex-direction: column; gap: 0.375rem;",
        htmltools::tags$h2(style = title_style, title),
        if (!is.null(description) && nzchar(description)) {
          htmltools::tags$p(
            style = "margin: 0; font-size: 0.875rem; color: var(--muted-foreground); line-height: 1.4;",
            description
          )
        }
      ),
      htmltools::tags$div(
        style = "font-size: 0.875rem; line-height: 1.5;",
        htmltools::tags$p(
          style = "margin: 0;",
          "Adjust the controls on the right to see this preview react."
        )
      ),
      if (!is.null(footer_tags)) {
        htmltools::tags$div(
          style = "display: flex; flex-wrap: wrap; justify-content: flex-end; gap: 0.5rem;",
          footer_tags
        )
      }
    )
  }

  output$showcase_dialog_trigger_ui <- shiny::renderUI({
    label <- input$showcase_dialog_doc_trigger %||% ""
    if (!nzchar(label)) {
      return(htmltools::tags$p(
        style = "font-size: 0.875rem; color: var(--muted-foreground); margin: 0;",
        "trigger label is empty - set one in the Content panel to render a trigger button here."
      ))
    }
    showcase_action_button(
      "showcase_dialog_trigger_click",
      label,
      variant = "default",
      size = "default",
      class = NULL
    )
  })
  shiny::outputOptions(
    output,
    "showcase_dialog_trigger_ui",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_dialog_trigger_click, {
    update_block_dialog(session, "showcase_dialog_preview", open = TRUE)
  })

  shiny::observe({
    style_val <- input$showcase_dialog_doc_style %||% ""
    update_block_dialog(
      session,
      "showcase_dialog_preview",
      size = input$showcase_dialog_doc_size %||% "default",
      class = if (isTRUE(input$showcase_dialog_doc_class)) {
        "showcase-dialog-preview-custom"
      } else {
        NULL
      },
      style = if (nzchar(style_val)) style_val else NULL
    )
  })

  output$showcase_dialog_preview_value <- showcase_render_code({
    value <- input$showcase_dialog_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (isTRUE(value)) {
      "TRUE"
    } else {
      "FALSE"
    }
    paste0("input$showcase_dialog_preview = ", val_str)
  })
  shiny::outputOptions(
    output,
    "showcase_dialog_preview_value",
    suspendWhenHidden = FALSE
  )

  output$showcase_dialog_preview_ui <- shiny::renderUI({
    title <- input$showcase_dialog_doc_title %||% "Confirm action"
    description <- input$showcase_dialog_doc_description %||% ""
    size <- input$showcase_dialog_doc_size %||% "default"
    hide_title <- isTRUE(input$showcase_dialog_doc_hide_title)

    footer_tags <- if (isTRUE(input$showcase_dialog_doc_footer)) {
      if (identical(footer_kind(), "custom")) custom_footer() else default_footer()
    } else {
      NULL
    }

    extra_style <- input$showcase_dialog_doc_style %||% ""
    if (!nzchar(extra_style)) extra_style <- NULL

    extra_class <- if (isTRUE(input$showcase_dialog_doc_class)) {
      "showcase-dialog-preview-custom"
    } else {
      NULL
    }

    inline_dialog_preview(title, description, footer_tags, size, hide_title, extra_style, extra_class)
  })
  shiny::outputOptions(
    output,
    "showcase_dialog_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_dialog_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    title_val <- input$showcase_dialog_doc_title %||% "Confirm action"
    desc_val <- input$showcase_dialog_doc_description %||% ""
    trigger_val <- input$showcase_dialog_doc_trigger %||% ""
    size_val <- input$showcase_dialog_doc_size %||% "default"
    hide_title_val <- isTRUE(input$showcase_dialog_doc_hide_title)
    footer_val <- isTRUE(input$showcase_dialog_doc_footer)
    footer_kind_val <- footer_kind()

    args <- c(
      'id = "showcase_dialog_preview"',
      paste0("title = ", string_literal(title_val))
    )
    if (nzchar(desc_val)) {
      args <- c(args, paste0("description = ", string_literal(desc_val)))
    }
    if (footer_val) {
      footer_str <- if (identical(footer_kind_val, "custom")) {
        'footer = htmltools::tagList(\n    block_button("Discard", variant = "outline"),\n    block_button("Save draft", variant = "secondary"),\n    block_button("Publish")\n  )'
      } else {
        'footer = htmltools::tagList(\n    block_button("Cancel", variant = "outline"),\n    block_button("Continue")\n  )'
      }
      args <- c(args, footer_str)
    }
    if (nzchar(trigger_val)) {
      args <- c(args, paste0("trigger = ", string_literal(trigger_val)))
    }
    if (!identical(size_val, "default")) {
      args <- c(args, paste0("size = ", string_literal(size_val)))
    }
    if (hide_title_val) {
      args <- c(args, "hide_title = TRUE")
    }
    style_val <- input$showcase_dialog_doc_style %||% ""
    if (nzchar(style_val)) {
      args <- c(args, paste0("style = ", string_literal(style_val)))
    }
    if (isTRUE(input$showcase_dialog_doc_class)) {
      args <- c(args, 'class = "showcase-dialog-preview-custom"')
    }

    paste0("block_dialog(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_dialog_preview_code",
    suspendWhenHidden = FALSE
  )

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_dialog() code here."
  ))

  output$showcase_dialog_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(
    output,
    "showcase_dialog_reactive_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_dialog_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("id", "title", "description", "footer", "trigger", "open", "size", "hide_title", "class", "style"),
      Type = c("character", "character | tag", "character | tag", "tag | tagList", "character", "logical", "character", "logical", "character", "character | named list"),
      Default = c("required", "required", "NULL", "NULL", "NULL", "FALSE", "\"default\"", "FALSE", "NULL", "NULL"),
      Description = c(
        "Required input id. input$<id> reports the open state as a boolean.",
        "Required dialog title. Used as the accessible name.",
        "Optional description rendered below the title.",
        "Optional footer content (typically action buttons). Right-aligned wrapping flex row.",
        "Optional label. Renders a default-variant block_button that opens the dialog locally.",
        "Initial open state.",
        "Content max-width preset. One of sm, default, lg, xl.",
        "Visually hide the title while keeping it as the accessible name.",
        "Additional class merged onto the dialog content container.",
        "Optional inline CSS styles for the dialog content container."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_dialog_api_table",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_dialog_open, {
    update_block_dialog(session, "showcase_dialog_preview", open = TRUE)
    reactive_code(paste0(
      "update_block_dialog(\n",
      "  session = session,\n",
      "  input_id = \"showcase_dialog_preview\",\n",
      "  open = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_dialog_close, {
    update_block_dialog(session, "showcase_dialog_preview", open = FALSE)
    reactive_code(paste0(
      "update_block_dialog(\n",
      "  session = session,\n",
      "  input_id = \"showcase_dialog_preview\",\n",
      "  open = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_dialog_resize_sm, {
    update_block_select(session, "showcase_dialog_doc_size", selected = "sm")
    update_block_dialog(session, "showcase_dialog_preview", size = "sm")
    reactive_code(paste0(
      "update_block_dialog(\n",
      "  session = session,\n",
      "  input_id = \"showcase_dialog_preview\",\n",
      "  size = \"sm\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_dialog_resize_lg, {
    update_block_select(session, "showcase_dialog_doc_size", selected = "lg")
    update_block_dialog(session, "showcase_dialog_preview", size = "lg")
    reactive_code(paste0(
      "update_block_dialog(\n",
      "  session = session,\n",
      "  input_id = \"showcase_dialog_preview\",\n",
      "  size = \"lg\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_dialog_swap_footer, {
    next_kind <- if (identical(footer_kind(), "default")) "custom" else "default"
    footer_kind(next_kind)
    new_footer <- if (identical(next_kind, "custom")) custom_footer() else default_footer()
    update_block_dialog(
      session,
      "showcase_dialog_preview",
      footer = new_footer
    )
    code_body <- if (identical(next_kind, "custom")) {
      paste0(
        "  footer = htmltools::tagList(\n",
        "    block_button(\"Discard\", variant = \"outline\"),\n",
        "    block_button(\"Save draft\", variant = \"secondary\"),\n",
        "    block_button(\"Publish\")\n",
        "  )"
      )
    } else {
      paste0(
        "  footer = htmltools::tagList(\n",
        "    block_button(\"Cancel\", variant = \"outline\"),\n",
        "    block_button(\"Continue\")\n",
        "  )"
      )
    }
    reactive_code(paste0(
      "update_block_dialog(\n",
      "  session = session,\n",
      "  input_id = \"showcase_dialog_preview\",\n",
      code_body, "\n",
      ")"
    ))
  })
}
