htmltools::tagList(
  htmltools::tags$section(
    `aria-label` = "Interactive Playground",
    showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("trigger label", `for` = "showcase_popover_doc_trigger"),
          block_textarea("showcase_popover_doc_trigger", value = "Open popover", rows = 1)
        ),
        block_field(
          block_field_label("body", `for` = "showcase_popover_doc_body"),
          block_textarea(
            "showcase_popover_doc_body",
            value = "Place additional details, a small form, or contextual actions inside the popover.",
            rows = 3
          )
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("open", `for` = "showcase_popover_doc_open"),
          block_checkbox("showcase_popover_doc_open", "Open", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        htmltools::div(
          style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
          showcase_action_button("showcase_popover_open", "Open"),
          showcase_action_button("showcase_popover_close", "Close"),
          showcase_action_button("showcase_popover_reposition", "Move"),
          showcase_action_button("showcase_popover_swap_body", "Swap text")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("side", `for` = "showcase_popover_doc_side"),
          block_select("showcase_popover_doc_side", choices = c("bottom", "top", "left", "right"), selected = "bottom", size = "sm")
        ),
        block_field(
          block_field_label("align", `for` = "showcase_popover_doc_align"),
          block_select("showcase_popover_doc_align", choices = c("center", "start", "end"), selected = "center", size = "sm")
        ),
        block_field(
          block_field_label("style", `for` = "showcase_popover_doc_style"),
          block_textarea("showcase_popover_doc_style", value = "", rows = 1, placeholder = "e.g., border: 2px dashed red;")
        ),
        block_field(
          block_field_label("class", `for` = "showcase_popover_doc_class"),
          block_checkbox("showcase_popover_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_popover_preview_ui",
    code_output_id = "showcase_popover_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_popover_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_popover_reactive_code")
      )
    ),
    preview_canvas_style = paste(
      "position: relative; display: flex; align-items: center; justify-content: center;",
      "padding: 3rem 2rem; background: color-mix(in oklab, var(--muted) 28%, transparent);",
      "border: 0; border-radius: 0.75rem; min-height: 180px; box-sizing: border-box;"
    )
    )
  ),
  htmltools::tags$div(
    style = "display: none;",
    block_popover(
      trigger = "Static fallback",
      htmltools::tags$p("Hidden mount that satisfies the showcase static-render test.")
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_popover_api_table")
)
