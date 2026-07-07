htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("label", `for` = "showcase_toggle_group_doc_label"),
          block_input("showcase_toggle_group_doc_label", value = "View")
        ),
        block_field(
          block_field_label("choices (one per line, label|value)", `for` = "showcase_toggle_group_doc_choices"),
          block_textarea(
            "showcase_toggle_group_doc_choices",
            value = "List|list\nGrid|grid\nBoard|board",
            rows = 3,
            resize = "none"
          )
        ),
        block_field(
          block_field_label("initial selected (comma-separated)", `for` = "showcase_toggle_group_doc_selected"),
          block_input("showcase_toggle_group_doc_selected", value = "list")
        ),
        block_field(
          block_field_label("icons", `for` = "showcase_toggle_group_doc_icons"),
          block_checkbox("showcase_toggle_group_doc_icons", "Show list/grid icons", value = FALSE)
        ),
        block_field(
          block_field_label("icon_only", `for` = "showcase_toggle_group_doc_icon_only"),
          block_checkbox("showcase_toggle_group_doc_icon_only", "Icon-only items (requires icons)", value = FALSE)
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("type", `for` = "showcase_toggle_group_doc_type"),
          block_radio_group(
            "showcase_toggle_group_doc_type",
            choices = c(Single = "single", Multiple = "multiple"),
            selected = "single",
            orientation = "horizontal"
          )
        ),
        block_field(
          block_field_label("disabled", `for` = "showcase_toggle_group_doc_disabled"),
          block_checkbox("showcase_toggle_group_doc_disabled", "Disable whole group", value = FALSE)
        ),
        block_field(
          block_field_label("per-item disabled", `for` = "showcase_toggle_group_doc_disabled_item"),
          block_checkbox("showcase_toggle_group_doc_disabled_item", "Disable last choice only", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        block_cluster(
          gap = "sm",
          showcase_action_button("showcase_toggle_group_select_grid", "Select grid"),
          showcase_action_button("showcase_toggle_group_clear", "Clear"),
          showcase_action_button("showcase_toggle_group_disable", "Disable"),
          showcase_action_button("showcase_toggle_group_enable", "Enable"),
          showcase_action_button("showcase_toggle_group_swap_choices", "Swap choices")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("variant", `for` = "showcase_toggle_group_doc_variant"),
          block_radio_group(
            "showcase_toggle_group_doc_variant",
            choices = c(Default = "default", Outline = "outline"),
            selected = "default",
            orientation = "horizontal"
          )
        ),
        block_field(
          block_field_label("size", `for` = "showcase_toggle_group_doc_size"),
          block_radio_group(
            "showcase_toggle_group_doc_size",
            choices = c(Default = "default", Small = "sm", Large = "lg"),
            selected = "default",
            orientation = "horizontal"
          )
        ),
        block_field(
          block_field_label("style", `for` = "showcase_toggle_group_doc_style"),
          block_input(
            "showcase_toggle_group_doc_style",
            value = "",
            placeholder = "e.g., margin-top: 0.5rem;"
          )
        ),
        block_field(
          block_field_label("class", `for` = "showcase_toggle_group_doc_class"),
          block_checkbox("showcase_toggle_group_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_toggle_group_preview_ui",
    code_output_id = "showcase_toggle_group_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_toggle_group_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_toggle_group_reactive_code")
      )
    ),
    preview_canvas_class = "showcase-preview-canvas--dashed",
    preview_canvas_style = "min-height: 160px;"
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_toggle_group_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instance used by tools/parity/ and tools/theme/. Do not remove."
  ),
  block_toggle_group(
    "sb_parity_toggle_group_on",
    choices = c(One = "one", Two = "two"),
    selected = "one",
    variant = "outline",
    class = "sb-parity-toggle-group-on"
  )
)
