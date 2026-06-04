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
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
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
              "position: relative; padding: 1.5rem; background: var(--card);",
              "border: 1px solid var(--border); border-radius: 0.75rem;",
              "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
            ),
            uiOutput("showcase_alert_preview_ui")
          )
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("showcase_alert_preview_code")
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
