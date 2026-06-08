htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("button label", `for` = "showcase_file_input_doc_button_label"),
          block_input("showcase_file_input_doc_button_label", value = "Browse")
        ),
        block_field(
          block_field_label("placeholder", `for` = "showcase_file_input_doc_placeholder"),
          block_input("showcase_file_input_doc_placeholder", value = "No file selected")
        ),
        block_field(
          block_field_label("accept", `for` = "showcase_file_input_doc_accept"),
          block_input("showcase_file_input_doc_accept", value = ".csv,text/csv", placeholder = ".csv,image/png")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("multiple", `for` = "showcase_file_input_doc_multiple"),
          block_checkbox("showcase_file_input_doc_multiple", "Allow multiple files", value = FALSE)
        ),
        block_field(
          block_field_label("disabled", `for` = "showcase_file_input_doc_disabled"),
          block_checkbox("showcase_file_input_doc_disabled", "Disabled", value = FALSE)
        ),
        block_field(
          block_field_label("invalid", `for` = "showcase_file_input_doc_invalid"),
          block_checkbox("showcase_file_input_doc_invalid", "Invalid", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("width", `for` = "showcase_file_input_doc_width"),
          block_input("showcase_file_input_doc_width", value = "100%", placeholder = "20rem or 100%")
        ),
        block_field(
          block_field_label("style", `for` = "showcase_file_input_doc_style"),
          block_textarea("showcase_file_input_doc_style", value = "", rows = 1, placeholder = "e.g., max-width: 24rem;", resize = "none")
        ),
        block_field(
          block_field_label("class", `for` = "showcase_file_input_doc_class"),
          block_checkbox("showcase_file_input_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_file_input_preview_ui",
    code_output_id = "showcase_file_input_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_file_input_preview_value")
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_file_input_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instance used by tools/parity/ and tools/theme/. Do not remove."
  ),
  htmltools::div(
    style = "max-width: 320px;",
    block_file_input(
      "sb_parity_file_input",
      button_label = "Upload",
      placeholder = "No upload",
      class = "sb-parity-file-input"
    )
  )
)
