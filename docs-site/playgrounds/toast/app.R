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
      error = function(e) {}
    )
  }
  if (!mounted) webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
  .libPaths(c("/packages", .libPaths()))
}

library(shiny)
do.call(library, list("shinyblocks", character.only = TRUE))

`%||%` <- function(a, b) if (is.null(a)) b else a
string_literal <- function(value) paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")

showcase_render_code <- function(expr, env = parent.frame()) {
  quoted <- substitute(expr)
  force(env)
  renderUI({
    block_code(paste(as.character(eval(quoted, envir = env)), collapse = "\n"), language = "r", copyable = TRUE, line_numbers = TRUE)
  })
}

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

control_group <- function(title, ..., first = FALSE) {
  block_stack(
    gap = "sm",
    class = if (first) "showcase-controls-group showcase-controls-group--first" else "showcase-controls-group",
    htmltools::tags$h4(class = "showcase-controls-group__title", title),
    ...
  )
}

toaster_id <- "showcase_toaster"

ui <- block_page(
  title = "shinyblocks - Toast playground",
  theme = htmltools::tagList(htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")),
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
          control_group(
            "Content",
            first = TRUE,
            block_field(block_field_label("title", `for` = "showcase_toast_doc_title"), block_textarea("showcase_toast_doc_title", value = "Changes saved", rows = 1, resize = "none")),
            block_field(block_field_label("description", `for` = "showcase_toast_doc_description"), block_textarea("showcase_toast_doc_description", value = "Your profile has been updated.", rows = 2, resize = "none"))
          ),
          control_group(
            "State",
            block_field(block_field_label("variant", `for` = "showcase_toast_doc_variant"), block_select("showcase_toast_doc_variant", choices = c("default", "destructive", "success", "warning", "info"), selected = "success", size = "sm")),
            block_field(block_field_label("icon", `for` = "showcase_toast_doc_icon"), block_select("showcase_toast_doc_icon", choices = c("info", "check-circle", "alert-triangle", "x-circle", "bell", "none"), selected = "check-circle", size = "sm")),
            block_field(block_field_label("dismissible", `for` = "showcase_toast_doc_dismissible"), block_checkbox("showcase_toast_doc_dismissible", "Show close button", value = TRUE))
          ),
          control_group(
            "Styling",
            block_field(block_field_label("position", `for` = "showcase_toast_doc_position"), block_select("showcase_toast_doc_position", choices = c("bottom-right", "bottom-center", "bottom-left", "top-right", "top-center", "top-left"), selected = "bottom-right", size = "sm")),
            block_field(block_field_label("duration (ms)", `for` = "showcase_toast_doc_duration"), block_select("showcase_toast_doc_duration", choices = c("3000", "5000", "8000", "0 (sticky)"), selected = "5000", size = "sm"))
          ),
          control_group(
            "Actions (Server)",
            block_cluster(
              gap = "sm",
              block_button("Show toast", id = "showcase_toast_fire", size = "sm"),
              block_button("Dismiss all", id = "showcase_toast_dismiss", variant = "outline", size = "sm")
            )
          )
        ),
        block_stack(
          gap = "lg",
          class = "showcase-playground__main",
          block_stack(
            gap = "sm",
            htmltools::div(class = "showcase-playground__label", "Preview"),
            htmltools::div(
              class = "showcase-preview-canvas showcase-preview-canvas--muted",
              style = "min-height: 200px;",
              uiOutput("showcase_toast_preview_ui")
            )
          ),
          htmltools::div(style = "font-size: 0.75rem; color: var(--muted-foreground);", "Click \"Show toast\" to fire a real toast. Changing the position moves it live."),
          block_toaster(toaster_id),
          uiOutput("showcase_toast_preview_value"),
          htmltools::div(htmltools::div(class = "showcase-playground__label--code", "UI Definition"), uiOutput("showcase_toast_preview_code")),
          htmltools::div(htmltools::div(class = "showcase-playground__label--code", "Server Action"), uiOutput("showcase_toast_reactive_code"))
        )
      )
    )
  )
)

