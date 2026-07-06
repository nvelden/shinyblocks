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

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

ui <- block_page(
  title = "shinyblocks - Breadcrumb playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    htmltools::tags$style(htmltools::HTML(
      ".showcase-breadcrumb-preview-custom { border: 2px dashed var(--ring); border-radius: 0.5rem; padding: 0.5rem 0.75rem; }"
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
              block_field_label("trail depth", `for` = "showcase_breadcrumb_doc_depth"),
              block_select(
                "showcase_breadcrumb_doc_depth",
                choices = c("2", "3", "4"),
                selected = "3",
                size = "sm"
              )
            ),
            block_field(
              block_field_label("current page label", `for` = "showcase_breadcrumb_doc_current"),
              block_textarea("showcase_breadcrumb_doc_current", value = "Breadcrumb", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("ellipsis", `for` = "showcase_breadcrumb_doc_ellipsis"),
              block_checkbox(
                "showcase_breadcrumb_doc_ellipsis",
                "Collapse the middle with block_breadcrumb_ellipsis()",
                value = FALSE
              )
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
              block_field_label("separator", `for` = "showcase_breadcrumb_doc_separator"),
              block_select(
                "showcase_breadcrumb_doc_separator",
                choices = c("chevron (default)" = "chevron", "slash" = "slash", "dot" = "dot"),
                selected = "chevron",
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
              block_field_label("class", `for` = "showcase_breadcrumb_doc_class"),
              block_checkbox(
                "showcase_breadcrumb_doc_class",
                "Use custom dashed-border class",
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
              style = "min-height: 100px;",
              uiOutput("showcase_breadcrumb_preview_ui")
            )
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              class = "showcase-playground__label showcase-playground__label--code",
              "UI Definition"
            ),
            uiOutput("showcase_breadcrumb_preview_code")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  ancestor_labels <- c("Home", "Library", "Data")

  trail_args <- reactive({
    current_label <- input$showcase_breadcrumb_doc_current %||% "Breadcrumb"
    if (!nzchar(current_label)) current_label <- "Breadcrumb"
    list(
      depth = as.integer(input$showcase_breadcrumb_doc_depth %||% "3"),
      current = current_label,
      ellipsis = isTRUE(input$showcase_breadcrumb_doc_ellipsis),
      separator = input$showcase_breadcrumb_doc_separator %||% "chevron",
      class = if (isTRUE(input$showcase_breadcrumb_doc_class)) "showcase-breadcrumb-preview-custom" else NULL
    )
  })

  output$showcase_breadcrumb_preview_ui <- renderUI({
    args <- trail_args()
    ancestors <- ancestor_labels[seq_len(args$depth - 1L)]

    items <- lapply(ancestors, function(label) {
      block_breadcrumb_item(label, href = "#")
    })
    if (args$ellipsis) {
      items <- append(items, list(block_breadcrumb_ellipsis()), after = 1L)
    }
    items <- c(items, list(block_breadcrumb_item(args$current, current = TRUE)))

    # "·" (middle dot) stays escaped so sourcing in a C locale can't
    # mangle the literal into raw <c2><b7> bytes.
    separator <- switch(args$separator, slash = "/", dot = "\u00b7", NULL)

    do.call(block_breadcrumb, c(items, list(separator = separator, class = args$class)))
  })
  outputOptions(output, "showcase_breadcrumb_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_breadcrumb_preview_code <- showcase_render_code({
    args <- trail_args()
    ancestors <- ancestor_labels[seq_len(args$depth - 1L)]

    lines <- vapply(ancestors, function(label) {
      sprintf('  block_breadcrumb_item(%s, href = "#")', string_literal(label))
    }, character(1))
    if (args$ellipsis) {
      lines <- append(lines, "  block_breadcrumb_ellipsis()", after = 1L)
    }
    lines <- c(lines, sprintf("  block_breadcrumb_item(%s, current = TRUE)", string_literal(args$current)))

    if (identical(args$separator, "slash")) {
      lines <- c(lines, '  separator = "/"')
    } else if (identical(args$separator, "dot")) {
      lines <- c(lines, '  separator = "\\u00b7"')
    }
    if (!is.null(args$class)) {
      lines <- c(lines, paste0("  class = ", string_literal(args$class)))
    }

    paste0("block_breadcrumb(\n", paste(lines, collapse = ",\n"), "\n)")
  })
  outputOptions(output, "showcase_breadcrumb_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
