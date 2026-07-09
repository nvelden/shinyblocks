# Install shinyblocks (pre-built WebAssembly binary) from r-universe.
# NOTE: must be installed.packages(), not requireNamespace() - webR shims
# requireNamespace() and it returns NULL (not FALSE) for packages missing
# from the default webR repo, so negating its result errors.
if (!"shinyblocks" %in% rownames(installed.packages())) {
  install.packages(
    "shinyblocks",
    repos = c("https://nvelden.r-universe.dev", "https://repo.r-wasm.org")
  )
}

library(shiny)
library(shinyblocks)

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

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

ui <- block_page(
  title = "shinyblocks - Alert playground",
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
            htmltools::tags$h4(
              class = "showcase-controls-group__title",
              "Content"
            ),
            block_field(
              block_field_label("title", `for` = "showcase_alert_doc_title"),
              block_textarea("showcase_alert_doc_title", value = "Heads up", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("description", `for` = "showcase_alert_doc_description"),
              block_textarea(
                "showcase_alert_doc_description",
                value = "shinyblocks alerts surface important inline messages.",
                rows = 3,
                resize = "none"
              )
            ),
            block_field(
              block_field_label("icon", `for` = "showcase_alert_doc_icon"),
              block_select(
                "showcase_alert_doc_icon",
                choices = c(
                  "<None>" = "none",
                  info = "info",
                  search = "search",
                  "alert-triangle" = "alert-triangle",
                  check = "check"
                ),
                selected = "info",
                size = "sm"
              )
            ),
            block_field(
              block_field_label("variant", `for` = "showcase_alert_doc_variant"),
              block_select(
                "showcase_alert_doc_variant",
                choices = c("default", "destructive", "success", "warning", "info"),
                selected = "default",
                size = "sm"
              )
            ),
            block_field(
              block_field_label("action", `for` = "showcase_alert_doc_action"),
              block_checkbox("showcase_alert_doc_action", "Include action button")
            ),
            block_field(
              block_field_label("action label", `for` = "showcase_alert_doc_action_label"),
              block_input("showcase_alert_doc_action_label", value = "Review")
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
              block_field_label("class", `for` = "showcase_alert_doc_class"),
              block_select(
                "showcase_alert_doc_class",
                choices = c("none", "shadow-lg", "border-dashed", "bg-transparent"),
                selected = "none",
                size = "sm"
              )
            ),
            block_field(
              block_field_label("style", `for` = "showcase_alert_doc_style"),
              block_textarea(
                "showcase_alert_doc_style",
                value = "",
                rows = 1,
                placeholder = "e.g., border-style: dashed;",
                resize = "none"
              )
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
              style = paste(
                "position: relative; padding: 1.5rem; background: var(--card);",
                "border: 1px solid var(--border); border-radius: 0.75rem;",
                "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
              ),
              uiOutput("showcase_alert_preview_ui")
            )
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              class = "showcase-playground__label--code",
              "UI Definition"
            ),
            uiOutput("showcase_alert_preview_code")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    title <- input$showcase_alert_doc_title %||% "Heads up"
    if (!nzchar(title)) title <- "Heads up"
    description <- input$showcase_alert_doc_description
    if (is.null(description) || !nzchar(description)) description <- NULL
    icon <- input$showcase_alert_doc_icon %||% "info"
    if (identical(icon, "none") || !nzchar(icon)) icon <- NULL
    action_label <- input$showcase_alert_doc_action_label %||% "Review"
    if (!nzchar(action_label)) action_label <- "Review"
    action <- if (isTRUE(input$showcase_alert_doc_action)) {
      block_alert_action(block_button(action_label, variant = "outline", size = "sm"))
    } else {
      NULL
    }
    class <- input$showcase_alert_doc_class %||% ""
    if (!nzchar(class) || identical(class, "none")) class <- NULL
    style <- input$showcase_alert_doc_style %||% ""
    if (!nzchar(style)) style <- NULL
    list(
      title = title,
      description = description,
      action = action,
      icon = icon,
      variant = input$showcase_alert_doc_variant %||% "default",
      class = class,
      style = style
    )
  })

  output$showcase_alert_preview_ui <- renderUI({
    args <- preview_args()
    block_alert(
      title = args$title,
      description = args$description,
      action = args$action,
      icon = args$icon,
      variant = args$variant,
      class = args$class,
      style = args$style
    )
  })
  outputOptions(output, "showcase_alert_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_alert_preview_code <- showcase_render_code({
    args <- preview_args()
    code_args <- c(paste0("title = ", string_literal(args$title)))
    if (!is.null(args$description)) {
      code_args <- c(code_args, paste0("description = ", string_literal(args$description)))
    }
    if (!is.null(args$icon)) {
      code_args <- c(code_args, paste0("icon = ", string_literal(args$icon)))
    }
    if (!identical(args$variant, "default")) {
      code_args <- c(code_args, paste0("variant = ", string_literal(args$variant)))
    }
    if (!is.null(args$action)) {
      action_label <- input$showcase_alert_doc_action_label %||% "Review"
      if (!nzchar(action_label)) action_label <- "Review"
      code_args <- c(
        code_args,
        paste0(
          "action = block_alert_action(block_button(",
          string_literal(action_label),
          ', variant = "outline", size = "sm"))'
        )
      )
    }
    if (!is.null(args$class)) {
      code_args <- c(code_args, paste0("class = ", string_literal(args$class)))
    }
    if (!is.null(args$style)) {
      code_args <- c(code_args, paste0("style = ", string_literal(args$style)))
    }
    paste0("block_alert(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "showcase_alert_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
