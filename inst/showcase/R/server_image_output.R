register_image_output_showcase <- function(input, output, session) {
  blank_to_null <- function(x) {
    if (is.null(x) || !nzchar(trimws(x))) NULL else x
  }

  string_literal <- function(value) {
    paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
  }

  # A regenerate counter feeds the RNG so the image demo pulls fresh random
  # data on demand.
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
      caption = blank_to_null(input$showcase_image_output_caption),
      width = blank_to_null(input$showcase_image_output_width),
      height = blank_to_null(input$showcase_image_output_height),
      aspect = if (identical(aspect_raw, "none")) NULL else aspect_raw,
      fit = input$showcase_image_output_fit %||% "cover",
      border = isTRUE(input$showcase_image_output_border),
      rounded = isTRUE(input$showcase_image_output_rounded),
      class = if (isTRUE(input$showcase_image_output_class)) "border-dashed" else NULL,
      style = blank_to_null(input$showcase_image_output_style)
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
      caption = s$caption,
      class = s$class,
      style = s$style
    )
    do.call(block_image_output, c(list(id = "showcase_image_output_image"), common))
  })
  shiny::outputOptions(output, "showcase_image_output_preview_ui", suspendWhenHidden = FALSE)

  # Image demo — vanilla shiny::renderImage(). The generated SVG is
  # intentionally portrait-shaped while the default frame is landscape, so the
  # fit control visibly demonstrates cover/contain/fill/none/scale-down.
  output$showcase_image_output_image <- shiny::renderImage(
    {
      v <- demo_values()
      cols <- c("#2563eb", "#16a34a", "#f59e0b", "#dc2626")
      w <- 260
      h <- 420
      plot_top <- 118
      plot_bottom <- 320
      plot_height <- plot_bottom - plot_top
      bw <- 30
      gap <- 18
      start_x <- 46
      grid <- vapply(seq(0, 100, by = 25), function(mark) {
        y <- plot_bottom - (mark / 110) * plot_height
        sprintf(
          "<line x1='34' y1='%.1f' x2='232' y2='%.1f' stroke='hsl(214 32%% 91%%)' stroke-width='1'/>",
          y, y
        )
      }, character(1))
      bars <- vapply(seq_along(v), function(i) {
        bh <- (v[[i]] / 110) * plot_height
        x <- start_x + (i - 1) * (bw + gap)
        y <- plot_bottom - bh
        label <- names(v)[[i]]
        sprintf(
          paste0(
            "<rect x='%.1f' y='%.1f' width='%d' height='%.1f' fill='%s' rx='4'/>",
            "<text x='%.1f' y='%.1f' text-anchor='middle' font-family='system-ui, sans-serif' font-size='12' font-weight='700' fill='hsl(222 47%% 11%%)'>%d</text>",
            "<text x='%.1f' y='342' text-anchor='middle' font-family='system-ui, sans-serif' font-size='10' fill='hsl(215 16%% 47%%)'>%s</text>"
          ),
          x, y, bw, bh, cols[[i]],
          x + bw / 2, max(98, y - 8), as.integer(v[[i]]),
          x + bw / 2, label
        )
      }, character(1))
      svg <- paste0(
        "<svg xmlns='http://www.w3.org/2000/svg' width='", w, "' height='", h, "'>",
        "<rect width='", w, "' height='", h, "' fill='hsl(0 0% 100%)'/>",
        "<rect x='18' y='24' width='224' height='356' rx='16' fill='hsl(220 14% 96%)' stroke='hsl(214 32% 91%)'/>",
        "<text x='34' y='62' font-family='system-ui, sans-serif' font-size='19' font-weight='800' fill='hsl(222 47% 11%)'>Revenue by region</text>",
        "<text x='34' y='84' font-family='system-ui, sans-serif' font-size='12' fill='hsl(215 16% 47%)'>Quarterly snapshot</text>",
        paste(grid, collapse = ""),
        "<line x1='34' y1='320' x2='232' y2='320' stroke='hsl(215 16% 47%)' stroke-width='1.25'/>",
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
    args <- paste0('id = "showcase_image_output_image"')
    if (!is.null(s$width)) args <- c(args, paste0("width = ", string_literal(s$width)))
    if (!is.null(s$height)) args <- c(args, paste0("height = ", string_literal(s$height)))
    if (!is.null(s$aspect)) args <- c(args, paste0("aspect = ", string_literal(s$aspect)))
    if (!identical(s$fit, "cover")) args <- c(args, paste0("fit = ", string_literal(s$fit)))
    if (isTRUE(s$border)) args <- c(args, "border = TRUE")
    if (!isTRUE(s$rounded)) args <- c(args, "rounded = FALSE")
    if (!is.null(s$caption)) args <- c(args, paste0("caption = ", string_literal(s$caption)))
    if (!is.null(s$class)) args <- c(args, paste0("class = ", string_literal(s$class)))
    if (!is.null(s$style)) args <- c(args, paste0("style = ", string_literal(s$style)))
    paste0("block_image_output(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(output, "showcase_image_output_preview_code", suspendWhenHidden = FALSE)

  # Server Render — the vanilla Shiny render recipe.
  output$showcase_image_output_reactive_code <- showcase_render_code({
    # Depend on demo_values() so pressing Regenerate visibly redraws this
    # panel with the freshly sampled data the render block just used.
    v <- demo_values()
    data_line <- paste0(
      "values <- c(",
      paste(sprintf("%s = %d", names(v), as.integer(v)), collapse = ", "),
      ")  # Regenerate draws a new sample"
    )
    paste0(
      data_line, "\n\n",
      "output$showcase_image_output_image <- renderImage({\n",
      "  # render `values` to an SVG/PNG file\n",
      '  list(src = file, contentType = "image/svg+xml",\n',
      '       alt = "Quarterly revenue by region")\n',
      "}, deleteFile = TRUE)"
    )
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
        "Shiny output id, passed verbatim to imageOutput().",
        "CSS width forwarded to the Shiny output and mirrored on the media box.",
        "CSS height. NULL resolves to \"100%\" when aspect is set, else Shiny's default.",
        "Media-box aspect ratio: NULL, a positive number, or a \"w/h\" string.",
        "object-fit for the rendered image: cover, contain, fill, none, scale-down.",
        "Draw a border around the media box.",
        "Round the media box corners (and clip overflow).",
        "Optional <figcaption> text below the media box.",
        "Forwarded to the Shiny output unchanged.",
        "Forwarded to the Shiny output unchanged.",
        "Forwarded to the Shiny output; default matches imageOutput().",
        "Additional classes for the <figure> wrapper.",
        "Inline style for the <figure> wrapper."
      )
    ))
  })
  shiny::outputOptions(output, "showcase_image_output_api_table", suspendWhenHidden = FALSE)
}
