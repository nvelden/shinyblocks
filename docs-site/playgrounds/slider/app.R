# Install shinyblocks (pre-built WebAssembly binary) from r-universe.
# NOTE: must be installed.packages(), not requireNamespace() - webR shims
# requireNamespace() and it returns NULL (not FALSE) for packages missing
# from the default webR repo, so negating its result errors.
if (!"shinyblocks" %in% rownames(installed.packages())) {
  install.packages(
    "shinyblocks",
    repos = c("https://nvelden.r-universe.dev", "https://repo.r-wasm.org")
  )
}

library(shiny)
library(shinyblocks)

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
  if (is.null(text) || !nzchar(text)) {
    return(fallback)
  }
  values <- suppressWarnings(as.numeric(trimws(strsplit(text, ",", fixed = TRUE)[[1]])))
  values <- values[!is.na(values)]
  if (!length(values)) {
    return(fallback)
  }
  values[seq_len(min(2, length(values)))]
}

slider_number <- function(value, fallback) {
  parsed <- suppressWarnings(as.numeric(value))
  if (length(parsed) != 1 || is.na(parsed)) fallback else parsed
}

slider_code_value <- function(value) {
  if (length(value) == 1) {
    return(as.character(value))
  }
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
      class = "showcase-playground",
      block_cluster(
        gap = "lg",
        align = "start",
        class = "showcase-playground__split",
        block_card(
          title = "Controls",
          class = "showcase-playground__controls",
          block_stack(
            gap = "sm",
            class = "showcase-controls-group showcase-controls-group--first",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Content"),
            block_field(block_field_label("value", `for` = "showcase_slider_doc_value"), block_input("showcase_slider_doc_value", value = "50", placeholder = "50 or 25,75")),
            block_field(block_field_label("min", `for` = "showcase_slider_doc_min"), block_input("showcase_slider_doc_min", value = "0", type = "number")),
            block_field(block_field_label("max", `for` = "showcase_slider_doc_max"), block_input("showcase_slider_doc_max", value = "100", type = "number")),
            block_field(block_field_label("step", `for` = "showcase_slider_doc_step"), block_input("showcase_slider_doc_step", value = "1", type = "number")),
            block_field(
              block_field_label("orientation", `for` = "showcase_slider_doc_orientation"),
              block_select("showcase_slider_doc_orientation", choices = c("horizontal", "vertical"), selected = "horizontal")
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "State"),
            block_field(block_field_label("disabled", `for` = "showcase_slider_doc_disabled"), block_checkbox("showcase_slider_doc_disabled", "Disabled")),
            block_field(block_field_label("invalid", `for` = "showcase_slider_doc_invalid"), block_checkbox("showcase_slider_doc_invalid", "Invalid"))
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Labels"),
            block_field(block_field_label("show value", `for` = "showcase_slider_doc_show_value"), block_checkbox("showcase_slider_doc_show_value", "Show current value")),
            block_field(block_field_label("min label", `for` = "showcase_slider_doc_min_label"), block_input("showcase_slider_doc_min_label", value = "Quiet", placeholder = "Optional minimum label")),
            block_field(block_field_label("max label", `for` = "showcase_slider_doc_max_label"), block_input("showcase_slider_doc_max_label", value = "Loud", placeholder = "Optional maximum label"))
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Styling"),
            block_field(block_field_label("width", `for` = "showcase_slider_doc_width"), block_input("showcase_slider_doc_width", value = "20rem", placeholder = "100% or 20rem")),
            block_field(
              block_field_label("style", `for` = "showcase_slider_doc_style"),
              block_textarea("showcase_slider_doc_style", value = "", rows = 1, placeholder = "e.g., max-width: 20rem;", resize = "none")
            ),
            block_field(block_field_label("class", `for` = "showcase_slider_doc_class"), block_checkbox("showcase_slider_doc_class", "Use custom dashed-border class"))
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Actions (Server Update)"),
            block_cluster(
              gap = "sm",
              showcase_action_button("showcase_slider_set_low", "Set 25"),
              showcase_action_button("showcase_slider_set_range", "Set range"),
              showcase_action_button("showcase_slider_disable", "Disable"),
              showcase_action_button("showcase_slider_enable", "Enable"),
              showcase_action_button("showcase_slider_resize", "Change bounds"),
              showcase_action_button("showcase_slider_vertical", "Show vertical")
            )
          )
        ),
        block_stack(
          gap = "lg",
          class = "showcase-playground__main",
          block_stack(
            gap = "sm",
            htmltools::div(class = "showcase-playground__label", "Preview"),
            htmltools::tags$div(
              class = "showcase-preview-canvas showcase-preview-canvas--dashed",
              style = "min-height: 180px;",
              uiOutput("showcase_slider_preview_ui")
            )
          ),
          uiOutput("showcase_slider_preview_value"),
          htmltools::div(htmltools::div(class = "showcase-playground__label--code", "UI Definition"), uiOutput("showcase_slider_preview_code")),
          htmltools::div(htmltools::div(class = "showcase-playground__label--code", "Server Action"), uiOutput("showcase_slider_reactive_code"))
        )
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
      "showcase_slider_preview",
      value = args$value, min = args$min, max = args$max,
      step = args$step, orientation = args$orientation, show_value = args$show_value,
      min_label = args$min_label, max_label = args$max_label,
      width = args$width, disabled = args$disabled, invalid = args$invalid,
      style = args$style, class = args$class
    )
    if (identical(args$orientation, "vertical")) {
      block_stack(
        gap = "sm",
        align = "center",
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
