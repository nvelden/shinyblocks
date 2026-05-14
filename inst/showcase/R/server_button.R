register_button_showcase <- function(input, output, session) {
  button_doc_icon <- function(icon_value) {
    if (is.null(icon_value) || identical(icon_value, "none")) {
      return(NULL)
    }
    icon_value
  }

  output$showcase_button_preview_ui <- shiny::renderUI({
    label <- input$showcase_button_doc_label %||% "Continue"
    variant <- input$showcase_button_doc_variant %||% "default"
    size <- input$showcase_button_doc_size %||% "default"
    icon <- button_doc_icon(input$showcase_button_doc_icon)
    icon_position <- input$showcase_button_doc_icon_position %||% "inline-start"
    style <- input$showcase_button_doc_style %||% ""
    if (!nzchar(style)) {
      style <- NULL
    }
    if (identical(size, "icon")) {
      if (is.null(icon)) {
        icon <- "search"
      }
      label <- NULL
    }

    block_button(
      label = label,
      id = "showcase_button_preview",
      variant = variant,
      size = size,
      icon = icon,
      icon_position = icon_position,
      disabled = isTRUE(input$showcase_button_doc_disabled),
      style = style,
      class = if (isTRUE(input$showcase_button_doc_class)) {
        "showcase-button-preview-custom"
      } else {
        NULL
      }
    )
  })
  shiny::outputOptions(
    output,
    "showcase_button_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_button_preview_code <- shiny::renderText({
    string_literal <- function(value) {
      paste0('"', gsub('(["\\\\])', '\\\\\\1', value, perl = TRUE), '"')
    }

    label_val <- input$showcase_button_doc_label %||% "Continue"
    variant_val <- input$showcase_button_doc_variant %||% "default"
    size_val <- input$showcase_button_doc_size %||% "default"
    icon_val <- button_doc_icon(input$showcase_button_doc_icon)
    icon_position_val <- input$showcase_button_doc_icon_position %||% "inline-start"
    disabled_val <- isTRUE(input$showcase_button_doc_disabled)
    style_val <- input$showcase_button_doc_style %||% ""
    class_val <- isTRUE(input$showcase_button_doc_class)
    if (identical(size_val, "icon")) {
      if (is.null(icon_val)) {
        icon_val <- "search"
      }
      label_val <- ""
    }

    args <- c(
      paste0("label = ", string_literal(label_val)),
      'id = "showcase_button_preview"'
    )

    if (variant_val != "default") {
      args <- c(args, paste0('variant = "', variant_val, '"'))
    }
    if (size_val != "default") {
      args <- c(args, paste0('size = "', size_val, '"'))
    }
    if (!is.null(icon_val)) {
      args <- c(args, paste0('icon = "', icon_val, '"'))
      if (icon_position_val != "inline-start") {
        args <- c(args, paste0('icon_position = "', icon_position_val, '"'))
      }
    }
    if (disabled_val) {
      args <- c(args, "disabled = TRUE")
    }
    if (nzchar(style_val)) {
      args <- c(args, paste0("style = ", string_literal(style_val)))
    }
    if (class_val) {
      args <- c(args, 'class = "showcase-button-preview-custom"')
    }

    paste0("block_button(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_button_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_button_reactive_code <- shiny::renderText({
    paste0(
      "# block_button() has no runtime update helper yet.\n",
      "# Change the controls to re-render this preview."
    )
  })
  shiny::outputOptions(
    output,
    "showcase_button_reactive_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_button_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("label", "variant", "size", "icon", "icon_position", "...", "class"),
      Type = c("character | tag", "character", "character", "character | tag", "character", "named attributes", "character"),
      Default = c("required", "\"default\"", "\"default\"", "NULL", "\"inline-start\"", "none", "NULL"),
      Description = c(
        "Content rendered inside the button.",
        "Visual variant. One of default, secondary, outline, ghost, destructive, or link.",
        "Button size. One of default, sm, lg, or icon.",
        "Optional leading/trailing icon name or tag.",
        "Controls icon placement when an icon is present.",
        "Additional button attributes such as id, disabled, aria-label, style, and data-*.",
        "Additional class merged onto the runtime button element."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_button_api_table",
    suspendWhenHidden = FALSE
  )
}
