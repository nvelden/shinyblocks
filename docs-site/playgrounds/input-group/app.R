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
  block_button(label, id = input_id, variant = "outline", size = "sm")
}

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

ui <- block_page(
  title = "shinyblocks - Input Group playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    htmltools::tags$style(htmltools::HTML(
      ".showcase-input-group-preview-custom { border: 2px dashed var(--ring) !important; }"
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
            htmltools::tags$h4(
              class = "showcase-controls-group__title",
              "Content"
            ),
            block_field(
              block_field_label("pattern", `for` = "showcase_input_group_doc_pattern"),
              block_select(
                "showcase_input_group_doc_pattern",
                choices = c(
                  "Leading Icon" = "leading_icon",
                  "Trailing Icon" = "trailing_icon",
                  "Both Addons" = "both_addons",
                  "Workspace Slug" = "workspace_slug"
                ),
                selected = "leading_icon",
                size = "sm"
              )
            ),
            block_field(
              block_field_label("placeholder", `for` = "showcase_input_group_doc_placeholder"),
              block_textarea("showcase_input_group_doc_placeholder", value = "Search workspace...", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("value", `for` = "showcase_input_group_doc_value"),
              block_textarea("showcase_input_group_doc_value", value = "", rows = 1, resize = "none")
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(
              class = "showcase-controls-group__title",
              "State"
            ),
            block_field(
              block_field_label("disabled", `for` = "showcase_input_group_doc_disabled"),
              block_checkbox("showcase_input_group_doc_disabled", label = "Disabled")
            ),
            block_field(
              block_field_label("invalid", `for` = "showcase_input_group_doc_invalid"),
              block_checkbox("showcase_input_group_doc_invalid", label = "Invalid")
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(
              class = "showcase-controls-group__title",
              "Styling"
            ),
            block_field(
              block_field_label("style", `for` = "showcase_input_group_doc_style"),
              block_textarea(
                "showcase_input_group_doc_style",
                value = "",
                rows = 1,
                placeholder = "e.g., font-family: var(--font-mono);",
                resize = "none"
              )
            ),
            block_field(
              block_field_label("class", `for` = "showcase_input_group_doc_class"),
              block_checkbox("showcase_input_group_doc_class", "Use custom dashed-border class")
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(
              class = "showcase-controls-group__title",
              "Actions (Server Update)"
            ),
            block_cluster(
              gap = "sm",
              showcase_action_button("showcase_input_group_set_value", "Set value"),
              showcase_action_button("showcase_input_group_clear", "Reset"),
              showcase_action_button("showcase_input_group_disable", "Disable"),
              showcase_action_button("showcase_input_group_enable", "Enable")
            )
          )
        ),
        block_stack(
          gap = "lg",
          class = "showcase-playground__main",
          block_stack(
            gap = "sm",
            htmltools::div(
              class = "showcase-playground__label",
              "Preview"
            ),
            htmltools::tags$div(
              class = "showcase-preview-canvas showcase-preview-canvas--dashed",
              style = "min-height: 180px;",
              uiOutput("showcase_input_group_preview_ui")
            )
          ),
          uiOutput("showcase_input_group_preview_value"),
          htmltools::div(
            htmltools::div(
              class = "showcase-playground__label--code",
              "UI Definition"
            ),
            uiOutput("showcase_input_group_preview_code")
          ),
          htmltools::div(
            htmltools::div(
              class = "showcase-playground__label--code",
              "Server Action"
            ),
            uiOutput("showcase_input_group_reactive_code")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    style <- input$showcase_input_group_doc_style %||% ""
    if (!nzchar(style)) style <- NULL
    list(
      pattern = input$showcase_input_group_doc_pattern %||% "leading_icon",
      placeholder = input$showcase_input_group_doc_placeholder %||% "Search workspace...",
      value = input$showcase_input_group_doc_value %||% "",
      invalid = isTRUE(input$showcase_input_group_doc_invalid),
      disabled = isTRUE(input$showcase_input_group_doc_disabled),
      style = style,
      class = if (isTRUE(input$showcase_input_group_doc_class)) "showcase-input-group-preview-custom" else NULL
    )
  })

  render_group <- function(args) {
    input_tag <- block_input(
      "showcase_input_group_preview",
      value = args$value,
      placeholder = args$placeholder,
      invalid = args$invalid,
      disabled = args$disabled
    )
    children <- switch(args$pattern,
      trailing_icon = list(input_tag, block_input_group_addon(block_icon("mail"))),
      both_addons = list(block_input_group_addon("$"), input_tag, block_input_group_addon("USD")),
      workspace_slug = list(block_input_group_addon("acme.app/"), input_tag),
      list(block_input_group_addon(block_icon("search")), input_tag)
    )
    do.call(block_input_group, c(children, list(class = args$class, style = args$style)))
  }

  output$showcase_input_group_preview_ui <- renderUI(render_group(preview_args()))

  output$showcase_input_group_preview_value <- showcase_render_value({
    value <- input$showcase_input_group_preview
    value <- if (is.null(value)) "<NULL>" else if (!nzchar(value)) "<EMPTY>" else value
    paste0("input$showcase_input_group_preview = ", value)
  })

  output$showcase_input_group_preview_code <- showcase_render_code({
    args <- preview_args()
    input_args <- c(
      'input_id = "showcase_input_group_preview"',
      paste0("value = ", string_literal(args$value)),
      paste0("placeholder = ", string_literal(args$placeholder))
    )
    if (args$invalid) input_args <- c(input_args, "invalid = TRUE")
    if (args$disabled) input_args <- c(input_args, "disabled = TRUE")
    input_code <- paste0("block_input(\n    ", paste(input_args, collapse = ",\n    "), "\n  )")
    children <- switch(args$pattern,
      trailing_icon = paste0("  ", input_code, ",\n  block_input_group_addon(block_icon(\"mail\"))"),
      both_addons = paste0("  block_input_group_addon(\"$\"),\n  ", input_code, ",\n  block_input_group_addon(\"USD\")"),
      workspace_slug = paste0("  block_input_group_addon(\"acme.app/\"),\n  ", input_code),
      paste0("  block_input_group_addon(block_icon(\"search\")),\n  ", input_code)
    )
    group_args <- children
    if (!is.null(args$class)) group_args <- c(group_args, paste0("class = ", string_literal(args$class)))
    if (!is.null(args$style)) group_args <- c(group_args, paste0("style = ", string_literal(args$style)))
    paste0("block_input_group(\n", paste(group_args, collapse = ",\n"), "\n)")
  })

  reactive_code <- reactiveVal("# Click an action button to see\n# the update_block_input() code here.")
  output$showcase_input_group_reactive_code <- showcase_render_code(reactive_code())

  observeEvent(input$showcase_input_group_set_value, {
    update_block_input(session, "showcase_input_group_preview", value = "workspace-success")
    reactive_code("update_block_input(\n  session,\n  \"showcase_input_group_preview\",\n  value = \"workspace-success\"\n)")
  })
  observeEvent(input$showcase_input_group_clear, {
    value <- preview_args()$value
    update_block_input(session, "showcase_input_group_preview", value = value)
    reactive_code(paste0("update_block_input(\n  session,\n  \"showcase_input_group_preview\",\n  value = ", string_literal(value), "\n)"))
  })
  observeEvent(input$showcase_input_group_disable, {
    update_block_input(session, "showcase_input_group_preview", disabled = TRUE)
    reactive_code("update_block_input(\n  session,\n  \"showcase_input_group_preview\",\n  disabled = TRUE\n)")
  })
  observeEvent(input$showcase_input_group_enable, {
    update_block_input(session, "showcase_input_group_preview", disabled = FALSE)
    reactive_code("update_block_input(\n  session,\n  \"showcase_input_group_preview\",\n  disabled = FALSE\n)")
  })
}

shinyApp(ui, server)
