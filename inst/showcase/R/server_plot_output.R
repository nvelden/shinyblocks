register_plot_output_showcase <- function(input, output, session) {
  # Shared output-playground helpers (showcase_blank_to_null,
  # showcase_string_literal, showcase_interaction_*) live in section.R.

  regen <- shiny::reactiveVal(0)
  shiny::observeEvent(input$showcase_plot_output_regen, {
    regen(regen() + 1)
  })

  demo_values <- shiny::reactive({
    seed <- regen()
    set.seed(100 + seed)
    stats::setNames(
      round(runif(4, 40, 100)),
      c("North", "South", "East", "West")
    )
  })

  frame_state <- shiny::reactive({
    aspect_raw <- input$showcase_plot_output_aspect %||% "16/9"
    list(
      caption = showcase_blank_to_null(input$showcase_plot_output_caption),
      width = showcase_blank_to_null(input$showcase_plot_output_width),
      height = showcase_blank_to_null(input$showcase_plot_output_height),
      aspect = if (identical(aspect_raw, "none")) NULL else aspect_raw,
      border = isTRUE(input$showcase_plot_output_border),
      rounded = isTRUE(input$showcase_plot_output_rounded),
      class = if (isTRUE(input$showcase_plot_output_class)) "border-dashed" else NULL,
      style = showcase_blank_to_null(input$showcase_plot_output_style)
    )
  })

  output$showcase_plot_output_preview_ui <- shiny::renderUI({
    s <- frame_state()
    common <- list(
      width = s$width %||% "100%",
      height = s$height,
      aspect = s$aspect,
      border = s$border,
      rounded = s$rounded,
      caption = s$caption,
      class = s$class,
      style = s$style
    )
    common <- c(common, showcase_interaction_args("showcase_plot_output"))
    do.call(block_plot_output, c(list(id = "showcase_plot_output_plot"), common))
  })
  shiny::outputOptions(output, "showcase_plot_output_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_plot_output_plot <- shiny::renderPlot({
    v <- demo_values()
    op <- graphics::par(mar = c(3, 3, 1, 1))
    on.exit(graphics::par(op), add = TRUE)
    graphics::barplot(
      v,
      col = c("#2563eb", "#16a34a", "#f59e0b", "#dc2626"),
      border = NA,
      ylim = c(0, 110)
    )
  }, alt = "Bar chart of quarterly revenue by region.")
  shiny::outputOptions(output, "showcase_plot_output_plot", suspendWhenHidden = FALSE)

  output$showcase_plot_output_preview_code <- showcase_render_code({
    s <- frame_state()
    args <- paste0('id = "showcase_plot_output_plot"')
    if (!is.null(s$width)) args <- c(args, paste0("width = ", showcase_string_literal(s$width)))
    if (!is.null(s$height)) args <- c(args, paste0("height = ", showcase_string_literal(s$height)))
    if (!is.null(s$aspect)) args <- c(args, paste0("aspect = ", showcase_string_literal(s$aspect)))
    if (isTRUE(s$border)) args <- c(args, "border = TRUE")
    if (!isTRUE(s$rounded)) args <- c(args, "rounded = FALSE")
    if (!is.null(s$caption)) args <- c(args, paste0("caption = ", showcase_string_literal(s$caption)))
    args <- c(args, showcase_interaction_code_args("showcase_plot_output"))
    if (!is.null(s$class)) args <- c(args, paste0("class = ", showcase_string_literal(s$class)))
    if (!is.null(s$style)) args <- c(args, paste0("style = ", showcase_string_literal(s$style)))
    paste0("block_plot_output(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(output, "showcase_plot_output_preview_code", suspendWhenHidden = FALSE)

  output$showcase_plot_output_interaction_value <- showcase_render_code({
    showcase_interaction_values(input, "showcase_plot_output")
  })
  shiny::outputOptions(output, "showcase_plot_output_interaction_value", suspendWhenHidden = FALSE)

  output$showcase_plot_output_reactive_code <- showcase_render_code({
    v <- demo_values()
    data_line <- paste0(
      "values <- c(",
      paste(sprintf("%s = %d", names(v), as.integer(v)), collapse = ", "),
      ")  # Regenerate draws a new sample"
    )
    paste0(
      data_line, "\n\n",
      "output$showcase_plot_output_plot <- renderPlot({\n",
      "  barplot(values, col = palette, border = NA)\n",
      '}, alt = "Quarterly revenue by region")'
    )
  })
  shiny::outputOptions(output, "showcase_plot_output_reactive_code", suspendWhenHidden = FALSE)

  output$showcase_plot_output_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c(
        "id", "width", "height", "aspect", "border", "rounded",
        "caption", "click / dblclick / hover / brush", "inline", "fill",
        "class", "style"
      ),
      Type = c(
        "character", "character", "character", "character | numeric",
        "logical", "logical", "character", "character | *Opts()", "logical",
        "logical", "character", "character"
      ),
      Default = c(
        "required", "\"100%\"", "NULL", "NULL", "FALSE", "TRUE",
        "NULL", "NULL", "FALSE", "!inline", "NULL", "NULL"
      ),
      Description = c(
        "Shiny output id, passed verbatim to plotOutput().",
        "CSS width forwarded to the Shiny output and mirrored on the media box.",
        "CSS height. NULL resolves to \"100%\" when aspect is set, else Shiny's default.",
        "Media-box aspect ratio: NULL, a positive number, or a \"w/h\" string.",
        "Draw a border around the media box.",
        "Round the media box corners (and clip overflow).",
        "Optional <figcaption> text below the media box.",
        "Forwarded to the Shiny output unchanged (plot click/hover/brush inputs).",
        "Forwarded to the Shiny output unchanged.",
        "Forwarded to the Shiny output; default matches plotOutput().",
        "Additional classes for the <figure> wrapper.",
        "Inline style for the <figure> wrapper."
      )
    ))
  })
  shiny::outputOptions(output, "showcase_plot_output_api_table", suspendWhenHidden = FALSE)
}
