radio_group_action_button <- function(input_id, label) {
  shiny::actionButton(
    input_id,
    label,
    class = "sb-button sb-button-outline sb-button-size-sm action-button"
  )
}

htmltools::tagList(
  block_field_set(
    block_field_legend("Static reference"),
    block_field(
      block_field_label("Notification preference", `for` = "showcase_radio_group_static"),
      block_radio_group(
        "showcase_radio_group_static",
        choices = c(All = "all", Mentions = "mentions", None = "none"),
        selected = "all"
      ),
      block_field_description(
        "Static example of block_radio_group() rendered directly in the showcase markup."
      )
    )
  ),
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        style = "width: 100%;",
        shiny::uiOutput("showcase_radio_group_preview_ui")
      ),
      htmltools::div(
        style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
        htmltools::div(
          style = "flex: 1 1 320px; min-width: 280px; display: flex; flex-direction: column; gap: 1rem;",
          shiny::verbatimTextOutput("showcase_radio_group_preview_value"),
          htmltools::tags$div(
            htmltools::tags$div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
              "UI Definition"
            ),
            shiny::verbatimTextOutput("showcase_radio_group_preview_code")
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
              "Server Action"
            ),
            shiny::verbatimTextOutput("showcase_radio_group_reactive_code")
          )
        ),
        htmltools::div(
          style = "flex: 2 1 480px; display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
            block_field(
              block_field_label("label", `for` = "showcase_radio_group_doc_label"),
              block_input("showcase_radio_group_doc_label", value = "Notification preference")
            ),
            block_field(
              block_field_label("choices (one per line, label|value)", `for` = "showcase_radio_group_doc_choices"),
              block_textarea(
                "showcase_radio_group_doc_choices",
                value = "All|all\nMentions|mentions\nNone|none",
                rows = 3
              )
            ),
            block_field(
              block_field_label("initial selected", `for` = "showcase_radio_group_doc_selected"),
              block_input("showcase_radio_group_doc_selected", value = "all")
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 2rem;",
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "State"),
              block_field(
                block_field_label("orientation", `for` = "showcase_radio_group_doc_orientation"),
                block_select(
                  "showcase_radio_group_doc_orientation",
                  choices = c("vertical", "horizontal"),
                  selected = "vertical"
                )
              ),
              block_field(
                block_field_label("disabled", `for` = "showcase_radio_group_doc_disabled"),
                block_checkbox("showcase_radio_group_doc_disabled", "Disabled", value = FALSE)
              ),
              block_field(
                block_field_label("invalid", `for` = "showcase_radio_group_doc_invalid"),
                block_checkbox("showcase_radio_group_doc_invalid", "Invalid", value = FALSE)
              )
            ),
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Actions (Server Update)"),
              htmltools::div(
                style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
                radio_group_action_button("showcase_radio_group_select_mentions", "Select mentions"),
                radio_group_action_button("showcase_radio_group_clear", "Reset"),
                radio_group_action_button("showcase_radio_group_disable", "Disable"),
                radio_group_action_button("showcase_radio_group_enable", "Enable"),
                radio_group_action_button("showcase_radio_group_swap_choices", "Swap choices")
              )
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
            block_field(
              block_field_label("style", `for` = "showcase_radio_group_doc_style"),
              block_textarea(
                "showcase_radio_group_doc_style",
                value = "",
                rows = 1,
                placeholder = "e.g., padding: 0.5rem;"
              )
            ),
            block_field(
              block_field_label("class", `for` = "showcase_radio_group_doc_class"),
              block_checkbox("showcase_radio_group_doc_class", "Use custom dashed-border class", value = FALSE)
            )
          )
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_radio_group_api_table")
)
