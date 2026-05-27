htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Tokens", first = TRUE,
        block_field(
          block_field_label("radius", `for` = "showcase_theme_doc_radius"),
          block_select("showcase_theme_doc_radius", choices = c("0rem", "0.25rem", "0.5rem", "1rem", "1.5rem"), selected = "0.5rem", size = "sm")
        ),
        block_field(
          block_field_label("primary", `for` = "showcase_theme_doc_primary"),
          block_select("showcase_theme_doc_primary", choices = c(
            "blue" = "hsl(221.2, 83.2%, 53.3%)",
            "red" = "hsl(0, 72.2%, 50.6%)",
            "green" = "hsl(142.1, 76.2%, 36.3%)",
            "purple" = "hsl(262.1, 83.3%, 57.8%)"
          ), selected = "hsl(221.2, 83.2%, 53.3%)", size = "sm")
        ),
        block_field(
          block_field_label("accent", `for` = "showcase_theme_doc_accent"),
          block_select("showcase_theme_doc_accent", choices = c(
            "subtle blue" = "hsl(210, 40%, 96.1%)",
            "subtle gray" = "hsl(0, 0%, 96.1%)",
            "subtle green" = "hsl(120, 30%, 96.1%)"
          ), selected = "hsl(210, 40%, 96.1%)", size = "sm")
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        showcase_action_button("showcase_theme_set_light", "Force Light Mode"),
        showcase_action_button("showcase_theme_set_dark", "Force Dark Mode"),
        showcase_action_button("showcase_theme_set_system", "Sync with System")
      )
    ),
    preview_output_id = "showcase_theme_preview_ui",
    code_output_id = "showcase_theme_preview_code",
    extra_outputs = htmltools::tags$div(
      htmltools::tags$div(
        style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
        "Server Action"
      ),
      shiny::uiOutput("showcase_theme_action_code")
    ),
    preview_canvas_style = paste(
      "position: relative; display: flex; align-items: center; justify-content: center;",
      "padding: 1.5rem; background: color-mix(in oklab, var(--muted) 28%, transparent);",
      "border: 0; border-radius: 0.75rem; min-height: 330px; box-sizing: border-box;"
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
