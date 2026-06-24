if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)

  mounted <- FALSE
  for (path in c("../../library.data.gz", "../library.data.gz")) {
    tryCatch({
      webr::mount("/packages", path)
      if ("shinyblocks" %in% installed.packages(lib.loc = "/packages")[, "Package"]) {
        mounted <- TRUE
        break
      }
    }, error = function(e) {
      # Try the next path; Shinylive resolves mount URLs differently by host.
    })
  }

  if (!mounted) {
    tryCatch({
      webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
    }, error = function(e) {
      stop("Failed to mount shinyblocks WASM package library: ", e$message)
    })
  }

  .libPaths(c("/packages", .libPaths()))
}

library(shiny)
do.call(library, list("shinyblocks", character.only = TRUE))

`%||%` <- function(a, b) if (is.null(a)) b else a

showcase_render_code <- function(expr, env = parent.frame()) {
  quoted <- substitute(expr)
  force(env)
  renderUI({
    value <- eval(quoted, envir = env)
    if (is.null(value) || !length(value)) value <- ""
    block_code(
      code = paste(as.character(value), collapse = "\n"),
      language = "r",
      copyable = TRUE,
      line_numbers = TRUE
    )
  })
}

blank_to_null <- function(x) {
  if (is.null(x) || !nzchar(trimws(x))) NULL else x
}

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

interaction_args <- function(output_id) {
  list(
    click = clickOpts(id = paste0(output_id, "_click")),
    dblclick = dblclickOpts(id = paste0(output_id, "_dblclick")),
    hover = hoverOpts(id = paste0(output_id, "_hover")),
    brush = brushOpts(id = paste0(output_id, "_brush"))
  )
}

interaction_code_args <- function(output_id) {
  c(
    paste0("click = shiny::clickOpts(id = ", string_literal(paste0(output_id, "_click")), ")"),
    paste0("dblclick = shiny::dblclickOpts(id = ", string_literal(paste0(output_id, "_dblclick")), ")"),
    paste0("hover = shiny::hoverOpts(id = ", string_literal(paste0(output_id, "_hover")), ")"),
    paste0("brush = shiny::brushOpts(id = ", string_literal(paste0(output_id, "_brush")), ")")
  )
}

format_interaction_value <- function(value) {
  if (is.null(value)) {
    return("<NULL>")
  }
  paste(utils::capture.output(str(value, max.level = 1, give.attr = FALSE)), collapse = "\n")
}

interaction_values <- function(input, output_id) {
  ids <- paste0(output_id, c("_click", "_dblclick", "_hover", "_brush"))
  paste(
    vapply(ids, function(id) {
      paste0("input$", id, "\n", format_interaction_value(input[[id]]))
    }, character(1)),
    collapse = "\n\n"
  )
}

controls_group <- function(title, ..., first = FALSE) {
  grp_class <- if (isTRUE(first)) "showcase-controls-group showcase-controls-group--first" else "showcase-controls-group"
  block_stack(
    gap = "sm",
    class = grp_class,
    htmltools::tags$h4(
      style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
      title
    ),
    ...
  )
}

action_button <- function(input_id, label) {
  block_button(label, id = input_id, variant = "outline", size = "sm")
}

ui <- block_page(
  title = "shinyblocks - Image output playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::tags$div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      class = "showcase-playground",
    block_cluster(
      gap = "lg",
      align = "start",
      class = "showcase-playground__split",
      block_card(
        title = "Controls",
        class = "showcase-playground__controls",
        style = "flex: 1; min-width: 280px; max-width: 320px;",
        controls_group(
          "Content", first = TRUE,
          block_field(
            block_field_label("caption", `for` = "caption"),
            block_input("caption", value = "Quarterly revenue by region")
          ),
          block_field(
            block_field_label("width", `for` = "width"),
            block_input("width", value = "", placeholder = "e.g., 360px (blank = 100%)")
          ),
          block_field(
            block_field_label("height", `for` = "height"),
            block_input("height", value = "", placeholder = "blank = aspect/Shiny default")
          )
        ),
        controls_group(
          "State",
          block_field(
            block_field_label("aspect", `for` = "aspect"),
            block_select(
              "aspect",
              choices = c("none", "16/9", "4/3", "1/1", "21/9"),
              selected = "16/9",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("border", `for` = "border"),
            block_checkbox("border", "Draw border", value = TRUE)
          ),
          block_field(
            block_field_label("rounded", `for` = "rounded"),
            block_checkbox("rounded", "Rounded corners", value = TRUE)
          )
        ),
        controls_group(
          "Actions (Server Render)",
          block_cluster(
            gap = "sm",
            action_button("regen", "Regenerate")
          )
        ),
        controls_group(
          "Styling",
          block_field(
            block_field_label("fit", `for` = "fit"),
            block_select(
              "fit",
              choices = c("cover", "contain", "fill", "none", "scale-down"),
              selected = "cover",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("class", `for` = "frame_class"),
            block_checkbox("frame_class", "Use border-dashed class", value = FALSE)
          ),
          block_field(
            block_field_label("style", `for` = "frame_style"),
            block_input(
              "frame_style",
              value = "",
              placeholder = "e.g., max-width: 34rem; margin-inline: auto;"
            )
          )
        )
      ),
      block_stack(
        gap = "lg",
        class = "showcase-playground__main",
        block_stack(
          gap = "sm",
          htmltools::tags$div(
            style = "font-size: 0.875rem; font-weight: 600; color: var(--foreground);",
            "Preview"
          ),
          htmltools::tags$div(
            style = paste(
              "position: relative; display: block;",
              "padding: 1.5rem; background: var(--card);",
              "border: 1px solid var(--border); border-radius: 0.75rem;",
              "box-sizing: border-box;",
              "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
            ),
            uiOutput("preview_ui")
          )
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "Interaction values"
          ),
          uiOutput("interaction_value")
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "Server Render"
          ),
          uiOutput("reactive_code")
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("preview_code")
        )
      )
        )
)
  )
)

