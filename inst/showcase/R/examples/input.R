htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("label", `for` = "showcase_input_doc_label"),
          block_input("showcase_input_doc_label", value = "Email")
        ),
        block_field(
          block_field_label("placeholder", `for` = "showcase_input_doc_placeholder"),
          block_input("showcase_input_doc_placeholder", value = "name@example.com")
        ),
        block_field(
          block_field_label("initial value", `for` = "showcase_input_doc_value"),
          block_input("showcase_input_doc_value", value = "")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("type", `for` = "showcase_input_doc_type"),
          block_select(
            "showcase_input_doc_type",
            choices = c("text", "password", "email", "url", "tel", "search", "number"),
            selected = "text"
          )
        ),
        block_field(
          block_field_label("min (number type)", `for` = "showcase_input_doc_min"),
          block_input("showcase_input_doc_min", value = "", type = "number", placeholder = "e.g. 0")
        ),
        block_field(
          block_field_label("max (number type)", `for` = "showcase_input_doc_max"),
          block_input("showcase_input_doc_max", value = "", type = "number", placeholder = "e.g. 10")
        ),
        block_field(
          block_field_label("step (number type)", `for` = "showcase_input_doc_step"),
          block_input("showcase_input_doc_step", value = "", type = "number", placeholder = "default 1")
        ),
        block_field(
          block_field_label("disabled", `for` = "showcase_input_doc_disabled"),
          block_checkbox("showcase_input_doc_disabled", "Disabled", value = FALSE)
        ),
        block_field(
          block_field_label("invalid", `for` = "showcase_input_doc_invalid"),
          block_checkbox("showcase_input_doc_invalid", "Invalid", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        block_cluster(
          gap = "sm",
          showcase_action_button("showcase_input_set_value", "Set value"),
          showcase_action_button("showcase_input_clear", "Clear"),
          showcase_action_button("showcase_input_disable", "Disable"),
          showcase_action_button("showcase_input_enable", "Enable"),
          showcase_action_button("showcase_input_to_password", "Type → password"),
          showcase_action_button("showcase_input_number_bounds", "Bounds 0–10, step 2")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("style", `for` = "showcase_input_doc_style"),
          block_input("showcase_input_doc_style", value = "", placeholder = "e.g., font-family: var(--font-mono);")
        ),
        block_field(
          block_field_label("class", `for` = "showcase_input_doc_class"),
          block_checkbox("showcase_input_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_input_preview_ui",
    code_output_id = "showcase_input_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_input_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_input_reactive_code")
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_input_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instance used by tools/parity/ and tools/theme/. Do not remove."
  ),
  htmltools::div(
    style = "max-width: 320px;",
    block_input(
      "sb_parity_input_default",
      value = "Parity",
      class = "sb-parity-input-default"
    )
  ),
  htmltools::div(
    class = "sb-parity-input-number-wrap",
    style = "max-width: 320px; margin-top: 0.75rem;",
    block_input(
      "sb_parity_input_number",
      value = 5,
      type = "number",
      min = 0,
      max = 10,
      class = "sb-parity-input-number"
    )
  )
)
