register_separator_showcase <- function(input, output, session) {
  output$showcase_separator_preview_ui <- shiny::renderUI({
    orientation <- input$showcase_separator_doc_orientation %||% "horizontal"
    decorative <- isTRUE(input$showcase_separator_doc_decorative)
    class <- input$showcase_separator_doc_class %||% ""
    if (!nzchar(class)) {
      class <- NULL
    }
    
    # We embed it inside a flex container to show the vertical vs horizontal correctly
    if (orientation == "horizontal") {
      htmltools::tagList(
        htmltools::tags$div(style = "font-size: 0.875rem; font-weight: 500;", "An elegant divider in horizontal layouts:"),
        block_separator(orientation = orientation, decorative = decorative, class = class),
        htmltools::tags$div(style = "font-size: 0.875rem; color: var(--muted-foreground);", "Content flows naturally above and below.")
      )
    } else {
      htmltools::tags$div(
        style = "display: flex; height: 1.5rem; align-items: center; gap: 1rem; font-size: 0.875rem; font-weight: 500;",
        "Left segment",
        block_separator(orientation = orientation, decorative = decorative, class = class),
        "Right segment"
      )
    }
  })
  shiny::outputOptions(
    output,
    "showcase_separator_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_separator_preview_code <- showcase_render_code({
    orientation_val <- input$showcase_separator_doc_orientation %||% "horizontal"
    decorative_val <- isTRUE(input$showcase_separator_doc_decorative)
    class_val <- input$showcase_separator_doc_class %||% ""

    args <- c()
    if (orientation_val != "horizontal") {
      args <- c(args, 'orientation = "vertical"')
    }
    if (!decorative_val) {
      args <- c(args, "decorative = FALSE")
    }
    if (nzchar(class_val)) {
      args <- c(args, paste0('class = "', class_val, '"'))
    }

    if (length(args) == 0) {
      "block_separator()"
    } else {
      paste0("block_separator(\n  ", paste(args, collapse = ",\n  "), "\n)")
    }
  })
  shiny::outputOptions(
    output,
    "showcase_separator_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_separator_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("orientation", "decorative", "class"),
      Type = c("character", "logical", "character"),
      Default = c("\"horizontal\"", "TRUE", "NULL"),
      Description = c(
        "Orientation direction. One of horizontal or vertical.",
        "Whether the separator is decorative only (TRUE hides it from accessibility tree).",
        "Additional CSS class merged onto the separator element."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_separator_api_table",
    suspendWhenHidden = FALSE
  )
}
