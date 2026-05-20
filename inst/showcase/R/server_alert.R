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
    class <- input$showcase_alert_doc_class %||% ""
    if (!nzchar(class)) {
      class <- NULL
    }

    block_alert(
      title = title,
      description = description,
      icon = icon,
      variant = variant,
      class = class
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
    class_val <- input$showcase_alert_doc_class %||% ""

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
    if (nzchar(class_val)) {
      args <- c(args, paste0('class = "', class_val, '"'))
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
      Argument = c("title", "...", "description", "icon", "variant", "class"),
      Type = c("character | tag", "named tags", "character | tag", "character | tag", "character", "character"),
      Default = c("required", "none", "NULL", "\"info\"", "\"default\"", "NULL"),
      Description = c(
        "Accessible title for the alert. Rendered inside a block_alert_title().",
        "Optional body child elements.",
        "Optional descriptive text. Rendered inside a block_alert_description().",
        "Optional leading icon name or element.",
        "Visual variant. One of default or destructive.",
        "Additional CSS class merged onto the alert container."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_alert_api_table",
    suspendWhenHidden = FALSE
  )
}
