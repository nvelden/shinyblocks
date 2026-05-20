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
            block_field_label("Preview", `for` = "showcase_alert_preview"),
            shiny::uiOutput("showcase_alert_preview_ui")
          ),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::uiOutput("showcase_alert_preview_code")
            )
          )
        ),
        htmltools::div(
          style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          # Content controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
            block_field(
              block_field_label("title", `for` = "showcase_alert_doc_title"),
              block_textarea("showcase_alert_doc_title", value = "Heads up", rows = 1)
            ),
            block_field(
              block_field_label("description", `for` = "showcase_alert_doc_description"),
              block_textarea("showcase_alert_doc_description", value = "shinyblocks alerts surface important inline messages.", rows = 2)
            ),
            block_field(
              block_field_label("icon", `for` = "showcase_alert_doc_icon"),
              block_select("showcase_alert_doc_icon", choices = c("<None>" = "none", info = "info", search = "search", `alert-triangle` = "alert-triangle", check = "check"), selected = "info")
            ),
            block_field(
              block_field_label("variant", `for` = "showcase_alert_doc_variant"),
              block_select("showcase_alert_doc_variant", choices = c("default", "destructive"), selected = "default")
            )
          ),
          # Styling controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
            block_field(
              block_field_label("class", `for` = "showcase_alert_doc_class"),
              block_textarea("showcase_alert_doc_class", value = "", rows = 1, placeholder = "e.g., shadow-sm")
            )
          )
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_alert_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 0.75rem;",
    block_alert("Heads up", description = "shinyblocks alerts surface important inline messages.", class = "sb-parity-alert-default"),
    block_alert("Build failed", description = "Three components failed to render.", variant = "destructive", icon = "alert-triangle", class = "sb-parity-alert-destructive")
  )
)
