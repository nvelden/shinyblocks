register_icon_showcase <- function(input, output, session) {
  output$showcase_icon_preview_ui <- shiny::renderUI({
    name <- input$showcase_icon_doc_name %||% "home"
    size <- input$showcase_icon_doc_size %||% "default"
    color <- input$showcase_icon_doc_color %||% "foreground"

    color_style <- switch(
      color,
      muted = "color: var(--muted-foreground);",
      primary = "color: var(--primary);",
      destructive = "color: var(--destructive);",
      NULL
    )

    block_icon(
      name = name,
      size = size,
      style = color_style
    )
  })
  shiny::outputOptions(
    output,
    "showcase_icon_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_icon_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    name_val <- input$showcase_icon_doc_name %||% "home"
    size_val <- input$showcase_icon_doc_size %||% "default"
    color_val <- input$showcase_icon_doc_color %||% "foreground"

    color_style <- switch(
      color_val,
      muted = "color: var(--muted-foreground);",
      primary = "color: var(--primary);",
      destructive = "color: var(--destructive);",
      NULL
    )

    args <- c(paste0('name = "', name_val, '"'))
    if (!identical(size_val, "default")) {
      args <- c(args, paste0('size = "', size_val, '"'))
    }
    if (!is.null(color_style)) {
      args <- c(args, paste0("style = ", string_literal(color_style)))
    }

    paste0("block_icon(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_icon_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_icon_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("name", "size", "class", "..."),
      Type = c("character | tag", "character", "character", "named attributes"),
      Default = c("required", "\"default\"", "NULL", "none"),
      Description = c(
        "Icon name from the vendored Lucide sprite or custom htmltools element.",
        "Icon size: default (1rem), sm (0.875rem), lg (1.5rem), or xl (2.25rem).",
        "Additional CSS class merged onto the svg element.",
        "Additional attributes passed to the svg tag (e.g. style, width, height, etc.)."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_icon_api_table",
    suspendWhenHidden = FALSE
  )
}
