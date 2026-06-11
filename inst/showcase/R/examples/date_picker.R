htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("value", `for` = "showcase_date_picker_doc_value"),
          block_textarea("showcase_date_picker_doc_value", value = "2024-01-15", rows = 1, placeholder = "yyyy-mm-dd", resize = "none")
        ),
        block_field(
          block_field_label("placeholder", `for` = "showcase_date_picker_doc_placeholder"),
          block_textarea("showcase_date_picker_doc_placeholder", value = "Pick a date", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("format", `for` = "showcase_date_picker_doc_format"),
          block_select("showcase_date_picker_doc_format", choices = c("yyyy-mm-dd", "M d, yyyy" = "M d, yyyy", "DD, MM d, yyyy" = "DD, MM d, yyyy", "dd/mm/yyyy" = "dd/mm/yyyy"), selected = "M d, yyyy")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("min", `for` = "showcase_date_picker_doc_min"),
          block_textarea("showcase_date_picker_doc_min", value = "", rows = 1, placeholder = "yyyy-mm-dd", resize = "none")
        ),
        block_field(
          block_field_label("max", `for` = "showcase_date_picker_doc_max"),
          block_textarea("showcase_date_picker_doc_max", value = "", rows = 1, placeholder = "yyyy-mm-dd", resize = "none")
        ),
        block_field(
          block_field_label("disabled", `for` = "showcase_date_picker_doc_disabled"),
          block_checkbox("showcase_date_picker_doc_disabled", "Disabled", value = FALSE)
        ),
        block_field(
          block_field_label("invalid", `for` = "showcase_date_picker_doc_invalid"),
          block_checkbox("showcase_date_picker_doc_invalid", "Invalid", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        htmltools::div(
          style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
          showcase_action_button("showcase_date_picker_set_today", "Set today"),
          showcase_action_button("showcase_date_picker_set_xmas", "Set 2025-12-25"),
          showcase_action_button("showcase_date_picker_clear", "Clear"),
          showcase_action_button("showcase_date_picker_disable", "Disable"),
          showcase_action_button("showcase_date_picker_enable", "Enable"),
          showcase_action_button("showcase_date_picker_set_bounds", "Bound to 2025")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("weekstart", `for` = "showcase_date_picker_doc_weekstart"),
          block_select("showcase_date_picker_doc_weekstart", choices = c("Sunday" = "0", "Monday" = "1"), selected = "0")
        ),
        block_field(
          block_field_label("width", `for` = "showcase_date_picker_doc_width"),
          block_textarea("showcase_date_picker_doc_width", value = "240px", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("style", `for` = "showcase_date_picker_doc_style"),
          block_textarea("showcase_date_picker_doc_style", value = "", rows = 1, placeholder = "e.g., border: 2px dashed red;", resize = "none")
        ),
        block_field(
          block_field_label("class", `for` = "showcase_date_picker_doc_class"),
          block_checkbox("showcase_date_picker_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_date_picker_preview_ui",
    code_output_id = "showcase_date_picker_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_date_picker_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_date_picker_reactive_code")
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_date_picker_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instance captured by the theme-conformance harness. Do not remove."
  ),
  htmltools::div(
    style = "padding: 1rem; border: 1px dashed var(--border); border-radius: 0.5rem; max-width: 260px;",
    block_date_picker(
      "showcase_parity_date_picker",
      value = "2024-01-15",
      width = "220px",
      class = "sb-parity-date-picker-default"
    )
  )
)
