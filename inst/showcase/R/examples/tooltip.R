htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        style = "display: flex; gap: 2rem; flex-wrap: wrap; align-items: flex-start;",
        # Left Column: Live Preview & Code Recipes
        htmltools::div(
          style = "flex: 1; min-width: 300px; display: flex; flex-direction: column; gap: 1.5rem;",
          block_field(
            block_field_label("Preview", `for` = "showcase_tooltip_preview_ui"),
            shiny::uiOutput("showcase_tooltip_preview_ui")
          ),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::uiOutput("showcase_tooltip_preview_code")
            )
          )
        ),
        # Right Column: Controls
        htmltools::div(
          style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          # Content controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
            block_field(
              block_field_label("trigger label", `for` = "showcase_tooltip_doc_trigger"),
              block_textarea("showcase_tooltip_doc_trigger", value = "Hover me", rows = 1)
            ),
            block_field(
              block_field_label("content", `for` = "showcase_tooltip_doc_content"),
              block_textarea("showcase_tooltip_doc_content", value = "Tooltip details go here.", rows = 2)
            ),
            block_field(
              block_field_label("delay_duration", `for` = "showcase_tooltip_doc_delay"),
              block_select(
                "showcase_tooltip_doc_delay",
                choices = c(
                  "0ms" = 0,
                  "100ms" = 100,
                  "500ms" = 500,
                  "700ms" = 700,
                  "1500ms" = 1500
                ),
                selected = "700"
              )
            )
          ),
          # Styling controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
            block_field(
              block_field_label("side", `for` = "showcase_tooltip_doc_side"),
              block_select(
                "showcase_tooltip_doc_side",
                choices = c("top", "bottom", "left", "right"),
                selected = "top"
              )
            ),
            block_field(
              block_field_label("align", `for` = "showcase_tooltip_doc_align"),
              block_select(
                "showcase_tooltip_doc_align",
                choices = c("center", "start", "end"),
                selected = "center"
              )
            ),
            block_field(
              block_field_label("style", `for` = "showcase_tooltip_doc_style"),
              block_textarea("showcase_tooltip_doc_style", value = "", rows = 1, placeholder = "e.g., border: 2px dashed red;")
            ),
            block_field(
              block_field_label("class", `for` = "showcase_tooltip_doc_class"),
              block_checkbox("showcase_tooltip_doc_class", "Use custom dashed-border class", value = FALSE)
            )
          )
        )
      ),
      htmltools::tags$div(
        style = "display: none;",
        block_tooltip("Static fallback", "Hidden mount for showcase.")
      )
    )
  ),
  
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_tooltip_api_table"),
  
  # Stable baseline patterns as parity fixtures
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "Common Patterns (Parity Fixtures)"),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 1rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/ and visual regression checkers. Do not remove."
  ),
  
  block_field_set(
    block_field_legend("Default placement and behavior"),
    htmltools::tags$p(
      style = "color: var(--muted-foreground); margin: 0 0 1rem 0; font-size: 0.875rem;",
      "Tooltips open after a short hover/focus delay and close on leave, blur, or the Escape key.",
      " Try hovering or tabbing onto each trigger."
    ),
    htmltools::div(
      style = "display: flex; flex-wrap: wrap; gap: 1rem; align-items: center;",
      block_tooltip(
        "Hover me",
        "Default top placement."
      ),
      block_tooltip(
        "Bottom",
        "Aligned beneath the trigger.",
        side = "bottom"
      ),
      block_tooltip(
        "Left",
        "Anchored to the left edge.",
        side = "left"
      ),
      block_tooltip(
        "Right",
        "Anchored to the right edge.",
        side = "right"
      )
    )
  ),
  block_field_set(
    block_field_legend("Alignment along the anchored side"),
    htmltools::div(
      style = "display: flex; flex-wrap: wrap; gap: 1rem; align-items: center;",
      block_tooltip("Start", "align = \"start\"", side = "bottom", align = "start"),
      block_tooltip("Center", "align = \"center\"", side = "bottom", align = "center"),
      block_tooltip("End", "align = \"end\"", side = "bottom", align = "end")
    )
  ),
  block_field_set(
    block_field_legend("Custom delay and rich content"),
    htmltools::div(
      style = "display: flex; flex-wrap: wrap; gap: 1rem; align-items: center;",
      block_tooltip(
        "Fast (100ms)",
        "Opens almost immediately on hover.",
        delay_duration = 100
      ),
      block_tooltip(
        "Slow (1500ms)",
        "Waits longer before showing.",
        delay_duration = 1500
      ),
      block_tooltip(
        "Rich content",
        htmltools::tagList(
          htmltools::tags$strong("Heads up:"),
          htmltools::tags$span(" tooltips accept inline HTML tags."),
          htmltools::tags$br(),
          htmltools::tags$em("Keep it concise.")
        ),
        side = "bottom"
      )
    )
  )
)
