htmltools::tagList(
  showcase_playground_layout(
      controls = htmltools::tagList(
        showcase_controls_group(
          "Content", first = TRUE,
          block_field(
            block_field_label("title", `for` = "showcase_alert_doc_title"),
            block_textarea("showcase_alert_doc_title", value = "Heads up", rows = 1)
          ),
          block_field(
            block_field_label("description", `for` = "showcase_alert_doc_description"),
            block_textarea(
              "showcase_alert_doc_description",
              value = "shinyblocks alerts surface important inline messages.",
              rows = 3
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
              choices = c("default", "destructive"),
              selected = "default",
              size = "sm"
            )
          )
        ),
        showcase_controls_group(
          "Styling",
          block_field(
            block_field_label("class", `for` = "showcase_alert_doc_class"),
            block_textarea(
              "showcase_alert_doc_class",
              value = "",
              rows = 1,
              placeholder = "e.g., shadow-sm"
            )
          ),
          block_field(
            block_field_label("style", `for` = "showcase_alert_doc_style"),
            block_textarea(
              "showcase_alert_doc_style",
              value = "",
              rows = 1,
              placeholder = "e.g., border-style: dashed;"
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
  shiny::tableOutput("showcase_alert_api_table"),
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
    block_alert("Build failed", description = "Three components failed to render.", variant = "destructive", icon = "alert-triangle", class = "sb-parity-alert-destructive")
  )
)
