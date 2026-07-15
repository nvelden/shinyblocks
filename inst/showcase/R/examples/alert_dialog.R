htmltools::tagList(
  htmltools::tags$section(
    `aria-label` = "Interactive Playground",
    showcase_playground_layout(
      controls = htmltools::tagList(
        showcase_controls_group(
          "Content", first = TRUE,
          block_field(block_field_label("title", `for` = "showcase_alert_dialog_title"), block_input("showcase_alert_dialog_title", value = "Delete account?")),
          block_field(block_field_label("description", `for` = "showcase_alert_dialog_description"), block_textarea("showcase_alert_dialog_description", value = "This action cannot be undone.", rows = 2, resize = "none")),
          block_field(block_field_label("confirm_label", `for` = "showcase_alert_dialog_confirm_label"), block_input("showcase_alert_dialog_confirm_label", value = "Delete")),
          block_field(block_field_label("cancel_label", `for` = "showcase_alert_dialog_cancel_label"), block_input("showcase_alert_dialog_cancel_label", value = "Cancel")),
          block_field(block_field_label("trigger", `for` = "showcase_alert_dialog_trigger"), block_input("showcase_alert_dialog_trigger", value = "Delete account"))
        ),
        showcase_controls_group(
          "State",
          block_field(block_field_label("confirm_variant", `for` = "showcase_alert_dialog_variant"), block_select("showcase_alert_dialog_variant", c("default", "destructive"), selected = "destructive", size = "sm"))
        ),
        showcase_controls_group(
          "Actions (Server Update)",
          block_cluster(gap = "sm", showcase_action_button("showcase_alert_dialog_open", "Open"), showcase_action_button("showcase_alert_dialog_close", "Close"))
        ),
        showcase_controls_group(
          "Styling",
          block_field(block_field_label("size", `for` = "showcase_alert_dialog_size"), block_select("showcase_alert_dialog_size", c("default", "sm", "lg", "xl"), selected = "default", size = "sm")),
          block_field(block_field_label("style", `for` = "showcase_alert_dialog_style"), block_input("showcase_alert_dialog_style", value = "", placeholder = "max-width: 28rem;")),
          block_field(block_field_label("class", `for` = "showcase_alert_dialog_class"), block_checkbox("showcase_alert_dialog_class", "Use custom preview class"))
        )
      ),
      preview_output_id = "showcase_alert_dialog_preview_ui",
      code_output_id = "showcase_alert_dialog_code",
      extra_outputs = htmltools::tagList(
        shiny::uiOutput("showcase_alert_dialog_value"),
        htmltools::div(htmltools::div(class = "showcase-playground__label--code", "Server Action"), shiny::uiOutput("showcase_alert_dialog_server_code"))
      ),
      preview_canvas_class = "showcase-preview-canvas--muted"
    )
  ),
  block_alert_dialog(
    "showcase_alert_dialog_preview",
    "Delete account?",
    "This action cannot be undone.",
    confirm_label = "Delete",
    trigger = "Delete account",
    confirm_variant = "destructive"
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_alert_dialog_api_table")
)
