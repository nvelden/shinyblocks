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
  title = "shinyblocks - Task button playground",
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
            block_field_label("label", `for` = "label"),
            block_input("label", value = "Run analysis")
          ),
          block_field(
            block_field_label("label_busy", `for` = "label_busy"),
            block_input("label_busy", value = "Crunching…")
          )
        ),
        controls_group(
          "State",
          block_field(
            block_field_label("variant", `for` = "variant"),
            block_select(
              "variant",
              choices = c("default", "secondary", "outline", "ghost", "destructive", "link"),
              selected = "default",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("auto_reset", `for` = "auto_reset"),
            block_checkbox("auto_reset", "Reset to ready after the click flush", value = TRUE)
          ),
          block_field(
            block_field_label("disabled", `for` = "disabled"),
            block_checkbox("disabled", "Disabled", value = FALSE)
          )
        ),
        controls_group(
          "Actions (Server Update)",
          htmltools::div(
            style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
            action_button("set_busy", "Set busy"),
            action_button("set_ready", "Set ready")
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
            "input$ value"
          ),
          uiOutput("preview_value")
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "Task result"
          ),
          uiOutput("task_result_ui")
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
  button_state <- reactive({
    list(
      label = blank_to_null(input$label) %||% "Run analysis",
      label_busy = blank_to_null(input$label_busy) %||% "Crunching…",
      variant = input$variant %||% "default",
      auto_reset = isTRUE(input$auto_reset),
      disabled = isTRUE(input$disabled)
    )
  })

  output$preview_ui <- renderUI({
    s <- button_state()
    block_task_button(
      input_id = "preview_task_button",
      label = s$label,
      label_busy = s$label_busy,
      variant = s$variant,
      auto_reset = s$auto_reset,
      disabled = s$disabled
    )
  })
  outputOptions(output, "preview_ui", suspendWhenHidden = FALSE)

  output$preview_value <- showcase_render_code({
    value <- input$preview_task_button
    paste0("input$preview_task_button = ", if (is.null(value)) "<NULL>" else as.character(value))
  })
  outputOptions(output, "preview_value", suspendWhenHidden = FALSE)

  output$preview_code <- showcase_render_code({
    s <- button_state()
    args <- c(
      'input_id = "preview_task_button"',
      paste0("label = ", string_literal(s$label)),
      paste0("label_busy = ", string_literal(s$label_busy))
    )
    if (s$variant != "default") args <- c(args, paste0("variant = ", string_literal(s$variant)))
    if (!s$auto_reset) args <- c(args, "auto_reset = FALSE")
    if (s$disabled) args <- c(args, "disabled = TRUE")
    paste0("block_task_button(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "preview_code", suspendWhenHidden = FALSE)

  # Simulated work so the busy state is visible. The click locks the button on
  # the client; Shiny holds the outgoing ready-reset until this observer's flush
  # finishes, so it stays busy for the duration of the work. With auto_reset it
  # then clears itself; otherwise it stays busy until "Set ready".
  task_result <- reactiveVal(NULL)
  observeEvent(input$preview_task_button, {
    Sys.sleep(1.5)
    task_result(sprintf(
      "Run #%d complete at %s",
      input$preview_task_button,
      format(Sys.time(), "%H:%M:%S")
    ))
  }, ignoreInit = TRUE)

  output$task_result_ui <- showcase_render_code({
    res <- task_result()
    if (is.null(res)) "# Click the button to run a (simulated) 1.5s task." else res
  })
  outputOptions(output, "task_result_ui", suspendWhenHidden = FALSE)

  reactive_code <- reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_task_button() code here."
  ))
  output$reactive_code <- showcase_render_code({
    reactive_code()
  })
  outputOptions(output, "reactive_code", suspendWhenHidden = FALSE)

  observeEvent(input$set_busy, {
    update_block_task_button(session, "preview_task_button", state = "busy")
    reactive_code('update_block_task_button(session, "preview_task_button", state = "busy")')
  })
  observeEvent(input$set_ready, {
    update_block_task_button(session, "preview_task_button", state = "ready")
    reactive_code('update_block_task_button(session, "preview_task_button", state = "ready")')
  })
}

shinyApp(ui, server)
