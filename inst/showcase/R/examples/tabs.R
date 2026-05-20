htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        style = "display: flex; gap: 2rem; flex-wrap: wrap; align-items: flex-start;",
        htmltools::div(
          style = "flex: 1; min-width: 300px; display: flex; flex-direction: column; gap: 1.5rem;",
          block_field(
            block_field_label("Preview", `for` = "showcase_tabs_preview"),
            shiny::uiOutput("showcase_tabs_preview_ui")
          ),
          htmltools::tags$div(
            style = "font-size: 0.875rem; font-weight: 500; padding: 0.5rem; background: var(--secondary); border-radius: 0.25rem;",
            shiny::textOutput("showcase_tabs_reactive_log")
          ),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::uiOutput("showcase_tabs_preview_code")
            )
          )
        ),
        htmltools::div(
          style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          # Controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Tab Styles"),
            block_field(
              block_field_label("variant", `for` = "showcase_tabs_doc_variant"),
              block_select("showcase_tabs_doc_variant", choices = c("default", "line"), selected = "default")
            ),
            block_field(
              block_field_label("orientation", `for` = "showcase_tabs_doc_orientation"),
              block_select("showcase_tabs_doc_orientation", choices = c("horizontal", "vertical"), selected = "horizontal")
            )
          )
        )
      )
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
