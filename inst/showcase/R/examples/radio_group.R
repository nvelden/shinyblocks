htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("label", `for` = "showcase_radio_group_doc_label"),
          block_input("showcase_radio_group_doc_label", value = "Notification preference")
        ),
        block_field(
          block_field_label("choices", `for` = "showcase_radio_group_doc_choices"),
          block_textarea(
            "showcase_radio_group_doc_choices",
            value = "All|all\nMentions|mentions\nNone|none",
            rows = 3,
            resize = "none"
          )
        ),
        block_field(
          block_field_label("initial selected", `for` = "showcase_radio_group_doc_selected"),
          block_input("showcase_radio_group_doc_selected", value = "all")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("orientation", `for` = "showcase_radio_group_doc_orientation"),
          block_radio_group(
            "showcase_radio_group_doc_orientation",
            choices = c(Vertical = "vertical", Horizontal = "horizontal"),
            selected = "vertical",
            orientation = "horizontal"
          )
        ),
        block_field(
          block_field_label("disabled", `for` = "showcase_radio_group_doc_disabled"),
          block_checkbox("showcase_radio_group_doc_disabled", "Disabled", value = FALSE)
        ),
        block_field(
          block_field_label("invalid", `for` = "showcase_radio_group_doc_invalid"),
          block_checkbox("showcase_radio_group_doc_invalid", "Invalid", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        block_cluster(
          gap = "sm",
          showcase_action_button("showcase_radio_group_select_mentions", "Select mentions"),
          showcase_action_button("showcase_radio_group_clear", "Reset"),
          showcase_action_button("showcase_radio_group_disable", "Disable"),
          showcase_action_button("showcase_radio_group_enable", "Enable"),
          showcase_action_button("showcase_radio_group_swap_choices", "Swap choices")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("style", `for` = "showcase_radio_group_doc_style"),
          block_input(
            "showcase_radio_group_doc_style",
            value = "",
            placeholder = "e.g., padding: 0.5rem;"
          )
        ),
        block_field(
          block_field_label("class", `for` = "showcase_radio_group_doc_class"),
          block_checkbox("showcase_radio_group_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_radio_group_preview_ui",
    code_output_id = "showcase_radio_group_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_radio_group_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_radio_group_reactive_code")
      )
    ),
    preview_canvas_class = "showcase-preview-canvas--dashed",
    preview_canvas_style = "min-height: 220px;"
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_radio_group_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instance used by tools/parity/ and tools/theme/. Do not remove."
  ),
  block_radio_group(
    "sb_parity_radio_group_checked",
    choices = c("One" = "one", "Two" = "two"),
    selected = "one",
    class = "sb-parity-radio-group-checked"
  )
)
