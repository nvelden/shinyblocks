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
            block_field_label("Preview", `for` = "showcase_nav_item_preview"),
            shiny::uiOutput("showcase_nav_item_preview_ui")
          ),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::uiOutput("showcase_nav_item_preview_code")
            )
          )
        ),
        htmltools::div(
          style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          # Controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Navigation Settings"),
            block_field(
              block_field_label("label", `for` = "showcase_nav_item_doc_label"),
              block_textarea("showcase_nav_item_doc_label", value = "Home", rows = 1)
            ),
            block_field(
              block_field_label("href", `for` = "showcase_nav_item_doc_href"),
              block_textarea("showcase_nav_item_doc_href", value = "#", rows = 1)
            ),
            block_field(
              block_field_label("icon", `for` = "showcase_nav_item_doc_icon"),
              block_select("showcase_nav_item_doc_icon", choices = c("home", "file-text", "users", "settings", "none"), selected = "home")
            ),
            block_field(
              block_field_label("selected", `for` = "showcase_nav_item_doc_selected"),
              block_checkbox("showcase_nav_item_doc_selected", label = "Set active/selected", value = TRUE)
            )
          )
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_nav_item_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    class = "sb-parity-nav-baseline",
    style = "background: var(--sidebar); color: var(--sidebar-foreground); padding: 0.75rem; border-radius: 0.5rem; max-width: 18rem;",
    block_nav(
      class = "sb-sidebar-nav",
      block_nav_item("Home", icon = "home", selected = TRUE),
      block_nav_item("Reports", icon = "file-text"),
      block_nav_item("Users", icon = "users"),
      block_nav_item("Settings", icon = "settings")
    )
  )
)
