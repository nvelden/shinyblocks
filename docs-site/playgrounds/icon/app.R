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
semantic_colors <- getFromNamespace("semantic_color_choices", "shinyblocks")()

ui <- block_page(
  title = "shinyblocks - Icon playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::tags$div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      class = "showcase-playground",
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
            block_field_label("name", `for` = "showcase_icon_doc_name"),
            block_select(
              "showcase_icon_doc_name",
              choices = icon_names,
              selected = "home",
              size = "sm"
            )
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
            block_field_label("size", `for` = "showcase_icon_doc_size"),
            block_select(
              "showcase_icon_doc_size",
              choices = c("sm", "default", "lg", "xl"),
              selected = "default",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("color", `for` = "showcase_icon_doc_color"),
            block_select(
              "showcase_icon_doc_color",
              choices = semantic_colors,
              selected = "default",
              size = "sm"
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
            class = "showcase-preview-canvas",
            uiOutput("showcase_icon_preview_ui")
          )
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            class = "showcase-playground__label showcase-playground__label--code",
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
    list(
      name = input$showcase_icon_doc_name %||% "home",
      size = input$showcase_icon_doc_size %||% "default",
      color = input$showcase_icon_doc_color %||% "default"
    )
  })

  output$showcase_icon_preview_ui <- renderUI({
    args <- preview_args()
    block_icon(args$name, size = args$size, color = args$color)
  })
  outputOptions(output, "showcase_icon_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_icon_preview_code <- showcase_render_code({
    args <- preview_args()
    lines <- c(paste0("  name = ", string_literal(args$name)))
    if (!identical(args$size, "default")) {
      lines <- c(lines, paste0("  size = ", string_literal(args$size)))
    }
    if (!identical(args$color, "default")) {
      lines <- c(lines, paste0("  color = ", string_literal(args$color)))
    }
    paste0("block_icon(\n", paste(lines, collapse = ",\n"), "\n)")
  })
  outputOptions(output, "showcase_icon_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
