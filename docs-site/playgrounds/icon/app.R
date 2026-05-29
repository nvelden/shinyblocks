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

icon_names <- sort(getFromNamespace("shinyblocks_icon_names", "shinyblocks")())

icon_style <- function(size, color) {
  size_style <- switch(
    size,
    small = "width: 1rem; height: 1rem;",
    large = "width: 2.25rem; height: 2.25rem;",
    "width: 1.5rem; height: 1.5rem;"
  )
  color_style <- switch(
    color,
    muted = "color: var(--muted-foreground);",
    primary = "color: var(--primary);",
    destructive = "color: var(--destructive);",
    NULL
  )
  paste(c(size_style, color_style), collapse = " ")
}

ui <- block_page(
  title = "shinyblocks - Icon playground",
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
            block_field_label("name", `for` = "showcase_icon_doc_name"),
            block_select(
              "showcase_icon_doc_name",
              choices = icon_names,
              selected = "home",
              size = "sm"
            )
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Styling"
          ),
          block_field(
            block_field_label("size", `for` = "showcase_icon_doc_size"),
            block_select(
              "showcase_icon_doc_size",
              choices = c("small", "medium", "large"),
              selected = "medium",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("color theme", `for` = "showcase_icon_doc_color"),
            block_select(
              "showcase_icon_doc_color",
              choices = c("foreground", "muted", "primary", "destructive"),
              selected = "foreground",
              size = "sm"
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
              "padding: 3rem 2rem; background: var(--card);",
              "border: 1px solid var(--border); border-radius: 0.75rem;",
              "min-height: 160px; box-sizing: border-box;",
              "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
            ),
            uiOutput("showcase_icon_preview_ui")
          )
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("showcase_icon_preview_code")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    size <- input$showcase_icon_doc_size %||% "medium"
    color <- input$showcase_icon_doc_color %||% "foreground"

    list(
      name = input$showcase_icon_doc_name %||% "home",
      style = icon_style(size, color)
    )
  })

  output$showcase_icon_preview_ui <- renderUI({
    args <- preview_args()
    block_icon(args$name, style = args$style)
  })
  outputOptions(output, "showcase_icon_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_icon_preview_code <- showcase_render_code({
    args <- preview_args()
    paste0(
      "block_icon(\n",
      "  name = ", string_literal(args$name), ",\n",
      "  style = ", string_literal(args$style), "\n",
      ")"
    )
  })
  outputOptions(output, "showcase_icon_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
