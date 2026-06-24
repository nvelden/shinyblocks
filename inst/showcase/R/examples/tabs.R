htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Tab Styles", first = TRUE,
        block_field(
          block_field_label("selected", `for` = "showcase_tabs_doc_selected"),
          block_select("showcase_tabs_doc_selected", choices = c("overview", "usage", "settings"), selected = "overview", size = "sm")
        ),
        block_field(
          block_field_label("variant", `for` = "showcase_tabs_doc_variant"),
          block_select("showcase_tabs_doc_variant", choices = c("default", "line"), selected = "default", size = "sm")
        ),
        block_field(
          block_field_label("orientation", `for` = "showcase_tabs_doc_orientation"),
          block_select("showcase_tabs_doc_orientation", choices = c("horizontal", "vertical"), selected = "horizontal", size = "sm")
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        block_cluster(
          gap = "sm",
          showcase_action_button("showcase_tabs_select_usage", "Select Usage"),
          showcase_action_button("showcase_tabs_select_settings", "Select Settings")
        )
      )
    ),
    preview_output_id = "showcase_tabs_preview_ui",
    code_output_id = "showcase_tabs_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_tabs_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_tabs_reactive_code")
      )
    ),
    preview_canvas_class = "showcase-preview-canvas--stretch",
    preview_canvas_style = paste(
      "padding: 1.5rem; border-style: dashed;",
      "min-height: 260px; width: 100%;"
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_tabs_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  block_stack(
    gap = "lg",
    block_tabs(
      id = "showcase_tabs_parity_default",
      selected = "overview",
      class = "sb-parity-tabs-default",
      block_tab(
        "Overview",
        value = "overview",
        block_card(
          title = "Workspace",
          description = "Manage workspace.",
          block_field_group(
            block_field(
              block_field_label("Workspace Name"),
              block_input("showcase_tabs_parity_name", value = "Acme")
            ),
            block_field(
              block_field_label("Plan"),
              block_select("showcase_tabs_parity_plan", choices = c("Starter", "Pro", "Enterprise"), selected = "Pro")
            )
          )
        )
      ),
      block_tab(
        "Usage",
        value = "usage",
        block_card(
          title = "Members",
          description = "Check members."
        )
      )
    ),
    block_tabs(
      id = "showcase_tabs_parity_line",
      selected = "account",
      variant = "line",
      class = "sb-parity-tabs-line",
      block_tab(
        "Account",
        value = "account",
        block_card(
          title = "Account",
          description = "Account settings."
        )
      )
    )
  )
)
