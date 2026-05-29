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
  title = "shinyblocks - Card playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
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
            "Header"
          ),
          block_field(
            block_field_label("title", `for` = "showcase_card_doc_title"),
            block_textarea("showcase_card_doc_title", value = "Card Title", rows = 1, resize = "none")
          ),
          block_field(
            block_field_label("description", `for` = "showcase_card_doc_desc"),
            block_textarea("showcase_card_doc_desc", value = "Card Description", rows = 1, resize = "none")
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Content"
          ),
          block_field(
            block_field_label("value", `for` = "showcase_card_doc_value"),
            block_textarea("showcase_card_doc_value", value = "$45,231.89", rows = 1, resize = "none")
          ),
          block_field(
            block_field_label("body content", `for` = "showcase_card_doc_body"),
            block_textarea("showcase_card_doc_body", value = "+20.1% from last month", rows = 2, resize = "none")
          ),
          block_field(
            block_field_label("footer", `for` = "showcase_card_doc_footer"),
            block_checkbox("showcase_card_doc_footer", label = "Include footer button", value = TRUE)
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Styling"
          ),
          block_field(
            block_field_label("class", `for` = "showcase_card_doc_class"),
            block_select(
              "showcase_card_doc_class",
              choices = c("none", "shadow-lg", "border-dashed"),
              selected = "none",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("style", `for` = "showcase_card_doc_style"),
            block_textarea(
              "showcase_card_doc_style",
              value = "",
              rows = 1,
              placeholder = "e.g., max-width: 24rem;",
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
              "position: relative; display: flex; align-items: center; justify-content: center;",
              "padding: 2rem; background: color-mix(in oklab, var(--muted) 28%, transparent);",
              "border: 0; border-radius: 0.75rem; min-height: 280px; box-sizing: border-box;"
            ),
            uiOutput("showcase_card_preview_ui")
          )
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("showcase_card_preview_code")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    title <- input$showcase_card_doc_title %||% "Card Title"
    if (!nzchar(title)) title <- NULL

    desc <- input$showcase_card_doc_desc %||% "Card Description"
    if (!nzchar(desc)) desc <- NULL

    value <- input$showcase_card_doc_value %||% "$45,231.89"
    if (!nzchar(value)) value <- NULL

    body <- input$showcase_card_doc_body %||% "+20.1% from last month"
    if (!nzchar(body)) body <- NULL

    class <- input$showcase_card_doc_class %||% ""
    if (!nzchar(class) || identical(class, "none")) class <- NULL

    style <- input$showcase_card_doc_style %||% ""
    if (!nzchar(style)) style <- NULL

    list(
      title = title,
      description = desc,
      value = value,
      body = body,
      footer = isTRUE(input$showcase_card_doc_footer),
      class = class,
      style = style
    )
  })

  output$showcase_card_preview_ui <- renderUI({
    args <- preview_args()
    footer_tag <- NULL
    if (args$footer) {
      footer_tag <- block_button("View details", variant = "outline", size = "sm")
    }

    block_card(
      title = args$title,
      description = args$description,
      value = args$value,
      footer = footer_tag,
      class = args$class,
      style = args$style,
      args$body
    )
  })
  outputOptions(output, "showcase_card_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_card_preview_code <- showcase_render_code({
    args <- preview_args()
    code_args <- c()
    if (!is.null(args$title)) {
      code_args <- c(code_args, paste0("title = ", string_literal(args$title)))
    }
    if (!is.null(args$description)) {
      code_args <- c(code_args, paste0("description = ", string_literal(args$description)))
    }
    if (!is.null(args$value)) {
      code_args <- c(code_args, paste0("value = ", string_literal(args$value)))
    }
    if (args$footer) {
      code_args <- c(code_args, "footer = block_button(\"View details\", variant = \"outline\", size = \"sm\")")
    }
    if (!is.null(args$class)) {
      code_args <- c(code_args, paste0("class = ", string_literal(args$class)))
    }
    if (!is.null(args$style)) {
      code_args <- c(code_args, paste0("style = ", string_literal(args$style)))
    }
    if (!is.null(args$body)) {
      code_args <- c(code_args, string_literal(args$body))
    }

    paste0("block_card(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "showcase_card_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
