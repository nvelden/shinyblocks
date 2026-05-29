htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("orientation", `for` = "showcase_separator_doc_orientation"),
          block_select("showcase_separator_doc_orientation", choices = c("horizontal", "vertical"), selected = "horizontal")
        ),
        block_field(
          block_field_label("decorative", `for` = "showcase_separator_doc_decorative"),
          block_checkbox("showcase_separator_doc_decorative", "Decorative (Accessibility)", value = TRUE)
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("class", `for` = "showcase_separator_doc_class"),
          block_checkbox("showcase_separator_doc_class", "Use primary separator class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_separator_preview_ui",
    code_output_id = "showcase_separator_preview_code"
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_separator_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 0.75rem;",
    block_separator(class = "sb-parity-separator-horizontal"),
    htmltools::div(
      style = "display: flex; height: 2rem; align-items: center; gap: 1rem;",
      htmltools::tags$span("Filters"),
      block_separator(orientation = "vertical", class = "sb-parity-separator-vertical"),
      htmltools::tags$span("Sort"),
      htmltools::tags$span("Export")
    )
  )
)
