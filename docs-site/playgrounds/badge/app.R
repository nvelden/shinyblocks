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
  title = "shinyblocks - Badge playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    htmltools::tags$style(htmltools::HTML(
      "
      [data-shinyblocks-root] .showcase-badge-preview-custom [data-slot='badge'],
      [data-shinyblocks-root].showcase-badge-preview-custom [data-slot='badge'] {
        box-shadow: 0 0 0 2px var(--ring);
      }
      "
    ))
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
            block_field_label("label", `for` = "showcase_badge_doc_label"),
            block_textarea("showcase_badge_doc_label", value = "Deploying", rows = 1, resize = "none")
          ),
          block_field(
            block_field_label("variant", `for` = "showcase_badge_doc_variant"),
            block_select(
              "showcase_badge_doc_variant",
              choices = c("default", "secondary", "outline", "destructive", "ghost", "link"),
              selected = "default",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("size", `for` = "showcase_badge_doc_size"),
            block_select(
              "showcase_badge_doc_size",
              choices = c("sm", "default", "lg"),
              selected = "default",
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
            block_field_label("class", `for` = "showcase_badge_doc_class"),
            block_textarea(
              "showcase_badge_doc_class",
              value = "",
              rows = 1,
              placeholder = "showcase-badge-preview-custom",
              resize = "none"
            )
          ),
          block_field(
            block_field_label("style", `for` = "showcase_badge_doc_style"),
            block_textarea(
              "showcase_badge_doc_style",
              value = "",
              rows = 1,
              placeholder = "e.g., letter-spacing: 0.04em;",
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
            class = "showcase-preview-canvas",
            uiOutput("showcase_badge_preview_ui")
          )
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            class = "showcase-playground__label showcase-playground__label--code",
            "UI Definition"
          ),
          uiOutput("showcase_badge_preview_code")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    label <- input$showcase_badge_doc_label %||% "Deploying"
    if (!nzchar(label)) label <- "Deploying"
    class <- input$showcase_badge_doc_class %||% ""
    if (!nzchar(class)) class <- NULL
    style <- input$showcase_badge_doc_style %||% ""
    if (!nzchar(style)) style <- NULL

    list(
      label = label,
      variant = input$showcase_badge_doc_variant %||% "default",
      size = input$showcase_badge_doc_size %||% "default",
      class = class,
      style = style
    )
  })

  output$showcase_badge_preview_ui <- renderUI({
    args <- preview_args()
    block_badge(
      label = args$label,
      variant = args$variant,
      size = args$size,
      class = args$class,
      style = args$style
    )
  })
  outputOptions(output, "showcase_badge_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_badge_preview_code <- showcase_render_code({
    args <- preview_args()
    code_args <- c(paste0("label = ", string_literal(args$label)))
    if (!identical(args$variant, "default")) {
      code_args <- c(code_args, paste0("variant = ", string_literal(args$variant)))
    }
    if (!identical(args$size, "default")) {
      code_args <- c(code_args, paste0("size = ", string_literal(args$size)))
    }
    if (!is.null(args$class)) {
      code_args <- c(code_args, paste0("class = ", string_literal(args$class)))
    }
    if (!is.null(args$style)) {
      code_args <- c(code_args, paste0("style = ", string_literal(args$style)))
    }
    paste0("block_badge(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "showcase_badge_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
