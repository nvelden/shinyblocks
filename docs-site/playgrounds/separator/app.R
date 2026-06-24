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
  title = "shinyblocks - Separator playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    htmltools::tags$style(htmltools::HTML(
      "
      [data-shinyblocks-root] .showcase-separator-preview-custom [data-slot='separator'],
      [data-shinyblocks-root].showcase-separator-preview-custom [data-slot='separator'] {
        background-color: var(--primary);
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
          htmltools::tags$h4(
            class = "showcase-controls-group__title",
            "Content"
          ),
          block_field(
            block_field_label("orientation", `for` = "showcase_separator_doc_orientation"),
            block_select(
              "showcase_separator_doc_orientation",
              choices = c("horizontal", "vertical"),
              selected = "horizontal",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("decorative", `for` = "showcase_separator_doc_decorative"),
            block_checkbox(
              "showcase_separator_doc_decorative",
              "Decorative (Accessibility)",
              value = TRUE
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
            block_field_label("class", `for` = "showcase_separator_doc_class"),
            block_checkbox(
              "showcase_separator_doc_class",
              "Use primary separator class",
              value = FALSE
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
            uiOutput("showcase_separator_preview_ui")
          )
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            class = "showcase-playground__label showcase-playground__label--code",
            "UI Definition"
          ),
          uiOutput("showcase_separator_preview_code")
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            class = "showcase-playground__label showcase-playground__label--code",
            "Rendered accessibility attributes"
          ),
          uiOutput("showcase_separator_accessibility_code")
        )
      )
    )
  )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    list(
      orientation = input$showcase_separator_doc_orientation %||% "horizontal",
      decorative = isTRUE(input$showcase_separator_doc_decorative),
      class = if (isTRUE(input$showcase_separator_doc_class)) "showcase-separator-preview-custom" else NULL
    )
  })

  output$showcase_separator_preview_ui <- renderUI({
    args <- preview_args()
    separator <- block_separator(
      orientation = args$orientation,
      decorative = args$decorative,
      class = args$class
    )

    if (identical(args$orientation, "horizontal")) {
      block_stack(
        gap = "md",
        class = "showcase-separator-stack",
        htmltools::tags$span("An elegant divider in horizontal layouts"),
        separator,
        htmltools::tags$span(
          style = "color: var(--muted-foreground);",
          "Content flows naturally above and below."
        )
      )
    } else {
      block_cluster(
        gap = "md",
        align = "center",
        wrap = FALSE,
        class = "showcase-separator-row",
        htmltools::tags$span("Left segment"),
        separator,
        htmltools::tags$span("Right segment")
      )
    }
  })
  outputOptions(output, "showcase_separator_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_separator_preview_code <- showcase_render_code({
    args <- preview_args()
    code_args <- c()
    if (!identical(args$orientation, "horizontal")) {
      code_args <- c(code_args, 'orientation = "vertical"')
    }
    if (!args$decorative) {
      code_args <- c(code_args, "decorative = FALSE")
    }
    if (!is.null(args$class)) {
      code_args <- c(code_args, paste0("class = ", string_literal(args$class)))
    }

    if (!length(code_args)) {
      "block_separator()"
    } else {
      paste0("block_separator(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
    }
  })
  outputOptions(output, "showcase_separator_preview_code", suspendWhenHidden = FALSE)

  output$showcase_separator_accessibility_code <- showcase_render_code({
    args <- preview_args()
    if (isTRUE(args$decorative)) {
      '<div data-slot="separator" aria-hidden="true">'
    } else {
      paste0(
        '<div data-slot="separator" role="separator" aria-orientation="',
        args$orientation,
        '">'
      )
    }
  })
  outputOptions(output, "showcase_separator_accessibility_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
