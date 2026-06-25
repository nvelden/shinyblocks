if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)

  mounted <- FALSE
  for (path in c("../../library.data.gz", "../library.data.gz")) {
    tryCatch(
      {
        webr::mount("/packages", path)
        if ("shinyblocks" %in% installed.packages(lib.loc = "/packages")[, "Package"]) {
          mounted <- TRUE
          break
        }
      },
      error = function(e) {
        # Try the next path; Shinylive resolves mount URLs differently by host.
      }
    )
  }

  if (!mounted) {
    tryCatch(
      {
        webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
      },
      error = function(e) {
        stop("Failed to mount shinyblocks WASM package library: ", e$message)
      }
    )
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
  if (is.null(x)) {
    return(fallback)
  }
  n <- suppressWarnings(as.numeric(x))
  if (length(n) != 1 || !is.finite(n)) fallback else n
}

blank_to_null <- function(x) {
  if (is.null(x) || !nzchar(trimws(x))) NULL else x
}

controls_group <- function(title, ..., first = FALSE) {
  grp_class <- if (isTRUE(first)) "showcase-controls-group showcase-controls-group--first" else "showcase-controls-group"
  block_stack(
    gap = "sm",
    class = grp_class,
    htmltools::tags$h4(
      class = "showcase-controls-group__title",
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
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    htmltools::tags$style(htmltools::HTML(
      ".docs-progress-preview-custom { border: 2px dashed var(--ring); border-radius: 0.5rem; padding: 0.5rem; }"
    ))
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
          controls_group(
            "Content",
            first = TRUE,
            block_field(
              block_field_label("value", `for` = "value"),
              block_input("value", value = "0.6", type = "number")
            ),
            block_field(
              block_field_label("min", `for` = "min"),
              block_input("min", value = "0", type = "number")
            ),
            block_field(
              block_field_label("max", `for` = "max"),
              block_input("max", value = "1", type = "number")
            ),
            block_field(
              block_field_label("label", `for` = "label"),
              block_input("label", value = "Upload")
            ),
            block_field(
              block_field_label("message", `for` = "message"),
              block_input("message", value = "Importing rows...")
            ),
            block_field(
              block_field_label("detail", `for` = "detail"),
              block_input("detail", value = "", placeholder = "e.g., 1,200 of 3,400")
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
            block_cluster(
              gap = "sm",
              action_button("set_25", "Set 25%"),
              action_button("set_75", "Set 75%"),
              action_button("inc", "Increment"),
              action_button("reset", "Reset"),
              action_button("toggle_indeterminate", "Indeterminate")
            ),
            htmltools::tags$p(
              style = "color: var(--muted-foreground); margin: 0.5rem 0 0.35rem 0; font-size: 0.8125rem;",
              paste(
                "Long-running task: advance a batch job without blocking the",
                "session. Run simulates a 20-batch import; the recipe appears",
                "under Server Action."
              )
            ),
            block_cluster(
              gap = "sm",
              action_button("batch_run", "Run import"),
              action_button("batch_cancel", "Cancel")
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
            ),
            block_field(
              block_field_label("width", `for` = "width"),
              block_input("width", value = "", placeholder = "e.g., 320px (blank = 100%)")
            ),
            block_field(
              block_field_label("style", `for` = "style"),
              block_input("style", value = "", placeholder = "e.g., opacity: 0.8;")
            ),
            block_field(
              block_field_label("class", `for` = "use_class"),
              block_checkbox("use_class", "Use custom dashed-border class", value = FALSE)
            )
          )
        ),
        block_stack(
          gap = "lg",
          class = "showcase-playground__main",
          block_stack(
            gap = "sm",
            htmltools::tags$div(
              class = "showcase-playground__label",
              "Preview"
            ),
            htmltools::tags$div(
              class = "showcase-preview-canvas",
              uiOutput("preview_ui")
            )
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              class = "showcase-playground__label--code",
              "Server Action"
            ),
            uiOutput("reactive_code")
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              class = "showcase-playground__label--code",
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
      detail = blank_to_null(input$detail),
      show_value = isTRUE(input$show_value),
      indeterminate = isTRUE(input$indeterminate),
      variant = input$variant %||% "default",
      width = blank_to_null(input$width),
      style = blank_to_null(input$style),
      use_class = isTRUE(input$use_class)
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
      detail = s$detail,
      label = s$label,
      show_value = s$show_value,
      indeterminate = s$indeterminate,
      variant = s$variant,
      width = s$width,
      style = s$style,
      class = if (s$use_class) "docs-progress-preview-custom" else NULL
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
    if (!is.null(s$detail)) args <- c(args, paste0('detail = "', s$detail, '"'))
    if (isTRUE(s$show_value)) args <- c(args, "show_value = TRUE")
    if (isTRUE(s$indeterminate)) args <- c(args, "indeterminate = TRUE")
    if (!identical(s$variant, "default")) args <- c(args, paste0('variant = "', s$variant, '"'))
    if (!is.null(s$width)) args <- c(args, paste0('width = "', s$width, '"'))
    if (!is.null(s$style)) args <- c(args, paste0('style = "', s$style, '"'))
    if (isTRUE(s$use_class)) args <- c(args, 'class = "docs-progress-preview-custom"')
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

  # Long-running task recipe, wired into the live preview bar. A stepped,
  # non-blocking reactive <U+2014> each tick advances one batch and pushes an update,
  # so Shiny flushes progress to the browser between steps instead of freezing
  # on a blocking loop.
  batch <- reactiveValues(running = FALSE, step = 0, total = 20)

  batch_recipe_code <- paste0(
    "batch <- reactiveValues(running = FALSE, step = 0, total = 20)\n\n",
    "observeEvent(input$run, {\n",
    "  batch$running <- TRUE\n",
    "  batch$step <- 0\n",
    "})\n\n",
    "# Stepped + non-blocking: re-invalidates until the job is done, so each\n",
    "# update_block_progress() call is flushed to the browser between steps.\n",
    "# A blocking for-loop would freeze the session and the bar would only\n",
    "# jump once, at the end.\n",
    "observe({\n",
    "  if (!batch$running) return()\n",
    "  invalidateLater(180, session)\n",
    "  isolate({\n",
    "    batch$step <- batch$step + 1\n",
    "    done <- batch$step >= batch$total\n",
    "    update_block_progress(\n",
    '      session, "preview_progress",\n',
    "      value   = batch$step / batch$total,\n",
    '      message = if (done) "Import complete" else sprintf("Importing batch %d of %d", batch$step, batch$total),\n',
    '      detail  = sprintf("%s rows written", format(batch$step * 500L, big.mark = ","))\n',
    "    )\n",
    "    if (done) batch$running <- FALSE\n",
    "  })\n",
    "})"
  )

  observeEvent(input$batch_run, {
    batch$running <- TRUE
    batch$step <- 0
    update_block_progress(
      session, "preview_progress",
      value = 0, message = "Starting import...", detail = NULL, indeterminate = FALSE
    )
    reactive_code(batch_recipe_code)
  })

  observeEvent(input$batch_cancel, {
    if (!batch$running) {
      return()
    }
    batch$running <- FALSE
    update_block_progress(
      session, "preview_progress",
      message = "Cancelled",
      detail = sprintf("Stopped at batch %d of %d", batch$step, batch$total)
    )
  })

  observe({
    if (!batch$running) {
      return()
    }
    invalidateLater(180, session)
    isolate({
      batch$step <- batch$step + 1
      done <- batch$step >= batch$total
      update_block_progress(
        session, "preview_progress",
        value = batch$step / batch$total,
        message = if (done) {
          "Import complete"
        } else {
          sprintf("Importing batch %d of %d", batch$step, batch$total)
        },
        detail = sprintf("%s rows written", format(batch$step * 500L, big.mark = ","))
      )
      if (done) batch$running <- FALSE
    })
  })
}

shinyApp(ui, server)
