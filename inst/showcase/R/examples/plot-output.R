htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("caption", `for` = "showcase_plot_output_caption"),
          block_input("showcase_plot_output_caption", value = "Quarterly revenue by region")
        ),
        block_field(
          block_field_label("width", `for` = "showcase_plot_output_width"),
          block_input("showcase_plot_output_width", value = "", placeholder = "e.g., 360px (blank = 100%)")
        ),
        block_field(
          block_field_label("height", `for` = "showcase_plot_output_height"),
          block_input("showcase_plot_output_height", value = "", placeholder = "blank = aspect/Shiny default")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("aspect", `for` = "showcase_plot_output_aspect"),
          block_select(
            "showcase_plot_output_aspect",
            choices = c("none", "16/9", "4/3", "1/1", "21/9"),
            selected = "16/9",
            size = "sm"
          )
        ),
        block_field(
          block_field_label("border", `for` = "showcase_plot_output_border"),
          block_checkbox("showcase_plot_output_border", "Draw border", value = TRUE)
        ),
        block_field(
          block_field_label("rounded", `for` = "showcase_plot_output_rounded"),
          block_checkbox("showcase_plot_output_rounded", "Rounded corners", value = TRUE)
        )
      ),
      showcase_controls_group(
        "Actions (Server Render)",
        block_cluster(
            gap = "sm",
          showcase_action_button("showcase_plot_output_regen", "Regenerate")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("class", `for` = "showcase_plot_output_class"),
          block_checkbox("showcase_plot_output_class", "Use border-dashed class", value = FALSE)
        ),
        block_field(
          block_field_label("style", `for` = "showcase_plot_output_style"),
          block_input(
            "showcase_plot_output_style",
            value = "",
            placeholder = "e.g., max-width: 34rem; margin-inline: auto;"
          )
        )
      )
    ),
    preview_output_id = "showcase_plot_output_preview_ui",
    code_output_id = "showcase_plot_output_preview_code",
    preview_canvas_style = paste(
      "position: relative; display: block;",
      "padding: 1.5rem; background: var(--card);",
      "border: 1px solid var(--border); border-radius: 0.75rem;",
      "box-sizing: border-box;",
      "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
    ),
    extra_outputs = htmltools::tagList(
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Interaction values"
        ),
        shiny::uiOutput("showcase_plot_output_interaction_value")
      ),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Render"
        ),
        shiny::uiOutput("showcase_plot_output_reactive_code")
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_plot_output_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  block_stack(
      gap = "md",
      style = "max-width: 28rem;",
    block_plot_output(
      "showcase_parity_plot_output",
      aspect = "16/9",
      border = TRUE,
      caption = "Bordered, captioned block_plot_output() frame.",
      class = "sb-parity-plot-output"
    )
  )
)
