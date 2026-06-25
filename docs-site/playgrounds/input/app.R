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
  title = "shinyblocks <U+00B7> Input playground",
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
          block_stack(
            gap = "sm",
            class = "showcase-controls-group showcase-controls-group--first",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Content"),
            block_field(
              block_field_label("label", `for` = "showcase_input_doc_label"),
              block_input("showcase_input_doc_label", value = "Email")
            ),
            block_field(
              block_field_label("placeholder", `for` = "showcase_input_doc_placeholder"),
              block_input("showcase_input_doc_placeholder", value = "name@example.com")
            ),
            block_field(
              block_field_label("initial value", `for` = "showcase_input_doc_value"),
              block_input("showcase_input_doc_value", value = "")
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "State"),
            block_field(
              block_field_label("type", `for` = "showcase_input_doc_type"),
              block_select(
                "showcase_input_doc_type",
                choices = c("text", "password", "email", "url", "tel", "search", "number"),
                selected = "text",
                size = "sm"
              )
            ),
            block_field(
              block_field_label("disabled", `for` = "showcase_input_doc_disabled"),
              block_checkbox("showcase_input_doc_disabled", "Disabled", value = FALSE)
            ),
            block_field(
              block_field_label("invalid", `for` = "showcase_input_doc_invalid"),
              block_checkbox("showcase_input_doc_invalid", "Invalid", value = FALSE)
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Styling"),
            block_field(
              block_field_label("style", `for` = "showcase_input_doc_style"),
              block_textarea(
                "showcase_input_doc_style",
                value = "",
                rows = 1,
                placeholder = "e.g., font-family: var(--font-mono);",
                resize = "none"
              )
            ),
            block_field(
              block_field_label("class", `for` = "showcase_input_doc_class"),
              block_checkbox(
                "showcase_input_doc_class",
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
              showcase_action_button("showcase_input_set_value", "Set value"),
              showcase_action_button("showcase_input_clear", "Clear"),
              showcase_action_button("showcase_input_disable", "Disable"),
              showcase_action_button("showcase_input_enable", "Enable"),
              showcase_action_button("showcase_input_to_password", "Type password")
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
              class = "showcase-preview-canvas",
              uiOutput("showcase_input_preview_ui")
            )
          ),
          uiOutput("showcase_input_preview_value"),
          block_stack(
            gap = "md",
            htmltools::tags$div(
              htmltools::tags$div(
                class = "showcase-playground__label--code",
                "UI Definition"
              ),
              uiOutput("showcase_input_preview_code")
            ),
            htmltools::tags$div(
              htmltools::tags$div(
                class = "showcase-playground__label--code",
                "Server Action"
              ),
              uiOutput("showcase_input_reactive_code")
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    label <- input$showcase_input_doc_label %||% "Email"
    if (!nzchar(label)) label <- "Email"

    placeholder <- input$showcase_input_doc_placeholder %||% "name@example.com"
    value <- input$showcase_input_doc_value %||% ""
    style <- input$showcase_input_doc_style %||% ""
    if (!nzchar(style)) style <- NULL

    list(
      label = label,
      value = value,
      placeholder = placeholder,
      type = input$showcase_input_doc_type %||% "text",
      disabled = isTRUE(input$showcase_input_doc_disabled),
      invalid = isTRUE(input$showcase_input_doc_invalid),
      style = style,
      class = if (isTRUE(input$showcase_input_doc_class)) "border-dashed" else NULL
    )
  })

  output$showcase_input_preview_ui <- renderUI({
    args <- preview_args()
    block_field(
      block_field_label(args$label, `for` = "showcase_input_preview"),
      block_input(
        "showcase_input_preview",
        value = args$value,
        placeholder = args$placeholder,
        type = args$type,
        disabled = args$disabled,
        invalid = args$invalid,
        style = args$style,
        class = args$class
      )
    )
  })
  outputOptions(output, "showcase_input_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_input_preview_value <- showcase_render_value({
    value <- input$showcase_input_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (!nzchar(value)) {
      "<EMPTY>"
    } else {
      value
    }
    paste0("input$showcase_input_preview = ", val_str)
  })
  outputOptions(output, "showcase_input_preview_value", suspendWhenHidden = FALSE)

  output$showcase_input_preview_code <- showcase_render_code({
    args <- preview_args()
    code_args <- c(
      'input_id = "showcase_input_preview"',
      paste0("value = ", string_literal(args$value)),
      paste0("placeholder = ", string_literal(args$placeholder)),
      paste0("type = ", string_literal(args$type))
    )
    if (args$disabled) code_args <- c(code_args, "disabled = TRUE")
    if (args$invalid) code_args <- c(code_args, "invalid = TRUE")
    if (!is.null(args$style)) code_args <- c(code_args, paste0("style = ", string_literal(args$style)))
    if (!is.null(args$class)) code_args <- c(code_args, paste0("class = ", string_literal(args$class)))

    paste0("block_input(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "showcase_input_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_input() code here."
  ))

  output$showcase_input_reactive_code <- showcase_render_code({
    reactive_code()
  })
  outputOptions(output, "showcase_input_reactive_code", suspendWhenHidden = FALSE)

  observeEvent(input$showcase_input_set_value, {
    update_block_input(
      session,
      "showcase_input_preview",
      value = "shipped@shinyblocks.dev"
    )
    reactive_code("update_block_input(\n  session = session,\n  input_id = \"showcase_input_preview\",\n  value = \"shipped@shinyblocks.dev\"\n)")
  })

  observeEvent(input$showcase_input_clear, {
    args <- preview_args()
    update_block_input(
      session,
      "showcase_input_preview",
      value = args$value,
      type = args$type
    )
    reactive_code(paste0(
      "update_block_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_input_preview\",\n",
      "  value = \"", args$value, "\",\n",
      "  type = \"", args$type, "\"\n",
      ")"
    ))
  })

  observeEvent(input$showcase_input_disable, {
    update_block_input(session, "showcase_input_preview", disabled = TRUE)
    reactive_code("update_block_input(\n  session = session,\n  input_id = \"showcase_input_preview\",\n  disabled = TRUE\n)")
  })

  observeEvent(input$showcase_input_enable, {
    update_block_input(session, "showcase_input_preview", disabled = FALSE)
    reactive_code("update_block_input(\n  session = session,\n  input_id = \"showcase_input_preview\",\n  disabled = FALSE\n)")
  })

  observeEvent(input$showcase_input_to_password, {
    update_block_input(session, "showcase_input_preview", type = "password")
    reactive_code("update_block_input(\n  session = session,\n  input_id = \"showcase_input_preview\",\n  type = \"password\"\n)")
  })
}

shinyApp(ui, server)
