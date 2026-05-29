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
  block_button(
    label,
    id = input_id,
    variant = "outline",
    size = "sm"
  )
}

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

ui <- block_page(
  title = "shinyblocks · Switch playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    htmltools::tags$style(htmltools::HTML(
      "
      [data-shinyblocks-root] .showcase-switch-preview-custom .sb-switch-button,
      [data-shinyblocks-root].showcase-switch-preview-custom .sb-switch-button {
        outline: 2px dashed red;
        outline-offset: 3px;
      }
      "
    ))
  ),
  htmltools::tags$div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      class = "showcase-playground", style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
      htmltools::div(
        class = "showcase-playground__controls", style = paste(
          "flex: 1; min-width: 280px; max-width: 320px;",
          "border: 1px solid var(--border); border-radius: 0.75rem;",
          "padding: 1.25rem; display: flex; flex-direction: column; gap: 1.25rem;",
          "background: color-mix(in oklab, var(--muted) 40%, transparent);"
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Content"
          ),
          block_field(
            block_field_label("label", `for` = "showcase_switch_doc_label"),
            block_input("showcase_switch_doc_label", value = "Send incident alerts")
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "State"
          ),
          block_field(
            block_field_label("value (checked)", `for` = "showcase_switch_doc_value"),
            block_checkbox("showcase_switch_doc_value", "Checked", value = FALSE)
          ),
          block_field(
            block_field_label("disabled", `for` = "showcase_switch_doc_disabled"),
            block_checkbox("showcase_switch_doc_disabled", "Disabled", value = FALSE)
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Styling"
          ),
          block_field(
            block_field_label("size", `for` = "showcase_switch_doc_size"),
            block_select(
              "showcase_switch_doc_size",
              choices = c("default", "sm", "lg"),
              selected = "default",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("style", `for` = "showcase_switch_doc_style"),
            block_textarea(
              "showcase_switch_doc_style",
              value = "",
              rows = 1,
              placeholder = "e.g., padding: 0.5rem;",
              resize = "none"
            )
          ),
          block_field(
            block_field_label("class", `for` = "showcase_switch_doc_class"),
            block_checkbox(
              "showcase_switch_doc_class",
              "Use custom dashed-border class",
              value = FALSE
            )
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Actions (Server Update)"
          ),
          htmltools::tags$div(
            style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
            showcase_action_button("showcase_switch_turn_on", "Turn on"),
            showcase_action_button("showcase_switch_turn_off", "Turn off"),
            showcase_action_button("showcase_switch_disable", "Disable"),
            showcase_action_button("showcase_switch_enable", "Enable"),
            showcase_action_button("showcase_switch_large", "Set large"),
            showcase_action_button("showcase_switch_rename", "Rename label")
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
              "padding: 3rem 2rem 2.5rem 2rem; background: var(--card);",
              "border: 1px dashed var(--border); border-radius: 0.75rem;",
              "min-height: 180px; box-sizing: border-box;"
            ),
            uiOutput("showcase_switch_preview_ui")
          )
        ),
        uiOutput("showcase_switch_preview_value"),
        htmltools::tags$div(
          style = "display: flex; flex-direction: column; gap: 1rem;",
          htmltools::tags$div(
            htmltools::tags$div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
              "UI Definition"
            ),
            uiOutput("showcase_switch_preview_code")
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
              "Server Action"
            ),
            uiOutput("showcase_switch_reactive_code")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  preview_label <- reactiveVal("Send incident alerts")

  preview_args <- reactive({
    label <- input$showcase_switch_doc_label %||% preview_label()
    if (!nzchar(label)) label <- preview_label()
    preview_label(label)

    style <- input$showcase_switch_doc_style %||% ""
    if (!nzchar(style)) style <- NULL
    size <- input$showcase_switch_doc_size %||% "default"

    list(
      label = label,
      value = isTRUE(input$showcase_switch_doc_value),
      disabled = isTRUE(input$showcase_switch_doc_disabled),
      size = size,
      style = style,
      class = if (isTRUE(input$showcase_switch_doc_class)) "showcase-switch-preview-custom" else NULL
    )
  })

  output$showcase_switch_preview_ui <- renderUI({
    args <- preview_args()
    block_field(
      block_switch(
        "showcase_switch_preview",
        args$label,
        value = args$value,
        disabled = args$disabled,
        size = args$size,
        style = args$style,
        class = args$class
      )
    )
  })

  output$showcase_switch_preview_value <- showcase_render_value({
    value <- input$showcase_switch_preview
    val_str <- if (is.null(value)) "<NULL>" else if (isTRUE(value)) "TRUE" else "FALSE"
    paste0("input$showcase_switch_preview = ", val_str)
  })

  output$showcase_switch_preview_code <- showcase_render_code({
    args <- preview_args()
    switch_args <- c(
      'input_id = "showcase_switch_preview"',
      paste0("label = ", string_literal(args$label))
    )
    if (args$value) switch_args <- c(switch_args, "value = TRUE")
    if (args$disabled) switch_args <- c(switch_args, "disabled = TRUE")
    if (!identical(args$size, "default")) switch_args <- c(switch_args, paste0("size = ", string_literal(args$size)))
    if (!is.null(args$style)) switch_args <- c(switch_args, paste0("style = ", string_literal(args$style)))
    if (!is.null(args$class)) switch_args <- c(switch_args, paste0("class = ", string_literal(args$class)))

    paste0(
      "block_field(\n",
      "  block_switch(\n",
      "    ", paste(switch_args, collapse = ",\n    "), "\n",
      "  )\n",
      ")"
    )
  })

  reactive_code <- reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_switch() code here."
  ))

  output$showcase_switch_reactive_code <- showcase_render_code({
    reactive_code()
  })

  observeEvent(input$showcase_switch_turn_on, {
    update_block_switch(session, "showcase_switch_preview", checked = TRUE)
    reactive_code(paste0(
      "update_block_switch(\n",
      "  session = session,\n",
      "  input_id = \"showcase_switch_preview\",\n",
      "  checked = TRUE\n",
      ")"
    ))
  })

  observeEvent(input$showcase_switch_turn_off, {
    update_block_switch(session, "showcase_switch_preview", checked = FALSE)
    reactive_code(paste0(
      "update_block_switch(\n",
      "  session = session,\n",
      "  input_id = \"showcase_switch_preview\",\n",
      "  checked = FALSE\n",
      ")"
    ))
  })

  observeEvent(input$showcase_switch_disable, {
    update_block_switch(session, "showcase_switch_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_switch(\n",
      "  session = session,\n",
      "  input_id = \"showcase_switch_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  observeEvent(input$showcase_switch_enable, {
    update_block_switch(session, "showcase_switch_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_switch(\n",
      "  session = session,\n",
      "  input_id = \"showcase_switch_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  observeEvent(input$showcase_switch_large, {
    update_block_switch(session, "showcase_switch_preview", size = "lg")
    update_block_select(session, "showcase_switch_doc_size", selected = "lg")
    reactive_code(paste0(
      "update_block_switch(\n",
      "  session = session,\n",
      "  input_id = \"showcase_switch_preview\",\n",
      "  size = \"lg\"\n",
      ")"
    ))
  })

  observeEvent(input$showcase_switch_rename, {
    new_label <- "Auto-resolve pages"
    update_block_input(session, "showcase_switch_doc_label", value = new_label)
    reactive_code(paste0(
      "# `label` is a constructor arg, not an update_block_switch() arg.\n",
      "# Re-render with the new label via the constructor's `label`.\n",
      "block_switch(\"showcase_switch_preview\",\n",
      "  label = \"", new_label, "\", ...)"
    ))
  })
}

shinyApp(ui, server)
