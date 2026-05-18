slider_action_button <- function(input_id, label) {
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
        style = "width: 100%;",
        shiny::uiOutput("showcase_slider_preview_ui")
      ),
      htmltools::div(
        style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
        htmltools::div(
          style = "flex: 1 1 320px; min-width: 280px; display: flex; flex-direction: column; gap: 1rem;",
          shiny::verbatimTextOutput("showcase_slider_preview_value"),
          htmltools::tags$div(
            htmltools::tags$div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
              "UI Definition"
            ),
            shiny::verbatimTextOutput("showcase_slider_preview_code")
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
              "Server Action"
            ),
            shiny::verbatimTextOutput("showcase_slider_reactive_code")
          )
        ),
        htmltools::div(
          style = "flex: 2 1 480px; display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
            block_field(
              block_field_label("value", `for` = "showcase_slider_doc_value"),
              block_input("showcase_slider_doc_value", value = "50", placeholder = "50 or 25,75")
            ),
            block_field(
              block_field_label("min", `for` = "showcase_slider_doc_min"),
              block_input("showcase_slider_doc_min", value = "0", type = "number")
            ),
            block_field(
              block_field_label("max", `for` = "showcase_slider_doc_max"),
              block_input("showcase_slider_doc_max", value = "100", type = "number")
            ),
            block_field(
              block_field_label("step", `for` = "showcase_slider_doc_step"),
              block_input("showcase_slider_doc_step", value = "1", type = "number")
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 2rem;",
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "State"),
              block_field(
                block_field_label("disabled", `for` = "showcase_slider_doc_disabled"),
                block_checkbox("showcase_slider_doc_disabled", "Disabled", value = FALSE)
              ),
              block_field(
                block_field_label("invalid", `for` = "showcase_slider_doc_invalid"),
                block_checkbox("showcase_slider_doc_invalid", "Invalid", value = FALSE)
              )
            ),
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Actions (Server Update)"),
              htmltools::div(
                style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
                slider_action_button("showcase_slider_set_low", "Set 25"),
                slider_action_button("showcase_slider_set_range", "Set range"),
                slider_action_button("showcase_slider_disable", "Disable"),
                slider_action_button("showcase_slider_enable", "Enable"),
                slider_action_button("showcase_slider_resize", "Change bounds")
              )
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
            block_field(
              block_field_label("width", `for` = "showcase_slider_doc_width"),
              block_input("showcase_slider_doc_width", value = "100%", placeholder = "100% or 20rem")
            ),
            block_field(
              block_field_label("style", `for` = "showcase_slider_doc_style"),
              block_textarea(
                "showcase_slider_doc_style",
                value = "",
                rows = 1,
                placeholder = "e.g., max-width: 20rem;"
              )
            ),
            block_field(
              block_field_label("class", `for` = "showcase_slider_doc_class"),
              block_checkbox("showcase_slider_doc_class", "Use custom dashed-border class", value = FALSE)
            )
          )
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_slider_api_table"),
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
    block_slider(
      "showcase_parity_slider_default",
      value = 50,
      min = 0,
      max = 100,
      class = "sb-parity-slider-default"
    ),
    block_slider(
      "showcase_parity_slider_range",
      value = c(25, 75),
      min = 0,
      max = 100,
      class = "sb-parity-slider-range"
    ),
    block_slider(
      "showcase_parity_slider_disabled",
      value = 30,
      min = 0,
      max = 100,
      disabled = TRUE,
      class = "sb-parity-slider-disabled"
    )
  )
)
