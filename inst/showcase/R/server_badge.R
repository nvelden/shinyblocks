register_badge_showcase <- function(input, output, session) {
  output$showcase_badge_preview_ui <- shiny::renderUI({
    label <- input$showcase_badge_doc_label %||% "Deploying"
    if (!nzchar(label)) {
      label <- "Deploying"
    }
    variant <- input$showcase_badge_doc_variant %||% "default"
    size <- input$showcase_badge_doc_size %||% "default"
    class <- input$showcase_badge_doc_class %||% ""
    if (!nzchar(class)) {
      class <- NULL
    }
    style <- input$showcase_badge_doc_style %||% ""
    if (!nzchar(style)) {
      style <- NULL
    }

    block_badge(
      label = label,
      variant = variant,
      size = size,
      class = class,
      style = style
    )
  })
  shiny::outputOptions(
    output,
    "showcase_badge_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_badge_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    label_val <- input$showcase_badge_doc_label %||% "Deploying"
    if (!nzchar(label_val)) {
      label_val <- "Deploying"
    }
    variant_val <- input$showcase_badge_doc_variant %||% "default"
    size_val <- input$showcase_badge_doc_size %||% "default"
    class_val <- input$showcase_badge_doc_class %||% ""
    style_val <- input$showcase_badge_doc_style %||% ""

    args <- c(
      paste0("label = ", string_literal(label_val))
    )

    if (variant_val != "default") {
      args <- c(args, paste0('variant = "', variant_val, '"'))
    }
    if (size_val != "default") {
      args <- c(args, paste0('size = "', size_val, '"'))
    }
    if (nzchar(class_val)) {
      args <- c(args, paste0('class = "', class_val, '"'))
    }
    if (nzchar(style_val)) {
      args <- c(args, paste0("style = ", string_literal(style_val)))
    }

    paste0("block_badge(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_badge_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_badge_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("label", "variant", "size", "class", "style"),
      Type = c("character | tag", "character", "character", "character", "character | named list"),
      Default = c("required", "\"default\"", "\"default\"", "NULL", "NULL"),
      Description = c(
        "Content rendered inside the badge.",
        "Visual variant. One of default, secondary, outline, destructive, success, warning, info, ghost, or link.",
        "Visual size. One of sm, default, or lg.",
        "Additional CSS class merged onto the badge element.",
        "Optional inline styles applied to the badge element."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_badge_api_table",
    suspendWhenHidden = FALSE
  )
}
