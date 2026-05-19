htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        style = "width: 100%;",
        shiny::uiOutput("showcase_dialog_preview_ui")
      ),
      htmltools::div(
        style = "display: flex; justify-content: center;",
        shiny::uiOutput("showcase_dialog_trigger_ui")
      ),
      htmltools::div(
        style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
        htmltools::div(
          style = "flex: 1 1 320px; min-width: 280px; display: flex; flex-direction: column; gap: 1rem;",
          shiny::verbatimTextOutput("showcase_dialog_preview_value"),
          htmltools::tags$div(
            htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
            shiny::verbatimTextOutput("showcase_dialog_preview_code")
          ),
          htmltools::tags$div(
            htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "Server Action"),
            shiny::verbatimTextOutput("showcase_dialog_reactive_code")
          )
        ),
        htmltools::div(
          style = "flex: 2 1 480px; display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 1rem;",
          htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
          block_field(
            block_field_label("title", `for` = "showcase_dialog_doc_title"),
            block_textarea("showcase_dialog_doc_title", value = "Confirm action", rows = 1)
          ),
          block_field(
            block_field_label("description", `for` = "showcase_dialog_doc_description"),
            block_textarea("showcase_dialog_doc_description", value = "This cannot be undone.", rows = 2)
          ),
          block_field(
            block_field_label("trigger label", `for` = "showcase_dialog_doc_trigger"),
            block_textarea("showcase_dialog_doc_trigger", value = "Open dialog", rows = 1)
          ),
          block_field(
            block_field_label("footer", `for` = "showcase_dialog_doc_footer"),
            block_checkbox("showcase_dialog_doc_footer", "Include Cancel + Continue footer", value = TRUE)
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 2rem;",
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "State"),
            block_field(
              block_field_label("hide_title", `for` = "showcase_dialog_doc_hide_title"),
              block_checkbox("showcase_dialog_doc_hide_title", "Hide title visually", value = FALSE)
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Actions (Server Update)"),
            htmltools::div(
              style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
              showcase_action_button("showcase_dialog_open", "Open modal"),
              showcase_action_button("showcase_dialog_close", "Close modal"),
              showcase_action_button("showcase_dialog_resize_sm", "Resize sm"),
              showcase_action_button("showcase_dialog_resize_lg", "Resize lg"),
              showcase_action_button("showcase_dialog_swap_footer", "Swap footer")
            )
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 1rem;",
          htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
          block_field(
            block_field_label("size", `for` = "showcase_dialog_doc_size"),
            block_select(
              "showcase_dialog_doc_size",
              choices = c("default", "sm", "lg", "xl"),
              selected = "default"
            )
          ),
          block_field(
            block_field_label("style", `for` = "showcase_dialog_doc_style"),
            block_textarea("showcase_dialog_doc_style", value = "", rows = 1, placeholder = "e.g., border: 2px dashed red;")
          ),
          block_field(
            block_field_label("class", `for` = "showcase_dialog_doc_class"),
            block_checkbox("showcase_dialog_doc_class", "Use custom dashed-border class", value = FALSE)
          )
        )
      ),
      ),
      block_dialog(
        id = "showcase_dialog_preview",
        title = "Confirm action",
        description = "This cannot be undone.",
        footer = htmltools::tagList(
          block_button("Cancel", variant = "outline"),
          block_button("Continue")
        ),
        htmltools::tags$p(
          "Click the trigger above or any 'Open modal' action to open the real dialog."
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_dialog_api_table")
)
