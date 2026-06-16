htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("value", `for` = "showcase_progress_doc_value"),
          block_textarea("showcase_progress_doc_value", value = "0.6", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("min", `for` = "showcase_progress_doc_min"),
          block_textarea("showcase_progress_doc_min", value = "0", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("max", `for` = "showcase_progress_doc_max"),
          block_textarea("showcase_progress_doc_max", value = "1", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("label", `for` = "showcase_progress_doc_label"),
          block_textarea("showcase_progress_doc_label", value = "Upload", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("message", `for` = "showcase_progress_doc_message"),
          block_textarea("showcase_progress_doc_message", value = "Importing rows...", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("detail", `for` = "showcase_progress_doc_detail"),
          block_textarea("showcase_progress_doc_detail", value = "", rows = 1, placeholder = "e.g., 1,200 of 3,400", resize = "none")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("show_value", `for` = "showcase_progress_doc_show_value"),
          block_checkbox("showcase_progress_doc_show_value", "Show percent", value = TRUE)
        ),
        block_field(
          block_field_label("indeterminate", `for` = "showcase_progress_doc_indeterminate"),
          block_checkbox("showcase_progress_doc_indeterminate", "Indeterminate", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        htmltools::div(
          style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
          showcase_action_button("showcase_progress_set_25", "Set 25%"),
          showcase_action_button("showcase_progress_set_75", "Set 75%"),
          showcase_action_button("showcase_progress_inc", "Increment"),
          showcase_action_button("showcase_progress_reset", "Reset"),
          showcase_action_button("showcase_progress_toggle_indeterminate", "Indeterminate")
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("variant", `for` = "showcase_progress_doc_variant"),
          block_select(
            "showcase_progress_doc_variant",
            choices = c("default", "success", "warning", "info", "destructive"),
            selected = "default",
            size = "sm"
          )
        ),
        block_field(
          block_field_label("width", `for` = "showcase_progress_doc_width"),
          block_textarea("showcase_progress_doc_width", value = "", rows = 1, placeholder = "e.g., 320px (blank = 100%)", resize = "none")
        ),
        block_field(
          block_field_label("style", `for` = "showcase_progress_doc_style"),
          block_textarea("showcase_progress_doc_style", value = "", rows = 1, placeholder = "e.g., opacity: 0.8;", resize = "none")
        ),
        block_field(
          block_field_label("class", `for` = "showcase_progress_doc_class"),
          block_checkbox("showcase_progress_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_progress_preview_ui",
    code_output_id = "showcase_progress_preview_code",
    preview_canvas_style = paste(
      "position: relative; display: flex; align-items: center; justify-content: center;",
      "padding: 2.5rem 2rem; background: var(--card);",
      "border: 1px solid var(--border); border-radius: 0.75rem;",
      "min-height: 160px; box-sizing: border-box;",
      "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
    ),
    extra_outputs = htmltools::tagList(
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_progress_reactive_code")
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_progress_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 0.75rem; max-width: 300px;",
    block_progress("showcase_parity_progress_default", value = 0.6, class = "sb-parity-progress-default"),
    block_progress(
      "showcase_parity_progress_success",
      value = 0.6,
      variant = "success",
      class = "sb-parity-progress-success"
    ),
    block_progress(
      "showcase_parity_progress_destructive",
      value = 0.6,
      variant = "destructive",
      class = "sb-parity-progress-destructive"
    ),
    block_progress(
      "showcase_parity_progress_indeterminate",
      indeterminate = TRUE,
      class = "sb-parity-progress-indeterminate"
    )
  )
)
