htmltools::tagList(
  htmltools::tags$section(
    `aria-label` = "Interactive Playground",
    showcase_playground_layout(
      controls = htmltools::tagList(
        showcase_controls_group(
          "Content", first = TRUE,
          block_field(
            block_field_label("title", `for` = "showcase_dialog_doc_title"),
            block_input("showcase_dialog_doc_title", value = "Confirm action")
          ),
          block_field(
            block_field_label("description", `for` = "showcase_dialog_doc_description"),
            block_textarea("showcase_dialog_doc_description", value = "This cannot be undone.", rows = 2, resize = "none")
          ),
          block_field(
            block_field_label("trigger label", `for` = "showcase_dialog_doc_trigger"),
            block_input("showcase_dialog_doc_trigger", value = "Open dialog")
          ),
          block_field(
            block_field_label("footer", `for` = "showcase_dialog_doc_footer"),
            block_checkbox("showcase_dialog_doc_footer", "Include Cancel + Continue footer", value = TRUE)
          )
        ),
        showcase_controls_group(
          "State",
          block_field(
            block_field_label("hide_title", `for` = "showcase_dialog_doc_hide_title"),
            block_checkbox("showcase_dialog_doc_hide_title", "Hide title visually", value = FALSE)
          )
        ),
        showcase_controls_group(
          "Actions (Server Update)",
          block_cluster(
              gap = "sm",
            showcase_action_button("showcase_dialog_open", "Open modal"),
            showcase_action_button("showcase_dialog_close", "Close modal"),
            showcase_action_button("showcase_dialog_resize_sm", "Resize sm"),
            showcase_action_button("showcase_dialog_resize_lg", "Resize lg"),
            showcase_action_button("showcase_dialog_swap_footer", "Swap footer")
          )
        ),
        showcase_controls_group(
          "Styling",
          block_field(
            block_field_label("size", `for` = "showcase_dialog_doc_size"),
            block_select("showcase_dialog_doc_size", choices = c("default", "sm", "lg", "xl"), selected = "default", size = "sm")
          ),
          block_field(
            block_field_label("style", `for` = "showcase_dialog_doc_style"),
            block_input("showcase_dialog_doc_style", value = "", placeholder = "e.g., border: 2px dashed red;")
          ),
          block_field(
            block_field_label("class", `for` = "showcase_dialog_doc_class"),
            block_checkbox("showcase_dialog_doc_class", "Use custom dashed-border class", value = FALSE)
          )
        )
      ),
      preview_output_id = "showcase_dialog_preview_ui",
      code_output_id = "showcase_dialog_preview_code",
      extra_outputs = htmltools::tagList(
        block_cluster(
            justify = "center",
          shiny::uiOutput("showcase_dialog_trigger_ui")
        ),
        shiny::uiOutput("showcase_dialog_preview_value"),
        htmltools::div(
          htmltools::div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "Server Action"
          ),
          shiny::uiOutput("showcase_dialog_reactive_code")
        )
      ),
      preview_canvas_class = "showcase-preview-canvas--muted"
    )
  ),
  block_dialog(
    id = "showcase_dialog_preview",
    title = "Confirm action",
    description = "This cannot be undone.",
    footer = htmltools::tagList(
      block_button("Cancel", variant = "outline"),
      block_button("Continue")
    ),
    htmltools::tags$p(
      "Click the trigger above or any 'Open modal' action to open the real dialog."
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_dialog_api_table")
)
