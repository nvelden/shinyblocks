register_spinner_showcase <- function(input, output, session) {
  output$showcase_spinner_preview_ui <- shiny::renderUI({
    label <- input$showcase_spinner_doc_label %||% "Loading"
    if (!nzchar(label)) {
      label <- "Loading"
    }
    size <- input$showcase_spinner_doc_size %||% "medium"
    color <- input$showcase_spinner_doc_color %||% "primary"
    
    class_str <- ""
    if (size == "small") {
      class_str <- paste0(class_str, "w-4 h-4")
    } else if (size == "medium") {
      class_str <- paste0(class_str, "w-6 h-6")
    } else if (size == "large") {
      class_str <- paste0(class_str, "w-10 h-10")
    }
    
    if (color == "primary") {
      class_str <- paste0(class_str, " text-primary")
    } else if (color == "destructive") {
      class_str <- paste0(class_str, " text-destructive")
    } else if (color == "muted") {
      class_str <- paste0(class_str, " text-muted-foreground")
    }

    block_spinner(
      label = label,
      class = if (nzchar(class_str)) class_str else NULL
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
    size_val <- input$showcase_spinner_doc_size %||% "medium"
    color_val <- input$showcase_spinner_doc_color %||% "primary"

    class_parts <- c()
    if (size_val == "small") {
      class_parts <- c(class_parts, "w-4 h-4")
    } else if (size_val == "medium") {
      class_parts <- c(class_parts, "w-6 h-6")
    } else if (size_val == "large") {
      class_parts <- c(class_parts, "w-10 h-10")
    }
    
    if (color_val == "primary") {
      class_parts <- c(class_parts, "text-primary")
    } else if (color_val == "destructive") {
      class_parts <- c(class_parts, "text-destructive")
    } else if (color_val == "muted") {
      class_parts <- c(class_parts, "text-muted-foreground")
    }

    args <- c()
    if (label_val != "Loading") {
      args <- c(args, paste0('label = "', label_val, '"'))
    }
    if (length(class_parts) > 0) {
      class_str <- paste(class_parts, collapse = " ")
      args <- c(args, paste0('class = "', class_str, '"'))
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
      Argument = c("label", "class"),
      Type = c("character", "character"),
      Default = c("\"Loading\"", "NULL"),
      Description = c(
        "Accessible screen-reader label for the spinner.",
        "Additional CSS class merged onto the spinner element (useful for sizing and custom colors)."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_spinner_api_table",
    suspendWhenHidden = FALSE
  )
}
