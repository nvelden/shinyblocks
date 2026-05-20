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
            block_field_label("Preview", `for` = "showcase_select_preview"),
            shiny::uiOutput("showcase_select_preview_ui")
          ),
          shiny::uiOutput("showcase_select_preview_value"),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::uiOutput("showcase_select_preview_code")
            ),
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "Server Action"),
              shiny::uiOutput("showcase_select_reactive_code")
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
              block_field_label("choices", `for` = "showcase_select_doc_choices"),
              block_select("showcase_select_doc_choices", choices = c("Plans" = "plans", "Frameworks" = "frameworks", "Fruits" = "fruits"), selected = "plans")
            ),
            block_field(
              block_field_label("selected", `for` = "showcase_select_doc_selected"),
              block_select("showcase_select_doc_selected", choices = c(Free = "free", Pro = "pro", Team = "team"), selected = "free")
            ),
            block_field(
              block_field_label("placeholder", `for` = "showcase_select_doc_placeholder"),
              block_textarea("showcase_select_doc_placeholder", value = "Choose a plan", rows = 1)
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 2rem;",
            # State controls
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "State"),
              block_field(
                block_field_label("disabled", `for` = "showcase_select_doc_disabled"),
                block_checkbox("showcase_select_doc_disabled", "Disabled", value = FALSE)
              ),
              block_field(
                block_field_label("invalid", `for` = "showcase_select_doc_invalid"),
                block_checkbox("showcase_select_doc_invalid", "Invalid", value = FALSE)
              )
            ),
            # Actions controls
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Actions (Server Update)"),
              htmltools::div(
                style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
                showcase_action_button("showcase_select_set_pro", "Set Pro"),
                showcase_action_button("showcase_select_clear", "Clear"),
                showcase_action_button("showcase_select_disable", "Disable"),
                showcase_action_button("showcase_select_enable", "Enable"),
                showcase_action_button("showcase_select_replace_choices", "Replace choices")
              )
            )
          ),
          # Styling controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
            block_field(
              block_field_label("size", `for` = "showcase_select_doc_size"),
              block_select("showcase_select_doc_size", choices = c("default", "sm", "lg"), selected = "default")
            ),
            block_field(
              block_field_label("width", `for` = "showcase_select_doc_width"),
              block_textarea("showcase_select_doc_width", value = "100%", rows = 1)
            ),
            block_field(
              block_field_label("style", `for` = "showcase_select_doc_style"),
              block_textarea("showcase_select_doc_style", value = "", rows = 1, placeholder = "e.g., border: 2px dashed red;")
            ),
            block_field(
              block_field_label("class", `for` = "showcase_select_doc_class"),
              block_checkbox("showcase_select_doc_class", "Use custom dashed-border class", value = FALSE)
            )
          )
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_select_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instance captured by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "padding: 1rem; border: 1px dashed var(--border); border-radius: 0.5rem;",
    block_select(
      "showcase_parity_select",
      choices = c("Apple", "Banana", "Cherry"),
      width = "180px",
      class = "sb-parity-select-default"
    )
  )
)
