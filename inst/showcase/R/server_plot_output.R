register_plot_output_showcase <- function(input, output, session) {
  blank_to_null <- function(x) {
    if (is.null(x) || !nzchar(trimws(x))) NULL else x
  }

  string_literal <- function(value) {
    paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
  }

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
      caption = blank_to_null(input$showcase_plot_output_caption),
      width = blank_to_null(input$showcase_plot_output_width),
      height = blank_to_null(input$showcase_plot_output_height),
      aspect = if (identical(aspect_raw, "none")) NULL else aspect_raw,
      border = isTRUE(input$showcase_plot_output_border),
      rounded = isTRUE(input$showcase_plot_output_rounded),
      class = if (isTRUE(input$showcase_plot_output_class)) "border-dashed" else NULL,
      style = blank_to_null(input$showcase_plot_output_style)
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
    if (!is.null(s$width)) args <- c(args, paste0("width = ", string_literal(s$width)))
    if (!is.null(s$height)) args <- c(args, paste0("height = ", string_literal(s$height)))
    if (!is.null(s$aspect)) args <- c(args, paste0("aspect = ", string_literal(s$aspect)))
    if (isTRUE(s$border)) args <- c(args, "border = TRUE")
    if (!isTRUE(s$rounded)) args <- c(args, "rounded = FALSE")
    if (!is.null(s$caption)) args <- c(args, paste0("caption = ", string_literal(s$caption)))
    if (!is.null(s$class)) args <- c(args, paste0("class = ", string_literal(s$class)))
    if (!is.null(s$style)) args <- c(args, paste0("style = ", string_literal(s$style)))
    paste0("block_plot_output(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(output, "showcase_plot_output_preview_code", suspendWhenHidden = FALSE)

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
        "id", "width", "height", "aspect", "fit", "border", "rounded",
        "caption", "click / dblclick / hover / brush", "inline", "fill",
        "class", "style"
      ),
      Type = c(
        "character", "character", "character", "character | numeric", "character",
        "logical", "logical", "character", "character | *Opts()", "logical",
        "logical", "character", "character"
      ),
      Default = c(
        "required", "\"100%\"", "NULL", "NULL", "\"cover\"", "FALSE", "TRUE",
        "NULL", "NULL", "FALSE", "!inline", "NULL", "NULL"
      ),
      Description = c(
        "Shiny output id, passed verbatim to plotOutput().",
        "CSS width forwarded to the Shiny output and mirrored on the media box.",
        "CSS height. NULL resolves to \"100%\" when aspect is set, else Shiny's default.",
        "Media-box aspect ratio: NULL, a positive number, or a \"w/h\" string.",
        "object-fit for the rendered plot image. renderPlot() usually renders to the box size, so this rarely changes the visible result.",
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
