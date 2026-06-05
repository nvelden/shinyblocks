register_icon_showcase <- function(input, output, session) {
  output$showcase_icon_preview_ui <- shiny::renderUI({
    name <- input$showcase_icon_doc_name %||% "home"
    size <- input$showcase_icon_doc_size %||% "default"
    color <- input$showcase_icon_doc_color %||% "default"

    block_icon(
      name = name,
      size = size,
      color = color
    )
  })
  shiny::outputOptions(
    output,
    "showcase_icon_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_icon_preview_code <- showcase_render_code({
    name_val <- input$showcase_icon_doc_name %||% "home"
    size_val <- input$showcase_icon_doc_size %||% "default"
    color_val <- input$showcase_icon_doc_color %||% "default"

    args <- c(paste0('name = "', name_val, '"'))
    if (!identical(size_val, "default")) {
      args <- c(args, paste0('size = "', size_val, '"'))
    }
    if (!identical(color_val, "default")) {
      args <- c(args, paste0('color = "', color_val, '"'))
    }

    paste0("block_icon(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_icon_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_icon_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("name", "size", "class", "color", "..."),
      Type = c("character | tag", "character", "character", "character", "named attributes"),
      Default = c("required", "\"default\"", "NULL", "\"default\"", "none"),
      Description = c(
        "Icon name from the vendored Lucide sprite or custom htmltools element.",
        "Icon size: default (1rem), sm (0.875rem), lg (1.5rem), or xl (2.25rem).",
        "Additional CSS class merged onto the svg element.",
        "Semantic foreground color. One of default, muted, primary, destructive, success, warning, or info.",
        "Additional attributes passed to the svg tag (e.g. style, width, height, etc.)."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_icon_api_table",
    suspendWhenHidden = FALSE
  )
}
