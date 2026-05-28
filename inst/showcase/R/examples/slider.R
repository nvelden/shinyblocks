htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("value", `for` = "showcase_slider_doc_value"),
          block_input("showcase_slider_doc_value", value = "50", placeholder = "50 or 25,75")
        ),
        block_field(
          block_field_label("min", `for` = "showcase_slider_doc_min"),
          block_input("showcase_slider_doc_min", value = "0", type = "number")
        ),
        block_field(
          block_field_label("max", `for` = "showcase_slider_doc_max"),
          block_input("showcase_slider_doc_max", value = "100", type = "number")
        ),
        block_field(
          block_field_label("step", `for` = "showcase_slider_doc_step"),
          block_input("showcase_slider_doc_step", value = "1", type = "number")
        ),
        block_field(
          block_field_label("orientation", `for` = "showcase_slider_doc_orientation"),
          block_select(
            "showcase_slider_doc_orientation",
            choices = c("horizontal", "vertical"),
            selected = "horizontal"
          )
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("disabled", `for` = "showcase_slider_doc_disabled"),
          block_checkbox("showcase_slider_doc_disabled", "Disabled", value = FALSE)
        ),
        block_field(
          block_field_label("invalid", `for` = "showcase_slider_doc_invalid"),
          block_checkbox("showcase_slider_doc_invalid", "Invalid", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Labels",
        block_field(
          block_field_label("show value", `for` = "showcase_slider_doc_show_value"),
          block_checkbox("showcase_slider_doc_show_value", "Show current value", value = FALSE)
        ),
        block_field(
          block_field_label("min label", `for` = "showcase_slider_doc_min_label"),
          block_input("showcase_slider_doc_min_label", value = "Quiet", placeholder = "Optional minimum label")
        ),
        block_field(
          block_field_label("max label", `for` = "showcase_slider_doc_max_label"),
          block_input("showcase_slider_doc_max_label", value = "Loud", placeholder = "Optional maximum label")
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        htmltools::div(
          style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
          showcase_action_button("showcase_slider_set_low", "Set 25"),
          showcase_action_button("showcase_slider_set_range", "Set range"),
          showcase_action_button("showcase_slider_disable", "Disable"),
          showcase_action_button("showcase_slider_enable", "Enable"),
          showcase_action_button("showcase_slider_resize", "Change bounds"),
          showcase_action_button("showcase_slider_vertical", "Show vertical")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("width", `for` = "showcase_slider_doc_width"),
          block_input("showcase_slider_doc_width", value = "20rem", placeholder = "100% or 20rem")
        ),
        block_field(
          block_field_label("style", `for` = "showcase_slider_doc_style"),
          block_textarea(
            "showcase_slider_doc_style",
            value = "",
            rows = 1,
            placeholder = "e.g., max-width: 20rem;"
          )
        ),
        block_field(
          block_field_label("class", `for` = "showcase_slider_doc_class"),
          block_checkbox("showcase_slider_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_slider_preview_ui",
    code_output_id = "showcase_slider_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_slider_preview_value"),
      htmltools::div(
        htmltools::div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_slider_reactive_code")
      )
    ),
    preview_canvas_style = paste(
      "position: relative; display: flex; align-items: center; justify-content: center;",
      "padding: 3rem 2rem 2.5rem; background: var(--card);",
      "border: 1px dashed var(--border); border-radius: 0.75rem;",
      "min-height: 180px; box-sizing: border-box;"
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_slider_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances captured by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 1rem; padding: 1rem; border: 1px dashed var(--border); border-radius: 0.5rem;",
    block_slider(
      "showcase_parity_slider_default",
      value = 50,
      min = 0,
      max = 100,
      class = "sb-parity-slider-default"
    ),
    block_slider(
      "showcase_parity_slider_range",
      value = c(25, 75),
      min = 0,
      max = 100,
      class = "sb-parity-slider-range"
    ),
    block_slider(
      "showcase_parity_slider_disabled",
      value = 30,
      min = 0,
      max = 100,
      disabled = TRUE,
      class = "sb-parity-slider-disabled"
    )
  )
)
