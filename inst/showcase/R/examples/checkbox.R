htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("label", `for` = "showcase_checkbox_doc_label"),
          block_textarea("showcase_checkbox_doc_label", value = "Email me product updates", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("description", `for` = "showcase_checkbox_doc_description"),
          block_textarea("showcase_checkbox_doc_description", value = "Unchecked default checkbox state.", rows = 2, resize = "none")
        ),
        block_field(
          block_field_label("invalid message", `for` = "showcase_checkbox_doc_invalid_message"),
          block_textarea("showcase_checkbox_doc_invalid_message", value = "You must confirm the rollout checklist before continuing.", rows = 2, resize = "none")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("checked", `for` = "showcase_checkbox_doc_checked"),
          block_checkbox("showcase_checkbox_doc_checked", "Checked", value = FALSE)
        ),
        block_field(
          block_field_label("disabled", `for` = "showcase_checkbox_doc_disabled"),
          block_checkbox("showcase_checkbox_doc_disabled", "Disabled", value = FALSE)
        ),
        block_field(
          block_field_label("invalid", `for` = "showcase_checkbox_doc_invalid"),
          block_checkbox("showcase_checkbox_doc_invalid", "Invalid", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        htmltools::div(
          style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
          showcase_action_button("showcase_checkbox_set_checked", "Set checked"),
          showcase_action_button("showcase_checkbox_clear", "Clear"),
          showcase_action_button("showcase_checkbox_disable", "Disable"),
          showcase_action_button("showcase_checkbox_enable", "Enable")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("style", `for` = "showcase_checkbox_doc_style"),
          block_textarea("showcase_checkbox_doc_style", value = "", rows = 1, placeholder = "e.g., background: rgba(0,0,0,.03); padding: 0.5rem;", resize = "none")
        ),
        block_field(
          block_field_label("class", `for` = "showcase_checkbox_doc_class"),
          block_checkbox("showcase_checkbox_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_checkbox_preview_ui",
    code_output_id = "showcase_checkbox_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_checkbox_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_checkbox_reactive_code")
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_checkbox_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances captured by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 0.5rem; padding: 1rem; border: 1px dashed var(--border); border-radius: 0.5rem;",
    block_checkbox(
      "showcase_parity_checkbox_default",
      "Default checkbox",
      value = FALSE,
      class = "sb-parity-checkbox-default"
    ),
    block_checkbox(
      "showcase_parity_checkbox_checked",
      "Checked checkbox",
      value = TRUE,
      class = "sb-parity-checkbox-checked"
    ),
    block_checkbox(
      "showcase_parity_checkbox_disabled",
      "Disabled checkbox",
      value = FALSE,
      disabled = TRUE,
      class = "sb-parity-checkbox-disabled"
    )
  )
)
