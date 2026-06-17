htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("label", `for` = "showcase_badge_doc_label"),
          block_input("showcase_badge_doc_label", value = "Deploying")
        ),
        block_field(
          block_field_label("variant", `for` = "showcase_badge_doc_variant"),
          block_select("showcase_badge_doc_variant", choices = c("default", "secondary", "outline", "destructive", "success", "warning", "info", "ghost", "link"), selected = "default")
        ),
        block_field(
          block_field_label("size", `for` = "showcase_badge_doc_size"),
          block_select("showcase_badge_doc_size", choices = c("sm", "default", "lg"), selected = "default")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("class", `for` = "showcase_badge_doc_class"),
          block_input("showcase_badge_doc_class", value = "", placeholder = "e.g., shadow-sm")
        ),
        block_field(
          block_field_label("style", `for` = "showcase_badge_doc_style"),
          block_input("showcase_badge_doc_style", value = "", placeholder = "e.g., letter-spacing: 0.04em;")
        )
      )
    ),
    preview_output_id = "showcase_badge_preview_ui",
    code_output_id = "showcase_badge_preview_code"
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_badge_api_table"),
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
    block_badge("Success", variant = "success", class = "sb-parity-badge-success"),
    block_badge("Warning", variant = "warning", class = "sb-parity-badge-warning"),
    block_badge("Info", variant = "info", class = "sb-parity-badge-info"),
    block_badge("Ghost", variant = "ghost", class = "sb-parity-badge-ghost"),
    block_badge("Link", variant = "link", class = "sb-parity-badge-link")
  )
)
