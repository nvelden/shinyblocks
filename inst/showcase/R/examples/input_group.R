htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        style = "display: flex; gap: 2rem; flex-wrap: wrap; align-items: flex-start;",
        # Left Column: Live Preview & Code Recipes
        htmltools::div(
          style = "flex: 1; min-width: 300px; display: flex; flex-direction: column; gap: 1.5rem;",
          block_field(
            block_field_label("Preview", `for` = "showcase_input_group_preview_ui"),
            shiny::uiOutput("showcase_input_group_preview_ui")
          ),
          # Reactive binding value display
          shiny::uiOutput("showcase_input_group_preview_value"),
          # Code snippets
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::uiOutput("showcase_input_group_preview_code")
            ),
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "Server Action"),
              shiny::uiOutput("showcase_input_group_reactive_code")
            )
          )
        ),
        # Right Column: Controls
        htmltools::div(
          style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          
          # Content controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
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
                selected = "leading_icon"
              )
            ),
            block_field(
              block_field_label("placeholder", `for` = "showcase_input_group_doc_placeholder"),
              block_textarea("showcase_input_group_doc_placeholder", value = "Search workspace...", rows = 1)
            ),
            block_field(
              block_field_label("value", `for` = "showcase_input_group_doc_value"),
              block_textarea("showcase_input_group_doc_value", value = "", rows = 1)
            )
          ),
          
          # State and Actions controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 2rem;",
            # State controls
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "State"),
              block_field(
                block_field_label("disabled", `for` = "showcase_input_group_doc_disabled"),
                block_checkbox("showcase_input_group_doc_disabled", label = "Disabled")
              ),
              block_field(
                block_field_label("invalid", `for` = "showcase_input_group_doc_invalid"),
                block_checkbox("showcase_input_group_doc_invalid", label = "Invalid")
              )
            ),
            
            # Actions (Server update)
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Actions (Server Update)"),
              htmltools::div(
                style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
                showcase_action_button("showcase_input_group_set_value", "Set value"),
                showcase_action_button("showcase_input_group_clear", "Reset"),
                showcase_action_button("showcase_input_group_disable", "Disable"),
                showcase_action_button("showcase_input_group_enable", "Enable")
              )
            )
          ),
          
          # Styling controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
            block_field(
              block_field_label("style", `for` = "showcase_input_group_doc_style"),
              block_textarea(
                "showcase_input_group_doc_style",
                value = "",
                rows = 1,
                placeholder = "e.g., font-family: var(--font-mono);"
              )
            ),
            block_field(
              block_field_label("class", `for` = "showcase_input_group_doc_class"),
              block_checkbox("showcase_input_group_doc_class", "Use custom dashed-border class", value = FALSE)
            )
          )
        )
      )
    )
  ),
  
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_input_group_api_table"),

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
