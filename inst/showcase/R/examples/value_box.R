htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
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
          block_textarea("showcase_value_box_doc_desc", value = "Up 12% month over month.", rows = 2)
        )
      ),
      showcase_controls_group(
        "Styling",
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
            placeholder = "e.g., min-width: 18rem;"
          )
        )
      )
    ),
    preview_output_id = "showcase_value_box_preview_ui",
    code_output_id = "showcase_value_box_preview_code",
    preview_canvas_style = paste(
      "position: relative; display: flex; align-items: center; justify-content: center;",
      "padding: 2rem; background: color-mix(in oklab, var(--muted) 28%, transparent);",
      "border: 0; border-radius: 0.75rem; min-height: 240px; box-sizing: border-box;"
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
