register_skeleton_showcase <- function(input, output, session) {
  output$showcase_skeleton_preview_ui <- shiny::renderUI({
    shape <- input$showcase_skeleton_doc_shape %||% "block"
    width <- input$showcase_skeleton_doc_width %||% "100%"
    height <- input$showcase_skeleton_doc_height %||% "1rem"
    
    style_str <- paste0("width: ", width, "; height: ", height, ";")
    
    class_str <- ""
    if (shape == "circle") {
      class_str <- "rounded-full"
    } else if (shape == "rounded") {
      class_str <- "rounded-md"
    }

    block_skeleton(
      class = if (nzchar(class_str)) class_str else NULL,
      style = style_str
    )
  })
  shiny::outputOptions(
    output,
    "showcase_skeleton_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_skeleton_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    shape_val <- input$showcase_skeleton_doc_shape %||% "block"
    width_val <- input$showcase_skeleton_doc_width %||% "100%"
    height_val <- input$showcase_skeleton_doc_height %||% "1rem"

    style_str <- paste0("width: ", width_val, "; height: ", height_val, ";")
    
    class_str <- ""
    if (shape_val == "circle") {
      class_str <- "rounded-full"
    } else if (shape_val == "rounded") {
      class_str <- "rounded-md"
    }

    args <- c()
    if (nzchar(class_str)) {
      args <- c(args, paste0('class = "', class_str, '"'))
    }
    args <- c(args, paste0("style = ", string_literal(style_str)))

    paste0("block_skeleton(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_skeleton_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_skeleton_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("class", "..."),
      Type = c("character", "named attributes"),
      Default = c("NULL", "none"),
      Description = c(
        "Additional CSS class merged onto the skeleton element (e.g. rounded-full).",
        "Additional attributes passed to the div tag (e.g. style for dimensions)."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_skeleton_api_table",
    suspendWhenHidden = FALSE
  )
}
