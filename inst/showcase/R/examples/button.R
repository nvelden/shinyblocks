button_action_button <- function(input_id, label) {
  shiny::actionButton(
    input_id,
    label,
    class = "sb-button sb-button-outline sb-button-size-sm action-button"
  )
}

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
            block_field_label("Preview", `for` = "showcase_button_preview"),
            shiny::uiOutput("showcase_button_preview_ui")
          ),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::verbatimTextOutput("showcase_button_preview_code")
            ),
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "Server Action"),
              shiny::verbatimTextOutput("showcase_button_reactive_code")
            )
          )
        ),
        htmltools::div(
          style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          # Content controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
            block_field(
              block_field_label("label", `for` = "showcase_button_doc_label"),
              block_textarea("showcase_button_doc_label", value = "Continue", rows = 1)
            ),
            block_field(
              block_field_label("variant", `for` = "showcase_button_doc_variant"),
              block_select("showcase_button_doc_variant", choices = c("default", "secondary", "outline", "ghost", "destructive", "link"), selected = "default")
            ),
            block_field(
              block_field_label("icon", `for` = "showcase_button_doc_icon"),
              block_select("showcase_button_doc_icon", choices = c("<None>" = "none", search = "search", `arrow-right` = "arrow-right", check = "check"), selected = "none")
            ),
            block_field(
              block_field_label("icon_position", `for` = "showcase_button_doc_icon_position"),
              block_select("showcase_button_doc_icon_position", choices = c("inline-start", "inline-end"), selected = "inline-start")
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 2rem;",
            # State controls
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "State"),
              block_field(
                block_field_label("disabled", `for` = "showcase_button_doc_disabled"),
                block_checkbox("showcase_button_doc_disabled", "Disabled", value = FALSE)
              )
            ),
            # Actions controls
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Actions (Server Update)"),
              htmltools::div(
                style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
                button_action_button("showcase_button_set_label", "Set label \"Saved!\""),
                button_action_button("showcase_button_cycle_variant", "Cycle variant"),
                button_action_button("showcase_button_disable", "Disable"),
                button_action_button("showcase_button_enable", "Enable"),
                button_action_button("showcase_button_set_icon", "Set icon: check"),
                button_action_button("showcase_button_clear_icon", "Clear icon")
              )
            )
          ),
          # Styling controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
            block_field(
              block_field_label("size", `for` = "showcase_button_doc_size"),
              block_select("showcase_button_doc_size", choices = c("default", "sm", "lg", "icon"), selected = "default")
            ),
            block_field(
              block_field_label("style", `for` = "showcase_button_doc_style"),
              block_textarea("showcase_button_doc_style", value = "", rows = 1, placeholder = "e.g., min-width: 10rem;")
            ),
            block_field(
              block_field_label("class", `for` = "showcase_button_doc_class"),
              block_checkbox("showcase_button_doc_class", "Use custom dashed-border class", value = FALSE)
            )
          )
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_button_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; gap: 0.75rem; flex-wrap: wrap;",
    block_button("Default", class = "sb-parity-button-default"),
    block_button("Disabled", disabled = TRUE, class = "sb-parity-button-disabled")
  )
)
