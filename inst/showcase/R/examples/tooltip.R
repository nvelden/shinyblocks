htmltools::tagList(
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
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_tooltip_api_table")
)
