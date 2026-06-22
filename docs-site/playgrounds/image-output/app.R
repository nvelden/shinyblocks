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

controls_group <- function(title, ..., first = FALSE) {
  border_style <- if (isTRUE(first)) "" else "border-top: 1px solid var(--border); padding-top: 0.75rem;"
  htmltools::div(
    style = paste("display: flex; flex-direction: column; gap: 0.75rem;", border_style),
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
  title = "shinyblocks - Image / plot output playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::tags$div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      class = "showcase-playground", style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
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
          htmltools::div(
            style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
            action_button("regen", "Regenerate")
          )
        ),
        controls_group(
          "Styling",
          block_field(
            block_field_label("demo", `for` = "demo"),
            block_select("demo", choices = c("plot", "image"), selected = "plot", size = "sm")
          ),
          block_field(
            block_field_label("fit", `for` = "fit"),
            block_select(
              "fit",
              choices = c("cover", "contain", "fill", "none", "scale-down"),
              selected = "cover",
              size = "sm"
            )
          )
        )
      ),
      htmltools::div(
        class = "showcase-playground__main", style = "flex: 2; min-width: 320px; display: flex; flex-direction: column; gap: 1.25rem;",
        htmltools::tags$div(
          style = "display: flex; flex-direction: column; gap: 0.5rem;",
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
      demo = input$demo %||% "plot",
      caption = blank_to_null(input$caption),
      width = blank_to_null(input$width),
      height = blank_to_null(input$height),
      aspect = if (identical(aspect_raw, "none")) NULL else aspect_raw,
      fit = input$fit %||% "cover",
      border = isTRUE(input$border),
      rounded = isTRUE(input$rounded)
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
      caption = s$caption
    )
    if (identical(s$demo, "image")) {
      do.call(block_image_output, c(list(id = "preview_image"), common))
    } else {
      do.call(block_plot_output, c(list(id = "preview_plot"), common))
    }
  })
  outputOptions(output, "preview_ui", suspendWhenHidden = FALSE)

  output$preview_plot <- renderPlot({
    v <- demo_values()
    op <- graphics::par(mar = c(3, 3, 1, 1))
    on.exit(graphics::par(op), add = TRUE)
    graphics::barplot(v, col = c("#2563eb", "#16a34a", "#f59e0b", "#dc2626"), border = NA, ylim = c(0, 110))
  }, alt = "Bar chart of quarterly revenue by region.")
  outputOptions(output, "preview_plot", suspendWhenHidden = FALSE)

  output$preview_image <- renderImage(
    {
      v <- demo_values()
      cols <- c("#2563eb", "#16a34a", "#f59e0b", "#dc2626")
      w <- 400; h <- 225; bw <- 70
      gap <- (w - length(v) * bw) / (length(v) + 1)
      bars <- vapply(seq_along(v), function(i) {
        bh <- (v[[i]] / 110) * (h - 30)
        x <- gap * i + bw * (i - 1)
        sprintf("<rect x='%.1f' y='%.1f' width='%d' height='%.1f' fill='%s' rx='3'/>", x, h - bh - 10, bw, bh, cols[[i]])
      }, character(1))
      svg <- paste0(
        "<svg xmlns='http://www.w3.org/2000/svg' width='", w, "' height='", h, "'>",
        "<rect width='", w, "' height='", h, "' fill='hsl(220 14% 96%)'/>",
        paste(bars, collapse = ""), "</svg>"
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
    fn <- if (identical(s$demo, "image")) "block_image_output" else "block_plot_output"
    id <- if (identical(s$demo, "image")) "preview_image" else "preview_plot"
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
  outputOptions(output, "preview_code", suspendWhenHidden = FALSE)

  output$reactive_code <- showcase_render_code({
    s <- frame_state()
    if (identical(s$demo, "image")) {
      paste0(
        "output$preview_image <- renderImage({\n",
        "  # ... write/locate an image file ...\n",
        '  list(src = file, contentType = "image/svg+xml",\n',
        '       alt = "Quarterly revenue by region")\n',
        "}, deleteFile = TRUE)"
      )
    } else {
      paste0(
        "output$preview_plot <- renderPlot({\n",
        "  barplot(values, col = palette, border = NA)\n",
        '}, alt = "Quarterly revenue by region")'
      )
    }
  })
  outputOptions(output, "reactive_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
