register_value_box_showcase <- function(input, output, session) {
  output$showcase_value_box_preview_ui <- shiny::renderUI({
    title <- input$showcase_value_box_doc_title %||% "Net Revenue"
    value <- input$showcase_value_box_doc_value %||% "$45,231.89"
    desc <- input$showcase_value_box_doc_desc %||% "Up 12% month over month."
    if (!nzchar(desc)) desc <- NULL
    
    icon_name <- input$showcase_value_box_doc_icon %||% "trending-up"
    icon_tag <- NULL
    if (icon_name != "none") {
      icon_tag <- icon_name
    }
    
    class <- input$showcase_value_box_doc_class %||% ""
    if (!nzchar(class) || class == "none") class <- NULL
    style <- input$showcase_value_box_doc_style %||% ""
    if (!nzchar(style)) style <- NULL

    block_value_box(
      title = title,
      value = value,
      description = desc,
      icon = icon_tag,
      class = class,
      style = style
    )
  })
  shiny::outputOptions(
    output,
    "showcase_value_box_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_value_box_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    title_val <- input$showcase_value_box_doc_title %||% "Net Revenue"
    value_val <- input$showcase_value_box_doc_value %||% "$45,231.89"
    desc_val <- input$showcase_value_box_doc_desc %||% "Up 12% month over month."
    icon_val <- input$showcase_value_box_doc_icon %||% "trending-up"
    class_val <- input$showcase_value_box_doc_class %||% ""
    style_val <- input$showcase_value_box_doc_style %||% ""

    args <- c(
      paste0("title = ", string_literal(title_val)),
      paste0("value = ", string_literal(value_val))
    )
    if (nzchar(desc_val)) {
      args <- c(args, paste0("description = ", string_literal(desc_val)))
    }
    if (icon_val != "none") {
      args <- c(args, paste0('icon = "', icon_val, '"'))
    }
    if (nzchar(class_val) && class_val != "none") {
      args <- c(args, paste0('class = "', class_val, '"'))
    }
    if (nzchar(style_val)) {
      args <- c(args, paste0("style = ", string_literal(style_val)))
    }

    paste0("block_value_box(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_value_box_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_value_box_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("title", "value", "...", "description", "icon", "class", "style"),
      Type = c("character | tag", "character | tag", "named/unnamed elements", "character | tag", "character | tag", "character", "character | named list"),
      Default = c("required", "required", "none", "NULL", "NULL", "NULL", "NULL"),
      Description = c(
        "Header title string or tag.",
        "Primary large metric/value highlight.",
        "Additional value box body content.",
        "Optional descriptive supporting text.",
        "Lucide leading icon name or tag.",
        "Additional CSS class merged onto the value box container.",
        "Optional inline styles applied to the value box container."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_value_box_api_table",
    suspendWhenHidden = FALSE
  )
}
