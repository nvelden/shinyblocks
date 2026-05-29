htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Header", first = TRUE,
        block_field(
          block_field_label("title", `for` = "showcase_card_doc_title"),
          block_textarea("showcase_card_doc_title", value = "Card Title", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("description", `for` = "showcase_card_doc_desc"),
          block_textarea("showcase_card_doc_desc", value = "Card Description", rows = 1, resize = "none")
        )
      ),
      showcase_controls_group(
        "Content",
        block_field(
          block_field_label("value", `for` = "showcase_card_doc_value"),
          block_textarea("showcase_card_doc_value", value = "$45,231.89", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("body content", `for` = "showcase_card_doc_body"),
          block_textarea("showcase_card_doc_body", value = "+20.1% from last month", rows = 2, resize = "none")
        ),
        block_field(
          block_field_label("footer", `for` = "showcase_card_doc_footer"),
          block_checkbox("showcase_card_doc_footer", label = "Include footer button", value = TRUE)
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("class", `for` = "showcase_card_doc_class"),
          block_select(
            "showcase_card_doc_class",
            choices = c("none", "shadow-lg", "border-dashed"),
            selected = "none",
            size = "sm"
          )
        ),
        block_field(
          block_field_label("style", `for` = "showcase_card_doc_style"),
          block_textarea(
            "showcase_card_doc_style",
            value = "",
            rows = 1,
            placeholder = "e.g., max-width: 24rem;",
            resize = "none"
          )
        )
      )
    ),
    preview_output_id = "showcase_card_preview_ui",
    code_output_id = "showcase_card_preview_code",
    preview_canvas_style = paste(
      "position: relative; display: flex; align-items: center; justify-content: center;",
      "padding: 2rem; background: color-mix(in oklab, var(--muted) 28%, transparent);",
      "border: 0; border-radius: 0.75rem; min-height: 280px; box-sizing: border-box;"
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_card_api_table"),
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
    block_card(
      class = "sb-parity-card-composed",
      block_card_header(
        block_card_title("Revenue"),
        block_card_description("Last 30 days")
      ),
      block_card_content(
        htmltools::tags$div(class = "sb-card-value", "$42k"),
        "Up 12% month over month."
      ),
      block_card_footer(block_button("View report", variant = "outline"))
    ),
    block_card(
      class = "sb-parity-card-props",
      title = "Active users",
      description = "Weekly snapshot",
      value = "1,284",
      footer = block_badge("Healthy", variant = "secondary"),
      "Up 8% from last week."
    ),
    block_card(
      class = "sb-parity-card-plain",
      title = "Plain card",
      paste(
        "Cards can also be used as plain surfaces for grouped content",
        "without a numeric value slot."
      )
    )
  )
)
