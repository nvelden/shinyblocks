htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("items", `for` = "showcase_accordion_doc_items"),
          block_textarea(
            "showcase_accordion_doc_items",
            value = paste(
              "shipping|Is it accessible?|Yes. It adheres to the WAI-ARIA design pattern.",
              "returns|Is it styled?|It ships with sensible token-driven defaults.",
              "billing|Is it animated?|Yes, the panel height animates by default.",
              sep = "\n"
            ),
            rows = 4,
            resize = "none"
          )
        ),
        block_field(
          block_field_label("icons", `for` = "showcase_accordion_doc_icons"),
          block_checkbox("showcase_accordion_doc_icons", "Show leading icons", value = FALSE)
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("type", `for` = "showcase_accordion_doc_type"),
          block_radio_group(
            "showcase_accordion_doc_type",
            choices = c(Single = "single", Multiple = "multiple"),
            selected = "single",
            orientation = "horizontal"
          )
        ),
        block_field(
          block_field_label("collapsible", `for` = "showcase_accordion_doc_collapsible"),
          block_checkbox(
            "showcase_accordion_doc_collapsible",
            "Allow the open item to collapse (single mode)",
            value = TRUE
          )
        ),
        block_field(
          block_field_label("initial open", `for` = "showcase_accordion_doc_open"),
          block_input("showcase_accordion_doc_open", value = "shipping")
        ),
        block_field(
          block_field_label("disabled", `for` = "showcase_accordion_doc_disabled"),
          block_checkbox("showcase_accordion_doc_disabled", "Disable the last item", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        block_cluster(
          gap = "sm",
          showcase_action_button("showcase_accordion_open_billing", "Open billing"),
          showcase_action_button("showcase_accordion_open_all", "Open all"),
          showcase_action_button("showcase_accordion_close_all", "Close all")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("style", `for` = "showcase_accordion_doc_style"),
          block_input(
            "showcase_accordion_doc_style",
            value = "",
            placeholder = "e.g., max-width: 28rem;"
          )
        ),
        block_field(
          block_field_label("class", `for` = "showcase_accordion_doc_class"),
          block_checkbox("showcase_accordion_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_accordion_preview_ui",
    code_output_id = "showcase_accordion_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_accordion_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_accordion_reactive_code")
      )
    ),
    preview_canvas_style = "min-height: 220px;"
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_accordion_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instance used by tools/parity/ and tools/theme/. Do not remove."
  ),
  block_accordion(
    block_accordion_item("one", "Item one", "First panel body."),
    block_accordion_item("two", "Item two", "Second panel body."),
    open = "one",
    class = "sb-parity-accordion"
  )
)
