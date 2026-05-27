htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("label", `for` = "showcase_switch_doc_label"),
          block_input("showcase_switch_doc_label", value = "Send incident alerts")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("value (checked)", `for` = "showcase_switch_doc_value"),
          block_checkbox("showcase_switch_doc_value", "Checked", value = FALSE)
        ),
        block_field(
          block_field_label("disabled", `for` = "showcase_switch_doc_disabled"),
          block_checkbox("showcase_switch_doc_disabled", "Disabled", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        htmltools::div(
          style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
          showcase_action_button("showcase_switch_turn_on", "Turn on"),
          showcase_action_button("showcase_switch_turn_off", "Turn off"),
          showcase_action_button("showcase_switch_disable", "Disable"),
          showcase_action_button("showcase_switch_enable", "Enable"),
          showcase_action_button("showcase_switch_rename", "Rename label")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("style", `for` = "showcase_switch_doc_style"),
          block_textarea(
            "showcase_switch_doc_style",
            value = "",
            rows = 1,
            placeholder = "e.g., padding: 0.5rem;"
          )
        ),
        block_field(
          block_field_label("class", `for` = "showcase_switch_doc_class"),
          block_checkbox("showcase_switch_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_switch_preview_ui",
    code_output_id = "showcase_switch_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_switch_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_switch_reactive_code")
      )
    ),
    preview_canvas_style = paste(
      "position: relative; display: flex; align-items: center; justify-content: center;",
      "padding: 3rem 2rem 2.5rem 2rem; background: var(--card);",
      "border: 1px dashed var(--border); border-radius: 0.75rem;",
      "min-height: 180px; box-sizing: border-box;"
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_switch_api_table"),
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
    block_switch(
      "showcase_parity_switch_default",
      "Default switch",
      value = FALSE,
      class = "sb-parity-switch-default"
    ),
    block_switch(
      "showcase_parity_switch_checked",
      "Checked switch",
      value = TRUE,
      class = "sb-parity-switch-checked"
    ),
    block_switch(
      "showcase_parity_switch_disabled",
      "Disabled switch",
      value = FALSE,
      disabled = TRUE,
      class = "sb-parity-switch-disabled"
    )
  )
)
