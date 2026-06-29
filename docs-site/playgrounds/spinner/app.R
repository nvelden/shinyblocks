if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)

  mounted <- FALSE
  for (path in c("../../library.data.gz", "../library.data.gz")) {
    tryCatch(
      {
        webr::mount("/packages", path)
        if (
          "shinyblocks" %in%
            installed.packages(lib.loc = "/packages")[, "Package"]
        ) {
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

semantic_colors <- getFromNamespace("semantic_color_choices", "shinyblocks")()
spinner_icons <- getFromNamespace("spinner_icon_choices", "shinyblocks")()

showcase_render_code <- function(expr, env = parent.frame()) {
  quoted <- substitute(expr)
  force(env)
  renderUI({
    value <- eval(quoted, envir = env)
    if (is.null(value) || !length(value)) {
      value <- ""
    }
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
    htmltools::tags$link(
      rel = "stylesheet",
      href = "../../../shinyblocks-runtime-override.css"
    )
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
              "Accessibility"
            ),
            block_field(
              block_field_label(
                "aria-label",
                `for` = "showcase_spinner_doc_label"
              ),
              block_textarea(
                "showcase_spinner_doc_label",
                value = "Loading",
                rows = 1,
                resize = "none"
              )
            ),
            block_field_description(
              "Screen-reader label only; it does not render visible text."
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
              block_field_label(
                "icon",
                `for` = "showcase_spinner_doc_spinner_icon"
              ),
              block_select(
                "showcase_spinner_doc_spinner_icon",
                choices = spinner_icons,
                selected = "loader-2",
                size = "sm"
              )
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
              uiOutput("showcase_spinner_preview_ui")
            )
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              class = "showcase-playground__label--code",
              "UI Definition"
            ),
            uiOutput("showcase_spinner_preview_code")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    label <- input$showcase_spinner_doc_label %||% "Loading"
    if (!nzchar(label)) {
      label <- "Loading"
    }
    size <- input$showcase_spinner_doc_size %||% "default"
    color <- input$showcase_spinner_doc_color %||% "default"
    icon <- input$showcase_spinner_doc_spinner_icon %||% "loader-2"
    list(label = label, size = size, color = color, icon = icon)
  })

  output$showcase_spinner_preview_ui <- renderUI({
    args <- preview_args()
    block_spinner(
      label = args$label,
      size = args$size,
      color = args$color,
      icon = args$icon
    )
  })
  outputOptions(
    output,
    "showcase_spinner_preview_ui",
    suspendWhenHidden = FALSE
  )

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
    if (!identical(args$icon, "loader-2")) {
      code_args <- c(code_args, paste0("icon = ", string_literal(args$icon)))
    }
    if (length(code_args) == 0) {
      "block_spinner()"
    } else {
      paste0("block_spinner(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
    }
  })
  outputOptions(
    output,
    "showcase_spinner_preview_code",
    suspendWhenHidden = FALSE
  )
}

shinyApp(ui, server)
