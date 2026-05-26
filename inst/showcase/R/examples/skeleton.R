htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    showcase_playground_layout(
      controls = htmltools::tagList(
        showcase_controls_group(
          "Shape", first = TRUE,
          block_field(
            block_field_label("shape", `for` = "showcase_skeleton_doc_shape"),
            block_select(
              "showcase_skeleton_doc_shape",
              choices = c("block", "rounded", "circle"),
              selected = "block",
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
              choices = c("100%", "8rem", "4rem", "2rem"),
              selected = "100%",
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
      code_output_id = "showcase_skeleton_preview_code"
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
