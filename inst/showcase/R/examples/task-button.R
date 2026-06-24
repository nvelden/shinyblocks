htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("label", `for` = "showcase_task_button_doc_label"),
          block_input("showcase_task_button_doc_label", value = "Run analysis")
        ),
        block_field(
          block_field_label("label_busy", `for` = "showcase_task_button_doc_label_busy"),
          block_input("showcase_task_button_doc_label_busy", value = "Crunching...")
        ),
        block_field(
          block_field_label("icon", `for` = "showcase_task_button_doc_icon"),
          block_select("showcase_task_button_doc_icon", choices = c("<None>" = "none", play = "play", `arrow-right` = "arrow-right", check = "check"), selected = "none")
        ),
        block_field(
          block_field_label("icon_busy", `for` = "showcase_task_button_doc_icon_busy"),
          block_select("showcase_task_button_doc_icon_busy", choices = c("Spinner (default)" = "none", `refresh-cw` = "refresh-cw", check = "check"), selected = "none")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("variant", `for` = "showcase_task_button_doc_variant"),
          block_select("showcase_task_button_doc_variant", choices = c("default", "secondary", "outline", "ghost", "destructive", "link"), selected = "default")
        ),
        block_field(
          block_field_label("auto_reset", `for` = "showcase_task_button_doc_auto_reset"),
          block_checkbox("showcase_task_button_doc_auto_reset", "Reset to ready after the click flush", value = TRUE)
        ),
        block_field(
          block_field_label("disabled", `for` = "showcase_task_button_doc_disabled"),
          block_checkbox("showcase_task_button_doc_disabled", "Disabled", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("size", `for` = "showcase_task_button_doc_size"),
          block_select("showcase_task_button_doc_size", choices = c("default", "sm", "lg"), selected = "default")
        ),
        block_field(
          block_field_label("icon_position", `for` = "showcase_task_button_doc_icon_position"),
          block_select("showcase_task_button_doc_icon_position", choices = c("inline-start", "inline-end"), selected = "inline-start")
        ),
        block_field(
          block_field_label("style", `for` = "showcase_task_button_doc_style"),
          block_input("showcase_task_button_doc_style", value = "", placeholder = "e.g., min-width: 12rem;")
        ),
        block_field(
          block_field_label("class", `for` = "showcase_task_button_doc_class"),
          block_checkbox("showcase_task_button_doc_class", "Use custom dashed-border class", value = FALSE)
        )
      ),
      showcase_controls_group(
        "Actions (Server Update)",
        htmltools::div(
          style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
          # The signature server interaction: manual busy/ready control plus
          # disabled-state preservation. The Content / State / Styling controls
          # above already exercise the remaining update fields live.
          showcase_action_button("showcase_task_button_set_busy", "Set busy"),
          showcase_action_button("showcase_task_button_set_ready", "Set ready"),
          showcase_action_button("showcase_task_button_disable", "Disable"),
          showcase_action_button("showcase_task_button_enable", "Enable")
        )
      )
    ),
    preview_output_id = "showcase_task_button_preview_ui",
    code_output_id = "showcase_task_button_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_task_button_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Task result"
        ),
        shiny::uiOutput("showcase_task_button_result")
      ),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_task_button_reactive_code")
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_task_button_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instance used by the theme/style harness. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; gap: 0.75rem; flex-wrap: wrap;",
    block_task_button("sb_parity_task_button", "Default", class = "sb-parity-task-button-default")
  )
)
