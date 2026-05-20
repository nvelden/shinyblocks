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
            block_field_label("Preview", `for` = "showcase_theme_preview"),
            shiny::uiOutput("showcase_theme_preview_ui")
          ),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::uiOutput("showcase_theme_preview_code")
            )
          )
        ),
        htmltools::div(
          style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          # Controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Tokens"),
            block_field(
              block_field_label("radius", `for` = "showcase_theme_doc_radius"),
              block_select("showcase_theme_doc_radius", choices = c("0rem", "0.25rem", "0.5rem", "1rem", "1.5rem"), selected = "0.5rem")
            ),
            block_field(
              block_field_label("primary (color)", `for` = "showcase_theme_doc_primary"),
              block_select("showcase_theme_doc_primary", choices = c(
                "blue" = "hsl(221.2, 83.2%, 53.3%)",
                "red" = "hsl(0, 72.2%, 50.6%)",
                "green" = "hsl(142.1, 76.2%, 36.3%)",
                "purple" = "hsl(262.1, 83.3%, 57.8%)"
              ), selected = "hsl(221.2, 83.2%, 53.3%)")
            ),
            block_field(
              block_field_label("accent (background)", `for` = "showcase_theme_doc_accent"),
              block_select("showcase_theme_doc_accent", choices = c(
                "subtle blue" = "hsl(210, 40%, 96.1%)",
                "subtle gray" = "hsl(0, 0%, 96.1%)",
                "subtle green" = "hsl(120, 30%, 96.1%)"
              ), selected = "hsl(210, 40%, 96.1%)")
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Server Theme Mode"),
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 0.5rem;",
              block_button("Force Light Mode", id = "showcase_theme_set_light", variant = "outline", size = "sm"),
              block_button("Force Dark Mode", id = "showcase_theme_set_dark", variant = "outline", size = "sm"),
              block_button("Sync with System", id = "showcase_theme_set_system", variant = "outline", size = "sm")
            )
          )
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_theme_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    class = "sb-parity-theme-baseline",
    style = "display: flex; gap: 1rem; align-items: center;",
    block_theme(
      accent = "oklch(0.3 0.03 260)",
      radius = "0.5rem"
    ),
    block_dark_mode_toggle(),
    block_button("Primary Button (Theme)", icon = "sun"),
    block_button("Outline Button (Theme)", variant = "outline")
  )
)
