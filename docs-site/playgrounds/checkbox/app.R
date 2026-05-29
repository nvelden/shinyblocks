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
  title = "shinyblocks · Checkbox playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    htmltools::tags$style(htmltools::HTML(
      "
      [data-shinyblocks-root] .showcase-checkbox-preview-custom .sb-checkbox-button,
      [data-shinyblocks-root].showcase-checkbox-preview-custom .sb-checkbox-button {
        border: 2px dashed red;
      }
      "
    ))
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
htmltools::div(
            style = "display: flex; flex-direction: column; gap: 0.75rem;",
            htmltools::tags$h4(
              style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
              "Content"
            ),
            block_field(
              block_field_label("label", `for` = "showcase_checkbox_doc_label"),
              block_textarea("showcase_checkbox_doc_label", value = "Email me product updates", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("description", `for` = "showcase_checkbox_doc_description"),
              block_textarea(
                "showcase_checkbox_doc_description",
                value = "Unchecked default checkbox state.",
                rows = 2,
                resize = "none"
              )
            ),
            block_field(
              block_field_label("invalid message", `for` = "showcase_checkbox_doc_invalid_message"),
              block_textarea(
                "showcase_checkbox_doc_invalid_message",
                value = "You must confirm the rollout checklist before continuing.",
                rows = 2,
                resize = "none"
              )
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
            htmltools::tags$h4(
              style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
              "State"
            ),
            block_field(
              block_field_label("checked", `for` = "showcase_checkbox_doc_checked"),
              block_checkbox("showcase_checkbox_doc_checked", "Checked", value = FALSE)
            ),
            block_field(
              block_field_label("disabled", `for` = "showcase_checkbox_doc_disabled"),
              block_checkbox("showcase_checkbox_doc_disabled", "Disabled", value = FALSE)
            ),
            block_field(
              block_field_label("invalid", `for` = "showcase_checkbox_doc_invalid"),
              block_checkbox("showcase_checkbox_doc_invalid", "Invalid", value = FALSE)
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
            htmltools::tags$h4(
              style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
              "Styling"
            ),
            block_field(
              block_field_label("style", `for` = "showcase_checkbox_doc_style"),
              block_textarea(
                "showcase_checkbox_doc_style",
                value = "",
                rows = 1,
                placeholder = "e.g., background: rgba(0,0,0,.03); padding: 0.5rem;",
                resize = "none"
              )
            ),
            block_field(
              block_field_label("class", `for` = "showcase_checkbox_doc_class"),
              block_checkbox(
                "showcase_checkbox_doc_class",
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
              showcase_action_button("showcase_checkbox_set_checked", "Set checked"),
              showcase_action_button("showcase_checkbox_clear", "Clear"),
              showcase_action_button("showcase_checkbox_disable", "Disable"),
              showcase_action_button("showcase_checkbox_enable", "Enable")
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
                "border: 1px solid var(--border); border-radius: 0.75rem;",
                "min-height: 160px; box-sizing: border-box;",
                "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
              ),
              uiOutput("showcase_checkbox_preview_ui")
            )
          ),
          uiOutput("showcase_checkbox_preview_value"),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(
                style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
                "UI Definition"
              ),
              uiOutput("showcase_checkbox_preview_code")
            ),
            htmltools::tags$div(
              htmltools::tags$div(
                style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
                "Server Action"
              ),
              uiOutput("showcase_checkbox_reactive_code")
            )
          )
        )
      )
    )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    label <- input$showcase_checkbox_doc_label %||% "Email me product updates"
    if (!nzchar(label)) label <- "Email me product updates"

    description <- input$showcase_checkbox_doc_description %||% "Unchecked default checkbox state."
    invalid_message <- input$showcase_checkbox_doc_invalid_message %||%
      "You must confirm the rollout checklist before continuing."
    style <- input$showcase_checkbox_doc_style %||% ""
    if (!nzchar(style)) style <- NULL

    list(
      label = label,
      description = description,
      invalid_message = invalid_message,
      checked = isTRUE(input$showcase_checkbox_doc_checked),
      disabled = isTRUE(input$showcase_checkbox_doc_disabled),
      invalid = isTRUE(input$showcase_checkbox_doc_invalid),
      style = style,
      class = if (isTRUE(input$showcase_checkbox_doc_class)) "showcase-checkbox-preview-custom" else NULL
    )
  })

  output$showcase_checkbox_preview_ui <- renderUI({
    args <- preview_args()
    preview <- block_field(
      block_checkbox(
        "showcase_checkbox_preview",
        args$label,
        value = args$checked,
        disabled = args$disabled,
        style = args$style,
        class = args$class
      ),
      block_field_description(args$description)
    )
    if (args$invalid) {
      block_field_invalid(preview, args$invalid_message)
    } else {
      preview
    }
  })

  output$showcase_checkbox_preview_value <- showcase_render_value({
    value <- input$showcase_checkbox_preview
    val_str <- if (is.null(value)) "<NULL>" else if (isTRUE(value)) "TRUE" else "FALSE"
    paste0("input$showcase_checkbox_preview = ", val_str)
  })

  output$showcase_checkbox_preview_code <- showcase_render_code({
    args <- preview_args()
    checkbox_args <- c(
      'input_id = "showcase_checkbox_preview"',
      paste0("label = ", string_literal(args$label))
    )
    if (args$checked) checkbox_args <- c(checkbox_args, "value = TRUE")
    if (args$disabled) checkbox_args <- c(checkbox_args, "disabled = TRUE")
    if (!is.null(args$style)) checkbox_args <- c(checkbox_args, paste0("style = ", string_literal(args$style)))
    if (!is.null(args$class)) checkbox_args <- c(checkbox_args, paste0("class = ", string_literal(args$class)))

    code <- paste0(
      "block_field(\n",
      "  block_checkbox(\n",
      "    ", paste(checkbox_args, collapse = ",\n    "), "\n",
      "  ),\n",
      "  block_field_description(", string_literal(args$description), ")\n",
      ")"
    )
    if (args$invalid) {
      code <- paste0(
        "block_field_invalid(\n",
        "  ", gsub("\n", "\n  ", code, fixed = TRUE), ",\n",
        "  ", string_literal(args$invalid_message), "\n",
        ")"
      )
    }
    code
  })

  reactive_code <- reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_checkbox() code here."
  ))

  output$showcase_checkbox_reactive_code <- showcase_render_code({
    reactive_code()
  })

  observeEvent(input$showcase_checkbox_set_checked, {
    update_block_checkbox(session, "showcase_checkbox_preview", checked = TRUE)
    reactive_code(paste0(
      "update_block_checkbox(\n",
      "  session = session,\n",
      "  input_id = \"showcase_checkbox_preview\",\n",
      "  checked = TRUE\n",
      ")"
    ))
  })

  observeEvent(input$showcase_checkbox_clear, {
    update_block_checkbox(session, "showcase_checkbox_preview", checked = FALSE)
    reactive_code(paste0(
      "update_block_checkbox(\n",
      "  session = session,\n",
      "  input_id = \"showcase_checkbox_preview\",\n",
      "  checked = FALSE\n",
      ")"
    ))
  })

  observeEvent(input$showcase_checkbox_disable, {
    update_block_checkbox(session, "showcase_checkbox_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_checkbox(\n",
      "  session = session,\n",
      "  input_id = \"showcase_checkbox_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  observeEvent(input$showcase_checkbox_enable, {
    update_block_checkbox(session, "showcase_checkbox_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_checkbox(\n",
      "  session = session,\n",
      "  input_id = \"showcase_checkbox_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })
}

shinyApp(ui, server)
