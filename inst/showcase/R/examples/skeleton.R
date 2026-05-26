htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Shape", first = TRUE,
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
      showcase_controls_group(
        "Dimensions",
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
    preview_output_id = "showcase_skeleton_preview_ui",
    code_output_id = "showcase_skeleton_preview_code",
    preview_canvas_style = paste(
      "position: relative; display: flex; align-items: center; justify-content: center;",
      "padding: 2rem; background: color-mix(in oklab, var(--muted) 28%, transparent);",
      "border: 0; border-radius: 0.75rem; min-height: 260px; box-sizing: border-box;"
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_skeleton_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 0.75rem; max-width: 300px;",
    block_skeleton(class = "sb-parity-skeleton-default", style = "height: 1rem; width: 6rem;"),
    block_skeleton(class = "sb-parity-skeleton-circle rounded-full", style = "height: 4rem; width: 4rem;")
  )
)
