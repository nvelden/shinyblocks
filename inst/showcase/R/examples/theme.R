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
            "default (adapts to light/dark)" = "inherit",
            "blue" = "hsl(221.2, 83.2%, 53.3%)",
            "green" = "hsl(142.1, 76.2%, 36.3%)",
            "violet" = "hsl(262.1, 83.3%, 57.8%)",
            "rose" = "hsl(346.8, 77.2%, 49.8%)"
          ), selected = "inherit", size = "sm")
        ),
        block_field(
          block_field_label("secondary", `for` = "showcase_theme_doc_secondary"),
          block_select("showcase_theme_doc_secondary", choices = c(
            "default (adapts to light/dark)" = "inherit",
            "cool" = "oklch(0.93 0.03 250)",
            "warm" = "oklch(0.95 0.04 80)"
          ), selected = "inherit", size = "sm")
        ),
        block_field(
          block_field_label("accent", `for` = "showcase_theme_doc_accent"),
          block_select("showcase_theme_doc_accent", choices = c(
            "default (adapts to light/dark)" = "inherit",
            "blue tint" = "hsl(214, 95%, 93%)",
            "green tint" = "hsl(142, 69%, 90%)",
            "amber tint" = "hsl(48, 96%, 89%)",
            "rose tint" = "hsl(351, 95%, 93%)"
          ), selected = "inherit", size = "sm")
        ),
        block_field(
          block_field_label("destructive", `for` = "showcase_theme_doc_destructive"),
          block_select("showcase_theme_doc_destructive", choices = c(
            "default (adapts to light/dark)" = "inherit",
            "orange" = "oklch(0.65 0.2 40)",
            "crimson" = "hsl(346.8, 77.2%, 49.8%)"
          ), selected = "inherit", size = "sm")
        ),
        block_field(
          block_field_label("muted", `for` = "showcase_theme_doc_muted"),
          block_select("showcase_theme_doc_muted", choices = c(
            "default (adapts to light/dark)" = "inherit",
            "cool" = "oklch(0.95 0.02 250)",
            "warm" = "oklch(0.96 0.02 80)"
          ), selected = "inherit", size = "sm")
        ),
        block_field(
          block_field_label("border", `for` = "showcase_theme_doc_border"),
          block_select("showcase_theme_doc_border", choices = c(
            "default (adapts to light/dark)" = "inherit",
            "strong" = "oklch(0.8 0 0)",
            "blue" = "oklch(0.8 0.05 250)"
          ), selected = "inherit", size = "sm")
        ),
        block_field(
          block_field_label("ring", `for` = "showcase_theme_doc_ring"),
          block_select("showcase_theme_doc_ring", choices = c(
            "default (adapts to light/dark)" = "inherit",
            "blue" = "hsl(221.2, 83.2%, 53.3%)",
            "green" = "hsl(142.1, 76.2%, 36.3%)"
          ), selected = "inherit", size = "sm")
        )
      ),
      showcase_controls_group(
        "Dark mode overrides",
        block_field(
          block_field_label("primary (dark)", `for` = "showcase_theme_doc_primary_dark"),
          block_select("showcase_theme_doc_primary_dark", choices = c(
            "same as light" = "inherit",
            "blue" = "hsl(217, 91%, 60%)",
            "green" = "hsl(142, 71%, 45%)",
            "violet" = "hsl(263, 90%, 70%)",
            "rose" = "hsl(347, 77%, 60%)"
          ), selected = "inherit", size = "sm"),
          block_field_description(
            "Applied only in dark mode (block_theme(dark = ...)). Toggle the theme to compare."
          )
        ),
        block_field(
          block_field_label("accent (dark)", `for` = "showcase_theme_doc_accent_dark"),
          block_select("showcase_theme_doc_accent_dark", choices = c(
            "same as light" = "inherit",
            "blue" = "oklch(0.3 0.07 250)",
            "green" = "oklch(0.33 0.08 150)",
            "violet" = "oklch(0.34 0.09 290)"
          ), selected = "inherit", size = "sm")
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
      radius = "0.5rem",
      scope = ".sb-parity-theme-baseline"
    ),
    block_dark_mode_toggle(),
    block_button("Primary Button (Theme)", icon = "sun"),
    block_button("Outline Button (Theme)", variant = "outline")
  )
)
