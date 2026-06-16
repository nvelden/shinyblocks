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

num_or <- function(x, fallback) {
  if (is.null(x)) return(fallback)
  n <- suppressWarnings(as.numeric(x))
  if (length(n) != 1 || !is.finite(n)) fallback else n
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
  title = "shinyblocks - Progress playground",
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
            block_field_label("value", `for` = "value"),
            block_textarea("value", value = "0.6", rows = 1, resize = "none")
          ),
          block_field(
            block_field_label("min", `for` = "min"),
            block_textarea("min", value = "0", rows = 1, resize = "none")
          ),
          block_field(
            block_field_label("max", `for` = "max"),
            block_textarea("max", value = "1", rows = 1, resize = "none")
          ),
          block_field(
            block_field_label("label", `for` = "label"),
            block_textarea("label", value = "Upload", rows = 1, resize = "none")
          ),
          block_field(
            block_field_label("message", `for` = "message"),
            block_textarea("message", value = "Importing rows...", rows = 1, resize = "none")
          )
        ),
        controls_group(
          "State",
          block_field(
            block_field_label("show_value", `for` = "show_value"),
            block_checkbox("show_value", "Show percent", value = TRUE)
          ),
          block_field(
            block_field_label("indeterminate", `for` = "indeterminate"),
            block_checkbox("indeterminate", "Indeterminate", value = FALSE)
          )
        ),
        controls_group(
          "Actions (Server Update)",
          htmltools::div(
            style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
            action_button("set_25", "Set 25%"),
            action_button("set_75", "Set 75%"),
            action_button("inc", "Increment"),
            action_button("reset", "Reset"),
            action_button("toggle_indeterminate", "Indeterminate")
          )
        ),
        controls_group(
          "Styling",
          block_field(
            block_field_label("variant", `for` = "variant"),
            block_select(
              "variant",
              choices = c("default", "success", "warning", "info", "destructive"),
              selected = "default",
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
              "position: relative; display: flex; align-items: center; justify-content: center;",
              "padding: 2.5rem 2rem; background: var(--card);",
              "border: 1px solid var(--border); border-radius: 0.75rem;",
              "min-height: 160px; box-sizing: border-box;",
              "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
            ),
            uiOutput("preview_ui")
          )
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "Server Action"
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
  state <- reactive({
    min <- num_or(input$min, 0)
    max <- num_or(input$max, 1)
    if (!(min < max)) {
      min <- 0
      max <- 1
    }
    list(
      value = num_or(input$value, min),
      min = min,
      max = max,
      label = blank_to_null(input$label),
      message = blank_to_null(input$message),
      show_value = isTRUE(input$show_value),
      indeterminate = isTRUE(input$indeterminate),
      variant = input$variant %||% "default"
    )
  })

  output$preview_ui <- renderUI({
    s <- state()
    block_progress(
      id = "preview_progress",
      value = s$value,
      min = s$min,
      max = s$max,
      message = s$message,
      label = s$label,
      show_value = s$show_value,
      indeterminate = s$indeterminate,
      variant = s$variant
    )
  })
  outputOptions(output, "preview_ui", suspendWhenHidden = FALSE)

  output$preview_code <- showcase_render_code({
    s <- state()
    args <- c('id = "preview_progress"')
    if (s$value != 0) args <- c(args, paste0("value = ", s$value))
    if (s$min != 0) args <- c(args, paste0("min = ", s$min))
    if (s$max != 1) args <- c(args, paste0("max = ", s$max))
    if (!is.null(s$label)) args <- c(args, paste0('label = "', s$label, '"'))
    if (!is.null(s$message)) args <- c(args, paste0('message = "', s$message, '"'))
    if (isTRUE(s$show_value)) args <- c(args, "show_value = TRUE")
    if (isTRUE(s$indeterminate)) args <- c(args, "indeterminate = TRUE")
    if (!identical(s$variant, "default")) args <- c(args, paste0('variant = "', s$variant, '"'))
    paste0("block_progress(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "preview_code", suspendWhenHidden = FALSE)

  reactive_code <- reactiveVal(paste0(
    "# Click an action button to see the\n",
    "# update_block_progress() / inc_block_progress() call here."
  ))
  output$reactive_code <- showcase_render_code({
    reactive_code()
  })
  outputOptions(output, "reactive_code", suspendWhenHidden = FALSE)

  observeEvent(input$set_25, {
    update_block_progress(session, "preview_progress", value = 0.25, indeterminate = FALSE)
    reactive_code('update_block_progress(session, "preview_progress", value = 0.25)')
  })
  observeEvent(input$set_75, {
    update_block_progress(session, "preview_progress", value = 0.75, indeterminate = FALSE)
    reactive_code('update_block_progress(session, "preview_progress", value = 0.75)')
  })
  observeEvent(input$inc, {
    inc_block_progress(session, "preview_progress", amount = 0.1)
    reactive_code('inc_block_progress(session, "preview_progress", amount = 0.1)')
  })
  observeEvent(input$reset, {
    update_block_progress(session, "preview_progress", value = 0, indeterminate = FALSE)
    reactive_code('update_block_progress(session, "preview_progress", value = 0)  # reset to min')
  })
  observeEvent(input$toggle_indeterminate, {
    update_block_progress(session, "preview_progress", indeterminate = TRUE)
    reactive_code('update_block_progress(session, "preview_progress", indeterminate = TRUE)')
  })
}

shinyApp(ui, server)
