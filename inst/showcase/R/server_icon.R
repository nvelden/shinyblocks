register_icon_showcase <- function(input, output, session) {
  output$showcase_icon_preview_ui <- shiny::renderUI({
    name <- input$showcase_icon_doc_name %||% "home"
    size <- input$showcase_icon_doc_size %||% "medium"
    color <- input$showcase_icon_doc_color %||% "foreground"
    
    style_str <- ""
    if (size == "small") {
      style_str <- paste0(style_str, "width: 1rem; height: 1rem;")
    } else if (size == "medium") {
      style_str <- paste0(style_str, "width: 1.5rem; height: 1.5rem;")
    } else if (size == "large") {
      style_str <- paste0(style_str, "width: 2.25rem; height: 2.25rem;")
    }
    
    if (color == "muted") {
      style_str <- paste0(style_str, " color: var(--muted-foreground);")
    } else if (color == "primary") {
      style_str <- paste0(style_str, " color: var(--primary);")
    } else if (color == "destructive") {
      style_str <- paste0(style_str, " color: var(--destructive);")
    }
    
    block_icon(
      name = name,
      style = if (nzchar(style_str)) style_str else NULL
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
    size_val <- input$showcase_icon_doc_size %||% "medium"
    color_val <- input$showcase_icon_doc_color %||% "foreground"

    style_parts <- c()
    if (size_val == "small") {
      style_parts <- c(style_parts, "width: 1rem; height: 1rem;")
    } else if (size_val == "medium") {
      style_parts <- c(style_parts, "width: 1.5rem; height: 1.5rem;")
    } else if (size_val == "large") {
      style_parts <- c(style_parts, "width: 2.25rem; height: 2.25rem;")
    }
    
    if (color_val == "muted") {
      style_parts <- c(style_parts, "color: var(--muted-foreground);")
    } else if (color_val == "primary") {
      style_parts <- c(style_parts, "color: var(--primary);")
    } else if (color_val == "destructive") {
      style_parts <- c(style_parts, "color: var(--destructive);")
    }

    args <- c(
      paste0('name = "', name_val, '"')
    )

    if (length(style_parts) > 0) {
      style_str <- paste(style_parts, collapse = " ")
      args <- c(args, paste0("style = ", string_literal(style_str)))
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
      Argument = c("name", "class", "..."),
      Type = c("character | tag", "character", "named attributes"),
      Default = c("required", "NULL", "none"),
      Description = c(
        "Icon name from the vendored Lucide sprite or custom htmltools element.",
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
