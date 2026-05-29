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
    }, error = function(e) {})
  }
  if (!mounted) {
    webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
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
    block_code(paste(as.character(value), collapse = "\n"), language = "r", copyable = TRUE, line_numbers = TRUE)
  })
}

# Lightweight live-value renderer used for the drag-rate `input$<slider>`
# readout. block_code() is a runtime React mount; re-rendering it on every
# 100ms throttle tick during a drag adds visible lag in Shinylive (webR)
# because each tick triggers a worker round-trip + a React re-mount of the
# code widget. A plain <pre><code> avoids the React mount entirely while
# matching block_code()'s visual weight closely enough for a one-line value.
showcase_render_value <- function(expr, env = parent.frame()) {
  quoted <- substitute(expr)
  force(env)
  renderUI({
    value <- eval(quoted, envir = env)
    htmltools::tags$pre(
      class = "sb-code-block sb-code-block-default",
      style = "margin: 0; padding: 0.75rem 1rem; font-size: 0.8125rem;",
      htmltools::tags$code(paste(as.character(value), collapse = "\n"))
    )
  })
}

showcase_action_button <- function(input_id, label) {
  block_button(label, id = input_id, variant = "outline", size = "sm")
}

parse_slider_value <- function(text, fallback = 50) {
  if (is.null(text) || !nzchar(text)) return(fallback)
  values <- suppressWarnings(as.numeric(trimws(strsplit(text, ",", fixed = TRUE)[[1]])))
  values <- values[!is.na(values)]
  if (!length(values)) return(fallback)
  values[seq_len(min(2, length(values)))]
}

slider_number <- function(value, fallback) {
  parsed <- suppressWarnings(as.numeric(value))
  if (length(parsed) != 1 || is.na(parsed)) fallback else parsed
}

slider_code_value <- function(value) {
  if (length(value) == 1) return(as.character(value))
  paste0("c(", paste(value, collapse = ", "), ")")
}

