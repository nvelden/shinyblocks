htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("title", `for` = "showcase_empty_doc_title"),
          block_textarea("showcase_empty_doc_title", value = "No projects found", rows = 1)
        ),
        block_field(
          block_field_label("description", `for` = "showcase_empty_doc_description"),
          block_textarea("showcase_empty_doc_description", value = "Get started by creating a new repository.", rows = 2)
        )
      ),
      showcase_controls_group(
        "Settings",
        block_field(
          block_field_label("icon", `for` = "showcase_empty_doc_icon"),
          block_select(
            "showcase_empty_doc_icon",
            choices = c("folder", "inbox", "search", "alert-circle", "none"),
            selected = "folder",
            size = "sm"
          )
        ),
        block_field(
          block_field_label("action", `for` = "showcase_empty_doc_action"),
          block_checkbox("showcase_empty_doc_action", label = "Include action button", value = TRUE)
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("class", `for` = "showcase_empty_doc_class"),
          block_select(
            "showcase_empty_doc_class",
            choices = c("none", "border-dashed", "bg-transparent"),
            selected = "none",
            size = "sm"
          )
        )
      )
    ),
    preview_output_id = "showcase_empty_preview_ui",
    code_output_id = "showcase_empty_preview_code",
    preview_canvas_style = paste(
      "position: relative; display: flex; align-items: center; justify-content: center;",
      "padding: 2rem; background: color-mix(in oklab, var(--muted) 28%, transparent);",
      "border: 0; border-radius: 0.75rem; min-height: 280px; box-sizing: border-box;"
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_empty_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 0.75rem; max-width: 400px;",
    block_empty(
      title = "No projects found",
      description = "Get started by creating a new repository.",
      icon = "folder",
      action = block_button(
        label = "Create project",
        id = "showcase_empty_project_btn_parity",
        variant = "default",
        icon = "plus"
      ),
      class = "sb-parity-empty-default"
    )
  )
)
