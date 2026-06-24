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

icon_or_null <- function(value) {
  if (is.null(value) || identical(value, "none")) NULL else value
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
  title = "shinyblocks - Task button playground",
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
            block_field_label("label", `for` = "label"),
            block_input("label", value = "Run analysis")
          ),
          block_field(
            block_field_label("label_busy", `for` = "label_busy"),
            block_input("label_busy", value = "Crunching...")
          ),
          block_field(
            block_field_label("icon", `for` = "icon"),
            block_select(
              "icon",
              choices = c("<None>" = "none", play = "play", `arrow-right` = "arrow-right", check = "check"),
              selected = "none",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("icon_busy", `for` = "icon_busy"),
            block_select(
              "icon_busy",
              choices = c("Spinner (default)" = "none", `refresh-cw` = "refresh-cw", check = "check"),
              selected = "none",
              size = "sm"
            )
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
          "Styling",
          block_field(
            block_field_label("size", `for` = "size"),
            block_select(
              "size",
              choices = c("default", "sm", "lg"),
              selected = "default",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("icon_position", `for` = "icon_position"),
            block_select(
              "icon_position",
              choices = c("inline-start", "inline-end"),
              selected = "inline-start",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("style", `for` = "style"),
            block_input("style", value = "", placeholder = "e.g., min-width: 12rem;")
          ),
          block_field(
            block_field_label("class", `for` = "class"),
            block_checkbox("class", "Use custom dashed-border class", value = FALSE)
          )
        ),
        controls_group(
          "Actions (Server Update)",
          block_cluster(
            gap = "sm",
            # The signature server interaction: manual busy/ready control plus
            # disabled-state preservation. The Content / State / Styling controls
            # above already exercise the remaining update fields live.
            action_button("set_busy", "Set busy"),
            action_button("set_ready", "Set ready"),
            action_button("disable", "Disable"),
            action_button("enable", "Enable")
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
            class = "showcase-preview-canvas",
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
)

server <- function(input, output, session) {
  button_state <- reactive({
    list(
      label = blank_to_null(input$label) %||% "Run analysis",
      label_busy = blank_to_null(input$label_busy) %||% "Crunching...",
      icon = icon_or_null(input$icon),
      icon_busy = icon_or_null(input$icon_busy),
      variant = input$variant %||% "default",
      size = input$size %||% "default",
      icon_position = input$icon_position %||% "inline-start",
      auto_reset = isTRUE(input$auto_reset),
      disabled = isTRUE(input$disabled),
      style = blank_to_null(input$style),
      class = isTRUE(input$class)
    )
  })

  output$preview_ui <- renderUI({
    s <- button_state()
    block_task_button(
      input_id = "preview_task_button",
      label = s$label,
      label_busy = s$label_busy,
      variant = s$variant,
      size = s$size,
      icon = s$icon,
      icon_busy = s$icon_busy,
      icon_position = s$icon_position,
      auto_reset = s$auto_reset,
      disabled = s$disabled,
      style = s$style,
      class = if (s$class) "border-dashed" else NULL
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
    if (s$size != "default") args <- c(args, paste0("size = ", string_literal(s$size)))
    if (!is.null(s$icon)) args <- c(args, paste0("icon = ", string_literal(s$icon)))
    if (!is.null(s$icon_busy)) args <- c(args, paste0("icon_busy = ", string_literal(s$icon_busy)))
    if ((!is.null(s$icon) || !is.null(s$icon_busy)) && s$icon_position != "inline-start") {
      args <- c(args, paste0("icon_position = ", string_literal(s$icon_position)))
    }
    if (!s$auto_reset) args <- c(args, "auto_reset = FALSE")
    if (s$disabled) args <- c(args, "disabled = TRUE")
    if (!is.null(s$style)) args <- c(args, paste0("style = ", string_literal(s$style)))
    if (s$class) args <- c(args, 'class = "border-dashed"')
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

  show_update <- function(arg) {
    reactive_code(paste0('update_block_task_button(session, "preview_task_button", ', arg, ")"))
  }

  observeEvent(input$set_busy, {
    update_block_task_button(session, "preview_task_button", state = "busy")
    show_update('state = "busy"')
  })
  observeEvent(input$set_ready, {
    update_block_task_button(session, "preview_task_button", state = "ready")
    show_update('state = "ready"')
  })
  observeEvent(input$disable, {
    update_block_task_button(session, "preview_task_button", disabled = TRUE)
    show_update("disabled = TRUE")
  })
  observeEvent(input$enable, {
    update_block_task_button(session, "preview_task_button", disabled = FALSE)
    show_update("disabled = FALSE")
  })
}

shinyApp(ui, server)
