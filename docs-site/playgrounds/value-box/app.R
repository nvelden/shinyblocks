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
  title = "shinyblocks - Value Box playground",
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
            block_field_label("title", `for` = "showcase_value_box_doc_title"),
            block_textarea("showcase_value_box_doc_title", value = "Net Revenue", rows = 1, resize = "none")
          ),
          block_field(
            block_field_label("value", `for` = "showcase_value_box_doc_value"),
            block_textarea("showcase_value_box_doc_value", value = "$45,231.89", rows = 1, resize = "none")
          ),
          block_field(
            block_field_label("description", `for` = "showcase_value_box_doc_desc"),
            block_textarea("showcase_value_box_doc_desc", value = "Up 12% month over month.", rows = 2, resize = "none")
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
            block_field_label("icon", `for` = "showcase_value_box_doc_icon"),
            block_select(
              "showcase_value_box_doc_icon",
              choices = c("trending-up", "alert-triangle", "users", "dollar-sign", "none"),
              selected = "trending-up",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("variant", `for` = "showcase_value_box_doc_variant"),
            block_select(
              "showcase_value_box_doc_variant",
              choices = c("default", "accent", "destructive"),
              selected = "default",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("class", `for` = "showcase_value_box_doc_class"),
            block_select(
              "showcase_value_box_doc_class",
              choices = c("none", "shadow-md", "border-dashed"),
              selected = "none",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("style", `for` = "showcase_value_box_doc_style"),
            block_textarea(
              "showcase_value_box_doc_style",
              value = "",
              rows = 1,
              placeholder = "e.g., min-width: 18rem;",
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
            class = "showcase-preview-canvas showcase-preview-canvas--muted",
            style = "min-height: 240px;",
            uiOutput("showcase_value_box_preview_ui")
          )
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            class = "showcase-playground__label showcase-playground__label--code",
            "UI Definition"
          ),
          uiOutput("showcase_value_box_preview_code")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    desc <- input$showcase_value_box_doc_desc %||% "Up 12% month over month."
    if (!nzchar(desc)) desc <- NULL

    icon <- input$showcase_value_box_doc_icon %||% "trending-up"
    if (identical(icon, "none")) icon <- NULL

    class <- input$showcase_value_box_doc_class %||% ""
    if (!nzchar(class) || identical(class, "none")) class <- NULL
    style <- input$showcase_value_box_doc_style %||% ""
    if (!nzchar(style)) style <- NULL

    list(
      title = input$showcase_value_box_doc_title %||% "Net Revenue",
      value = input$showcase_value_box_doc_value %||% "$45,231.89",
      description = desc,
      icon = icon,
      variant = input$showcase_value_box_doc_variant %||% "default",
      class = class,
      style = style
    )
  })

  output$showcase_value_box_preview_ui <- renderUI({
    args <- preview_args()
    block_value_box(
      title = args$title,
      value = args$value,
      description = args$description,
      icon = args$icon,
      variant = args$variant,
      class = args$class,
      style = args$style
    )
  })
  outputOptions(output, "showcase_value_box_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_value_box_preview_code <- showcase_render_code({
    args <- preview_args()
    code_args <- c(
      paste0("title = ", string_literal(args$title)),
      paste0("value = ", string_literal(args$value))
    )
    if (!is.null(args$description)) {
      code_args <- c(code_args, paste0("description = ", string_literal(args$description)))
    }
    if (!is.null(args$icon)) {
      code_args <- c(code_args, paste0("icon = ", string_literal(args$icon)))
    }
    if (!identical(args$variant, "default")) {
      code_args <- c(code_args, paste0("variant = ", string_literal(args$variant)))
    }
    if (!is.null(args$class)) {
      code_args <- c(code_args, paste0("class = ", string_literal(args$class)))
    }
    if (!is.null(args$style)) {
      code_args <- c(code_args, paste0("style = ", string_literal(args$style)))
    }

    paste0("block_value_box(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "showcase_value_box_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
