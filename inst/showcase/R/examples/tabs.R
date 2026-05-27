htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Tab Styles", first = TRUE,
        block_field(
          block_field_label("variant", `for` = "showcase_tabs_doc_variant"),
          block_select("showcase_tabs_doc_variant", choices = c("default", "line"), selected = "default", size = "sm")
        ),
        block_field(
          block_field_label("orientation", `for` = "showcase_tabs_doc_orientation"),
          block_select("showcase_tabs_doc_orientation", choices = c("horizontal", "vertical"), selected = "horizontal", size = "sm")
        )
      )
    ),
    preview_output_id = "showcase_tabs_preview_ui",
    code_output_id = "showcase_tabs_preview_code",
    extra_outputs = htmltools::tags$div(
      style = "font-size: 0.875rem; font-weight: 500; padding: 0.5rem; background: var(--secondary); border-radius: 0.25rem;",
      shiny::textOutput("showcase_tabs_reactive_log")
    ),
    preview_canvas_style = paste(
      "position: relative; display: flex; align-items: stretch; justify-content: stretch;",
      "padding: 1.5rem; background: var(--card);",
      "border: 1px dashed var(--border); border-radius: 0.75rem;",
      "min-height: 260px; box-sizing: border-box; width: 100%;"
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_tabs_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: grid; gap: 1.5rem;",
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
