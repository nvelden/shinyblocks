htmltools::tagList(
  showcase_playground_layout(
      controls = htmltools::tagList(
        showcase_controls_group(
          "Content", first = TRUE,
          block_field(
            block_field_label("title", `for` = "showcase_alert_doc_title"),
            block_textarea("showcase_alert_doc_title", value = "Heads up", rows = 1, resize = "none")
          ),
          block_field(
            block_field_label("description", `for` = "showcase_alert_doc_description"),
            block_textarea(
              "showcase_alert_doc_description",
              value = "shinyblocks alerts surface important inline messages.",
              rows = 3,
              resize = "none"
            )
          ),
          block_field(
            block_field_label("icon", `for` = "showcase_alert_doc_icon"),
            block_select(
              "showcase_alert_doc_icon",
              choices = c(
                "<None>" = "none",
                info = "info",
                search = "search",
                "alert-triangle" = "alert-triangle",
                check = "check"
              ),
              selected = "info",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("variant", `for` = "showcase_alert_doc_variant"),
            block_select(
              "showcase_alert_doc_variant",
              choices = c("default", "destructive", "success", "warning", "info"),
              selected = "default",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("action", `for` = "showcase_alert_doc_action"),
            block_checkbox("showcase_alert_doc_action", "Include action button")
          ),
          block_field(
            block_field_label("action label", `for` = "showcase_alert_doc_action_label"),
            block_input("showcase_alert_doc_action_label", value = "Review")
          )
        ),
        showcase_controls_group(
          "Styling",
          block_field(
            block_field_label("class", `for` = "showcase_alert_doc_class"),
            block_select(
              "showcase_alert_doc_class",
              choices = c("none", "shadow-lg", "border-dashed", "bg-transparent"),
              selected = "none",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("style", `for` = "showcase_alert_doc_style"),
            block_textarea(
              "showcase_alert_doc_style",
              value = "",
              rows = 1,
              placeholder = "e.g., border-style: dashed;",
              resize = "none"
            )
          )
        )
      ),
      preview_output_id = "showcase_alert_preview_ui",
      code_output_id = "showcase_alert_preview_code",
      preview_canvas_style = paste(
        "position: relative; padding: 1.5rem; background: var(--card);",
        "border: 1px solid var(--border); border-radius: 0.75rem;",
        "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
      )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_alert_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 0.75rem;",
    block_alert("Heads up", description = "shinyblocks alerts surface important inline messages.", class = "sb-parity-alert-default"),
    block_alert(
      "Review requested",
      description = "Action slots compose buttons or links inside the alert.",
      action = block_alert_action(block_button("Review", variant = "outline", size = "sm")),
      class = "sb-parity-alert-action"
    ),
    block_alert("Build failed", description = "Three components failed to render.", variant = "destructive", icon = "alert-triangle", class = "sb-parity-alert-destructive"),
    block_alert("Payment received", description = "The invoice is settled.", variant = "success"),
    block_alert("Needs review", description = "Confirm the account details.", variant = "warning"),
    block_alert("Sync active", description = "Changes are being propagated.", variant = "info")
  )
)
