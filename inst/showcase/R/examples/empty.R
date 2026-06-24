htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("title", `for` = "showcase_empty_doc_title"),
          block_input("showcase_empty_doc_title", value = "No projects found")
        ),
        block_field(
          block_field_label("description", `for` = "showcase_empty_doc_description"),
          block_textarea("showcase_empty_doc_description", value = "Get started by creating a new repository.", rows = 2, resize = "none")
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
    preview_canvas_class = "showcase-preview-canvas--muted"
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_empty_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  block_stack(
      gap = "sm",
      style = "max-width: 400px;",
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
