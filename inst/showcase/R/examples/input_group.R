htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("pattern", `for` = "showcase_input_group_doc_pattern"),
          block_select(
            "showcase_input_group_doc_pattern",
            choices = c(
              "Leading Icon" = "leading_icon",
              "Trailing Icon" = "trailing_icon",
              "Both Addons" = "both_addons",
              "Workspace Slug" = "workspace_slug"
            ),
            selected = "leading_icon",
            size = "sm"
          )
        ),
        block_field(
          block_field_label("placeholder", `for` = "showcase_input_group_doc_placeholder"),
          block_input("showcase_input_group_doc_placeholder", value = "Search workspace...")
        ),
        block_field(
          block_field_label("value", `for` = "showcase_input_group_doc_value"),
          block_input("showcase_input_group_doc_value", value = "")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("disabled", `for` = "showcase_input_group_doc_disabled"),
          block_checkbox("showcase_input_group_doc_disabled", label = "Disabled")
        ),
        block_field(
          block_field_label("invalid", `for` = "showcase_input_group_doc_invalid"),
          block_checkbox("showcase_input_group_doc_invalid", label = "Invalid")
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        htmltools::div(
          style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
          showcase_action_button("showcase_input_group_set_value", "Set value"),
          showcase_action_button("showcase_input_group_clear", "Reset"),
          showcase_action_button("showcase_input_group_disable", "Disable"),
          showcase_action_button("showcase_input_group_enable", "Enable")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("style", `for` = "showcase_input_group_doc_style"),
          block_input(
            "showcase_input_group_doc_style",
            value = "",
            placeholder = "e.g., font-family: var(--font-mono);"
          )
        ),
        block_field(
          block_field_label("class", `for` = "showcase_input_group_doc_class"),
          block_checkbox("showcase_input_group_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_input_group_preview_ui",
    code_output_id = "showcase_input_group_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_input_group_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_input_group_reactive_code")
      )
    ),
    preview_canvas_style = paste(
      "position: relative; display: flex; align-items: center; justify-content: center;",
      "padding: 3rem 2rem 2.5rem 2rem; background: var(--card);",
      "border: 1px dashed var(--border); border-radius: 0.75rem;",
      "min-height: 180px; box-sizing: border-box;"
    )
  ),
  
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_input_group_api_table"),

  # Stable baseline patterns as parity fixtures
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "Common Patterns (Parity Fixtures)"),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 1rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/ and visual regression checkers. Do not remove."
  ),
  htmltools::div(
    class = "sb-parity-input-group-fixtures",
    style = "display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.25rem; border: 1px solid var(--border); padding: 1.5rem; border-radius: 0.5rem; background: var(--background);",
    block_field(
      block_field_label("Leading icon", `for` = "sb-parity-input-group-search"),
      block_input_group(
        class = "sb-parity-input-group-leading",
        block_input_group_addon(block_icon("search")),
        block_input(
          "sb-parity-input-group-search",
          placeholder = "Search workspace"
        )
      )
    ),
    block_field(
      block_field_label("Trailing icon", `for` = "sb-parity-input-group-email"),
      block_input_group(
        class = "sb-parity-input-group-trailing",
        block_input(
          "sb-parity-input-group-email",
          placeholder = "name@company.com"
        ),
        block_input_group_addon(block_icon("mail"))
      )
    ),
    block_field(
      block_field_label("Both addons", `for` = "sb-parity-input-group-amount"),
      block_input_group(
        class = "sb-parity-input-group-both",
        block_input_group_addon("$"),
        block_input(
          "sb-parity-input-group-amount",
          type = "number",
          value = 0,
          placeholder = "0"
        ),
        block_input_group_addon("USD")
      )
    ),
    block_field(
      block_field_label("Workspace slug", `for` = "sb-parity-input-group-slug"),
      block_input_group(
        class = "sb-parity-input-group-slug",
        block_input_group_addon("acme.app/"),
        block_input(
          "sb-parity-input-group-slug",
          placeholder = "your-team"
        )
      )
    )
  )
)
