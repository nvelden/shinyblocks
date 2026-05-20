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
            block_field_label("Preview", `for` = "showcase_card_preview"),
            shiny::uiOutput("showcase_card_preview_ui")
          ),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::uiOutput("showcase_card_preview_code")
            )
          )
        ),
        htmltools::div(
          style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          # Content controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Header"),
            block_field(
              block_field_label("title", `for` = "showcase_card_doc_title"),
              block_textarea("showcase_card_doc_title", value = "Card Title", rows = 1)
            ),
            block_field(
              block_field_label("description", `for` = "showcase_card_doc_desc"),
              block_textarea("showcase_card_doc_desc", value = "Card Description", rows = 1)
            )
          ),
          # Body & Settings controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Body & Settings"),
            block_field(
              block_field_label("value", `for` = "showcase_card_doc_value"),
              block_textarea("showcase_card_doc_value", value = "$45,231.89", rows = 1)
            ),
            block_field(
              block_field_label("body content", `for` = "showcase_card_doc_body"),
              block_textarea("showcase_card_doc_body", value = "+20.1% from last month", rows = 1)
            ),
            block_field(
              block_field_label("footer", `for` = "showcase_card_doc_footer"),
              block_checkbox("showcase_card_doc_footer", label = "Include footer button", value = TRUE)
            ),
            block_field(
              block_field_label("class", `for` = "showcase_card_doc_class"),
              block_select("showcase_card_doc_class", choices = c("none", "shadow-lg", "border-dashed"), selected = "none")
            )
          )
        )
      )
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
