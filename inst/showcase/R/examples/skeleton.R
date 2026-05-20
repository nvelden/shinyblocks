htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        style = "display: flex; gap: 2rem; flex-wrap: wrap; align-items: flex-start;",
        htmltools::div(
          style = "flex: 1; min-width: 300px; display: flex; flex-direction: column; gap: 1.5rem;",
          block_field(
            block_field_label("Preview", `for` = "showcase_skeleton_preview"),
            shiny::uiOutput("showcase_skeleton_preview_ui")
          ),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::uiOutput("showcase_skeleton_preview_code")
            )
          )
        ),
        htmltools::div(
          style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          # Content controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Shape"),
            block_field(
              block_field_label("shape", `for` = "showcase_skeleton_doc_shape"),
              block_select("showcase_skeleton_doc_shape", choices = c("block", "rounded", "circle"), selected = "block")
            )
          ),
          # Styling controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Dimensions"),
            block_field(
              block_field_label("width", `for` = "showcase_skeleton_doc_width"),
              block_select("showcase_skeleton_doc_width", choices = c("100%", "8rem", "4rem", "2rem"), selected = "100%")
            ),
            block_field(
              block_field_label("height", `for` = "showcase_skeleton_doc_height"),
              block_select("showcase_skeleton_doc_height", choices = c("1rem", "2rem", "4rem", "6rem"), selected = "1rem")
            )
          )
        )
      )
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
