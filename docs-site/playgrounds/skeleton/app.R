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
  title = "shinyblocks - Skeleton playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    htmltools::tags$style(htmltools::HTML(
      "
      [data-shinyblocks-root].rounded-full [data-slot='skeleton'] {
        border-radius: 9999px;
      }
      [data-shinyblocks-root].rounded-md [data-slot='skeleton'] {
        border-radius: calc(var(--radius) - 2px);
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
              "Shape"
            ),
            block_field(
              block_field_label("shape", `for` = "showcase_skeleton_doc_shape"),
              block_select(
                "showcase_skeleton_doc_shape",
                choices = c("sharp", "rounded", "circle"),
                selected = "rounded",
                size = "sm"
              )
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(
              class = "showcase-controls-group__title",
              "Dimensions"
            ),
            block_field(
              block_field_label("width", `for` = "showcase_skeleton_doc_width"),
              block_select(
                "showcase_skeleton_doc_width",
                choices = c("12rem", "8rem", "4rem", "100%"),
                selected = "12rem",
                size = "sm"
              )
            ),
            block_field(
              block_field_label("height", `for` = "showcase_skeleton_doc_height"),
              block_select(
                "showcase_skeleton_doc_height",
                choices = c("1rem", "2rem", "4rem", "6rem"),
                selected = "1rem",
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
              uiOutput("showcase_skeleton_preview_ui")
            )
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              class = "showcase-playground__label--code",
              "UI Definition"
            ),
            uiOutput("showcase_skeleton_preview_code")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  shape_radius <- function(shape) {
    switch(shape %||% "rounded",
      sharp = "0",
      circle = "9999px",
      "calc(var(--radius) * 0.8)"
    )
  }

  skeleton_style <- function(width, height, radius, extra = NULL) {
    paste0(
      "display: block;",
      "width: ", width, ";",
      "height: ", height, ";",
      "border-radius: ", radius, ";",
      extra %||% ""
    )
  }

  preview_args <- reactive({
    shape <- input$showcase_skeleton_doc_shape %||% "rounded"
    list(
      radius = shape_radius(shape),
      avatar_radius = if (identical(shape, "circle")) "9999px" else shape_radius(shape),
      width = input$showcase_skeleton_doc_width %||% "12rem",
      height = input$showcase_skeleton_doc_height %||% "1rem"
    )
  })

  preview_card <- function(args) {
    block_stack(
      gap = "md",
      style = paste(
        "width: min(100%, 30rem);",
        "padding: 1.25rem; border-radius: 0.75rem; background: var(--card);",
        "box-shadow: 0 1px 2px rgb(0 0 0 / 0.06); box-sizing: border-box;"
      ),
      block_cluster(
        gap = "sm",
        align = "center",
        block_skeleton(
          style = skeleton_style(
            "3rem",
            "3rem",
            args$avatar_radius,
            "flex: 0 0 auto;"
          )
        ),
        block_stack(
          gap = "sm",
          style = "flex: 1; min-width: 0;",
          block_skeleton(
            style = skeleton_style(
              args$width,
              args$height,
              args$radius,
              "max-width: 100%;"
            )
          ),
          block_skeleton(
            style = skeleton_style("65%", args$height, args$radius)
          )
        )
      ),
      block_skeleton(
        style = skeleton_style("100%", "5rem", args$radius)
      ),
      block_cluster(
        gap = "sm",
        block_skeleton(
          style = skeleton_style("5rem", args$height, args$radius)
        ),
        block_skeleton(
          style = skeleton_style("7rem", args$height, args$radius)
        )
      )
    )
  }

  output$showcase_skeleton_preview_ui <- renderUI({
    preview_card(preview_args())
  })

  outputOptions(output, "showcase_skeleton_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_skeleton_preview_code <- showcase_render_code({
    args <- preview_args()
    paste0(
      "block_stack(\n",
      "  gap = \"md\",\n",
      "  block_skeleton(style = ",
      string_literal(skeleton_style(args$width, args$height, args$radius)),
      "),\n",
      "  block_skeleton(style = ",
      string_literal(skeleton_style("65%", args$height, args$radius)),
      "),\n",
      "  block_skeleton(style = ",
      string_literal(skeleton_style("100%", "5rem", args$radius)),
      ")\n",
      ")"
    )
  })
  outputOptions(output, "showcase_skeleton_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
