register_image_output_showcase <- function(input, output, session) {
  blank_to_null <- function(x) {
    if (is.null(x) || !nzchar(trimws(x))) NULL else x
  }

  # A regenerate counter feeds the RNG so both the plot and image demos pull
  # fresh random data on demand.
  regen <- shiny::reactiveVal(0)
  shiny::observeEvent(input$showcase_image_output_regen, {
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

  # Resolved frame args shared by the preview and the UI-definition code block.
  frame_state <- shiny::reactive({
    aspect_raw <- input$showcase_image_output_aspect %||% "16/9"
    list(
      demo = input$showcase_image_output_demo %||% "plot",
      caption = blank_to_null(input$showcase_image_output_caption),
      width = blank_to_null(input$showcase_image_output_width),
      height = blank_to_null(input$showcase_image_output_height),
      aspect = if (identical(aspect_raw, "none")) NULL else aspect_raw,
      fit = input$showcase_image_output_fit %||% "cover",
      border = isTRUE(input$showcase_image_output_border),
      rounded = isTRUE(input$showcase_image_output_rounded)
    )
  })

  output$showcase_image_output_preview_ui <- shiny::renderUI({
    s <- frame_state()
    common <- list(
      width = s$width %||% "100%",
      height = s$height,
      aspect = s$aspect,
      fit = s$fit,
      border = s$border,
      rounded = s$rounded,
      caption = s$caption
    )
    if (identical(s$demo, "image")) {
      do.call(block_image_output, c(list(id = "showcase_image_output_image"), common))
    } else {
      do.call(block_plot_output, c(list(id = "showcase_image_output_plot"), common))
    }
  })
  shiny::outputOptions(output, "showcase_image_output_preview_ui", suspendWhenHidden = FALSE)

  # Plot demo — vanilla shiny::renderPlot(), base graphics.
  output$showcase_image_output_plot <- shiny::renderPlot({
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
  shiny::outputOptions(output, "showcase_image_output_plot", suspendWhenHidden = FALSE)

  # Image demo — vanilla shiny::renderImage(). A hand-built SVG written to a
  # temp file keeps the demo dependency-free and portable (no graphics device
  # needed), exercising the same image-output frame as renderImage() of a file.
  output$showcase_image_output_image <- shiny::renderImage(
    {
      v <- demo_values()
      cols <- c("#2563eb", "#16a34a", "#f59e0b", "#dc2626")
      w <- 400
      h <- 225
      bw <- 70
      gap <- (w - length(v) * bw) / (length(v) + 1)
      bars <- vapply(seq_along(v), function(i) {
        bh <- (v[[i]] / 110) * (h - 30)
        x <- gap * i + bw * (i - 1)
        y <- h - bh - 10
        sprintf(
          "<rect x='%.1f' y='%.1f' width='%d' height='%.1f' fill='%s' rx='3'/>",
          x, y, bw, bh, cols[[i]]
        )
      }, character(1))
      svg <- paste0(
        "<svg xmlns='http://www.w3.org/2000/svg' width='", w, "' height='", h, "'>",
        "<rect width='", w, "' height='", h, "' fill='hsl(220 14% 96%)'/>",
        paste(bars, collapse = ""),
        "</svg>"
      )
      outfile <- tempfile(fileext = ".svg")
      writeLines(svg, outfile)
      list(
        src = outfile,
        contentType = "image/svg+xml",
        alt = "Generated bar chart of quarterly revenue by region."
      )
    },
    deleteFile = TRUE
  )
  shiny::outputOptions(output, "showcase_image_output_image", suspendWhenHidden = FALSE)

  # UI Definition — the block_*_output() call that builds the framed preview.
  output$showcase_image_output_preview_code <- showcase_render_code({
    s <- frame_state()
    fn <- if (identical(s$demo, "image")) "block_image_output" else "block_plot_output"
    id <- if (identical(s$demo, "image")) "showcase_image_output_image" else "showcase_image_output_plot"
    args <- paste0('id = "', id, '"')
    if (!is.null(s$width)) args <- c(args, paste0('width = "', s$width, '"'))
    if (!is.null(s$height)) args <- c(args, paste0('height = "', s$height, '"'))
    if (!is.null(s$aspect)) args <- c(args, paste0('aspect = "', s$aspect, '"'))
    if (!identical(s$fit, "cover")) args <- c(args, paste0('fit = "', s$fit, '"'))
    if (isTRUE(s$border)) args <- c(args, "border = TRUE")
    if (!isTRUE(s$rounded)) args <- c(args, "rounded = FALSE")
    if (!is.null(s$caption)) args <- c(args, paste0('caption = "', s$caption, '"'))
    paste0(fn, "(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(output, "showcase_image_output_preview_code", suspendWhenHidden = FALSE)

  # Server Render — the vanilla Shiny render recipe for the active demo.
  output$showcase_image_output_reactive_code <- showcase_render_code({
    s <- frame_state()
    # Depend on demo_values() so pressing Regenerate visibly redraws this
    # panel with the freshly sampled data the render block just used.
    v <- demo_values()
    data_line <- paste0(
      "values <- c(",
      paste(sprintf("%s = %d", names(v), as.integer(v)), collapse = ", "),
      ")  # Regenerate draws a new sample"
    )
    if (identical(s$demo, "image")) {
      paste0(
        data_line, "\n\n",
        "output$showcase_image_output_image <- renderImage({\n",
        "  # render `values` to an SVG/PNG file\n",
        '  list(src = file, contentType = "image/svg+xml",\n',
        '       alt = "Quarterly revenue by region")\n',
        "}, deleteFile = TRUE)"
      )
    } else {
      paste0(
        data_line, "\n\n",
        "output$showcase_image_output_plot <- renderPlot({\n",
        "  barplot(values, col = palette, border = NA)\n",
        '}, alt = "Quarterly revenue by region")'
      )
    }
  })
  shiny::outputOptions(output, "showcase_image_output_reactive_code", suspendWhenHidden = FALSE)

  output$showcase_image_output_api_table <- shiny::renderUI({
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
        "NULL", "NULL", "FALSE",
        "FALSE (image) / !inline (plot)", "NULL", "NULL"
      ),
      Description = c(
        "Shiny output id, passed verbatim to imageOutput() / plotOutput().",
        "CSS width forwarded to the Shiny output and mirrored on the media box.",
        "CSS height. NULL resolves to \"100%\" when aspect is set, else Shiny's default.",
        "Media-box aspect ratio: NULL, a positive number, or a \"w/h\" string.",
        "object-fit for the rendered image: cover, contain, fill, none, scale-down.",
        "Draw a border around the media box.",
        "Round the media box corners (and clip overflow).",
        "Optional <figcaption> text below the media box.",
        "Forwarded to the Shiny output unchanged (plot click/hover/brush inputs).",
        "Forwarded to the Shiny output unchanged.",
        "Forwarded to the Shiny output; default matches the underlying function.",
        "Additional classes for the <figure> wrapper.",
        "Inline style for the <figure> wrapper."
      )
    ))
  })
  shiny::outputOptions(output, "showcase_image_output_api_table", suspendWhenHidden = FALSE)
}
