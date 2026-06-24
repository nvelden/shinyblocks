htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("label", `for` = "showcase_button_doc_label"),
          block_input("showcase_button_doc_label", value = "Continue")
        ),
        block_field(
          block_field_label("variant", `for` = "showcase_button_doc_variant"),
          block_select("showcase_button_doc_variant", choices = c("default", "secondary", "outline", "ghost", "destructive", "link"), selected = "default")
        ),
        block_field(
          block_field_label("icon", `for` = "showcase_button_doc_icon"),
          block_select("showcase_button_doc_icon", choices = c("<None>" = "none", search = "search", `arrow-right` = "arrow-right", check = "check"), selected = "none")
        ),
        block_field(
          block_field_label("icon_position", `for` = "showcase_button_doc_icon_position"),
          block_select("showcase_button_doc_icon_position", choices = c("inline-start", "inline-end"), selected = "inline-start")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("disabled", `for` = "showcase_button_doc_disabled"),
          block_checkbox("showcase_button_doc_disabled", "Disabled", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        block_cluster(
            gap = "sm",
          showcase_action_button("showcase_button_set_label", "Set label \"Saved!\""),
          showcase_action_button("showcase_button_cycle_variant", "Cycle variant"),
          showcase_action_button("showcase_button_disable", "Disable"),
          showcase_action_button("showcase_button_enable", "Enable"),
          showcase_action_button("showcase_button_set_icon", "Set icon: check"),
          showcase_action_button("showcase_button_clear_icon", "Clear icon")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("size", `for` = "showcase_button_doc_size"),
          block_select("showcase_button_doc_size", choices = c("default", "sm", "lg"), selected = "default")
        ),
        block_field(
          block_field_label("icon-only", `for` = "showcase_button_doc_icon_only"),
          block_checkbox("showcase_button_doc_icon_only", "Render icon-only button", value = FALSE)
        ),
        block_field(
          block_field_label("style", `for` = "showcase_button_doc_style"),
          block_input("showcase_button_doc_style", value = "", placeholder = "e.g., min-width: 10rem;")
        ),
        block_field(
          block_field_label("class", `for` = "showcase_button_doc_class"),
          block_checkbox("showcase_button_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_button_preview_ui",
    code_output_id = "showcase_button_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_button_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_button_reactive_code")
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_button_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  block_cluster(
      gap = "sm",
    block_button("Default", class = "sb-parity-button-default"),
    block_button("Disabled", disabled = TRUE, class = "sb-parity-button-disabled")
  )
)
