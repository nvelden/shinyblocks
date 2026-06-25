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
  title = "shinyblocks <U+00B7> Switch playground",
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
            block_field(
              block_field_label("label", `for` = "showcase_switch_doc_label"),
              block_input("showcase_switch_doc_label", value = "Send incident alerts")
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "State"),
            block_field(
              block_field_label("value (checked)", `for` = "showcase_switch_doc_value"),
              block_checkbox("showcase_switch_doc_value", "Checked", value = FALSE)
            ),
            block_field(
              block_field_label("disabled", `for` = "showcase_switch_doc_disabled"),
              block_checkbox("showcase_switch_doc_disabled", "Disabled", value = FALSE)
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Styling"),
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
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Actions (Server Update)"),
            block_cluster(
              gap = "sm",
              showcase_action_button("showcase_switch_turn_on", "Turn on"),
              showcase_action_button("showcase_switch_turn_off", "Turn off"),
              showcase_action_button("showcase_switch_disable", "Disable"),
              showcase_action_button("showcase_switch_enable", "Enable"),
              showcase_action_button("showcase_switch_large", "Set large"),
              showcase_action_button("showcase_switch_rename", "Rename label")
            )
          )
        ),
        block_stack(
          gap = "lg",
          class = "showcase-playground__main",
          block_stack(
            gap = "sm",
            htmltools::tags$div(class = "showcase-playground__label", "Preview"),
            htmltools::tags$div(
              class = "showcase-preview-canvas showcase-preview-canvas--dashed",
              style = "min-height: 180px;",
              uiOutput("showcase_switch_preview_ui")
            )
          ),
          uiOutput("showcase_switch_preview_value"),
          block_stack(
            gap = "md",
            htmltools::tags$div(
              htmltools::tags$div(
                class = "showcase-playground__label--code",
                "UI Definition"
              ),
              uiOutput("showcase_switch_preview_code")
            ),
            htmltools::tags$div(
              htmltools::tags$div(
                class = "showcase-playground__label--code",
                "Server Action"
              ),
              uiOutput("showcase_switch_reactive_code")
            )
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
