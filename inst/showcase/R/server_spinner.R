register_spinner_showcase <- function(input, output, session) {
  output$showcase_spinner_preview_ui <- shiny::renderUI({
    label <- input$showcase_spinner_doc_label %||% "Loading"
    if (!nzchar(label)) {
      label <- "Loading"
    }
    size <- input$showcase_spinner_doc_size %||% "default"
    color <- input$showcase_spinner_doc_color %||% "default"

    block_spinner(
      label = label,
      size = size,
      color = color
    )
  })
  shiny::outputOptions(
    output,
    "showcase_spinner_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_spinner_preview_code <- showcase_render_code({
    label_val <- input$showcase_spinner_doc_label %||% "Loading"
    if (!nzchar(label_val)) {
      label_val <- "Loading"
    }
    size_val <- input$showcase_spinner_doc_size %||% "default"
    color_val <- input$showcase_spinner_doc_color %||% "default"

    args <- c()
    if (label_val != "Loading") {
      args <- c(args, paste0('label = "', label_val, '"'))
    }
    if (size_val != "default") {
      args <- c(args, paste0('size = "', size_val, '"'))
    }
    if (color_val != "default") {
      args <- c(args, paste0('color = "', color_val, '"'))
    }

    if (length(args) == 0) {
      "block_spinner()"
    } else {
      paste0("block_spinner(\n  ", paste(args, collapse = ",\n  "), "\n)")
    }
  })
  shiny::outputOptions(
    output,
    "showcase_spinner_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_spinner_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("label", "size", "color", "class", "style"),
      Type = c("character", "character", "character", "character", "character | named list"),
      Default = c("\"Loading\"", "\"default\"", "\"default\"", "NULL", "NULL"),
      Description = c(
        "Accessible screen-reader label for the spinner.",
        "Visual size. One of sm, default, or lg.",
        "Semantic color. One of default, muted, primary, destructive, success, warning, or info.",
        "Additional CSS class merged onto the spinner element.",
        "Optional inline styles applied to the spinner element."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_spinner_api_table",
    suspendWhenHidden = FALSE
  )
}
