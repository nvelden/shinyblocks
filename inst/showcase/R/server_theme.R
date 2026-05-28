register_theme_showcase <- function(input, output, session) {
  # Observe button events to update active theme mode
  shiny::observeEvent(input$showcase_theme_set_light, {
    update_block_theme(session, mode = "light")
  })
  shiny::observeEvent(input$showcase_theme_set_dark, {
    update_block_theme(session, mode = "dark")
  })
  shiny::observeEvent(input$showcase_theme_set_system, {
    update_block_theme(session, mode = "system")
  })

  # Dynamic preview UI (renders style overrides + some styled components)
  output$showcase_theme_preview_ui <- shiny::renderUI({
    radius <- input$showcase_theme_doc_radius %||% "0.5rem"
    primary <- input$showcase_theme_doc_primary %||% "hsl(221.2, 83.2%, 53.3%)"
    accent <- input$showcase_theme_doc_accent %||% "hsl(214, 95%, 93%)"
    
    htmltools::tagList(
      block_theme(
        radius = radius,
        primary = primary,
        accent = accent
      ),
      htmltools::div(
        style = "display: flex; flex-direction: column; gap: 1rem; width: 100%;",
        htmltools::div(
          style = "display: flex; gap: 0.75rem; align-items: center; flex-wrap: wrap;",
          block_button("Primary Button", variant = "default"),
          block_button("Secondary Button", variant = "secondary"),
          block_button("Outline Button", variant = "outline")
        ),
        htmltools::div(
          style = paste(
            "padding: 1rem;",
            "background: var(--accent); color: var(--accent-foreground);",
            "border: 1px solid color-mix(in oklab, var(--accent) 70%, var(--foreground));",
            "border-radius: calc(var(--radius) * 1.2);",
            "font-size: 0.875rem; font-weight: 500;",
            "display: flex; align-items: center; justify-content: space-between; gap: 1rem;"
          ),
          htmltools::span("Accent surface (uses --accent token)"),
          block_badge("Token preview", variant = "secondary")
        ),
        block_card(
          title = "Dynamic Card",
          description = "Check out the rounded corners and active color tokens!",
          "This surface and the buttons above immediately inherit the chosen radius, primary, and accent overrides."
        )
      )
    )
  })
  shiny::outputOptions(
    output,
    "showcase_theme_preview_ui",
    suspendWhenHidden = FALSE
  )

  # Dynamic code snippet rendering
  output$showcase_theme_preview_code <- showcase_render_code({
    radius_val <- input$showcase_theme_doc_radius %||% "0.5rem"
    primary_val <- input$showcase_theme_doc_primary %||% "hsl(221.2, 83.2%, 53.3%)"
    accent_val <- input$showcase_theme_doc_accent %||% "hsl(214, 95%, 93%)"

    paste0(
      "block_theme(\n",
      "  radius = \"", radius_val, "\",\n",
      "  primary = \"", primary_val, "\",\n",
      "  accent = \"", accent_val, "\"\n",
      ")"
    )
  })
  shiny::outputOptions(
    output,
    "showcase_theme_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_theme_action_code <- showcase_render_code({
    paste(
      "update_block_theme(",
      "  session = session,",
      "  mode = \"dark\"",
      ")",
      sep = "\n"
    )
  })
  shiny::outputOptions(
    output,
    "showcase_theme_action_code",
    suspendWhenHidden = FALSE
  )

  # API Reference table
  output$showcase_theme_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("...", "session", "mode"),
      Type = c("Named HSL/CSS token overrides", "Shiny Session", "character"),
      Default = c("none", "getDefaultReactiveDomain()", "required"),
      Description = c(
        "CSS variables to override (e.g., primary, radius, border, background, chart-1).",
        "The active Shiny session domain (required for theme updates).",
        "The targeted theme mode: 'system', 'light', or 'dark'."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_theme_api_table",
    suspendWhenHidden = FALSE
  )
}
