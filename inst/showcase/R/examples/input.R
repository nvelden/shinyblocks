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
        htmltools::div(
          style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
          showcase_action_button("showcase_input_set_value", "Set value"),
          showcase_action_button("showcase_input_clear", "Clear"),
          showcase_action_button("showcase_input_disable", "Disable"),
          showcase_action_button("showcase_input_enable", "Enable"),
          showcase_action_button("showcase_input_to_password", "Type → password")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("style", `for` = "showcase_input_doc_style"),
          block_textarea("showcase_input_doc_style", value = "", rows = 1, placeholder = "e.g., font-family: var(--font-mono);", resize = "none")
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
      shiny::uiOutput("showcase_input_preview_value")
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_input_api_table")
)
