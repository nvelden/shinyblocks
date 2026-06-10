register_toast_showcase <- function(input, output, session) {
  toaster_id <- "showcase_toaster"

  parse_duration <- function(value) {
    raw <- value %||% "5000"
    if (identical(raw, "0 (sticky)")) {
      return(0)
    }
    suppressWarnings(as.numeric(raw)) %||% 5000
  }

  current_icon <- function() {
    icon <- input$showcase_toast_doc_icon %||% "check-circle"
    if (identical(icon, "none")) NULL else icon
  }

  variant_tokens <- function(variant) {
    switch(
      variant,
      destructive = list(bg = "var(--card)", fg = "var(--destructive)", border = "var(--destructive-border)"),
      success = list(bg = "var(--success)", fg = "var(--success-foreground)", border = "var(--success-border)"),
      warning = list(bg = "var(--warning)", fg = "var(--warning-foreground)", border = "var(--warning-border)"),
      info = list(bg = "var(--info)", fg = "var(--info-foreground)", border = "var(--info-border)"),
      list(bg = "var(--card)", fg = "var(--card-foreground)", border = "var(--border)")
    )
  }

  # Inline facsimile of a rendered toast so the variant/icon look updates live in
  # the preview without firing. The real toaster (below) renders the actual
  # portal toast when an action button is clicked.
  output$showcase_toast_preview_ui <- shiny::renderUI({
    variant <- input$showcase_toast_doc_variant %||% "success"
    title <- input$showcase_toast_doc_title %||% "Changes saved"
    description <- input$showcase_toast_doc_description %||% ""
    icon <- current_icon()
    dismissible <- isTRUE(input$showcase_toast_doc_dismissible)
    tokens <- variant_tokens(variant)

    htmltools::tags$div(
      style = paste0(
        "position: relative; display: grid; grid-template-columns: auto minmax(0, 1fr);",
        " column-gap: 0.75rem; width: min(360px, 100%); border: 1px solid ", tokens$border, ";",
        " border-radius: var(--radius); padding: 0.75rem 2.25rem 0.75rem 1rem;",
        " background-color: ", tokens$bg, "; color: ", tokens$fg, ";",
        " box-shadow: var(--sb-overlay-shadow); font-size: 0.875rem; line-height: 1.25rem;"
      ),
      if (!is.null(icon)) {
        htmltools::tags$div(
          style = "display: flex; align-items: flex-start; padding-top: 0.125rem;",
          block_icon(icon, size = "sm")
        )
      },
      htmltools::tags$div(
        style = "display: flex; flex-direction: column; gap: 0.25rem; min-width: 0;",
        htmltools::tags$div(
          style = "font-weight: 500; letter-spacing: -0.025em; line-height: 1.2;",
          title
        ),
        if (nzchar(description)) {
          htmltools::tags$div(style = "font-size: 0.8125rem; opacity: 0.9;", description)
        }
      ),
      if (dismissible) {
        htmltools::tags$div(
          style = "position: absolute; top: 0.5rem; right: 0.5rem; opacity: 0.6; font-size: 1rem; line-height: 1;",
          htmltools::HTML("&times;")
        )
      }
    )
  })
  shiny::outputOptions(output, "showcase_toast_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_toast_preview_value <- showcase_render_code({
    value <- input[[toaster_id]]
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else {
      sprintf(
        "list(action = \"%s\", id = %s, seq = %s)",
        value$action %||% "",
        if (is.null(value$id)) "NULL" else paste0("\"", value$id, "\""),
        value$seq %||% 0
      )
    }
    paste0("input$", toaster_id, " = ", val_str)
  })
  shiny::outputOptions(output, "showcase_toast_preview_value", suspendWhenHidden = FALSE)

  output$showcase_toast_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    position <- input$showcase_toast_doc_position %||% "bottom-right"
    ui_line <- if (identical(position, "bottom-right")) {
      "block_toaster(\"notifications\")"
    } else {
      paste0("block_toaster(\"notifications\", position = ", string_literal(position), ")")
    }

    title_val <- input$showcase_toast_doc_title %||% "Changes saved"
    desc_val <- input$showcase_toast_doc_description %||% ""
    variant_val <- input$showcase_toast_doc_variant %||% "success"
    icon <- current_icon()
    duration <- parse_duration(input$showcase_toast_doc_duration)
    dismissible <- isTRUE(input$showcase_toast_doc_dismissible)

    args <- c(
      "session = session",
      "toaster_id = \"notifications\"",
      paste0("title = ", string_literal(title_val))
    )
    if (nzchar(desc_val)) {
      args <- c(args, paste0("description = ", string_literal(desc_val)))
    }
    if (!identical(variant_val, "default")) {
      args <- c(args, paste0("variant = ", string_literal(variant_val)))
    }
    if (is.null(icon)) {
      args <- c(args, "icon = NULL")
    } else if (!identical(icon, "info")) {
      args <- c(args, paste0("icon = ", string_literal(icon)))
    }
    if (!identical(duration, 5000)) {
      args <- c(args, paste0("duration = ", duration))
    }
    if (!dismissible) {
      args <- c(args, "dismissible = FALSE")
    }

    paste0(
      "# UI: mount one toaster\n",
      ui_line,
      "\n\n# Server: fire a toast\n",
      "show_toast(\n  ", paste(args, collapse = ",\n  "), "\n)"
    )
  })
  shiny::outputOptions(output, "showcase_toast_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the show_toast() / dismiss_toast() code here."
  ))
  output$showcase_toast_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(output, "showcase_toast_reactive_code", suspendWhenHidden = FALSE)

  # Live position: move the mounted toaster without re-mounting it.
  shiny::observeEvent(input$showcase_toast_doc_position, {
    update_block_toaster(
      session,
      toaster_id,
      position = input$showcase_toast_doc_position %||% "bottom-right"
    )
  })

  shiny::observeEvent(input$showcase_toast_fire, {
    icon <- current_icon()
    duration <- parse_duration(input$showcase_toast_doc_duration)
    desc_val <- input$showcase_toast_doc_description %||% ""

    show_toast(
      session,
      toaster_id,
      title = input$showcase_toast_doc_title %||% "Changes saved",
      description = if (nzchar(desc_val)) desc_val else NULL,
      variant = input$showcase_toast_doc_variant %||% "success",
      icon = icon,
      duration = duration,
      dismissible = isTRUE(input$showcase_toast_doc_dismissible)
    )

    reactive_code(paste0(
      "show_toast(\n",
      "  session = session,\n",
      "  toaster_id = \"showcase_toaster\",\n",
      "  title = \"", input$showcase_toast_doc_title %||% "Changes saved", "\",\n",
      "  variant = \"", input$showcase_toast_doc_variant %||% "success", "\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_toast_dismiss, {
    dismiss_toast(session, toaster_id)
    reactive_code(paste0(
      "dismiss_toast(\n",
      "  session = session,\n",
      "  toaster_id = \"showcase_toaster\"\n",
      ")"
    ))
  })

  output$showcase_toast_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c(
        "block_toaster(id)", "block_toaster(position)",
        "show_toast(toaster_id)", "show_toast(title)", "show_toast(description)",
        "show_toast(variant)", "show_toast(icon)", "show_toast(duration)",
        "show_toast(dismissible)", "show_toast(id)",
        "update_block_toaster(position)", "dismiss_toast(toast_id)"
      ),
      Type = c(
        "character", "character",
        "character", "character | tag", "character | tag",
        "character", "character | tag", "numeric",
        "logical", "character", "character", "character"
      ),
      Default = c(
        "required", "\"bottom-right\"",
        "required", "required", "NULL",
        "\"default\"", "\"info\"", "5000",
        "TRUE", "auto", "required", "NULL"
      ),
      Description = c(
        "Required input id. input$<id> reports lifecycle events {action, id, seq}.",
        "Screen anchor: top/bottom + left/center/right.",
        "Target block_toaster() id.",
        "Toast title. Required.",
        "Optional secondary text.",
        "One of default, destructive, success, warning, info.",
        "Icon name or tag; NULL omits it.",
        "Milliseconds before auto-dismiss. 0 keeps it until dismissed.",
        "Whether the toast shows a close button.",
        "Optional stable toast id for later dismissal.",
        "Move the mounted toaster to a new position without re-mounting.",
        "Toast to dismiss. NULL dismisses all."
      )
    ))
  })
  shiny::outputOptions(output, "showcase_toast_api_table", suspendWhenHidden = FALSE)
}