server <- function(input, output, session) {
  reactive_code <- reactiveVal("# Click an action button to see\n# the show_toast() / dismiss_toast() code here.")

  parse_duration <- function(value) {
    raw <- value %||% "5000"
    if (identical(raw, "0 (sticky)")) {
      return(0)
    }
    suppressWarnings(as.numeric(raw)) %||% 5000
  }
  current_icon <- function() {
    icon <- input$showcase_toast_doc_icon %||% "check-circle"
    if (identical(icon, "none")) NULL else icon
  }
  variant_tokens <- function(variant) {
    switch(variant,
      destructive = list(bg = "var(--card)", fg = "var(--destructive)", border = "var(--destructive-border)"),
      success = list(bg = "var(--success)", fg = "var(--success-foreground)", border = "var(--success-border)"),
      warning = list(bg = "var(--warning)", fg = "var(--warning-foreground)", border = "var(--warning-border)"),
      info = list(bg = "var(--info)", fg = "var(--info-foreground)", border = "var(--info-border)"),
      list(bg = "var(--card)", fg = "var(--card-foreground)", border = "var(--border)")
    )
  }

  output$showcase_toast_preview_ui <- renderUI({
    variant <- input$showcase_toast_doc_variant %||% "success"
    title <- input$showcase_toast_doc_title %||% "Changes saved"
    description <- input$showcase_toast_doc_description %||% ""
    icon <- current_icon()
    dismissible <- isTRUE(input$showcase_toast_doc_dismissible)
    tokens <- variant_tokens(variant)
    htmltools::div(
      style = paste0(
        "position: relative; display: grid; grid-template-columns: auto minmax(0, 1fr);",
        " column-gap: 0.75rem; width: min(360px, 100%); border: 1px solid ", tokens$border, ";",
        " border-radius: var(--radius); padding: 0.75rem 2.25rem 0.75rem 1rem;",
        " background-color: ", tokens$bg, "; color: ", tokens$fg, ";",
        " box-shadow: var(--sb-overlay-shadow); font-size: 0.875rem; line-height: 1.25rem;"
      ),
      if (!is.null(icon)) htmltools::div(style = "display: flex; align-items: flex-start; padding-top: 0.125rem;", block_icon(icon, size = "sm")),
      htmltools::div(
        style = "display: flex; flex-direction: column; gap: 0.25rem; min-width: 0;",
        htmltools::div(style = "font-weight: 500; letter-spacing: -0.025em; line-height: 1.2;", title),
        if (nzchar(description)) htmltools::div(style = "font-size: 0.8125rem; opacity: 0.9;", description)
      ),
      if (dismissible) htmltools::div(style = "position: absolute; top: 0.5rem; right: 0.5rem; opacity: 0.6; font-size: 1rem; line-height: 1;", htmltools::HTML("&times;"))
    )
  })

  output$showcase_toast_preview_value <- showcase_render_value({
    value <- input[[toaster_id]]
    if (is.null(value)) {
      paste0("input$", toaster_id, " = <NULL>")
    } else {
      sprintf("input$%s = list(action = \"%s\", id = %s, seq = %s)", toaster_id, value$action %||% "", if (is.null(value$id)) "NULL" else paste0("\"", value$id, "\""), value$seq %||% 0)
    }
  })

  output$showcase_toast_preview_code <- showcase_render_code({
    position <- input$showcase_toast_doc_position %||% "bottom-right"
    ui_line <- if (identical(position, "bottom-right")) "block_toaster(\"notifications\")" else paste0("block_toaster(\"notifications\", position = ", string_literal(position), ")")
    title <- input$showcase_toast_doc_title %||% "Changes saved"
    description <- input$showcase_toast_doc_description %||% ""
    variant <- input$showcase_toast_doc_variant %||% "success"
    icon <- current_icon()
    duration <- parse_duration(input$showcase_toast_doc_duration)
    dismissible <- isTRUE(input$showcase_toast_doc_dismissible)
    args <- c("session = session", "toaster_id = \"notifications\"", paste0("title = ", string_literal(title)))
    if (nzchar(description)) args <- c(args, paste0("description = ", string_literal(description)))
    if (!identical(variant, "default")) args <- c(args, paste0("variant = ", string_literal(variant)))
    if (is.null(icon)) args <- c(args, "icon = NULL") else if (!identical(icon, "info")) args <- c(args, paste0("icon = ", string_literal(icon)))
    if (!identical(duration, 5000)) args <- c(args, paste0("duration = ", duration))
    if (!dismissible) args <- c(args, "dismissible = FALSE")
    paste0("# UI: mount one toaster\n", ui_line, "\n\n# Server: fire a toast\n", "show_toast(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })

  output$showcase_toast_reactive_code <- showcase_render_code(reactive_code())

  observeEvent(input$showcase_toast_doc_position, {
    update_block_toaster(session, toaster_id, position = input$showcase_toast_doc_position %||% "bottom-right")
  })

  observeEvent(input$showcase_toast_fire, {
    desc <- input$showcase_toast_doc_description %||% ""
    show_toast(
      session,
      toaster_id,
      title = input$showcase_toast_doc_title %||% "Changes saved",
      description = if (nzchar(desc)) desc else NULL,
      variant = input$showcase_toast_doc_variant %||% "success",
      icon = current_icon(),
      duration = parse_duration(input$showcase_toast_doc_duration),
      dismissible = isTRUE(input$showcase_toast_doc_dismissible)
    )
    reactive_code(paste0("show_toast(\n  session = session,\n  toaster_id = \"showcase_toaster\",\n  title = \"", input$showcase_toast_doc_title %||% "Changes saved", "\",\n  variant = \"", input$showcase_toast_doc_variant %||% "success", "\"\n)"))
  })

  observeEvent(input$showcase_toast_dismiss, {
    dismiss_toast(session, toaster_id)
    reactive_code("dismiss_toast(\n  session = session,\n  toaster_id = \"showcase_toaster\"\n)")
  })
}

shinyApp(ui, server)
