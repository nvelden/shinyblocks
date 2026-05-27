htmltools::tagList(
  showcase_playground_layout(
      controls = htmltools::tagList(
        showcase_controls_group(
          "Accessibility", first = TRUE,
          block_field(
            block_field_label("label", `for` = "showcase_spinner_doc_label"),
            block_textarea("showcase_spinner_doc_label", value = "Loading", rows = 1)
          )
        ),
        showcase_controls_group(
          "Styling",
          block_field(
            block_field_label("size", `for` = "showcase_spinner_doc_size"),
            block_select(
              "showcase_spinner_doc_size",
              choices = c("sm", "default", "lg"),
              selected = "default",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("color", `for` = "showcase_spinner_doc_color"),
            block_select(
              "showcase_spinner_doc_color",
              choices = c("default", "destructive", "muted"),
              selected = "default",
              size = "sm"
            )
          )
        )
      ),
      preview_output_id = "showcase_spinner_preview_ui",
      code_output_id = "showcase_spinner_preview_code"
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_spinner_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; gap: 1rem; align-items: center;",
    block_spinner(class = "sb-parity-spinner-default")
  )
)
