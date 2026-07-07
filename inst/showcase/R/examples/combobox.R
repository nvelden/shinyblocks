htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("choices", `for` = "showcase_combobox_doc_choices"),
          block_select("showcase_combobox_doc_choices", choices = c("Frameworks" = "frameworks", "Countries" = "countries", "Fruits" = "fruits"), selected = "frameworks")
        ),
        block_field(
          block_field_label("selected", `for` = "showcase_combobox_doc_selected"),
          shiny::uiOutput("showcase_combobox_doc_selected_ui")
        ),
        block_field(
          block_field_label("placeholder", `for` = "showcase_combobox_doc_placeholder"),
          block_input("showcase_combobox_doc_placeholder", value = "Select a framework")
        ),
        block_field(
          block_field_label("search_placeholder", `for` = "showcase_combobox_doc_search"),
          block_input("showcase_combobox_doc_search", value = "Search frameworks...")
        ),
        block_field(
          block_field_label("empty_message", `for` = "showcase_combobox_doc_empty"),
          block_input("showcase_combobox_doc_empty", value = "No framework found.")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("multiple", `for` = "showcase_combobox_doc_multiple"),
          block_checkbox("showcase_combobox_doc_multiple", "Allow multiple values", value = FALSE)
        ),
        block_field(
          block_field_label("max_items", `for` = "showcase_combobox_doc_max_items"),
          block_select(
            "showcase_combobox_doc_max_items",
            choices = c("No cap" = "none", "1" = "1", "2" = "2", "3" = "3"),
            selected = "none"
          )
        ),
        block_field(
          block_field_label("disabled", `for` = "showcase_combobox_doc_disabled"),
          block_checkbox("showcase_combobox_doc_disabled", "Disabled", value = FALSE)
        ),
        block_field(
          block_field_label("invalid", `for` = "showcase_combobox_doc_invalid"),
          block_checkbox("showcase_combobox_doc_invalid", "Invalid", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        block_cluster(
          gap = "sm",
          showcase_action_button("showcase_combobox_set_vue", "Set Vue"),
          showcase_action_button("showcase_combobox_set_two", "Select two"),
          showcase_action_button("showcase_combobox_clear", "Clear"),
          showcase_action_button("showcase_combobox_disable", "Disable"),
          showcase_action_button("showcase_combobox_enable", "Enable"),
          showcase_action_button("showcase_combobox_replace_choices", "Replace choices")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("size", `for` = "showcase_combobox_doc_size"),
          block_select("showcase_combobox_doc_size", choices = c("default", "sm", "lg"), selected = "default")
        ),
        block_field(
          block_field_label("width", `for` = "showcase_combobox_doc_width"),
          block_input("showcase_combobox_doc_width", value = "100%")
        ),
        block_field(
          block_field_label("style", `for` = "showcase_combobox_doc_style"),
          block_input("showcase_combobox_doc_style", value = "", placeholder = "e.g., border: 2px dashed red;")
        ),
        block_field(
          block_field_label("class", `for` = "showcase_combobox_doc_class"),
          block_checkbox("showcase_combobox_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_combobox_preview_ui",
    code_output_id = "showcase_combobox_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_combobox_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_combobox_reactive_code")
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_combobox_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instance captured by tools/parity/. Do not remove."
  ),
  block_cluster(
    gap = "md",
    class = "showcase-demo-frame",
    block_combobox(
      "showcase_parity_combobox",
      choices = c("Apple", "Banana", "Cherry"),
      width = "180px",
      class = "sb-parity-combobox-default"
    ),
    block_combobox(
      "showcase_parity_multi_combobox",
      choices = c("Apple", "Banana", "Cherry"),
      selected = c("Apple", "Banana"),
      multiple = TRUE,
      width = "220px",
      class = "sb-parity-multi-combobox"
    )
  )
)
