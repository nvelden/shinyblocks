register_skeleton_showcase <- function(input, output, session) {
  shape_radius <- function(shape) {
    switch(
      shape %||% "rounded",
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

  preview_args <- shiny::reactive({
    shape <- input$showcase_skeleton_doc_shape %||% "rounded"
    list(
      radius = shape_radius(shape),
      avatar_radius = if (identical(shape, "circle")) "9999px" else shape_radius(shape),
      width = input$showcase_skeleton_doc_width %||% "12rem",
      height = input$showcase_skeleton_doc_height %||% "1rem"
    )
  })

  preview_card <- function(args) {
    htmltools::tags$div(
      style = paste(
        "width: min(100%, 30rem); display: flex; flex-direction: column; gap: 1rem;",
        "padding: 1.25rem; border-radius: 0.75rem; background: var(--card);",
        "box-shadow: 0 1px 2px rgb(0 0 0 / 0.06); box-sizing: border-box;"
      ),
      htmltools::tags$div(
        style = "display: flex; align-items: center; gap: 0.875rem;",
        block_skeleton(
          style = skeleton_style(
            "3rem",
            "3rem",
            args$avatar_radius,
            "flex: 0 0 auto;"
          )
        ),
        htmltools::tags$div(
          style = "flex: 1; display: flex; flex-direction: column; gap: 0.5rem; min-width: 0;",
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
      htmltools::tags$div(
        style = "display: flex; gap: 0.5rem; flex-wrap: wrap;",
        block_skeleton(
          style = skeleton_style("5rem", args$height, args$radius)
        ),
        block_skeleton(
          style = skeleton_style("7rem", args$height, args$radius)
        )
      )
    )
  }

  output$showcase_skeleton_preview_ui <- shiny::renderUI({
    preview_card(preview_args())
  })
  shiny::outputOptions(
    output,
    "showcase_skeleton_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_skeleton_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    args <- preview_args()

    paste0(
      "htmltools::div(\n",
      "  style = \"display: flex; flex-direction: column; gap: 1rem;\",\n",
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
  shiny::outputOptions(
    output,
    "showcase_skeleton_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_skeleton_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("class", "..."),
      Type = c("character", "named attributes"),
      Default = c("NULL", "none"),
      Description = c(
        "Additional CSS class merged onto the skeleton element (e.g. rounded-full).",
        "Additional attributes passed to the div tag (e.g. style for dimensions)."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_skeleton_api_table",
    suspendWhenHidden = FALSE
  )
}
