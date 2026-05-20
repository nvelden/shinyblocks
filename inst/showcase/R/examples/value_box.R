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
            block_field_label("Preview", `for` = "showcase_value_box_preview"),
            shiny::uiOutput("showcase_value_box_preview_ui")
          ),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::uiOutput("showcase_value_box_preview_code")
            )
          )
        ),
        htmltools::div(
          style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          # Content controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
            block_field(
              block_field_label("title", `for` = "showcase_value_box_doc_title"),
              block_textarea("showcase_value_box_doc_title", value = "Net Revenue", rows = 1)
            ),
            block_field(
              block_field_label("value", `for` = "showcase_value_box_doc_value"),
              block_textarea("showcase_value_box_doc_value", value = "$45,231.89", rows = 1)
            ),
            block_field(
              block_field_label("description", `for` = "showcase_value_box_doc_desc"),
              block_textarea("showcase_value_box_doc_desc", value = "Up 12% month over month.", rows = 1)
            )
          ),
          # Settings controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Settings"),
            block_field(
              block_field_label("icon", `for` = "showcase_value_box_doc_icon"),
              block_select("showcase_value_box_doc_icon", choices = c("trending-up", "alert-triangle", "users", "dollar-sign", "none"), selected = "trending-up")
            ),
            block_field(
              block_field_label("class", `for` = "showcase_value_box_doc_class"),
              block_select("showcase_value_box_doc_class", choices = c("none", "shadow-md", "border-dashed"), selected = "none")
            )
          )
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_value_box_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1rem;",
    block_value_box(
      "Net revenue",
      "$42k",
      description = "Up 12% month over month.",
      icon = "trending-up",
      class = "sb-parity-value-box-revenue"
    ),
    block_value_box(
      "Open incidents",
      "7",
      description = "Two require immediate response.",
      icon = "alert-triangle",
      class = "sb-parity-value-box-incidents"
    ),
    block_value_box(
      "Team seats",
      "24",
      block_badge("Healthy", variant = "secondary"),
      description = "No pending invites.",
      icon = "users",
      class = "sb-parity-value-box-seats"
    )
  )
)
