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
            block_field_label("Preview", `for` = "showcase_textarea_preview"),
            shiny::uiOutput("showcase_textarea_preview_ui")
          ),
          shiny::uiOutput("showcase_textarea_preview_value"),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(
                style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
                "UI Definition"
              ),
              shiny::uiOutput("showcase_textarea_preview_code")
            ),
            htmltools::tags$div(
              htmltools::tags$div(
                style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
                "Server Action"
              ),
              shiny::uiOutput("showcase_textarea_reactive_code")
            )
          )
        ),
        htmltools::div(
          style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
            block_field(
              block_field_label("label", `for` = "showcase_textarea_doc_label"),
              block_textarea(
                "showcase_textarea_doc_label",
                value = "Notes",
                rows = 1
              )
            ),
            block_field(
              block_field_label("placeholder", `for` = "showcase_textarea_doc_placeholder"),
              block_textarea(
                "showcase_textarea_doc_placeholder",
                value = "Add release notes here…",
                rows = 1
              )
            ),
            block_field(
              block_field_label("initial value", `for` = "showcase_textarea_doc_value"),
              block_textarea(
                "showcase_textarea_doc_value",
                value = "",
                rows = 3
              )
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 2rem;",
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "State"),
              block_field(
                block_field_label("rows", `for` = "showcase_textarea_doc_rows"),
                block_textarea(
                  "showcase_textarea_doc_rows",
                  value = "3",
                  rows = 1
                )
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
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Actions (Server Update)"),
              htmltools::div(
                style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
                showcase_action_button("showcase_textarea_set_value", "Set value"),
                showcase_action_button("showcase_textarea_clear", "Clear"),
                showcase_action_button("showcase_textarea_disable", "Disable"),
                showcase_action_button("showcase_textarea_enable", "Enable"),
                showcase_action_button("showcase_textarea_grow", "Resize 6 rows")
              )
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
            block_field(
              block_field_label("style", `for` = "showcase_textarea_doc_style"),
              block_textarea(
                "showcase_textarea_doc_style",
                value = "",
                rows = 1,
                placeholder = "e.g., font-family: var(--font-mono);"
              )
            ),
            block_field(
              block_field_label("class", `for` = "showcase_textarea_doc_class"),
              block_checkbox("showcase_textarea_doc_class", "Use custom dashed-border class", value = FALSE)
            )
          )
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_textarea_api_table"),
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
