htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        style = "width: 100%;",
        shiny::uiOutput("showcase_switch_preview_ui")
      ),
      htmltools::div(
        style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
        htmltools::div(
          style = "flex: 1 1 320px; min-width: 280px; display: flex; flex-direction: column; gap: 1rem;",
          shiny::verbatimTextOutput("showcase_switch_preview_value"),
          htmltools::tags$div(
            htmltools::tags$div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
              "UI Definition"
            ),
            shiny::verbatimTextOutput("showcase_switch_preview_code")
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
              "Server Action"
            ),
            shiny::verbatimTextOutput("showcase_switch_reactive_code")
          )
        ),
        htmltools::div(
          style = "flex: 2 1 480px; display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
            block_field(
              block_field_label("label", `for` = "showcase_switch_doc_label"),
              block_input("showcase_switch_doc_label", value = "Send incident alerts")
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 2rem;",
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "State"),
              block_field(
                block_field_label("value (checked)", `for` = "showcase_switch_doc_value"),
                block_checkbox("showcase_switch_doc_value", "Checked", value = FALSE)
              ),
              block_field(
                block_field_label("disabled", `for` = "showcase_switch_doc_disabled"),
                block_checkbox("showcase_switch_doc_disabled", "Disabled", value = FALSE)
              )
            ),
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Actions (Server Update)"),
              htmltools::div(
                style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
                showcase_action_button("showcase_switch_turn_on", "Turn on"),
                showcase_action_button("showcase_switch_turn_off", "Turn off"),
                showcase_action_button("showcase_switch_disable", "Disable"),
                showcase_action_button("showcase_switch_enable", "Enable"),
                showcase_action_button("showcase_switch_rename", "Rename label")
              )
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
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
        )
      )
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
