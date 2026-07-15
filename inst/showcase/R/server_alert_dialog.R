register_alert_dialog_showcase <- function(input, output, session) {
  `%||%` <- function(x, y) if (is.null(x)) y else x
  server_code <- shiny::reactiveVal("# Use update_block_alert_dialog() to open or close.")

  shiny::observe({
    update_block_alert_dialog(
      session, "showcase_alert_dialog_preview",
      title = input$showcase_alert_dialog_title %||% "Delete account?",
      description = input$showcase_alert_dialog_description %||% "",
      confirm_label = input$showcase_alert_dialog_confirm_label %||% "Delete",
      cancel_label = input$showcase_alert_dialog_cancel_label %||% "Cancel",
      confirm_variant = input$showcase_alert_dialog_variant %||% "destructive",
      size = input$showcase_alert_dialog_size %||% "default",
      class = if (isTRUE(input$showcase_alert_dialog_class)) "showcase-dialog-preview-custom" else NULL,
      style = if (nzchar(input$showcase_alert_dialog_style %||% "")) input$showcase_alert_dialog_style else NULL
    )
  })
  shiny::observeEvent(input$showcase_alert_dialog_open, {
    update_block_alert_dialog(session, "showcase_alert_dialog_preview", open = TRUE)
    server_code('update_block_alert_dialog(session, "showcase_alert_dialog_preview", open = TRUE)')
  })
  shiny::observeEvent(input$showcase_alert_dialog_close, {
    update_block_alert_dialog(session, "showcase_alert_dialog_preview", open = FALSE)
    server_code('update_block_alert_dialog(session, "showcase_alert_dialog_preview", open = FALSE)')
  })

  output$showcase_alert_dialog_preview_ui <- shiny::renderUI({
    custom_class <- if (isTRUE(input$showcase_alert_dialog_class)) {
      "showcase-dialog-preview-custom"
    } else {
      NULL
    }
    custom_style <- input$showcase_alert_dialog_style %||% ""
    block_stack(
      gap = "sm",
      class = c("sb-parity-alert-dialog", custom_class),
      style = if (nzchar(custom_style)) custom_style else NULL,
      htmltools::tags$strong(input$showcase_alert_dialog_title %||% "Delete account?"),
      htmltools::tags$p(style = "margin:0;color:var(--muted-foreground);", input$showcase_alert_dialog_description %||% ""),
      block_cluster(justify = "end", block_button(input$showcase_alert_dialog_cancel_label %||% "Cancel", variant = "outline"), block_button(input$showcase_alert_dialog_confirm_label %||% "Delete", variant = input$showcase_alert_dialog_variant %||% "destructive"))
    )
  })
  output$showcase_alert_dialog_value <- showcase_render_code({
    value <- input$showcase_alert_dialog_preview
    paste0("input$showcase_alert_dialog_preview = ", if (is.null(value)) "NULL" else dQuote(value))
  })
  output$showcase_alert_dialog_code <- showcase_render_code({
    args <- c(
      '"showcase_alert_dialog_preview"',
      dQuote(input$showcase_alert_dialog_title %||% "Delete account?"),
      paste0("description = ", dQuote(input$showcase_alert_dialog_description %||% "")),
      paste0("confirm_label = ", dQuote(input$showcase_alert_dialog_confirm_label %||% "Delete")),
      paste0("cancel_label = ", dQuote(input$showcase_alert_dialog_cancel_label %||% "Cancel")),
      paste0("trigger = ", dQuote(input$showcase_alert_dialog_trigger %||% "")),
      paste0("confirm_variant = ", dQuote(input$showcase_alert_dialog_variant %||% "destructive"))
    )
    size <- input$showcase_alert_dialog_size %||% "default"
    if (!identical(size, "default")) args <- c(args, paste0("size = ", dQuote(size)))
    style <- input$showcase_alert_dialog_style %||% ""
    if (nzchar(style)) args <- c(args, paste0("style = ", dQuote(style)))
    if (isTRUE(input$showcase_alert_dialog_class)) {
      args <- c(args, 'class = "showcase-dialog-preview-custom"')
    }
    paste0("block_alert_dialog(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  output$showcase_alert_dialog_server_code <- showcase_render_code({ server_code() })
  output$showcase_alert_dialog_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("id", "title", "description", "...", "confirm_label", "cancel_label", "trigger", "open", "confirm_variant", "size", "class", "style"),
      Type = c("character", "character | tag", "character | tag", "tag | tagList", rep("character", 3), "logical", "character", "character", "character", "character | named list"),
      Default = c("required", "required", "NULL", "NULL", '"Continue"', '"Cancel"', "NULL", "FALSE", '"default"', '"default"', "NULL", "NULL"),
      Description = c("Outcome input id.", "Accessible title.", "Supporting copy.", "Optional body.", "Confirm label.", "Cancel label.", "Opener label.", "Initial state.", "Confirm button variant.", "Width preset.", "Content class.", "Content style.")
    ))
  })
}