server <- function(input, output, session) {
  regen <- reactiveVal(0)
  observeEvent(input$regen, regen(regen() + 1))

  demo_values <- reactive({
    set.seed(100 + regen())
    stats::setNames(round(runif(4, 40, 100)), c("North", "South", "East", "West"))
  })

  frame_state <- reactive({
    aspect_raw <- input$aspect %||% "16/9"
    list(
      caption = blank_to_null(input$caption),
      width = blank_to_null(input$width),
      height = blank_to_null(input$height),
      aspect = if (identical(aspect_raw, "none")) NULL else aspect_raw,
      fit = input$fit %||% "cover",
      border = isTRUE(input$border),
      rounded = isTRUE(input$rounded),
      class = if (isTRUE(input$frame_class)) "border-dashed" else NULL,
      style = blank_to_null(input$frame_style)
    )
  })

  output$preview_ui <- renderUI({
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
    common <- c(common, interaction_args("preview_image"))
    do.call(block_image_output, c(list(id = "preview_image"), common))
  })
  outputOptions(output, "preview_ui", suspendWhenHidden = FALSE)

  output$preview_image <- renderImage(
    {
      v <- demo_values()
      cols <- c("#2563eb", "#16a34a", "#f59e0b", "#dc2626")
      w <- 260; h <- 420
      plot_top <- 118; plot_bottom <- 320; plot_height <- plot_bottom - plot_top
      bw <- 30; gap <- 18; start_x <- 46
      grid <- vapply(seq(0, 100, by = 25), function(mark) {
        y <- plot_bottom - (mark / 110) * plot_height
        sprintf("<line x1='34' y1='%.1f' x2='232' y2='%.1f' stroke='hsl(214 32%% 91%%)' stroke-width='1'/>", y, y)
      }, character(1))
      bars <- vapply(seq_along(v), function(i) {
        bh <- (v[[i]] / 110) * plot_height
        x <- start_x + (i - 1) * (bw + gap)
        y <- plot_bottom - bh
        sprintf(
          paste0(
            "<rect x='%.1f' y='%.1f' width='%d' height='%.1f' fill='%s' rx='4'/>",
            "<text x='%.1f' y='%.1f' text-anchor='middle' font-family='system-ui, sans-serif' font-size='12' font-weight='700' fill='hsl(222 47%% 11%%)'>%d</text>",
            "<text x='%.1f' y='342' text-anchor='middle' font-family='system-ui, sans-serif' font-size='10' fill='hsl(215 16%% 47%%)'>%s</text>"
          ),
          x, y, bw, bh, cols[[i]],
          x + bw / 2, max(98, y - 8), as.integer(v[[i]]),
          x + bw / 2, names(v)[[i]]
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
      list(src = outfile, contentType = "image/svg+xml", alt = "Generated bar chart of quarterly revenue by region.")
    },
    deleteFile = TRUE
  )
  outputOptions(output, "preview_image", suspendWhenHidden = FALSE)

  output$preview_code <- showcase_render_code({
    s <- frame_state()
    args <- paste0('id = "preview_image"')
    if (!is.null(s$width)) args <- c(args, paste0("width = ", string_literal(s$width)))
    if (!is.null(s$height)) args <- c(args, paste0("height = ", string_literal(s$height)))
    if (!is.null(s$aspect)) args <- c(args, paste0("aspect = ", string_literal(s$aspect)))
    if (!identical(s$fit, "cover")) args <- c(args, paste0("fit = ", string_literal(s$fit)))
    if (isTRUE(s$border)) args <- c(args, "border = TRUE")
    if (!isTRUE(s$rounded)) args <- c(args, "rounded = FALSE")
    if (!is.null(s$caption)) args <- c(args, paste0("caption = ", string_literal(s$caption)))
    args <- c(args, interaction_code_args("preview_image"))
    if (!is.null(s$class)) args <- c(args, paste0("class = ", string_literal(s$class)))
    if (!is.null(s$style)) args <- c(args, paste0("style = ", string_literal(s$style)))
    paste0("block_image_output(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "preview_code", suspendWhenHidden = FALSE)

  output$interaction_value <- showcase_render_code({
    interaction_values(input, "preview_image")
  })
  outputOptions(output, "interaction_value", suspendWhenHidden = FALSE)

  output$reactive_code <- showcase_render_code({
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
      "output$preview_image <- renderImage({\n",
      "  # render `values` to an SVG/PNG file\n",
      '  list(src = file, contentType = "image/svg+xml",\n',
      '       alt = "Quarterly revenue by region")\n',
      "}, deleteFile = TRUE)"
    )
  })
  outputOptions(output, "reactive_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
