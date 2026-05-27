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
  title = "shinyblocks - Spinner playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::tags$div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
      htmltools::div(
        style = paste(
          "flex: 1; min-width: 280px; max-width: 320px;",
          "border: 1px solid var(--border); border-radius: 0.75rem;",
          "padding: 1.25rem; display: flex; flex-direction: column; gap: 1.25rem;",
          "background: color-mix(in oklab, var(--muted) 40%, transparent);"
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Accessibility"
          ),
          block_field(
            block_field_label("label", `for` = "showcase_spinner_doc_label"),
            block_textarea("showcase_spinner_doc_label", value = "Loading", rows = 1)
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Styling"
          ),
          block_field(
            block_field_label("size", `for` = "showcase_spinner_doc_size"),
            block_select(
              "showcase_spinner_doc_size",
              choices = c("sm", "default", "lg"),
              selected = "default",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("color", `for` = "showcase_spinner_doc_color"),
            block_select(
              "showcase_spinner_doc_color",
              choices = c("default", "destructive", "muted"),
              selected = "default",
              size = "sm"
            )
          )
        )
      ),
      htmltools::div(
        style = "flex: 2; min-width: 320px; display: flex; flex-direction: column; gap: 1.25rem;",
        htmltools::tags$div(
          style = "display: flex; flex-direction: column; gap: 0.5rem;",
          htmltools::tags$div(
            style = "font-size: 0.875rem; font-weight: 600; color: var(--foreground);",
            "Preview"
          ),
          htmltools::tags$div(
            style = paste(
              "position: relative; display: flex; align-items: center; justify-content: center;",
              "padding: 3rem 2rem; background: var(--card);",
              "border: 1px solid var(--border); border-radius: 0.75rem;",
              "min-height: 160px; box-sizing: border-box;",
              "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
            ),
            uiOutput("showcase_spinner_preview_ui")
          )
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("showcase_spinner_preview_code")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    label <- input$showcase_spinner_doc_label %||% "Loading"
    if (!nzchar(label)) label <- "Loading"
    size <- input$showcase_spinner_doc_size %||% "default"
    color <- input$showcase_spinner_doc_color %||% "default"
    list(label = label, size = size, color = color)
  })

  output$showcase_spinner_preview_ui <- renderUI({
    args <- preview_args()
    block_spinner(label = args$label, size = args$size, color = args$color)
  })
  outputOptions(output, "showcase_spinner_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_spinner_preview_code <- showcase_render_code({
    args <- preview_args()
    code_args <- c()
    if (!identical(args$label, "Loading")) {
      code_args <- c(code_args, paste0("label = ", string_literal(args$label)))
    }
    if (!identical(args$size, "default")) {
      code_args <- c(code_args, paste0("size = ", string_literal(args$size)))
    }
    if (!identical(args$color, "default")) {
      code_args <- c(code_args, paste0("color = ", string_literal(args$color)))
    }
    if (length(code_args) == 0) {
      "block_spinner()"
    } else {
      paste0("block_spinner(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
    }
  })
  outputOptions(output, "showcase_spinner_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
