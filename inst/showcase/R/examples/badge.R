htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        class = "showcase-playground", style = "display: flex; gap: 2rem; flex-wrap: wrap; align-items: flex-start;",
        htmltools::div(
          class = "showcase-playground__main", style = "flex: 1; min-width: 300px; display: flex; flex-direction: column; gap: 1.5rem;",
          block_field(
            block_field_label("Preview", `for` = "showcase_badge_preview"),
            shiny::uiOutput("showcase_badge_preview_ui")
          ),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::uiOutput("showcase_badge_preview_code")
            )
          )
        ),
        htmltools::div(
          class = "showcase-playground__controls", style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          # Content controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
            block_field(
              block_field_label("label", `for` = "showcase_badge_doc_label"),
              block_textarea("showcase_badge_doc_label", value = "Deploying", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("variant", `for` = "showcase_badge_doc_variant"),
              block_select("showcase_badge_doc_variant", choices = c("default", "secondary", "outline", "destructive", "ghost", "link"), selected = "default")
            ),
            block_field(
              block_field_label("size", `for` = "showcase_badge_doc_size"),
              block_select("showcase_badge_doc_size", choices = c("sm", "default", "lg"), selected = "default")
            )
          ),
          # Styling controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
            block_field(
              block_field_label("class", `for` = "showcase_badge_doc_class"),
              block_textarea("showcase_badge_doc_class", value = "", rows = 1, placeholder = "e.g., shadow-sm", resize = "none")
            ),
            block_field(
              block_field_label("style", `for` = "showcase_badge_doc_style"),
              block_textarea("showcase_badge_doc_style", value = "", rows = 1, placeholder = "e.g., letter-spacing: 0.04em;", resize = "none")
            )
          )
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_badge_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; gap: 0.5rem; flex-wrap: wrap;",
    block_badge("Default", class = "sb-parity-badge-default"),
    block_badge("Secondary", variant = "secondary", class = "sb-parity-badge-secondary"),
    block_badge("Outline", variant = "outline", class = "sb-parity-badge-outline"),
    block_badge("Destructive", variant = "destructive", class = "sb-parity-badge-destructive"),
    block_badge("Ghost", variant = "ghost", class = "sb-parity-badge-ghost"),
    block_badge("Link", variant = "link", class = "sb-parity-badge-link")
  )
)
