htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("label", `for` = "showcase_textarea_doc_label"),
          block_input("showcase_textarea_doc_label", value = "Notes")
        ),
        block_field(
          block_field_label("placeholder", `for` = "showcase_textarea_doc_placeholder"),
          block_input("showcase_textarea_doc_placeholder", value = "Add release notes here…")
        ),
        block_field(
          block_field_label("initial value", `for` = "showcase_textarea_doc_value"),
          block_textarea("showcase_textarea_doc_value", value = "", rows = 3, resize = "none")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("rows", `for` = "showcase_textarea_doc_rows"),
          block_input("showcase_textarea_doc_rows", value = "3")
        ),
        block_field(
          block_field_label("disabled", `for` = "showcase_textarea_doc_disabled"),
          block_checkbox("showcase_textarea_doc_disabled", "Disabled", value = FALSE)
        ),
        block_field(
          block_field_label("invalid", `for` = "showcase_textarea_doc_invalid"),
          block_checkbox("showcase_textarea_doc_invalid", "Invalid", value = FALSE)
        ),
        block_field(
          block_field_label("resize", `for` = "showcase_textarea_doc_resize"),
          block_select(
            "showcase_textarea_doc_resize",
            choices = c("vertical", "none", "both", "horizontal"),
            selected = "vertical",
            size = "sm"
          )
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        htmltools::div(
          style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
          showcase_action_button("showcase_textarea_set_value", "Set value"),
          showcase_action_button("showcase_textarea_clear", "Clear"),
          showcase_action_button("showcase_textarea_disable", "Disable"),
          showcase_action_button("showcase_textarea_enable", "Enable"),
          showcase_action_button("showcase_textarea_grow", "Resize 6 rows")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("style", `for` = "showcase_textarea_doc_style"),
          block_input("showcase_textarea_doc_style", value = "", placeholder = "e.g., font-family: var(--font-mono);")
        ),
        block_field(
          block_field_label("class", `for` = "showcase_textarea_doc_class"),
          block_checkbox("showcase_textarea_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_textarea_preview_ui",
    code_output_id = "showcase_textarea_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_textarea_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_textarea_reactive_code")
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_textarea_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances captured by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 1rem; padding: 1rem; border: 1px dashed var(--border); border-radius: 0.5rem;",
    block_field(
      block_field_label("Default", `for` = "showcase_parity_textarea_default"),
      block_textarea(
        "showcase_parity_textarea_default",
        placeholder = "Record rollout details for the next operator.",
        rows = 2,
        class = "sb-parity-textarea-default"
      )
    ),
    block_field(
      block_field_label("Disabled", `for` = "showcase_parity_textarea_disabled"),
      block_textarea(
        "showcase_parity_textarea_disabled",
        value = "Escalate to the on-call operator if retries fail.",
        rows = 2,
        disabled = TRUE,
        class = "sb-parity-textarea-disabled"
      )
    ),
    block_field_invalid(
      block_field(
        block_field_label("Invalid", `for` = "showcase_parity_textarea_invalid"),
        block_textarea(
          "showcase_parity_textarea_invalid",
          value = "Document rollback steps before continuing.",
          rows = 2,
          class = "sb-parity-textarea-invalid"
        )
      ),
      "A rollback plan is required before deployment."
    )
  )
)