ui <- block_page(
  title = "shinyblocks - Slider playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    htmltools::tags$style(htmltools::HTML(
      "[data-shinyblocks-root].showcase-slider-preview-custom .sb-slider-root { outline: 2px dashed var(--ring); outline-offset: 4px; }"
    ))
  ),
  htmltools::div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
      htmltools::div(
        style = paste(
          "flex: 1; min-width: 280px; max-width: 320px;",
          "border: 1px solid var(--border); border-radius: 0.75rem;",
          "padding: 1.25rem; display: flex; flex-direction: column; gap: 1.25rem;",
          "background: color-mix(in oklab, var(--muted) 40%, transparent);"
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem;",
          htmltools::tags$h4(style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; color: var(--muted-foreground); margin: 0;", "Content"),
          block_field(block_field_label("value", `for` = "showcase_slider_doc_value"), block_input("showcase_slider_doc_value", value = "50", placeholder = "50 or 25,75")),
          block_field(block_field_label("min", `for` = "showcase_slider_doc_min"), block_input("showcase_slider_doc_min", value = "0", type = "number")),
          block_field(block_field_label("max", `for` = "showcase_slider_doc_max"), block_input("showcase_slider_doc_max", value = "100", type = "number")),
          block_field(block_field_label("step", `for` = "showcase_slider_doc_step"), block_input("showcase_slider_doc_step", value = "1", type = "number")),
          block_field(
            block_field_label("orientation", `for` = "showcase_slider_doc_orientation"),
            block_select("showcase_slider_doc_orientation", choices = c("horizontal", "vertical"), selected = "horizontal")
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; color: var(--muted-foreground); margin: 0;", "State"),
          block_field(block_field_label("disabled", `for` = "showcase_slider_doc_disabled"), block_checkbox("showcase_slider_doc_disabled", "Disabled")),
          block_field(block_field_label("invalid", `for` = "showcase_slider_doc_invalid"), block_checkbox("showcase_slider_doc_invalid", "Invalid"))
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; color: var(--muted-foreground); margin: 0;", "Labels"),
          block_field(block_field_label("show value", `for` = "showcase_slider_doc_show_value"), block_checkbox("showcase_slider_doc_show_value", "Show current value")),
          block_field(block_field_label("min label", `for` = "showcase_slider_doc_min_label"), block_input("showcase_slider_doc_min_label", value = "Quiet", placeholder = "Optional minimum label")),
          block_field(block_field_label("max label", `for` = "showcase_slider_doc_max_label"), block_input("showcase_slider_doc_max_label", value = "Loud", placeholder = "Optional maximum label"))
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; color: var(--muted-foreground); margin: 0;", "Styling"),
          block_field(block_field_label("width", `for` = "showcase_slider_doc_width"), block_input("showcase_slider_doc_width", value = "20rem", placeholder = "100% or 20rem")),
          block_field(
            block_field_label("style", `for` = "showcase_slider_doc_style"),
            block_textarea("showcase_slider_doc_style", value = "", rows = 1, placeholder = "e.g., max-width: 20rem;", resize = "none")
          ),
          block_field(block_field_label("class", `for` = "showcase_slider_doc_class"), block_checkbox("showcase_slider_doc_class", "Use custom dashed-border class"))
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; color: var(--muted-foreground); margin: 0;", "Actions (Server Update)"),
          htmltools::div(
            style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
            showcase_action_button("showcase_slider_set_low", "Set 25"),
            showcase_action_button("showcase_slider_set_range", "Set range"),
            showcase_action_button("showcase_slider_disable", "Disable"),
            showcase_action_button("showcase_slider_enable", "Enable"),
            showcase_action_button("showcase_slider_resize", "Change bounds"),
            showcase_action_button("showcase_slider_vertical", "Show vertical")
          )
        )
      ),
      htmltools::div(
        style = "flex: 2; min-width: 320px; display: flex; flex-direction: column; gap: 1.25rem;",
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.5rem;",
          htmltools::div(style = "font-size: 0.875rem; font-weight: 600; color: var(--foreground);", "Preview"),
          htmltools::div(
            style = paste(
              "position: relative; display: flex; align-items: center; justify-content: center;",
              "padding: 3rem 2rem 2.5rem; background: var(--card);",
              "border: 1px dashed var(--border); border-radius: 0.75rem;",
              "min-height: 180px; box-sizing: border-box;"
            ),
            uiOutput("showcase_slider_preview_ui")
          )
        ),
        uiOutput("showcase_slider_preview_value"),
        htmltools::div(htmltools::div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;", "UI Definition"), uiOutput("showcase_slider_preview_code")),
        htmltools::div(htmltools::div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;", "Server Action"), uiOutput("showcase_slider_reactive_code"))
      )
    )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    min <- slider_number(input$showcase_slider_doc_min, 0)
    max <- slider_number(input$showcase_slider_doc_max, 100)
    if (min >= max) {
      min <- 0
      max <- 100
    }
    value <- pmin(max, pmax(min, parse_slider_value(input$showcase_slider_doc_value, 50)))
    if (length(value) == 2 && value[[1]] > value[[2]]) value <- sort(value)
    step <- slider_number(input$showcase_slider_doc_step, 1)
    if (step <= 0) step <- 1
    orientation <- input$showcase_slider_doc_orientation %||% "horizontal"
    if (!orientation %in% c("horizontal", "vertical")) orientation <- "horizontal"
    min_label <- input$showcase_slider_doc_min_label %||% ""
    if (!nzchar(min_label)) min_label <- NULL
    max_label <- input$showcase_slider_doc_max_label %||% ""
    if (!nzchar(max_label)) max_label <- NULL
    width <- input$showcase_slider_doc_width %||% "20rem"
    if (!nzchar(width)) width <- NULL
    style <- input$showcase_slider_doc_style %||% ""
    if (!nzchar(style)) style <- NULL
    list(
      value = value, min = min, max = max, step = step, width = width,
      orientation = orientation,
      show_value = isTRUE(input$showcase_slider_doc_show_value),
      min_label = min_label,
      max_label = max_label,
      disabled = isTRUE(input$showcase_slider_doc_disabled),
      invalid = isTRUE(input$showcase_slider_doc_invalid),
      style = style,
      class = if (isTRUE(input$showcase_slider_doc_class)) "showcase-slider-preview-custom" else NULL
    )
  })

  output$showcase_slider_preview_ui <- renderUI({
    args <- preview_args()
    slider <- block_slider(
      "showcase_slider_preview", value = args$value, min = args$min, max = args$max,
      step = args$step, orientation = args$orientation, show_value = args$show_value,
      min_label = args$min_label, max_label = args$max_label,
      width = args$width, disabled = args$disabled, invalid = args$invalid,
      style = args$style, class = args$class
    )
    if (identical(args$orientation, "vertical")) {
      htmltools::div(
        style = "display: inline-flex; flex-direction: column; align-items: center; gap: 0.75rem;",
        htmltools::tags$label(
          `for` = "showcase_slider_preview",
          style = "font-size: 0.875rem; font-weight: 500; line-height: 1;",
          "Volume"
        ),
        slider
      )
    } else {
      block_field(block_field_label("Volume", `for` = "showcase_slider_preview"), slider)
    }
  })

  output$showcase_slider_preview_value <- showcase_render_value({
    value <- input$showcase_slider_preview
    paste0("input$showcase_slider_preview = ", if (is.null(value)) "<NULL>" else paste(value, collapse = ", "))
  })

  output$showcase_slider_preview_code <- showcase_render_code({
    args <- preview_args()
    code <- c(
      'input_id = "showcase_slider_preview"',
      paste0("value = ", slider_code_value(args$value)),
      paste0("min = ", args$min),
      paste0("max = ", args$max),
      paste0("step = ", args$step)
    )
    if (args$orientation != "horizontal") code <- c(code, paste0('orientation = "', args$orientation, '"'))
    if (args$show_value) code <- c(code, "show_value = TRUE")
    if (!is.null(args$min_label)) code <- c(code, paste0('min_label = "', args$min_label, '"'))
    if (!is.null(args$max_label)) code <- c(code, paste0('max_label = "', args$max_label, '"'))
    if (!is.null(args$width)) code <- c(code, paste0('width = "', args$width, '"'))
    if (args$disabled) code <- c(code, "disabled = TRUE")
    if (args$invalid) code <- c(code, "invalid = TRUE")
    if (!is.null(args$style)) code <- c(code, paste0('style = "', args$style, '"'))
    if (!is.null(args$class)) code <- c(code, 'class = "showcase-slider-preview-custom"')
    paste0("block_slider(\n  ", paste(code, collapse = ",\n  "), "\n)")
  })

  reactive_code <- reactiveVal("# Click an action button to see\n# the update_block_slider() code here.")
  output$showcase_slider_reactive_code <- showcase_render_code(reactive_code())

  observeEvent(input$showcase_slider_set_low, {
    update_block_slider(session, "showcase_slider_preview", value = 25)
    reactive_code("update_block_slider(\n  session,\n  \"showcase_slider_preview\",\n  value = 25\n)")
  })
  observeEvent(input$showcase_slider_set_range, {
    update_block_slider(session, "showcase_slider_preview", value = c(25, 75))
    reactive_code("update_block_slider(\n  session,\n  \"showcase_slider_preview\",\n  value = c(25, 75)\n)")
  })
  observeEvent(input$showcase_slider_disable, {
    update_block_slider(session, "showcase_slider_preview", disabled = TRUE)
    reactive_code("update_block_slider(\n  session,\n  \"showcase_slider_preview\",\n  disabled = TRUE\n)")
  })
  observeEvent(input$showcase_slider_enable, {
    update_block_slider(session, "showcase_slider_preview", disabled = FALSE)
    reactive_code("update_block_slider(\n  session,\n  \"showcase_slider_preview\",\n  disabled = FALSE\n)")
  })
  observeEvent(input$showcase_slider_resize, {
    update_block_slider(session, "showcase_slider_preview", min = -50, max = 150, value = 40, step = 5)
    reactive_code("update_block_slider(\n  session,\n  \"showcase_slider_preview\",\n  min = -50, max = 150,\n  value = 40, step = 5\n)")
  })
  observeEvent(input$showcase_slider_vertical, {
    update_block_select(session, "showcase_slider_doc_orientation", selected = "vertical")
    update_block_checkbox(session, "showcase_slider_doc_show_value", checked = TRUE)
    update_block_input(session, "showcase_slider_doc_min_label", value = "Low")
    update_block_input(session, "showcase_slider_doc_max_label", value = "High")
    update_block_slider(
      session,
      "showcase_slider_preview",
      orientation = "vertical",
      show_value = TRUE,
      min_label = "Low",
      max_label = "High"
    )
    reactive_code("update_block_slider(\n  session,\n  \"showcase_slider_preview\",\n  orientation = \"vertical\",\n  show_value = TRUE,\n  min_label = \"Low\",\n  max_label = \"High\"\n)")
  })
}

shinyApp(ui, server)
