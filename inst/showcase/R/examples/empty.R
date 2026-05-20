htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        style = "display: flex; gap: 2rem; flex-wrap: wrap; align-items: flex-start;",
        htmltools::div(
          style = "flex: 1; min-width: 300px; display: flex; flex-direction: column; gap: 1.5rem;",
          block_field(
            block_field_label("Preview", `for` = "showcase_empty_preview"),
            shiny::uiOutput("showcase_empty_preview_ui")
          ),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::uiOutput("showcase_empty_preview_code")
            )
          )
        ),
        htmltools::div(
          style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          # Content controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
            block_field(
              block_field_label("title", `for` = "showcase_empty_doc_title"),
              block_textarea("showcase_empty_doc_title", value = "No projects found", rows = 1)
            ),
            block_field(
              block_field_label("description", `for` = "showcase_empty_doc_description"),
              block_textarea("showcase_empty_doc_description", value = "Get started by creating a new repository.", rows = 2)
            )
          ),
          # Settings & Styling controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Settings"),
            block_field(
              block_field_label("icon", `for` = "showcase_empty_doc_icon"),
              block_select("showcase_empty_doc_icon", choices = c("folder", "inbox", "search", "alert-circle", "none"), selected = "folder")
            ),
            block_field(
              block_field_label("action", `for` = "showcase_empty_doc_action"),
              block_checkbox("showcase_empty_doc_action", label = "Include Action Button", value = TRUE)
            ),
            block_field(
              block_field_label("class", `for` = "showcase_empty_doc_class"),
              block_select("showcase_empty_doc_class", choices = c("none", "border-dashed", "bg-transparent"), selected = "none")
            )
          )
        )
      )
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
