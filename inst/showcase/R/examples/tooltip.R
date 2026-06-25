htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("trigger label", `for` = "showcase_tooltip_doc_trigger"),
          block_input("showcase_tooltip_doc_trigger", value = "Hover me")
        ),
        block_field(
          block_field_label("content", `for` = "showcase_tooltip_doc_content"),
          block_textarea("showcase_tooltip_doc_content", value = "Tooltip details go here.", rows = 2, resize = "none")
        ),
        block_field(
          block_field_label("delay_duration", `for` = "showcase_tooltip_doc_delay"),
          block_select(
            "showcase_tooltip_doc_delay",
            choices = c("0ms" = 0, "100ms" = 100, "500ms" = 500, "700ms" = 700, "1500ms" = 1500),
            selected = "700",
            size = "sm"
          )
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("side", `for` = "showcase_tooltip_doc_side"),
          block_select("showcase_tooltip_doc_side", choices = c("top", "bottom", "left", "right"), selected = "top", size = "sm")
        ),
        block_field(
          block_field_label("align", `for` = "showcase_tooltip_doc_align"),
          block_select("showcase_tooltip_doc_align", choices = c("center", "start", "end"), selected = "center", size = "sm")
        ),
        block_field(
          block_field_label("style", `for` = "showcase_tooltip_doc_style"),
          block_input("showcase_tooltip_doc_style", value = "", placeholder = "e.g., border: 2px dashed red;")
        ),
        block_field(
          block_field_label("class", `for` = "showcase_tooltip_doc_class"),
          block_checkbox("showcase_tooltip_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_tooltip_preview_ui",
    code_output_id = "showcase_tooltip_preview_code",
    preview_canvas_class = "showcase-preview-canvas--muted",
    preview_canvas_style = "min-height: 190px;"
  ),
  
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_tooltip_api_table"),
  
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
    block_cluster(
        gap = "md",
        align = "center",
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
    block_cluster(
        gap = "md",
        align = "center",
      block_tooltip("Start", "align = \"start\"", side = "bottom", align = "start"),
      block_tooltip("Center", "align = \"center\"", side = "bottom", align = "center"),
      block_tooltip("End", "align = \"end\"", side = "bottom", align = "end")
    )
  ),
  block_field_set(
    block_field_legend("Custom delay and rich content"),
    block_cluster(
        gap = "md",
        align = "center",
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
