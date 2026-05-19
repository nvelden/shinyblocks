htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        style = "width: 100%;",
        shiny::uiOutput("showcase_input_preview_ui")
      ),
      htmltools::div(
        style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
        htmltools::div(
          style = "flex: 1 1 320px; min-width: 280px; display: flex; flex-direction: column; gap: 1rem;",
          shiny::verbatimTextOutput("showcase_input_preview_value"),
          htmltools::tags$div(
            htmltools::tags$div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
              "UI Definition"
            ),
            shiny::verbatimTextOutput("showcase_input_preview_code")
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
              "Server Action"
            ),
            shiny::verbatimTextOutput("showcase_input_reactive_code")
          )
        ),
        htmltools::div(
          style = "flex: 2 1 480px; display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
            block_field(
              block_field_label("label", `for` = "showcase_input_doc_label"),
              block_input("showcase_input_doc_label", value = "Email")
            ),
            block_field(
              block_field_label("placeholder", `for` = "showcase_input_doc_placeholder"),
              block_input(
                "showcase_input_doc_placeholder",
                value = "name@example.com"
              )
            ),
            block_field(
              block_field_label("initial value", `for` = "showcase_input_doc_value"),
              block_input("showcase_input_doc_value", value = "")
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 2rem;",
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "State"),
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
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Actions (Server Update)"),
              htmltools::div(
                style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
                showcase_action_button("showcase_input_set_value", "Set value"),
                showcase_action_button("showcase_input_clear", "Clear"),
                showcase_action_button("showcase_input_disable", "Disable"),
                showcase_action_button("showcase_input_enable", "Enable"),
                showcase_action_button("showcase_input_to_password", "Type → password")
              )
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
            block_field(
              block_field_label("style", `for` = "showcase_input_doc_style"),
              block_textarea(
                "showcase_input_doc_style",
                value = "",
                rows = 1,
                placeholder = "e.g., font-family: var(--font-mono);"
              )
            ),
            block_field(
              block_field_label("class", `for` = "showcase_input_doc_class"),
              block_checkbox("showcase_input_doc_class", "Use custom dashed-border class", value = FALSE)
            )
          )
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_input_api_table")
)
