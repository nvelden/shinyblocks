htmltools::tagList(
  htmltools::tags$section(
    `aria-label` = "Interactive Playground",
    showcase_playground_layout(
      controls = htmltools::tagList(
        showcase_controls_group(
          "Content", first = TRUE,
          block_field(
            block_field_label("title", `for` = "showcase_toast_doc_title"),
            block_input("showcase_toast_doc_title", value = "Changes saved")
          ),
          block_field(
            block_field_label("description", `for` = "showcase_toast_doc_description"),
            block_textarea("showcase_toast_doc_description", value = "Your profile has been updated.", rows = 2, resize = "none")
          )
        ),
        showcase_controls_group(
          "State",
          block_field(
            block_field_label("variant", `for` = "showcase_toast_doc_variant"),
            block_select(
              "showcase_toast_doc_variant",
              choices = c("default", "destructive", "success", "warning", "info"),
              selected = "success",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("icon", `for` = "showcase_toast_doc_icon"),
            block_select(
              "showcase_toast_doc_icon",
              choices = c("info", "check-circle", "alert-triangle", "x-circle", "bell", "none"),
              selected = "check-circle",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("dismissible", `for` = "showcase_toast_doc_dismissible"),
            block_checkbox("showcase_toast_doc_dismissible", "Show close button", value = TRUE)
          )
        ),
        showcase_controls_group(
          "Styling",
          block_field(
            block_field_label("position", `for` = "showcase_toast_doc_position"),
            block_select(
              "showcase_toast_doc_position",
              choices = c(
                "bottom-right", "bottom-center", "bottom-left",
                "top-right", "top-center", "top-left"
              ),
              selected = "bottom-right",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("duration (ms)", `for` = "showcase_toast_doc_duration"),
            block_select(
              "showcase_toast_doc_duration",
              choices = c("3000", "5000", "8000", "0 (sticky)"),
              selected = "5000",
              size = "sm"
            )
          )
        ),
        showcase_controls_group(
          "Actions (Server)",
          block_cluster(
              gap = "sm",
            showcase_action_button("showcase_toast_fire", "Show toast", variant = "default"),
            showcase_action_button("showcase_toast_dismiss", "Dismiss all")
          )
        )
      ),
      preview_output_id = "showcase_toast_preview_ui",
      code_output_id = "showcase_toast_preview_code",
      extra_outputs = htmltools::tagList(
        # The real toaster, mounted once. Toasts portal to the page and render at
        # the position chosen at construction. Firing happens from the server.
        htmltools::tags$div(
          style = "font-size: 0.75rem; color: var(--muted-foreground);",
          "Click \"Show toast\" to fire a real toast. Changing the position moves it live."
        ),
        block_toaster("showcase_toaster"),
        shiny::uiOutput("showcase_toast_preview_value"),
        htmltools::div(
          htmltools::div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "Server Action"
          ),
          shiny::uiOutput("showcase_toast_reactive_code")
        )
      ),
      preview_canvas_class = "showcase-preview-canvas--muted",
      preview_canvas_style = "min-height: 200px;"
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_toast_api_table")
)
