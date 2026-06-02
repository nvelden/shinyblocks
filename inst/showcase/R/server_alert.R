register_alert_showcase <- function(input, output, session) {
  output$showcase_alert_preview_ui <- shiny::renderUI({
    title <- input$showcase_alert_doc_title %||% "Heads up"
    if (!nzchar(title)) {
      title <- "Heads up"
    }
    description <- input$showcase_alert_doc_description %||% "shinyblocks alerts surface important inline messages."
    if (!nzchar(description)) {
      description <- NULL
    }
    icon <- input$showcase_alert_doc_icon %||% "info"
    if (identical(icon, "none")) {
      icon <- NULL
    }
    variant <- input$showcase_alert_doc_variant %||% "default"
    action_label <- input$showcase_alert_doc_action_label %||% "Review"
    if (!nzchar(action_label)) {
      action_label <- "Review"
    }
    action <- if (isTRUE(input$showcase_alert_doc_action)) {
      block_alert_action(block_button(action_label, variant = "outline", size = "sm"))
    } else {
      NULL
    }
    class <- input$showcase_alert_doc_class %||% ""
    if (!nzchar(class) || identical(class, "none")) {
      class <- NULL
    }
    style <- input$showcase_alert_doc_style %||% ""
    if (!nzchar(style)) {
      style <- NULL
    }

    block_alert(
      title = title,
      description = description,
      action = action,
      icon = icon,
      variant = variant,
      class = class,
      style = style
    )
  })
  shiny::outputOptions(
    output,
    "showcase_alert_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_alert_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    title_val <- input$showcase_alert_doc_title %||% "Heads up"
    if (!nzchar(title_val)) {
      title_val <- "Heads up"
    }
    description_val <- input$showcase_alert_doc_description %||% "shinyblocks alerts surface important inline messages."
    icon_val <- input$showcase_alert_doc_icon %||% "info"
    variant_val <- input$showcase_alert_doc_variant %||% "default"
    action_enabled <- isTRUE(input$showcase_alert_doc_action)
    action_label <- input$showcase_alert_doc_action_label %||% "Review"
    if (!nzchar(action_label)) {
      action_label <- "Review"
    }
    class_val <- input$showcase_alert_doc_class %||% ""
    style_val <- input$showcase_alert_doc_style %||% ""

    args <- c(
      paste0("title = ", string_literal(title_val))
    )

    if (nzchar(description_val)) {
      args <- c(args, paste0("description = ", string_literal(description_val)))
    }
    if (icon_val != "none" && icon_val != "info") {
      args <- c(args, paste0('icon = "', icon_val, '"'))
    } else if (icon_val == "none") {
      args <- c(args, "icon = NULL")
    }
    if (variant_val != "default") {
      args <- c(args, paste0('variant = "', variant_val, '"'))
    }
    if (action_enabled) {
      args <- c(
        args,
        paste0(
          "action = block_alert_action(block_button(",
          string_literal(action_label),
          ', variant = "outline", size = "sm"))'
        )
      )
    }
    if (nzchar(class_val) && class_val != "none") {
      args <- c(args, paste0('class = "', class_val, '"'))
    }
    if (nzchar(style_val)) {
      args <- c(args, paste0("style = ", string_literal(style_val)))
    }

    paste0("block_alert(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_alert_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_alert_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("title", "...", "description", "action", "icon", "variant", "class", "style"),
      Type = c("character | tag", "named tags", "character | tag", "character | tag", "character | tag", "character", "character", "character | named list"),
      Default = c("required", "none", "NULL", "NULL", "\"info\"", "\"default\"", "NULL", "NULL"),
      Description = c(
        "Accessible title for the alert. Rendered inside a block_alert_title().",
        "Optional body child elements.",
        "Optional descriptive text. Rendered inside a block_alert_description().",
        "Optional action content. Use block_alert_action() to position a button or link.",
        "Optional leading icon name or element.",
        "Visual variant. One of default, destructive, success, warning, or info.",
        "Additional CSS class merged onto the alert container.",
        "Optional inline styles applied to the alert container."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_alert_api_table",
    suspendWhenHidden = FALSE
  )
}
