htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        style = "width: 100%;",
        shiny::uiOutput("showcase_popover_preview_ui")
      ),
      htmltools::div(
        style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
        htmltools::div(
          style = "flex: 1 1 320px; min-width: 280px; display: flex; flex-direction: column; gap: 1rem;",
          shiny::uiOutput("showcase_popover_preview_value"),
          htmltools::tags$div(
            htmltools::tags$div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
              "UI Definition"
            ),
            shiny::uiOutput("showcase_popover_preview_code")
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
              "Server Action"
            ),
            shiny::uiOutput("showcase_popover_reactive_code")
          )
        ),
        htmltools::div(
          style = "flex: 2 1 480px; display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
            block_field(
              block_field_label("trigger label", `for` = "showcase_popover_doc_trigger"),
              block_textarea("showcase_popover_doc_trigger", value = "Open popover", rows = 1)
            ),
            block_field(
              block_field_label("body", `for` = "showcase_popover_doc_body"),
              block_textarea(
                "showcase_popover_doc_body",
                value = "Place additional details, a small form, or contextual actions inside the popover.",
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
                block_field_label("open", `for` = "showcase_popover_doc_open"),
                block_checkbox("showcase_popover_doc_open", "Open", value = TRUE)
              )
            ),
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Actions (Server Update)"),
              htmltools::div(
                style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
                showcase_action_button("showcase_popover_open", "Open"),
                showcase_action_button("showcase_popover_close", "Close"),
                showcase_action_button("showcase_popover_reposition", "Move"),
                showcase_action_button("showcase_popover_swap_body", "Swap text")
              )
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
            block_field(
              block_field_label("side", `for` = "showcase_popover_doc_side"),
              block_select(
                "showcase_popover_doc_side",
                choices = c("bottom", "top", "left", "right"),
                selected = "bottom"
              )
            ),
            block_field(
              block_field_label("align", `for` = "showcase_popover_doc_align"),
              block_select(
                "showcase_popover_doc_align",
                choices = c("center", "start", "end"),
                selected = "center"
              )
            ),
            block_field(
              block_field_label("style", `for` = "showcase_popover_doc_style"),
              block_textarea("showcase_popover_doc_style", value = "", rows = 1, placeholder = "e.g., border: 2px dashed red;")
            ),
            block_field(
              block_field_label("class", `for` = "showcase_popover_doc_class"),
              block_checkbox("showcase_popover_doc_class", "Use custom dashed-border class", value = FALSE)
            )
          )
        )
      ),
      htmltools::tags$div(
        style = "display: none;",
        block_popover(
          trigger = "Static fallback",
          htmltools::tags$p("Hidden mount that satisfies the showcase static-render test.")
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_popover_api_table")
)
