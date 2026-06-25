htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("choices", `for` = "showcase_select_doc_choices"),
          block_select("showcase_select_doc_choices", choices = c("Plans" = "plans", "Frameworks" = "frameworks", "Fruits" = "fruits"), selected = "plans")
        ),
        block_field(
          block_field_label("selected", `for` = "showcase_select_doc_selected"),
          shiny::uiOutput("showcase_select_doc_selected_ui")
        ),
        block_field(
          block_field_label("placeholder", `for` = "showcase_select_doc_placeholder"),
          block_input("showcase_select_doc_placeholder", value = "Choose a plan")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("multiple", `for` = "showcase_select_doc_multiple"),
          block_checkbox("showcase_select_doc_multiple", "Allow multiple values", value = FALSE)
        ),
        block_field(
          block_field_label("max_items", `for` = "showcase_select_doc_max_items"),
          block_select(
            "showcase_select_doc_max_items",
            choices = c("No cap" = "none", "1" = "1", "2" = "2", "3" = "3"),
            selected = "none"
          )
        ),
        block_field(
          block_field_label("disabled", `for` = "showcase_select_doc_disabled"),
          block_checkbox("showcase_select_doc_disabled", "Disabled", value = FALSE)
        ),
        block_field(
          block_field_label("invalid", `for` = "showcase_select_doc_invalid"),
          block_checkbox("showcase_select_doc_invalid", "Invalid", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        block_cluster(
          gap = "sm",
          showcase_action_button("showcase_select_set_pro", "Set Pro"),
          showcase_action_button("showcase_select_set_two", "Select two"),
          showcase_action_button("showcase_select_clear", "Clear"),
          showcase_action_button("showcase_select_disable", "Disable"),
          showcase_action_button("showcase_select_enable", "Enable"),
          showcase_action_button("showcase_select_replace_choices", "Replace choices")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("size", `for` = "showcase_select_doc_size"),
          block_select("showcase_select_doc_size", choices = c("default", "sm", "lg"), selected = "default")
        ),
        block_field(
          block_field_label("width", `for` = "showcase_select_doc_width"),
          block_input("showcase_select_doc_width", value = "100%")
        ),
        block_field(
          block_field_label("style", `for` = "showcase_select_doc_style"),
          block_input("showcase_select_doc_style", value = "", placeholder = "e.g., border: 2px dashed red;")
        ),
        block_field(
          block_field_label("class", `for` = "showcase_select_doc_class"),
          block_checkbox("showcase_select_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_select_preview_ui",
    code_output_id = "showcase_select_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_select_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_select_reactive_code")
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_select_api_table"),
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
    block_select(
      "showcase_parity_select",
      choices = c("Apple", "Banana", "Cherry"),
      width = "180px",
      class = "sb-parity-select-default"
    ),
    block_select(
      "showcase_parity_multi_select",
      choices = c("Apple", "Banana", "Cherry"),
      selected = c("Apple", "Banana"),
      multiple = TRUE,
      width = "220px",
      class = "sb-parity-multi-select"
    )
  )
)
