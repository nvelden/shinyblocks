htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        class = "showcase-playground", style = "display: flex; gap: 2rem; flex-wrap: wrap; align-items: flex-start;",
        htmltools::div(
          class = "showcase-playground__main", style = "flex: 1; min-width: 300px; display: flex; flex-direction: column; gap: 1.5rem;",
          block_field(
            block_field_label("Preview", `for` = "showcase_checkbox_preview"),
            shiny::uiOutput("showcase_checkbox_preview_ui")
          ),
          shiny::uiOutput("showcase_checkbox_preview_value"),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(
                style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
                "UI Definition"
              ),
              shiny::uiOutput("showcase_checkbox_preview_code")
            ),
            htmltools::tags$div(
              htmltools::tags$div(
                style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
                "Server Action"
              ),
              shiny::uiOutput("showcase_checkbox_reactive_code")
            )
          )
        ),
        htmltools::div(
          class = "showcase-playground__controls", style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
            block_field(
              block_field_label("label", `for` = "showcase_checkbox_doc_label"),
              block_textarea(
                "showcase_checkbox_doc_label",
                value = "Email me product updates",
                rows = 1,
                resize = "none"
              )
            ),
            block_field(
              block_field_label("description", `for` = "showcase_checkbox_doc_description"),
              block_textarea(
                "showcase_checkbox_doc_description",
                value = "Unchecked default checkbox state.",
                rows = 2,
                resize = "none"
              )
            ),
            block_field(
              block_field_label("invalid message", `for` = "showcase_checkbox_doc_invalid_message"),
              block_textarea(
                "showcase_checkbox_doc_invalid_message",
                value = "You must confirm the rollout checklist before continuing.",
                rows = 2,
                resize = "none"
              )
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 2rem;",
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "State"),
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
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Actions (Server Update)"),
              htmltools::div(
                style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
                showcase_action_button("showcase_checkbox_set_checked", "Set checked"),
                showcase_action_button("showcase_checkbox_clear", "Clear"),
                showcase_action_button("showcase_checkbox_disable", "Disable"),
                showcase_action_button("showcase_checkbox_enable", "Enable")
              )
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
            block_field(
              block_field_label("style", `for` = "showcase_checkbox_doc_style"),
              block_textarea(
                "showcase_checkbox_doc_style",
                value = "",
                rows = 1,
                placeholder = "e.g., background: rgba(0,0,0,.03); padding: 0.5rem;",
                resize = "none"
              )
            ),
            block_field(
              block_field_label("class", `for` = "showcase_checkbox_doc_class"),
              block_checkbox("showcase_checkbox_doc_class", "Use custom dashed-border class", value = FALSE)
            )
          )
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_checkbox_api_table"),
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
